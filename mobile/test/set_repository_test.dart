import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/services/set_api.dart';
import 'package:choird/services/set_local_store.dart';
import 'package:choird/services/set_repository.dart';
import 'package:choird/services/set_sync_preferences.dart';
import 'package:choird/services/song_api.dart';
import 'package:choird/services/song_local_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SetRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase.memory();
    repository = SetRepository(
      api: SetApi(
        client: MockClient((request) async {
          return http.Response(
            '''
{
  "data": [
    {
      "id": 1,
      "name": "Sunday Worship",
      "scheduledFor": "2026-02-01T09:00:00.000000Z",
      "createdByUserId": 1,
      "notes": null,
      "setSongs": [
        {
          "id": 10,
          "songId": 5,
          "position": 1,
          "song": {
            "id": 5,
            "title": "Amazing Grace",
            "artist": "Traditional",
            "key": "G",
            "capo": 0,
            "keyboardTranspose": 0
          }
        }
      ],
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
      localStore: SetLocalStore(database),
      syncPreferences: SetSyncPreferences(),
      songApi: SongApi(
        client: MockClient((request) async {
          return http.Response(
            '''
{
  "data": {
    "id": 5,
    "title": "Amazing Grace",
    "artist": "Traditional",
    "key": "G",
    "capo": 0,
    "keyboardTranspose": 0,
    "content": "[G]Amazing grace",
    "createdAt": "2026-01-01T00:00:00.000000Z",
    "updatedAt": "2026-01-02T00:00:00.000000Z"
  }
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
      songLocalStore: SongLocalStore(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('loads empty local sets before first sync', () async {
    final sets = await repository.getLocalSets();
    expect(sets, isEmpty);
    expect(await repository.getLastSyncedAt(), isNull);
  });

  test('sync stores sets, caches song content, and records sync time', () async {
    final synced = await repository.syncSets();

    expect(synced, hasLength(1));
    expect(synced.first.displayName, 'Sunday Worship');
    expect(synced.first.setSongs, hasLength(1));

    final local = await repository.getLocalSets();
    expect(local, hasLength(1));
    expect(local.first.setSongs.first.songId, 5);
    expect(local.first.setSongs.first.song?.title, 'Amazing Grace');

    final cachedSong = await SongLocalStore(database).getSongById(5);
    expect(cachedSong, isNotNull);
    expect(cachedSong!.content, '[G]Amazing grace');

    expect(await repository.getLastSyncedAt(), isNotNull);
  });

  test('sync replaces sets that are no longer on the server', () async {
    await SetLocalStore(database).replaceAll([]);
    await repository.syncSets();

    final local = await repository.getLocalSets();
    expect(local.map((set) => set.id), [1]);
  });
}
