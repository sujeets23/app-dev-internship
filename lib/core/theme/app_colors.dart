import 'package:flutter/material.dart';

/// Centralized Design System & Color Palette for Date²
/// Inspired by the visual aesthetic and color direction of Glanceable (https://www.glanceable.io/en):
/// - Clean, soft, and elegant light backgrounds (#F8F9FD).
/// - Pure white (#FFFFFF) and subtle off-white/pastel surfaces (#EEF1FB, #F1F3F9).
/// - Dark navy/charcoal typography (#1C2134) for exceptional contrast and readability.
/// - Vibrant Royal Blue (#4D65FF) and Violet (#7C3AED) as the main brand accents.
/// - Soft Rose / Blush Pink (#EE78A4) and Lavender (#C6A0FF, #E0D4FC) as supporting accents.
/// - Signature Blue-to-Violet-to-Pink gradient highlights.
/// - Soft pastel tints for cards, badges, and secondary elements.
/// - Subtle, elegant borders (#E8EAF0) and airy soft shadows.
class AppColors {
  // ===========================================================================
  // 1. MAIN BRAND ACCENTS (Blue, Violet, Purple)
  // ===========================================================================
  /// Glanceable Vibrant Royal Blue - Primary brand accent & main CTA color
  static const Color primary = Color(0xFF4D65FF);
  static const Color royalBlue = Color(0xFF4D65FF);
  static const Color royalBlueLight = Color(0xFF3898EC);
  static const Color primaryDark = Color(0xFF223AAA);
  static const Color primaryLight = Color(0xFFEEF1FB); // Soft periwinkle/blue tint
  static const Color primarySubtle = Color(0xFFF5F8FF); // Ultra subtle background tint

  /// Electric Violet & Deep Purple - Secondary brand accent
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color deepViolet = Color(0xFF6549D5);
  static const Color deepPurple = Color(0xFF5B21B6);
  static const Color violetAccent = Color(0xFFC6A0FF); // Soft vibrant violet/periwinkle
  static const Color electricViolet = primary; // Backward compatibility alias

  // ===========================================================================
  // 2. SUPPORTING ACCENTS (Pink, Lavender, Peach, Aqua)
  // ===========================================================================
  /// Soft Rose & Blush Pink - Supporting romantic & warm accent
  static const Color secondary = Color(0xFFEE78A4);
  static const Color softPink = secondary;
  static const Color blushPink = Color(0xFFEE78A4);
  static const Color softPinkNew = Color(0xFFF492BA);
  static const Color secondaryLight = Color(0xFFFDF2F8); // Soft pastel pink tint
  static const Color secondaryDark = Color(0xFFD64D82);

  /// Lavender & Periwinkle tints
  static const Color lavender = Color(0xFFE0D4FC);
  static const Color softLavender = Color(0xFFEEF1FB);
  static const Color lightLavender = Color(0xFFF5F3FF);

  /// Peach & Coral Warm Highlights (Glanceable Warm Accent)
  static const Color peach = Color(0xFFF8A46A);
  static const Color coral = Color(0xFFF8A46A);
  static const Color peachLight = Color(0xFFFFF7ED);

  /// Aqua & Cyan Highlights (Glanceable Tech/Data Highlight)
  static const Color aqua = Color(0xFF7DE8E8);
  static const Color aquaDark = Color(0xFF2ED8C8);

  /// Accent alias (mapped to Glanceable's soft vibrant violet/periwinkle)
  static const Color accent = Color(0xFFC6A0FF);
  static const Color neonLime = Color(0xFF4D65FF); // Harmonized into Glanceable Royal Blue
  static const Color accentLight = Color(0xFFF5F3FF);
  static const Color accentDark = Color(0xFF6549D5);
  static const Color butterYellow = Color(0xFFFCE7B2);

