import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/models/song.dart';
import 'package:choird/services/song_api.dart';
import 'package:choird/services/song_local_store.dart';
import 'package:choird/services/song_repository.dart';
import 'package:choird/services/song_sync_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SongRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.memory();
    repository = SongRepository(
      api: SongApi(
        client: MockClient((request) async {
          return http.Response(
            '''
{
  "data": [
    {
      "id": 1,
      "title": "Amazing Grace",
      "artist": "Traditional",
      "key": "G",
      "capo": 2,
      "keyboardTranspose": 0,
      "content": "[G]Amazing grace",
      "createdAt": "2026-01-01T00:00:00.000000Z",
      "updatedAt": "2026-01-02T00:00:00.000000Z"
    }
  ]
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
      localStore: SongLocalStore(database),
      syncPreferences: SongSyncPreferences(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('loads empty local catalog before first sync', () async {
    final songs = await repository.getLocalSongs();
    expect(songs, isEmpty);
    expect(await repository.getLastSyncedAt(), isNull);
  });

  test('sync replaces local songs and records last synced time', () async {
    final synced = await repository.syncSongs();

    expect(synced, hasLength(1));
    expect(synced.first.title, 'Amazing Grace');

    final local = await repository.getLocalSongs();
    expect(local, hasLength(1));
    expect(local.first.id, 1);
    expect(local.first.content, '[G]Amazing grace');
    expect(await repository.getLastSyncedAt(), isNotNull);
  });

  test('sync removes songs that are no longer on the server', () async {
    await SongLocalStore(database).replaceAll([
      Song(
        id: 99,
        title: 'Old Song',
        content: 'gone',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    ]);

    final synced = await repository.syncSongs();
    final local = await repository.getLocalSongs();

    expect(synced.map((song) => song.id), [1]);
    expect(local.map((song) => song.id), [1]);
  });
}
