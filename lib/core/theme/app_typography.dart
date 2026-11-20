import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Modern neo-grotesque typography (Helvetica Now Display inspired) with stylish italic accents
class AppTypography {
  static const List<String> fallbackFonts = [
    'Helvetica Now Display',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  static TextTheme textTheme({bool isDark = false}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    // Base text style using Inter (neo-grotesque, metrically close to Helvetica Now Display)
    TextStyle baseStyle({
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
          fontFamily: 'Helvetica Neue',
          fontFamilyFallback: fallbackFonts,
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
      // Display - Italic & Extra Bold (Helvetica Now Display aesthetic)
      displayLarge: baseStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.8,
        height: 1.15,
      ),
      displayMedium: baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      displaySmall: baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.4,
        height: 1.25,
      ),

      // Headline - Italic & Punchy
      headlineLarge: baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      headlineMedium: baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      headlineSmall: baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.1,
        height: 1.35,
      ),

      // Title - Clean, legible neo-grotesque
      titleLarge: baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      titleMedium: baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Body - Ultra legible
      bodyLarge: baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodyMedium: baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      bodySmall: baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryColor,
      ),

      // Label - Dynamic button & badge typography
      labelLarge: baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
      ),
      labelMedium: baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
      ),
      labelSmall: baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
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
