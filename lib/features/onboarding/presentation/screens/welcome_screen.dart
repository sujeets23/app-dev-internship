import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: Welcome & Introduction
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Brand Emblem
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // App Name & Tagline
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 18),

              // Welcome Introduction Text
              Text(
                AppConstants.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.55,
                ),
              ),

              const Spacer(flex: 1),

              // Feature Value Pillars
              _buildPillarItem(
                context,
                icon: Icons.diversity_1_rounded,
                title: 'Authentic Inclusivity',
                description:
                    'Choose how you express your gender, pronouns, and orientation with full affirmation.',
              ),
              const SizedBox(height: 14),
              _buildPillarItem(
                context,
                icon: Icons.shield_outlined,
                title: 'Safety & Respect First',
                description:
                    'Clear boundaries, thoughtful standards, and a community built on empathy.',
              ),
              const SizedBox(height: 14),
              _buildPillarItem(
                context,
                icon: Icons.handshake_outlined,
                title: 'Transparent Intentions',
                description:
                    'Match for romantic relationships, casual dating, or platonic companionship.',
              ),

              const Spacer(flex: 2),

              // Action Buttons
              PrimaryButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => notifier.startOnboarding(),
              ),

              if (state.hasSavedDraft && state.profile.firstName.isNotEmpty) ...[
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Resume Setup (${state.profile.firstName})',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    // Jump to last saved step or review
                    final step = ref.read(onboardingLocalStorageProvider).loadCurrentStep();
                    notifier.goToStep(step > 0 ? step : 1);
                  },
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceMutedDark : AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
