import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/core/widgets/onboarding_progress_bar.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

/// Standard step wrapper ensuring consistent layout, spacing, and animations
class OnboardingStepScaffold extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Date²',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.primary,
            ),
          ),
          actions: [
            if (trailingHeaderAction != null)
              trailingHeaderAction!
            else
              TextButton(
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).fillDemoProfileAndComplete();
                  ref.read(authProvider.notifier).setPersonalInfoCompleted(true);
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark ? AppColors.accentTeal : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
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