  // ===========================================================================
  // 3. CLEAN BACKGROUNDS & SURFACES (Light & Dark)
  // ===========================================================================
  /// Light Theme - Clean, soft and elegant backgrounds & white surfaces
  static const Color background = Color(0xFFF8F9FD); // Soft breathable off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards & dialogs
  static const Color surfaceMuted = Color(0xFFF1F3F9); // Subtle off-white / unselected
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF8F9FD);
  static const Color cream = Color(0xFFF8F9FD);

  /// Dark Theme - Deep navy / slate surfaces maintaining brand mood
  static const Color backgroundDark = Color(0xFF0E1018); // Deep space navy
  static const Color surfaceDark = Color(0xFF16182A); // Rich dark slate navy
  static const Color surfaceMutedDark = Color(0xFF1C2134); // Muted dark card surface
  static const Color surfaceElevatedDark = Color(0xFF222942); // Elevated dark surface
  static const Color cardBackgroundDark = surfaceElevatedDark;

  // ===========================================================================
  // 4. TYPOGRAPHY & TEXT (Strong Contrast & Readability)
  // ===========================================================================
  /// High-contrast Dark Navy / Charcoal (WCAG AAA compliant on white & off-white)
  static const Color charcoal = Color(0xFF1C2134);
  static const Color darkCharcoal = Color(0xFF16182A);
  static const Color textPrimary = Color(0xFF1C2134);
  static const Color textSecondary = Color(0xFF505A78); // Slate navy helper/subtitle text
  static const Color textTertiary = Color(0xFF758696); // Muted placeholder / caption text
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF505A78);

  /// Dark Theme Text Tones
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFB0BBD0);
  static const Color textTertiaryDark = Color(0xFF707E96);
  static const Color textMutedDark = textSecondaryDark;

  // ===========================================================================
  // 5. BORDERS & DIVIDERS
  // ===========================================================================
  static const Color border = Color(0xFFE8EAF0); // Glanceable subtle clean border
  static const Color borderFocused = Color(0xFF4D65FF); // Royal blue focus border
  static const Color borderSubtle = Color(0xFFF1F3F7);
  static const Color borderDark = Color(0xFF2A324B);

  // ===========================================================================
  // 6. SIGNATURE GLANCEABLE GRADIENTS
  // ===========================================================================
  static const Color gradientStart = Color(0xFF4D65FF);
  static const Color gradientEnd = Color(0xFFEE78A4);
  static const Color gradientPeachStart = Color(0xFFF8A46A);
  static const Color gradientPeachEnd = Color(0xFFFCE7B2);

  /// Signature Hero Highlight: Blue (#4D65FF) -> Violet (#7C3AED) -> Pink (#EE78A4)
  static const LinearGradient brandHeroGradient = LinearGradient(
    colors: [primary, primaryViolet, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Direct Blue-to-Violet-to-Pink gradient for primary hero elements
  static const LinearGradient blueVioletPinkGradient = LinearGradient(
    colors: [Color(0xFF4D65FF), Color(0xFF7C3AED), Color(0xFFEE78A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue to Violet accent gradient
  static const LinearGradient blueVioletGradient = LinearGradient(
    colors: [primary, primaryViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Violet to Pink romantic accent gradient
  static const LinearGradient violetPinkGradient = LinearGradient(
    colors: [primaryViolet, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft pastel card gradient (for subtle card backgrounds & highlights)
  static const LinearGradient softPastelCardGradient = LinearGradient(
    colors: [Color(0xFFEEF1FB), Color(0xFFFDF2F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderBlushGradient = LinearGradient(
    colors: [Color(0xFFEEF1FB), Color(0xFFFDF2F8)],
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

  // ===========================================================================
  // 7. REUSABLE BOX SHADOWS
  // ===========================================================================
  /// Airy, elegant soft shadow for clean cards
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1C2134).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF1C2134).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Elevated shadow for prominent modal cards & floating surfaces
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1C2134).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Gentle glowing shadow for primary action buttons
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // ===========================================================================
  // 8. STATUS & UTILITY COLORS
  // ===========================================================================
  static const Color success = Color(0xFF10B981); // Clean emerald green
  static const Color successLight = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444); // Clean modern red
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // Amber warning
  static const Color warningLight = Color(0xFFFFFBEB);
}
