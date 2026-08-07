import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // ── DISPLAY FACE: Space Grotesk ──────────────────────────────────────────
  // Used for screen titles, section headings, and wallet names.
  static TextStyle displayLarge({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
        letterSpacing: -0.5,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
        letterSpacing: -0.3,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );

  // ── BODY FACE: Inter ─────────────────────────────────────────────────────
  // Used for descriptions, labels, metadata, and utility copy.
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.onSurface,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.onSurface,
        height: 1.5,
      );

  static TextStyle labelCaps({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? AppColors.secondary,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.secondary,
        height: 1.4,
      );

  // ── MONETARY FACE: JetBrains Mono ────────────────────────────────────────
  // Used exclusively for currency amounts — tabular figures, monospaced ledger feel.
  static TextStyle amountLarge({Color? color, double fontSize = 36}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
        letterSpacing: -1.0,
      );

  static TextStyle amountMedium({Color? color, double fontSize = 20}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle amountSmall({Color? color, double fontSize = 14}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );
}
