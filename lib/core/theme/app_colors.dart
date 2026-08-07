import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette — anchored to physical finance: Crimson ledger ink + warm paper
  static const Color primary = Color(0xFFB8000B); // Ledger Crimson — reserved for ONE action only
  static const Color primaryContainer = Color(0xFFE50914);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background & Surface Tokens — warm paper, NOT cold white
  static Color background = const Color(0xFFF5F4F2); // Warm parchment
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceContainerLow = const Color(0xFFF0EEE9);
  static Color surfaceContainer = const Color(0xFFE8E5DF);
  static Color surfaceContainerHigh = const Color(0xFFDEDAD3);
  static const Color darkSurface = Color(0xFF1A1C1C);

  // Text / Content Colors
  static Color onSurface = const Color(0xFF1A1C1C); // Near-black, not pure black
  static Color onSurfaceVariant = const Color(0xFF4A3F3B);
  static Color secondary = const Color(0xFF7A7069); // Warm gray
  static Color outline = const Color(0xFFE0DBD3); // Warm border
  static Color outlineVariant = const Color(0xFFD4B8B0);

  // Functional Status Colors — NOT decorative, only for real states
  static const Color success = Color(0xFF2A6834);
  static const Color incomeGreen = Color(0xFF2E7D32);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static void applyTheme(bool isDark) {
    if (isDark) {
      background = const Color(0xFF111110); // Dark warm charcoal
      surface = const Color(0xFF1C1C1A);
      surfaceContainerLow = const Color(0xFF222220);
      surfaceContainer = const Color(0xFF2A2A28);
      surfaceContainerHigh = const Color(0xFF333330);

      onSurface = const Color(0xFFF0EDE8);
      onSurfaceVariant = const Color(0xFFBBB5AC);
      secondary = const Color(0xFF9A9389);
      outline = const Color(0xFF383632);
      outlineVariant = const Color(0xFF52504A);
    } else {
      background = const Color(0xFFF5F4F2);
      surface = const Color(0xFFFFFFFF);
      surfaceContainerLow = const Color(0xFFF0EEE9);
      surfaceContainer = const Color(0xFFE8E5DF);
      surfaceContainerHigh = const Color(0xFFDEDAD3);

      onSurface = const Color(0xFF1A1C1C);
      onSurfaceVariant = const Color(0xFF4A3F3B);
      secondary = const Color(0xFF7A7069);
      outline = const Color(0xFFE0DBD3);
      outlineVariant = const Color(0xFFD4B8B0);
    }
  }
}
