import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/song.dart';
import '../models/song_category.dart';

class SongLocalStore {
  SongLocalStore(this._database);

  final AppDatabase _database;

  Future<List<Song>> getAllSongs() async {
    final rows = await (_database.select(
      _database.songs,
    )..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
    final categories = await _categoriesBySongId();

    return rows
        .map((row) => _songFromRow(row, categories[row.id] ?? const []))
        .toList();
  }

  Future<Song?> getSongById(int id) async {
    final row = await (_database.select(
      _database.songs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    final categories = await _categoriesBySongId(songId: id);
    return _songFromRow(row, categories[id] ?? const []);
  }

  Future<void> replaceAll(List<Song> songs) async {
    await _saveSongs(songs, replaceCatalog: true);
  }

  /// Inserts or updates the given songs without touching the rest of the
  /// local catalog. Useful for caching individual songs (e.g. songs viewed
  /// from a set) without requiring a full library sync.
  Future<void> upsertSongs(List<Song> songs) async {
    if (songs.isEmpty) {
      return;
    }

    await _saveSongs(songs, replaceCatalog: false);
  }

  Future<void> _saveSongs(
    List<Song> songs, {
    required bool replaceCatalog,
  }) async {
    await _database.transaction(() async {
      if (replaceCatalog) {
        await _database.delete(_database.songCategories).go();
        await _database.delete(_database.categories).go();
        await _database.delete(_database.songs).go();
      } else {
        final songIds = songs.map((song) => song.id).toList();
        await (_database.delete(
          _database.songCategories,
        )..where((table) => table.songId.isIn(songIds))).go();
      }

      if (songs.isEmpty) {
        return;
      }

      await _database.batch((batch) {
        batch.insertAll(
          _database.songs,
          songs.map(_companionFromSong).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });

      final categoriesById = <int, SongCategory>{};
      for (final song in songs) {
        for (final category in song.categories) {
          categoriesById[category.id] = category;
        }
      }

      if (categoriesById.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.categories,
            categoriesById.values.map(_companionFromCategory).toList(),
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      final links = [
        for (final song in songs)
          for (final category in song.categories)
            SongCategoriesCompanion.insert(
              songId: song.id,
              categoryId: category.id,
            ),
      ];

      if (links.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.songCategories,
            links,
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      await _deleteUnreferencedCategories();
    });
  }

  Future<void> _deleteUnreferencedCategories() async {
    final referenced = await _database.select(_database.songCategories).get();
    final ids = referenced.map((row) => row.categoryId).toSet();

    if (ids.isEmpty) {
      await _database.delete(_database.categories).go();
      return;
    }

    await (_database.delete(
      _database.categories,
    )..where((table) => table.id.isNotIn(ids))).go();
  }

  Future<Map<int, List<SongCategory>>> _categoriesBySongId({
    int? songId,
  }) async {
    final query = _database.select(_database.songCategories).join([
      innerJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.songCategories.categoryId),
      ),
    ]);

    if (songId != null) {
      query.where(_database.songCategories.songId.equals(songId));
    }

    query.orderBy([OrderingTerm.asc(_database.categories.name)]);

    final rows = await query.get();
    final categories = <int, List<SongCategory>>{};

    for (final row in rows) {
      final link = row.readTable(_database.songCategories);
      final category = row.readTable(_database.categories);
      categories
          .putIfAbsent(link.songId, () => [])
          .add(SongCategory(id: category.id, name: category.name));
    }

    return categories;
  }

  Song _songFromRow(SongEntry row, List<SongCategory> categories) {
    return Song(
      id: row.id,
      title: row.title,
      artist: row.artist,
      key: row.key,
      capo: row.capo,
      keyboardTranspose: row.keyboardTranspose,
      content: row.content,
      categories: categories,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SongsCompanion _companionFromSong(Song song) {
    return SongsCompanion(
      id: Value(song.id),
      title: Value(song.title),
      artist: Value(song.artist),
      key: Value(song.key),
      capo: Value(song.capo),
      keyboardTranspose: Value(song.keyboardTranspose),
      content: Value(song.content),
      createdAt: Value(song.createdAt),
      updatedAt: Value(song.updatedAt),
    );
  }

  CategoriesCompanion _companionFromCategory(SongCategory category) {
    return CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
    );
  }
}
