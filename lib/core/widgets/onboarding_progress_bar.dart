import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Elegant progress bar for onboarding steps
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? stepTitle;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    final Color accent = AppColors.adaptiveAccent(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: theme.textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            if (stepTitle != null)
              Text(
                stepTitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: isDark
                      ? AppColors.surfaceMutedDark
                      : AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
