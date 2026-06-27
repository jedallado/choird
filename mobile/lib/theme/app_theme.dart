import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.chords,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.lyrics,
      onSurfaceVariant: AppColors.accent,
      outline: Color(0xFFD7CCC8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.lyrics,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.accent.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected ? AppColors.accent : AppColors.lyrics,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? AppColors.accent : AppColors.lyrics,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.accent.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accent.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: AppColors.accent),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lyrics),
        bodyMedium: TextStyle(color: AppColors.lyrics),
        titleMedium: TextStyle(color: AppColors.lyrics),
        titleSmall: TextStyle(color: AppColors.accent),
      ),
    );
  }
}
