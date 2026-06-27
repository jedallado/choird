import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../utils/chord_lyric_layout.dart';
import '../utils/chord_pro_parser.dart';

class ChordLyricLineRow extends StatelessWidget {
  const ChordLyricLineRow({
    super.key,
    required this.line,
    required this.showChords,
  });

  final ChordLyricLine line;
  final bool showChords;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    const lyricStyle = AppTypography.chordLyricLyricStyle;
    const chordStyle = AppTypography.chordLyricChordStyle;

    final placements = ChordLyricLayout.computePlacements(
      lyrics: line.lyrics,
      chords: line.chords,
      lyricStyle: lyricStyle,
      chordStyle: chordStyle,
      textScaler: textScaler,
    );
    final chordRowHeight = ChordLyricLayout.measureLineHeight(
      chordStyle,
      textScaler: textScaler,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showChords && placements.isNotEmpty)
          SizedBox(
            height: chordRowHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final placement in placements)
                  Positioned(
                    left: placement.left,
                    top: 0,
                    child: Text(
                      placement.chord,
                      style: chordStyle,
                      textScaler: textScaler,
                    ),
                  ),
              ],
            ),
          ),
        if (line.lyrics.trim().isNotEmpty)
          Text(
            line.lyrics,
            style: lyricStyle,
            textScaler: textScaler,
          ),
      ],
    );
  }
}
