import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/chord_pro_parser.dart';

class ChordLyricContent extends StatelessWidget {
  const ChordLyricContent({
    super.key,
    required this.content,
    this.showChords = true,
  });

  final String content;
  final bool showChords;

  @override
  Widget build(BuildContext context) {
    final lines = ChordProParser.parse(content);

    const chordStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 16,
      height: 1.2,
      color: AppColors.chords,
      fontWeight: FontWeight.w600,
    );
    const lyricStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 16,
      height: 1.4,
      color: AppColors.lyrics,
    );
    const sectionStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.accent,
    );

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
            Text(line.lyrics, style: lyricStyle)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showChords)
                  Text(
                    ChordProParser.buildChordLine(line),
                    style: chordStyle,
                  ),
                Text(line.lyrics, style: lyricStyle),
              ],
            ),
        ],
      ],
    );
  }
}
