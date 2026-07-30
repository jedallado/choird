import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/song.dart';

class SongLocalStore {
  SongLocalStore(this._database);

  final AppDatabase _database;

  Future<List<Song>> getAllSongs() async {
    final rows = await (_database.select(
      _database.songs,
    )..orderBy([(t) => OrderingTerm.asc(t.title)])).get();

    return rows.map(_songFromRow).toList();
  }

  Future<void> replaceAll(List<Song> songs) async {
    await _database.transaction(() async {
      await _database.delete(_database.songs).go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.songs,
          songs.map(_companionFromSong).toList(),
        );
      });
    });
  }

  Song _songFromRow(SongEntry row) {
    return Song(
      id: row.id,
      title: row.title,
      artist: row.artist,
      key: row.key,
      capo: row.capo,
      keyboardTranspose: row.keyboardTranspose,
      content: row.content,
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
}
