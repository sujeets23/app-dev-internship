import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean selectable tile aligned with Glanceable's Glacier-active filter & list cards
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

    final Color accentColor = AppColors.adaptiveAccent(isDark);
    final Color backgroundColor = isSelected
        ? (isDark
            ? AppColors.accent.withValues(alpha: 0.14)
            : AppColors.glacierLight)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);

    final Color borderColor = isSelected
        ? accentColor
        : (isDark ? AppColors.borderDark : AppColors.border);

    final Color titleColor = isSelected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.glacierInk)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.6 : 1.0,
        ),
        boxShadow: isSelected ? AppColors.softShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
                          ? (isDark
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.secondary)
                          : (isDark
                              ? AppColors.surfaceMutedDark
                              : AppColors.surfaceWarm),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      leadingIcon,
                      size: 20,
                      color: isSelected
                          ? accentColor
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
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
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
                    color: isSelected ? accentColor : Colors.transparent,
                    shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius:
                        isMultiSelect ? BorderRadius.circular(6) : null,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.textTertiary),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.adaptiveOnAccent(isDark),
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
