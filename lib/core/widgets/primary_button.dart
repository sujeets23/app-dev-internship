import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Primary CTA button matching Glanceable's high-contrast action system:
/// - Light mode: Deep Encre ink (#1C2134) fill with crisp white label.
/// - Dark mode: Signature Ice-Cyan (#7DE8E8) fill with deep Encre ink label.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color defaultBg = isDark ? AppColors.accent : AppColors.primary;
    final Color defaultFg = isDark ? AppColors.encreDeep : AppColors.textInverse;
    final Color resolvedBg = backgroundColor ?? defaultBg;
    final Color resolvedFg = textColor ??
        (backgroundColor != null
            ? (backgroundColor!.computeLuminance() > 0.5
                ? AppColors.encreDeep
                : AppColors.textInverse)
            : defaultFg);
    final Color disabledFg =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    final Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedFg),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: isEnabled ? resolvedFg : disabledFg,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isEnabled ? resolvedFg : disabledFg,
              fontWeight: FontWeight.w600,
              fontSize: 15.5,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 54,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: resolvedBg,
          disabledBackgroundColor:
              isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
        child: content,
      ),
    );
  }
}
