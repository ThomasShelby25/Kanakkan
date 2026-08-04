import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display & Headers: Hanken Grotesk
  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.onSurface,
        height: 1.2,
      );

  static TextStyle headlineMedium({Color? color}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineSmall({Color? color}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleMedium({Color? color}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.onSurface,
      );

  // Body & UI Labels: Inter
  static TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelCaps({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: color ?? AppColors.secondary,
      );

  static TextStyle labelSmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.secondary,
      );

  // Monetary Data & Amounts: JetBrains Mono
  static TextStyle amountLarge({Color? color, double fontSize = 32}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle amountMedium({Color? color, double fontSize = 20}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle amountSmall({Color? color, double fontSize = 14}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );
}


