import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

/// Official Date² Wordmark & Logo Widget
/// Implements the brand identity with:
/// - Exact 'DaTe²' typography with superscript '²'
/// - High-contrast neon lime (#E2FF85), electric violet (#5000F4) or custom tint
/// - High-res PNG asset with crisp vector typography fallback
/// - Optional brand gradient hero container (#5000F4 -> #FFCCDF)
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
    this.isItalic = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoCore = Image.asset(
      'assets/images/date2_logo.png',
      height: height,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) => _buildFallbackWordmark(context),
    );

    if (showContainer) {
      logoCore = Container(
        padding: EdgeInsets.symmetric(
          horizontal: height * 0.45,
          vertical: height * 0.22,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.brandHeroGradient,
          borderRadius: BorderRadius.circular(height * 0.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            logoCore,
            if (showTagline) ...[
              const SizedBox(height: 4),
              Text(
                'Date Smart • Connect Meaningfully',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * 0.22,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      );
    } else if (showTagline) {
      logoCore = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoCore,
          const SizedBox(height: 6),
          Text(
            'Date Smart • Connect Meaningfully',
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: height * 0.26,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.4,
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

  Widget _buildFallbackWordmark(BuildContext context) {
    final textColor = color ?? AppColors.primary;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Helvetica Now Display',
          fontFamilyFallback: AppTypography.sansFallbacks,
          fontSize: height * 0.8,
          fontWeight: FontWeight.w900,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: textColor,
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(text: 'DaTe'),
          TextSpan(
            text: '²',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
