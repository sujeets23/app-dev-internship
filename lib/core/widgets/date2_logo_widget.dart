import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

/// Official Date² Wordmark & Logo Widget adapted to the Glanceable colour system
/// - Uses Deep Encre (#1C2134) in light mode and crisp White / Cyan (#7DE8E8) in dark surfaces
/// - Optional Deep Encre architectural container (AppColors.encrePrismGradient)
typedef DateLogo = Date2LogoWidget;

class Date2LogoWidget extends StatelessWidget {
  final double height;
  final Color? color;
  final bool showContainer;
  final bool showTagline;
  final bool isItalic;
  final VoidCallback? onTap;

  const Date2LogoWidget({
    super.key,
    this.height = 36,
    this.color,
    this.showContainer = false,
    this.showTagline = false,
    this.isItalic = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resolvedLogoTint = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.primary);

    Widget logoCore = Image.asset(
      'assets/images/date2_logo.png',
      height: height,
      fit: BoxFit.contain,
      color: resolvedLogoTint,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) =>
          _buildFallbackWordmark(context, resolvedLogoTint),
    );

    if (showTagline) {
      logoCore = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoCore,
          const SizedBox(height: 6),
          Text(
            'Date Smart • Connect Meaningfully',
            style: TextStyle(
              color: color ??
                  (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              fontSize: height * 0.26,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoCore,
      );
    }

    return logoCore;
  }

  Widget _buildFallbackWordmark(BuildContext context, Color textColor) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontFamilyFallback: AppTypography.sansFallbacks,
          fontSize: height * 0.8,
          fontWeight: FontWeight.w800,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: textColor,
          letterSpacing: -0.6,
        ),
        children: const [
          TextSpan(text: 'DaTe'),
          TextSpan(
            text: '²',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.accentTeal,
            ),
          ),
        ],
      ),
    );
  }
}
