import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/onboarding_provider.dart';

/// Success Screen shown upon profile completion
class ProfileCompletionSuccessScreen extends ConsumerWidget {
  const ProfileCompletionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Animated Celebration Icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 56,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Welcome Title
              Text(
                'Welcome, ${profile.firstName}!',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your profile is complete and safely saved. You are ready to experience respectful dating and companionship.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Summary Snapshot Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Profile Verified & Ready',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    _buildSummaryRow(
                      context,
                      label: 'Identity',
                      value: '${profile.displayGender} • ${profile.displayPronouns}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      label: 'Orientation',
                      value: profile.displayOrientation,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      label: 'Intent',
                      value: profile.connectionPreferences.join(', '),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Start Action
              PrimaryButton(
                label: 'Begin Discovering Connections',
                icon: Icons.explore_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Onboarding completed! (Discovery module is planned for Phase 02)',
                      ),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Reset / Restart for Testing
              SecondaryButton(
                label: 'Edit Answers or Reset Onboarding',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Reset Onboarding?'),
                      content: const Text(
                        'Would you like to review/edit your existing answers, or clear everything to test onboarding from scratch?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            notifier.goToStep(6); // Return to review
                          },
                          child: const Text('Edit Answers'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          onPressed: () async {
                            Navigator.of(dialogCtx).pop();
                            await notifier.resetOnboarding();
                          },
                          child: const Text('Clear & Start Fresh'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
