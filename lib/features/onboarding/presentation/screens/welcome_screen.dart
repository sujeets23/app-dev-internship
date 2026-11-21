import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: Welcome & Introduction (Phase 5 Redesign)
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Hero Header with Date² logo on signature gradient container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Date2LogoWidget(
                        height: 42,
                        showContainer: false,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontFamily: 'Helvetica Now Display',
                          fontFamilyFallback: AppTypography.sansFallbacks,
                          color: AppColors.neonLime,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Brand Tagline
                Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.accent : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),

                // Main Editorial Headline
                Text(
                  'Your story starts with a connection.',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.charcoal,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                // Supporting Text
                Text(
                  'Discover meaningful relationships, plan memorable dates and find safe companionship in an inclusive space.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 12),

                // Three Feature Value Pillars
                _buildPillarItem(
                  context,
                  icon: Icons.diversity_1_rounded,
                  title: 'Inclusive Connections',
                  description:
                      'Express your identity and discover people who truly understand you.',
                ),
                const SizedBox(height: 8),
                _buildPillarItem(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: 'Safety Comes First',
                  description:
                      'Verified profiles, privacy controls and thoughtful biometric safety features.',
                ),
                const SizedBox(height: 8),
                _buildPillarItem(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  title: 'More Than Dating',
                  description:
                      'Explore meaningful relationships, memorable AI date plans and safe companionship.',
                ),

                const SizedBox(height: 14),

                // Primary Action Button: "Get Started"
                PrimaryButton(
                  label: 'Get Started',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => notifier.startOnboarding(),
                ),

                const SizedBox(height: 10),

                // Secondary Action: "Already have an account? Log In"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: isDark ? AppColors.accent : AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Tertiary Action: "Explore as Guest"
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen(initialIndex: 0),
                        ),
                      );
                    },
                    child: Text(
                      'Explore as Guest ➔',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.accent : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (state.hasSavedDraft && state.profile.firstName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text('Resume Setup (${state.profile.firstName})'),
                      onPressed: () {
                        final step = ref.read(onboardingLocalStorageProvider).loadCurrentStep();
                        notifier.goToStep(step > 0 ? step : 1);
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.deepViolet],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.neonLime, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.3,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
