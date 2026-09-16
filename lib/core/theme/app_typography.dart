import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles based on Figma design specification:
/// - Display & Headlines: Manrope
/// - Body & Labels: Inter
class AppTypography {
  AppTypography._();

  // Display
  static TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    color: AppColors.onSurface,
    height: 1.2,
  );

  // Headlines
  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.35,
  );

  // Titles
  static TextStyle titleLarge = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleSmall = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
    color: AppColors.onSurfaceVariant,
  );

  // Brand title style
  static TextStyle brandTitle = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );
}
