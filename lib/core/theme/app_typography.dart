import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Editorial, modern typography hierarchy
class AppTypography {
  static TextTheme textTheme({bool isDark = false}) {
    final Color primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    // Base text style using Plus Jakarta Sans with standard fallback
    TextStyle baseStyle({
      required double fontSize,
      FontWeight fontWeight = FontWeight.normal,
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      try {
        return GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      } catch (_) {
        return TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          color: color ?? primaryColor,
          letterSpacing: letterSpacing,
        );
      }
    }

    return TextTheme(
      // Display
      displayLarge: baseStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displayMedium: baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.25,
      ),
      displaySmall: baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.3,
      ),

      // Headline
      headlineLarge: baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineMedium: baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
      ),
      headlineSmall: baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
      ),

      // Title
      titleLarge: baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
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

      // Body
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

      // Label
      labelLarge: baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }
}
