import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFFB8000B); // Crimson Red from Stitch design
  static const Color primaryContainer = Color(0xFFE50914);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background & Surface Tokens
  static Color background = const Color(0xFFF9F9F9);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceContainerLow = const Color(0xFFF4F3F3);
  static Color surfaceContainer = const Color(0xFFEEEEEE);
  static Color surfaceContainerHigh = const Color(0xFFE8E8E8);
  static const Color darkSurface = Color(0xFF1A1C1C); // Constant for pill nav

  // Text / Content Colors
  static Color onSurface = const Color(0xFF1A1C1C);
  static Color onSurfaceVariant = const Color(0xFF5E3F3B);
  static Color secondary = const Color(0xFF625D5D);
  static Color outline = const Color(0xFFE8E2E0);
  static Color outlineVariant = const Color(0xFFE9BCB6);

  // Functional Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static void applyTheme(bool isDark) {
    if (isDark) {
      background = const Color(0xFF121212);
      surface = const Color(0xFF1E1E1E);
      surfaceContainerLow = const Color(0xFF232525);
      surfaceContainer = const Color(0xFF2C2F2F);
      surfaceContainerHigh = const Color(0xFF333535);

      onSurface = const Color(0xFFFFFFFF);
      onSurfaceVariant = const Color(0xFFCCCCCC);
      secondary = const Color(0xFFAAAAAA);
      outline = const Color(0xFF444444);
      outlineVariant = const Color(0xFF666666);
    } else {
      background = const Color(0xFFF9F9F9);
      surface = const Color(0xFFFFFFFF);
      surfaceContainerLow = const Color(0xFFF4F3F3);
      surfaceContainer = const Color(0xFFEEEEEE);
      surfaceContainerHigh = const Color(0xFFE8E8E8);

      onSurface = const Color(0xFF1A1C1C);
      onSurfaceVariant = const Color(0xFF5E3F3B);
      secondary = const Color(0xFF625D5D);
      outline = const Color(0xFFE8E2E0);
      outlineVariant = const Color(0xFFE9BCB6);
    }
  }
}
