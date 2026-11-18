import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium, rounded primary action button
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

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: isEnabled
                ? (textColor ?? AppColors.textInverse)
                : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isEnabled
                ? (textColor ?? AppColors.textInverse)
                : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceMutedDark
              : AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: content,
      ),
    );
  }
}
