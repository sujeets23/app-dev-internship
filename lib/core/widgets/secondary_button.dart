import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean secondary / outlined action button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final Color? textColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? (isDark ? AppColors.borderDark : AppColors.border),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: content,
      ),
    );
  }
}
