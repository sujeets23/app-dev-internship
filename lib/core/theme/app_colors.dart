import 'package:flutter/material.dart';

/// Distinctive, modern palette for Date²
/// Inspired by the user reference design:
/// - Lavender backgrounds (#E5D5FF, #DCCBFF)
/// - Blush pink (#F28DB7, #F7A5C7, #FFCCDF)
/// - Peach (#F8C0AE) & Coral (#ED907B)
/// - Butter yellow (#FFE95C) & Neon lime (#E2FF85)
/// - Charcoal (#17151C) & Soft white (#FFF9F5)
class AppColors {
  // Brand Identity Primary & Accents
  static const Color softLavender = Color(0xFFE5D5FF);
  static const Color lightLavender = Color(0xFFDCCBFF);
  static const Color blushPink = Color(0xFFF28DB7);
  static const Color softPinkNew = Color(0xFFF7A5C7);
  static const Color peach = Color(0xFFF8C0AE);
  static const Color coral = Color(0xFFED907B);
  static const Color butterYellow = Color(0xFFFFE95C);
  static const Color charcoal = Color(0xFF17151C);
  static const Color softWhite = Color(0xFFFFF9F5);

  // Brand Triad
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

  // Hero & Card Gradients
  static const Color gradientStart = Color(0xFFE5D5FF);
  static const Color gradientEnd = Color(0xFFF28DB7);
  static const Color gradientPeachStart = Color(0xFFF8C0AE);
  static const Color gradientPeachEnd = Color(0xFFFFE95C);

  static const LinearGradient lavenderBlushGradient = LinearGradient(
    colors: [softLavender, blushPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blushPeachGradient = LinearGradient(
    colors: [blushPink, peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient peachYellowGradient = LinearGradient(
    colors: [peach, butterYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetPinkGradient = LinearGradient(
    colors: [primary, blushPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds & Surfaces (Light)
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3EDFD);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F0B1E);
  static const Color surfaceDark = Color(0xFF1B1433);
  static const Color surfaceMutedDark = Color(0xFF261D45);
  static const Color surfaceElevatedDark = Color(0xFF2E2452);

  // Borders & Dividers
  static const Color border = Color(0xFFE5DEFA);
  static const Color borderFocused = Color(0xFF5000F4);
  static const Color borderDark = Color(0xFF3B2E63);

  // Text Colors
  static const Color textPrimary = Color(0xFF17151C); // Charcoal
  static const Color textSecondary = Color(0xFF5A526B);
  static const Color textTertiary = Color(0xFF948B9E);
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
