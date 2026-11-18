import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../../../../core/widgets/primary_button.dart';

/// Standard step wrapper ensuring consistent layout, spacing, and animations
class OnboardingStepScaffold extends StatelessWidget {
  final int currentStep; // 1 to 6
  final int totalSteps; // 6
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextButtonLabel;
  final bool isLoading;
  final bool isNextEnabled;
  final Widget? trailingHeaderAction;

  const OnboardingStepScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onNext,
    this.onBack,
    this.nextButtonLabel = 'Continue',
    this.isLoading = false,
    this.isNextEnabled = true,
    this.trailingHeaderAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: onBack != null
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  onPressed: onBack,
                )
              : null,
          title: Text(
            'Kindred',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.primary,
            ),
          ),
          actions: [
            ?trailingHeaderAction,
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: OnboardingProgressBar(
                  currentStep: currentStep,
                  totalSteps: totalSteps,
                ),
              ),

              // Main Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      content,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                ),
                child: PrimaryButton(
                  label: nextButtonLabel,
                  onPressed: isNextEnabled ? onNext : null,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
