import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Visually distinctive selectable tile for onboarding options
class SelectionPillTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const SelectionPillTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.isSelected,
    this.isMultiSelect = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isSelected
        ? (isDark
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.primaryLight.withValues(alpha: 0.65))
        : (isDark ? AppColors.surfaceMutedDark : AppColors.surface);

    final Color borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.border);

    final Color titleColor = isSelected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.primaryDark)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.8 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : (isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceMuted),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      leadingIcon,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isMultiSelect ? BorderRadius.circular(6) : null,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.textTertiary),
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
