import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const chordLyricFontFamily = 'RobotoMono';

  static const chordLyricFontSize = 16.0;

  static const chordLyricLyricStyle = TextStyle(
    fontFamily: chordLyricFontFamily,
    fontSize: chordLyricFontSize,
    height: 1.4,
    color: AppColors.lyrics,
  );

  static const chordLyricChordStyle = TextStyle(
    fontFamily: chordLyricFontFamily,
    fontSize: chordLyricFontSize,
    height: 1.2,
    color: AppColors.chords,
    fontWeight: FontWeight.w500,
  );
}
