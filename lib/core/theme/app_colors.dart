import 'package:flutter/material.dart';

/// Distinctive, modern palette for Date²
class AppColors {
  // Brand Triad (User Brand Identity)
  static const Color primary = Color(0xFF5000F4); // Electric Violet
  static const Color primaryLight = Color(0xFFECE4FE);
  static const Color primaryDark = Color(0xFF3800B0);
  static const Color primarySubtle = Color(0xFFF7F3FF);

  static const Color secondary = Color(0xFFFFCCDF); // Soft Pastel Pink
  static const Color secondaryLight = Color(0xFFFFF0F6);
  static const Color secondaryDark = Color(0xFFD98CA8);

  static const Color accent = Color(0xFFE2FF85); // Neon Lime Green
  static const Color accentLight = Color(0xFFF6FFD6);
  static const Color accentDark = Color(0xFF98BD1C);

  // Gradient (Top Hero gradient: Violet to Pink)
  static const Color gradientStart = Color(0xFF5000F4);
  static const Color gradientEnd = Color(0xFFFFCCDF);

  // Neutral Backgrounds & Surfaces (Light)
  static const Color background = Color(0xFFFAF9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3EDFD);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Neutral Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F0B1E);
  static const Color surfaceDark = Color(0xFF1B1433);
  static const Color surfaceMutedDark = Color(0xFF261D45);
  static const Color surfaceElevatedDark = Color(0xFF2E2452);

  // Borders & Dividers
  static const Color border = Color(0xFFE5DEFA);
  static const Color borderFocused = Color(0xFF5000F4);
  static const Color borderDark = Color(0xFF3B2E63);

  // Text Colors
  static const Color textPrimary = Color(0xFF120826);
  static const Color textSecondary = Color(0xFF675B82);
  static const Color textTertiary = Color(0xFF9E94B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color textPrimaryDark = Color(0xFFF6F3FF);
  static const Color textSecondaryDark = Color(0xFFBDB4D8);
  static const Color textTertiaryDark = Color(0xFF887DAB);

  // Convenient Aliases
  static const Color electricViolet = primary;
  static const Color softPink = secondary;
  static const Color neonLime = accent;
  static const Color cardBackgroundDark = surfaceElevatedDark;
  static const Color textMutedDark = textSecondaryDark;

  // Status & Affirmation
  static const Color success = Color(0xFF22A06B);
  static const Color successLight = Color(0xFFE6F7F0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFE68A1B);
}
