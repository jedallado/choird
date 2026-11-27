import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choird/database/app_database.dart';
import 'package:choird/models/song.dart';
import 'package:choird/models/song_category.dart';
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
      "categories": [
        {"id": 4, "name": "Worship"},
        {"id": 3, "name": "Hymns"}
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
    expect(local.first.categories.map((category) => category.name), [
      'Hymns',
      'Worship',
    ]);
    expect(await repository.getLastSyncedAt(), isNotNull);
  });

  test('sync removes songs that are no longer on the server', () async {
    await SongLocalStore(database).replaceAll([
      Song(
        id: 99,
        title: 'Old Song',
        content: 'gone',
        categories: const [SongCategory(id: 7, name: 'Retired')],
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    ]);

    final synced = await repository.syncSongs();
    final local = await repository.getLocalSongs();

    expect(synced.map((song) => song.id), [1]);
    expect(local.map((song) => song.id), [1]);
    expect(local.single.categories.map((category) => category.name), [
      'Hymns',
      'Worship',
    ]);
  });

  test(
    'upsert updates one song without clearing another song categories',
    () async {
      final store = SongLocalStore(database);
      final createdAt = DateTime.utc(2026, 1, 1);

      await store.replaceAll([
        Song(
          id: 1,
          title: 'Amazing Grace',
          content: '[G]Amazing grace',
          categories: const [SongCategory(id: 3, name: 'Hymns')],
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        Song(
          id: 2,
          title: 'How Great Thou Art',
          content: '[C]Then sings my soul',
          categories: const [SongCategory(id: 4, name: 'Worship')],
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ]);

      await store.upsertSongs([
        Song(
          id: 1,
          title: 'Amazing Grace',
          content: '[G]Amazing grace',
          categories: const [SongCategory(id: 5, name: 'Communion')],
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ]);

      final first = await store.getSongById(1);
      final second = await store.getSongById(2);

      expect(first!.categories.map((category) => category.name), ['Communion']);
      expect(second!.categories.map((category) => category.name), ['Worship']);
    },
  );
}
