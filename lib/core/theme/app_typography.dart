import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clean editorial geometric typography aligned with Glanceable (Brand Guidelines v1.2026):
/// - Crisp upright geometric sans-serif headings (Plus Jakarta Sans / Inter fallback)
/// - Tight -0.03em tracking on display/headline typography
/// - High-legibility regular & medium weights on cool/neutral & deep Encre surfaces
class AppTypography {
  AppTypography._();

  static const List<String> sansFallbacks = [
    'PP Mori',
    'Plus Jakarta Sans',
    'Inter',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextTheme textTheme({bool isDark = false}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    TextStyle headingStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.w600,
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      try {
        return GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: FontStyle.normal,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      } catch (_) {
        return TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontFamilyFallback: sansFallbacks,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: FontStyle.normal,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      }
    }

    TextStyle bodySansStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.w400,
      FontStyle fontStyle = FontStyle.normal,
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      try {
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      } catch (_) {
        return TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: sansFallbacks,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      }
    }

    return TextTheme(
      // Display - Clean architectural headings (-0.03em tracking per Glanceable spec)
      displayLarge: headingStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.12,
      ),
      displayMedium: headingStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.84,
        height: 1.16,
      ),
      displaySmall: headingStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.72,
        height: 1.2,
      ),

      // Headline - Balanced geometric sans
      headlineLarge: headingStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.66,
        height: 1.22,
      ),
      headlineMedium: headingStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.55,
        height: 1.28,
      ),
      headlineSmall: headingStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.45,
        height: 1.32,
      ),

      // Title
      titleLarge: bodySansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
        height: 1.35,
      ),
      titleMedium: bodySansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.38,
      ),
      titleSmall: bodySansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.38,
      ),

      // Body
      bodyLarge: bodySansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.48,
        color: secondaryColor,
      ),
      bodyMedium: bodySansStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.15,
        height: 1.45,
        color: secondaryColor,
      ),
      bodySmall: bodySansStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
        color: secondaryColor,
      ),

      // Label
      labelLarge: bodySansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      labelMedium: bodySansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      labelSmall: bodySansStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  static TextStyle get displayLarge => textTheme().displayLarge!;
  static TextStyle get displayMedium => textTheme().displayMedium!;
  static TextStyle get displaySmall => textTheme().displaySmall!;
  static TextStyle get headlineLarge => textTheme().headlineLarge!;
  static TextStyle get headlineMedium => textTheme().headlineMedium!;
  static TextStyle get headlineSmall => textTheme().headlineSmall!;
  static TextStyle get titleLarge => textTheme().titleLarge!;
  static TextStyle get titleMedium => textTheme().titleMedium!;
  static TextStyle get titleSmall => textTheme().titleSmall!;
  static TextStyle get bodyLarge => textTheme().bodyLarge!;
  static TextStyle get bodyMedium => textTheme().bodyMedium!;
  static TextStyle get bodySmall => textTheme().bodySmall!;
  static TextStyle get labelLarge => textTheme().labelLarge!;
  static TextStyle get labelMedium => textTheme().labelMedium!;
  static TextStyle get labelSmall => textTheme().labelSmall!;

  /// Crisp wordmark styling aligned with Glanceable header typography
  static TextStyle brandWordmark({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: sansFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal,
      color: color ?? AppColors.primary,
      letterSpacing: -0.8,
    );
  }
}
