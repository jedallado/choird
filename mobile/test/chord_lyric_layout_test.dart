import 'package:choird/theme/app_typography.dart';
import 'package:choird/utils/chord_lyric_layout.dart';
import 'package:choird/utils/chord_pro_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChordLyricLayout', () {
    test('places chords at measured lyric offsets', () {
      const lyricStyle = AppTypography.chordLyricLyricStyle;
      const chordStyle = AppTypography.chordLyricChordStyle;
      const textScaler = TextScaler.linear(1);

      final lines = ChordProParser.parse(
        '[G]Amazing grace how [C]sweet the sound',
      );

      final placements = ChordLyricLayout.computePlacements(
        lyrics: lines.first.lyrics,
        chords: lines.first.chords,
        lyricStyle: lyricStyle,
        chordStyle: chordStyle,
        textScaler: textScaler,
      );

      expect(placements, hasLength(2));
      expect(placements[0].left, 0);
      expect(placements[0].chord, 'G');
      expect(
        placements[1].left,
        ChordLyricLayout.measureTextWidth(
          'Amazing grace how ',
          lyricStyle,
          textScaler: textScaler,
        ),
      );
      expect(placements[1].chord, 'C');
    });

    test('shifts colliding chords to the right', () {
      const lyricStyle = AppTypography.chordLyricLyricStyle;
      const chordStyle = AppTypography.chordLyricChordStyle;
      const textScaler = TextScaler.linear(1);

      final lines = ChordProParser.parse('[G][Am][D]');

      final placements = ChordLyricLayout.computePlacements(
        lyrics: lines.first.lyrics,
        chords: lines.first.chords,
        lyricStyle: lyricStyle,
        chordStyle: chordStyle,
        textScaler: textScaler,
      );

      expect(placements[0].left, 0);
      expect(placements[1].left, greaterThan(placements[0].left));
      expect(placements[2].left, greaterThan(placements[1].left));
    });
  });
}
