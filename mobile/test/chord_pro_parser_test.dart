import 'package:choird/utils/chord_pro_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChordProParser', () {
    test('parses chords and lyrics on a single line', () {
      final lines = ChordProParser.parse(
        '[G]Amazing grace how [C]sweet the sound',
      );

      expect(lines, hasLength(1));
      expect(lines.first.lyrics, 'Amazing grace how sweet the sound');
      expect(lines.first.chords, hasLength(2));
      expect(lines.first.chords[0].position, 0);
      expect(lines.first.chords[0].chord, 'G');
      expect(lines.first.chords[1].position, 18);
      expect(lines.first.chords[1].chord, 'C');

      final chordLine = ChordProParser.buildChordLine(lines.first);
      expect(chordLine[0], 'G');
      expect(chordLine[18], 'C');
    });

    test('parses plain lyric lines without chords', () {
      final lines = ChordProParser.parse('That saved a wretch like me');

      expect(lines.first.lyrics, 'That saved a wretch like me');
      expect(lines.first.chords, isEmpty);
      expect(lines.first.hasChords, isFalse);
    });

    test('treats bracket-only lines as section headers', () {
      final lines = ChordProParser.parse('[Verse 1]');

      expect(lines.first.isSectionHeader, isTrue);
      expect(lines.first.displaySectionLabel, 'Verse 1');
    });

    test('preserves blank lines', () {
      final lines = ChordProParser.parse('[G]Line one\n\n[G]Line two');

      expect(lines, hasLength(3));
      expect(lines[1].isEmpty, isTrue);
    });

    test('strips metadata directives like title and artist', () {
      final lines = ChordProParser.parse(
        '{title: Amazing Grace}\n{artist: John Newton}\n[G]Amazing grace',
      );

      expect(lines, hasLength(1));
      expect(lines.first.lyrics, 'Amazing grace');
    });

    test('renders verse directives as section headers', () {
      final lines = ChordProParser.parse(
        '{start_of_verse: Verse 1}\n[G]Line one\n{end_of_verse}',
      );

      expect(lines, hasLength(2));
      expect(lines.first.isSectionHeader, isTrue);
      expect(lines.first.displaySectionLabel, 'Verse 1');
      expect(lines[1].lyrics, 'Line one');
    });

    test('supports ChordPro shorthand section directives', () {
      final lines = ChordProParser.parse('{sov: Verse 2}\n{soc}\n{comment: Bridge}');

      expect(lines, hasLength(3));
      expect(lines[0].displaySectionLabel, 'Verse 2');
      expect(lines[1].displaySectionLabel, 'Chorus');
      expect(lines[2].displaySectionLabel, 'Bridge');
    });
  });
}
