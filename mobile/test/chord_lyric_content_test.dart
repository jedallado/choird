import 'package:choird/widgets/chord_lyric_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hides chord line when showChords is false', (tester) async {
    const content = '[G]Amazing grace how [C]sweet the sound';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChordLyricContent(
            content: content,
            showChords: false,
          ),
        ),
      ),
    );

    expect(find.text('Amazing grace how sweet the sound'), findsOneWidget);
    expect(find.text('G'), findsNothing);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('shows chord line when showChords is true', (tester) async {
    const content = '[G]Amazing grace how [C]sweet the sound';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChordLyricContent(
            content: content,
            showChords: true,
          ),
        ),
      ),
    );

    expect(find.text('Amazing grace how sweet the sound'), findsOneWidget);
    expect(find.textContaining('G'), findsOneWidget);
    expect(find.textContaining('C'), findsOneWidget);
  });

  testWidgets('renders chord-only lines without a lyric row', (tester) async {
    const content = '[G][Am][D]';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChordLyricContent(
            content: content,
            showChords: true,
          ),
        ),
      ),
    );

    expect(find.textContaining('G'), findsOneWidget);
    expect(find.textContaining('Am'), findsOneWidget);
    expect(find.textContaining('D'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });
}
