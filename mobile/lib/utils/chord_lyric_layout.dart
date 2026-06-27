import 'package:flutter/material.dart';

import 'chord_pro_parser.dart';

class ChordLyricPlacement {
  const ChordLyricPlacement({
    required this.left,
    required this.chord,
  });

  final double left;
  final String chord;
}

class ChordLyricLayout {
  static const double chordGap = 4;

  static double measureTextWidth(
    String text,
    TextStyle style, {
    required TextScaler textScaler,
  }) {
    if (text.isEmpty) {
      return 0;
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    return painter.width;
  }

  static double measureLineHeight(
    TextStyle style, {
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: 'Mg', style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    return painter.height;
  }

  static List<ChordLyricPlacement> computePlacements({
    required String lyrics,
    required List<ChordPlacement> chords,
    required TextStyle lyricStyle,
    required TextStyle chordStyle,
    required TextScaler textScaler,
  }) {
    final placements = <ChordLyricPlacement>[];
    var nextAvailable = 0.0;

    for (final chord in chords) {
      final prefixEnd = chord.position.clamp(0, lyrics.length);
      final prefix = lyrics.substring(0, prefixEnd);
      final lyricLeft = measureTextWidth(
        prefix,
        lyricStyle,
        textScaler: textScaler,
      );
      final left = lyricLeft > nextAvailable ? lyricLeft : nextAvailable;

      placements.add(ChordLyricPlacement(left: left, chord: chord.chord));
      nextAvailable = left +
          measureTextWidth(
            chord.chord,
            chordStyle,
            textScaler: textScaler,
          ) +
          chordGap;
    }

    return placements;
  }
}
