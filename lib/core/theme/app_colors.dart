import 'package:flutter/material.dart';

/// Centralized Design System & Colour Tokens for Date²
/// Faithfully aligned with Glanceable (https://www.glanceable.io/en):
/// - Deep Encre ink navy (#1C2134 / #0E1018) for primary actions, dark surfaces & contrast headings.
/// - Signature Ice-Cyan (#7DE8E8) and Mineral Teal (#2ED8C8) highlights & dark-mode CTAs.
/// - Soft Glacier sky surfaces (#E8F4F8, #D6EEF8, #F2F9FC) with #B8DDF0 chip borders.
/// - Clean warm neutral off-whites (#FBFBFB, #F4F3F0, #F6F6F3) and crisp white (#FFFFFF) cards.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PRIMARY BRAND INK FAMILY (Glanceable Encre)
  // ===========================================================================
  /// --brand--encre-700: Primary brand ink, light-mode CTAs, dark section blocks & active ink
  static const Color primary = Color(0xFF1C2134);

  /// --brand--encre-900: Deepest ink for pressed states & dark-mode scaffold canvas
  static const Color encreDeep = Color(0xFF0E1018);

  /// --brand--encre-800: Dark surface ink & muted dark cards
  static const Color encreDark = Color(0xFF16182A);

  /// Elevated dark surface card (matches Glanceable .compliance_card #22283F)
  static const Color encreElevated = Color(0xFF22283F);

  /// --brand--encre-600: Crisp border stroke on dark containers
  static const Color encreBorderDark = Color(0xFF2A304A);

  /// --brand--encre-500: Secondary strong slate ink
  static const Color primarySoft = Color(0xFF3A4260);

  // ===========================================================================
  // 2. SIGNATURE HIGHLIGHT ACCENTS (Glanceable Blue-300 Cyan & Mineral Teal)
  // ===========================================================================
  /// --brand--blue-300: Signature cyan-ice highlight (CTA arrow tiles, dark-mode primary CTA)
  static const Color accent = Color(0xFF7DE8E8);

  /// Saturated mineral cyan-teal highlight (.lb-home_eyebrow / interactive dark icons)
  static const Color accentTeal = Color(0xFF2ED8C8);

  /// Direct aliases for Glanceable Design Tokens
  static const Color glanceableCyan = accent;
  static const Color glanceableCyanDeep = accentTeal;

  /// --brand--blue-50: Pale cyan whisper tint
  static const Color accentLight = Color(0xFFE5FAFA);

  /// --brand--blue-900: Deep cyan ink for accessible text on cyan/ice pills
  static const Color accentInk = Color(0xFF063838);

  // ===========================================================================
  // 3. SECONDARY ICE SURFACES (Glanceable Glacier)
  // ===========================================================================
  /// --brand--glacier-200: Glacier sky highlight (secondary buttons & nav pills)
  static const Color secondary = Color(0xFFD6EEF8);

  /// --brand--glacier-100: Signature ice-wash surface (selected tabs, banners, feature cards)
  static const Color glacierLight = Color(0xFFE8F4F8);

  /// --brand--glacier-50: Ultra-light glacier hover/card tint
  static const Color glacierSoft = Color(0xFFF2F9FC);

  /// --brand--glacier-300: Cool glacier border & active badge stroke
  static const Color glacierBorder = Color(0xFFB8DDF0);

  /// --brand--glacier-900: Deep glacier ink for text over Glacier-100 / Glacier-200
  static const Color glacierInk = Color(0xFF102A38);

  // ===========================================================================
  // 4. BACKGROUNDS & WARM EDITORIAL SURFACES (Light & Dark)
  // ===========================================================================
  /// --brand--neutral: Clean editorial off-white app canvas
  static const Color background = Color(0xFFFBFBFB);

  /// --brand--neutral-200: Warm stone/linen section background
  static const Color backgroundWarm = Color(0xFFF4F3F0);

  /// --neutral--white: Pure crisp white elevated cards, inputs & bottom sheets
  static const Color surface = Color(0xFFFFFFFF);

  /// --brand--beige: Warm architectural card surface
  static const Color surfaceWarm = Color(0xFFF6F6F3);

  /// --neutral--neutral-200: Warm ivory highlight surface
  static const Color surfaceCream = Color(0xFFFAF8F2);

  /// --neutral--neutral-300: Warm sand neutral surface for muted controls & chips
  static const Color surfaceMuted = Color(0xFFF0EDE4);

  /// Dark Theme Surfaces (Deep Encre night mode)
  static const Color backgroundDark = encreDeep;
  static const Color surfaceDark = primary;
  static const Color surfaceMutedDark = encreDark;
  static const Color surfaceElevatedDark = encreElevated;

  /// Surface variants for neutral cards and chips
  static const Color surfaceVariant = surfaceMuted;
  static const Color surfaceVariantDark = encreDark;

  // ===========================================================================
  // 5. TYPOGRAPHY & NEUTRAL INKS
  // ===========================================================================
  /// Light Mode Text
  static const Color textPrimary = Color(0xFF1C2134); // --brand--encre-700
  static const Color textSecondary = Color(0xFF505A78); // --brand--encre-400
  static const Color textTertiary = Color(0xFF788098); // --brand--encre-300
  static const Color textWarmMuted = Color(0xFFA8A496); // --neutral--neutral-600
  static const Color textWarmCharcoal = Color(0xFF585550); // --neutral--neutral-800
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFC8CCD8); // --brand--encre-100
  static const Color textTertiaryDark = Color(0xFFA0A6B8); // --brand--encre-200

  // ===========================================================================
  // 6. BORDERS & DIVIDERS
  // ===========================================================================
  static const Color border = Color(0xFFE8EAF0); // --brand--encre-50
  static const Color borderWarm = Color(0xFFE2DED4); // --brand--neutral-400
  static const Color borderSubtle = Color(0xFFF1F2F6);
  static const Color borderFocused = Color(0xFF1C2134);
  static const Color borderDark = encreBorderDark;

  // ===========================================================================
  // 7. GLANCEABLE PRISMATIC & ATMOSPHERIC GRADIENTS
  // ===========================================================================
  /// Top-to-bottom Glacier wash into clean off-white canvas
  static const LinearGradient heroWashGradient = LinearGradient(
    colors: [glacierLight, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Warm linen vertical wash into neutral off-white
  static const LinearGradient warmWashGradient = LinearGradient(
    colors: [backgroundWarm, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Soft luminous Glacier prism gradient for featured light cards & AI callouts
  static const LinearGradient glacierPrismGradient = LinearGradient(
    colors: [glacierSoft, glacierLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Signature Deep Encre-to-Glacier dark surface gradient (hero banners & featured dark cards)
  static const LinearGradient encrePrismGradient = LinearGradient(
    colors: [encreDeep, primary, glacierInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cool cyan-glacier highlight gradient for verified badges & high-emphasis pills (dark text)
  static const LinearGradient cyanPrismGradient = LinearGradient(
    colors: [glacierLight, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===========================================================================
  // 8. SUBTLE STRUCTURAL SHADOWS
  // ===========================================================================
  /// Airy neutral card elevation shadow
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: encreDeep.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: encreDeep.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Modal & floating card depth
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: encreDeep.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Subtle crisp shadow for elevated dark cards & hero CTAs
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.16),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // ===========================================================================
  // 9. SEMANTIC STATUS TOKENS
  // ===========================================================================
  static const Color success = Color(0xFF0E9F6E);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  // ===========================================================================
  // 10. ADAPTIVE THEME HELPERS
  // ===========================================================================
  /// High-contrast accent ink for icons, links & selected states per brightness
  static Color adaptiveAccent(bool isDark) => isDark ? accent : primary;

  /// Accessible foreground color placed on [adaptiveAccent]
  static Color adaptiveOnAccent(bool isDark) => isDark ? encreDeep : textInverse;

  /// Tinted highlight container per brightness
  static Color adaptiveHighlightBg(bool isDark) =>
      isDark ? encreElevated : glacierLight;

  /// Hairline card border per brightness
  static Color adaptiveBorder(bool isDark) => isDark ? borderDark : border;
}
