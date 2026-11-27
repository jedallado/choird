import 'package:choird/database/app_database.dart';
import 'package:choird/models/set_list.dart';
import 'package:choird/models/song.dart';
import 'package:choird/models/song_category.dart';
import 'package:choird/screens/scheduled/set_detail_screen.dart';
import 'package:choird/screens/songs/song_detail_screen.dart';
import 'package:choird/screens/songs/song_list_screen.dart';
import 'package:choird/theme/app_colors.dart';
import 'package:choird/theme/app_theme.dart';
import 'package:choird/services/song_api.dart';
import 'package:choird/services/song_local_store.dart';
import 'package:choird/services/song_repository.dart';
import 'package:choird/services/song_sync_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const categories = [
    SongCategory(id: 3, name: 'Hymns'),
    SongCategory(id: 4, name: 'Worship'),
  ];

  Song song() {
    return Song(
      id: 1,
      title: 'Amazing Grace',
      artist: 'Traditional',
      key: 'G',
      content: '[G]Amazing grace',
      categories: categories,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('song detail shows categories', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SongDetailScreen(song: song())));
    await tester.pumpAndSettle();

    expect(find.text('Hymns'), findsOneWidget);
    expect(find.text('Worship'), findsOneWidget);
    expect(find.text('Key: G'), findsOneWidget);
  });

  testWidgets('capo and transpose chips use a stronger color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SongDetailScreen(
          song: Song(
            id: 1,
            title: 'Amazing Grace',
            key: 'G',
            capo: 2,
            keyboardTranspose: 1,
            content: '[G]Amazing grace',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Chip chip(String label) {
      return tester.widget<Chip>(find.widgetWithText(Chip, label));
    }

    expect(chip('Capo 2').backgroundColor, AppColors.highlight);
    expect(chip('Keyboard +1').backgroundColor, AppColors.highlight);
    expect(chip('Key: G').backgroundColor, isNull);
  });

  testWidgets('song detail omits categories when a song has none', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SongDetailScreen(
          song: Song(
            id: 1,
            title: 'Amazing Grace',
            content: '[G]Amazing grace',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNothing);
    expect(find.text('Amazing Grace'), findsOneWidget);
  });

  testWidgets('song list does not show categories', (tester) async {
    final database = AppDatabase.memory();
    addTearDown(database.close);

    await SongLocalStore(database).replaceAll([song()]);

    await tester.pumpWidget(
      MaterialApp(
        home: SongListScreen(
          repository: SongRepository(
            api: SongApi(
              client: MockClient((request) async => http.Response('', 500)),
            ),
            localStore: SongLocalStore(database),
            syncPreferences: SongSyncPreferences(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Traditional'), findsOneWidget);
    expect(find.text('All Categories'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Hymns')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Worship'),
      ),
      findsNothing,
    );
  });

  testWidgets('set song list does not show categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SetDetailScreen(
          setList: SetList(
            id: 1,
            name: 'Sunday Worship',
            scheduledFor: DateTime.utc(2026, 2, 1, 9),
            createdByUserId: 1,
            setSongs: const [
              SetSongItem(
                id: 10,
                songId: 1,
                position: 1,
                song: SetSongSummary(
                  id: 1,
                  title: 'Amazing Grace',
                  artist: 'Traditional',
                  key: 'G',
                ),
              ),
            ],
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Hymns'), findsNothing);
    expect(find.text('Worship'), findsNothing);
  });

  testWidgets('song list filters locally by one category', (tester) async {
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final createdAt = DateTime.utc(2026, 1, 1);

    await SongLocalStore(database).replaceAll([
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
        categories: const [
          SongCategory(id: 3, name: 'Hymns'),
          SongCategory(id: 4, name: 'Worship'),
        ],
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SongListScreen(
          repository: SongRepository(
            api: SongApi(
              client: MockClient((request) async => http.Response('', 500)),
            ),
            localStore: SongLocalStore(database),
            syncPreferences: SongSyncPreferences(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('How Great Thou Art'), findsOneWidget);

    await tester.tap(find.byKey(const Key('song-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Worship').last);
    await tester.pumpAndSettle();

    expect(find.text('Amazing Grace'), findsNothing);
    expect(find.text('How Great Thou Art'), findsOneWidget);

    await tester.tap(find.byKey(const Key('song-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hymns').last);
    await tester.pumpAndSettle();

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('How Great Thou Art'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Amazing');
    await tester.pumpAndSettle();

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('How Great Thou Art'), findsNothing);
  });
}
