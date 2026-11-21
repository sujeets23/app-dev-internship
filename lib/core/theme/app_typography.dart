import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Artistic and editorial typography pairing:
/// - Editorial Serif Headlines (Playfair Display / DM Serif Display)
/// - Modern Clean Body Typography (Inter / Helvetica Now)
class AppTypography {
  static const List<String> serifFallbacks = [
    'Playfair Display',
    'DM Serif Display',
    'Georgia',
    'Baskerville',
    'serif',
  ];

  static const List<String> sansFallbacks = [
    'Inter',
    'Helvetica Now Display',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  static TextTheme textTheme({bool isDark = false}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.charcoal;
    final Color secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    // Serif style for editorial headings
    TextStyle serifStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.w700,
      FontStyle fontStyle = FontStyle.normal,
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      try {
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      } catch (_) {
        return TextStyle(
          fontFamily: 'Playfair Display',
          fontFamilyFallback: serifFallbacks,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      }
    }

    // Modern clean sans-serif for body, buttons and labels
    TextStyle sansStyle({
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
      // Display - Editorial Serif Headlines
      displayLarge: serifStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      displayMedium: serifStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: serifStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.3,
        height: 1.25,
      ),

      // Headline - Elegant Serif
      headlineLarge: serifStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      headlineMedium: serifStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      headlineSmall: serifStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        height: 1.35,
      ),

      // Title - Clean, legible neo-grotesque
      titleLarge: sansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      titleMedium: sansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: sansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Body - Ultra legible clean sans
      bodyLarge: sansStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodyMedium: sansStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodySmall: sansStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryColor,
      ),

      // Label - Dynamic button & badge typography
      labelLarge: sansStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: sansStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: sansStyle(
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
}
