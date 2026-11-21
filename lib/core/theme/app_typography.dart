import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Artistic and editorial typography pairing:
/// - Editorial Headlines (Helvetica Now Display / Playfair Display)
/// - Modern Clean Body Typography (Helvetica Now Display / Inter)
/// - Italic styling for brand accent and editorial warmth
class AppTypography {
  static const List<String> sansFallbacks = [
    'Helvetica Now Display',
    'Helvetica Neue',
    'Helvetica',
    'Inter',
    'Arial',
    'sans-serif',
  ];

  static const List<String> serifFallbacks = [
    'Playfair Display',
    'DM Serif Display',
    'Georgia',
    'Baskerville',
    'serif',
  ];

  static TextTheme textTheme({bool isDark = false}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.charcoal;
    final Color secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    // Editorial headline typography (Helvetica Now Display / Serif fallback)
    TextStyle headlineStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.w700,
      FontStyle fontStyle = FontStyle.italic,
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: 'Helvetica Now Display',
        fontFamilyFallback: sansFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        color: color ?? primaryColor,
        letterSpacing: letterSpacing,
      );
    }

    // Modern clean typography for body, buttons and labels
    TextStyle bodySansStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.normal,
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
      // Display - Bold Editorial Italic Headlines
      displayLarge: headlineStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      displayMedium: headlineStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: headlineStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.3,
        height: 1.25,
      ),

      // Headline - Distinctive & Expressive
      headlineLarge: headlineStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      headlineMedium: headlineStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      headlineSmall: headlineStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        height: 1.35,
      ),

      // Title - Clean, legible neo-grotesque
      titleLarge: bodySansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      titleMedium: bodySansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: bodySansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Body - Ultra legible clean sans
      bodyLarge: bodySansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodyMedium: bodySansStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodySmall: bodySansStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryColor,
      ),

      // Label - Dynamic button & badge typography
      labelLarge: bodySansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: bodySansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: bodySansStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  // Direct Static Getters
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

  /// Signature brand wordmark typography
  static TextStyle brandWordmark({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w900,
    FontStyle fontStyle = FontStyle.italic,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Helvetica Now Display',
      fontFamilyFallback: sansFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color ?? AppColors.primary,
      letterSpacing: -0.5,
    );
  }
}
