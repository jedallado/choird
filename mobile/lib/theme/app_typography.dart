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

  static const _sectionHeaderScale = 0.875;

  static TextStyle chordLyricLyricStyleAt(double fontSize) {
    return chordLyricLyricStyle.copyWith(fontSize: fontSize);
  }

  static TextStyle chordLyricChordStyleAt(double fontSize) {
    return chordLyricChordStyle.copyWith(fontSize: fontSize);
  }

  static TextStyle chordLyricSectionStyleAt(double fontSize) {
    return TextStyle(
      fontSize: fontSize * _sectionHeaderScale,
      fontWeight: FontWeight.bold,
      color: AppColors.accent,
    );
  }
}
