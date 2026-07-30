import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/set_list.dart';

class SetLocalStore {
  SetLocalStore(this._database);

  final AppDatabase _database;

  Future<List<SetList>> getAllSets() async {
    final setRows =
        await (_database.select(_database.sets)..orderBy([
              (t) => OrderingTerm.desc(t.scheduledFor),
            ]))
            .get();

    final setSongRows =
        await (_database.select(_database.setSongs)..orderBy([
              (t) => OrderingTerm.asc(t.position),
            ]))
            .get();

    final setSongsBySetId = <int, List<SetSongEntry>>{};
    for (final row in setSongRows) {
      setSongsBySetId.putIfAbsent(row.setId, () => []).add(row);
    }

    return setRows
        .map((row) => _setFromRow(row, setSongsBySetId[row.id] ?? const []))
        .toList();
  }

  Future<void> replaceAll(List<SetList> sets) async {
    await _database.transaction(() async {
      await _database.delete(_database.setSongs).go();
      await _database.delete(_database.sets).go();

      if (sets.isEmpty) {
        return;
      }

      await _database.batch((batch) {
        batch.insertAll(_database.sets, sets.map(_setCompanionFromSetList));
      });

      final setSongCompanions = <SetSongsCompanion>[
        for (final set in sets)
          for (final setSong in set.setSongs)
            _setSongCompanionFromItem(set.id, setSong),
      ];

      if (setSongCompanions.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(_database.setSongs, setSongCompanions);
        });
      }
    });
  }

  SetList _setFromRow(SetEntry row, List<SetSongEntry> setSongRows) {
    return SetList(
      id: row.id,
      name: row.name,
      scheduledFor: row.scheduledFor,
      createdByUserId: row.createdByUserId,
      notes: row.notes,
      setSongs: setSongRows.map(_setSongFromRow).toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SetSongItem _setSongFromRow(SetSongEntry row) {
    return SetSongItem(
      id: row.id,
      songId: row.songId,
      position: row.position,
      song: SetSongSummary(
        id: row.songId,
        title: row.title,
        artist: row.artist,
        key: row.key,
        capo: row.capo,
        keyboardTranspose: row.keyboardTranspose,
      ),
    );
  }

  SetsCompanion _setCompanionFromSetList(SetList set) {
    return SetsCompanion(
      id: Value(set.id),
      name: Value(set.name),
      scheduledFor: Value(set.scheduledFor),
      createdByUserId: Value(set.createdByUserId),
      notes: Value(set.notes),
      createdAt: Value(set.createdAt),
      updatedAt: Value(set.updatedAt),
    );
  }

  SetSongsCompanion _setSongCompanionFromItem(int setId, SetSongItem item) {
    final song = item.song;

    return SetSongsCompanion(
      id: Value(item.id),
      setId: Value(setId),
      songId: Value(item.songId),
      position: Value(item.position),
      title: Value(song?.title ?? 'Unknown song'),
      artist: Value(song?.artist),
      key: Value(song?.key),
      capo: Value(song?.capo),
      keyboardTranspose: Value(song?.keyboardTranspose),
    );
  }
}
