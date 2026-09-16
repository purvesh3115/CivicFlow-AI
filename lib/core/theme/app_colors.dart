import 'package:flutter/material.dart';

/// Centralized color palette matching CitizenConnect Design System
class AppColors {
  AppColors._();

  // Primary Civic Blue
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  // Secondary
  static const Color secondary = Color(0xFF4059AA);
  static const Color secondaryContainer = Color(0xFF8FA7FE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D3989);
  static const Color secondaryFixed = Color(0xFFDCE1FF);
  static const Color secondaryFixedDim = Color(0xFFB6C4FF);

  // Tertiary
  static const Color tertiary = Color(0xFF6A1EDB);
  static const Color tertiaryContainer = Color(0xFF8343F4);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFF7EDFF);
  static const Color tertiaryFixed = Color(0xFFEADDFF);
  static const Color tertiaryFixedDim = Color(0xFFD2BBFF);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceVariant = Color(0xFFD3E4FE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Text & Content
  static const Color onBackground = Color(0xFF0B1C30);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF434655);

  // Borders & Dividers
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // Functional / Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color success = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF14532D);

  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF78350F);

  // Status Colors for Grievances
  static const Color statusSubmitted = Color(0xFF2563EB); // Blue
  static const Color statusUnderReview = Color(0xFFD97706); // Amber
  static const Color statusAssigned = Color(0xFF7C3AED); // Purple
  static const Color statusInProgress = Color(0xFF0284C7); // Cyan
  static const Color statusResolved = Color(0xFF16A34A); // Green
  static const Color statusClosed = Color(0xFF475569); // Slate

  // CitizenConnect AI Specific Tokens
  static const Color aiAccent = Color(0xFF0F766E); // Teal-700
  static const Color aiSecondary = Color(0xFF006A63);
  static const Color aiSurface = Color(0xFFF0FDFA); // Light teal tint
  static const Color aiBorder = Color(0xFFCCFBF1); // Teal border
  static const Color aiDarkText = Color(0xFF134E4A); // Teal-900
  static const Color aiContainer = Color(0xFF99EFE5);
  static const Color aiOnContainer = Color(0xFF006F67);

  // Shadows
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withAlpha(12),
    blurRadius: 15,
    offset: const Offset(0, 4),
  );

  static BoxShadow buttonShadow = BoxShadow(
    color: primary.withAlpha(60),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
}
