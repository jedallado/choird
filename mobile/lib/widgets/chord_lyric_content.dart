import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../utils/chord_pro_parser.dart';
import 'chord_lyric_line_row.dart';

class ChordLyricContent extends StatelessWidget {
  const ChordLyricContent({
    super.key,
    required this.content,
    this.showChords = true,
    this.fontSize = AppTypography.chordLyricFontSize,
  });

  final String content;
  final bool showChords;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final lines = ChordProParser.parse(content);
    final textScaler = MediaQuery.textScalerOf(context);
    final lyricStyle = AppTypography.chordLyricLyricStyleAt(fontSize);
    final sectionStyle = AppTypography.chordLyricSectionStyleAt(fontSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          if (line.isEmpty)
            const SizedBox(height: 16)
          else if (line.isSectionHeader)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(line.displaySectionLabel, style: sectionStyle),
            )
          else if (!line.hasChords)
            Text(
              line.lyrics,
              style: lyricStyle,
              textScaler: textScaler,
            )
          else
            ChordLyricLineRow(
              line: line,
              showChords: showChords,
              fontSize: fontSize,
            ),
        ],
      ],
    );
  }
}
