import 'package:choird/models/song.dart';
import 'package:choird/screens/songs/song_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('video links menu lists every voice', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SongDetailScreen(
          song: Song(
            id: 1,
            title: 'Amazing Grace',
            content: '[G]Amazing grace',
            sopranoUrl: 'https://www.youtube.com/watch?v=soprano',
            tenorUrl: 'https://youtu.be/tenor',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Video Links'));
    await tester.pumpAndSettle();

    expect(find.text('Soprano'), findsOneWidget);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('Tenor'), findsOneWidget);
    expect(find.text('Bass'), findsOneWidget);
    expect(
      find.text('https://www.youtube.com/watch?v=soprano'),
      findsOneWidget,
    );
    expect(find.text('https://youtu.be/tenor'), findsOneWidget);
    expect(find.text('No link'), findsNWidgets(2));
  });
}
