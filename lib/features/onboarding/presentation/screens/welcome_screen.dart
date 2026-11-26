import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/signup_screen.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: Welcome & Brand Introduction (Editorial Redesign)
class WelcomeScreen extends ConsumerWidget {
  final bool isInsideFlow;

  const WelcomeScreen({
    super.key,
    this.isInsideFlow = false,
  });

  void _handlePrimaryAction(BuildContext context, WidgetRef ref) {
    ref.read(onboardingProvider.notifier).startOnboarding();
    if (!isInsideFlow) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP: Prominent Date² Wordmark & Tagline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Date2LogoWidget(
                    height: 40,
                    showContainer: false,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.encreElevated
                          : AppColors.glacierLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.glacierBorder,
                      ),
                    ),
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppColors.adaptiveAccent(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Brand Tagline
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: AppColors.adaptiveAccent(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 12),

              // MAIN SECTION: Clean Architectural Headline
              Text(
                'Meet someone who gets you.',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  letterSpacing: -0.7,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 6),

              // Supporting Text
              Text(
                'Real connections. Memorable dates. Safe companionship. All on your terms.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // FEATURES: Three Concise Benefits
              _buildBenefitItem(
                context,
                icon: Icons.favorite_rounded,
                iconColor: AppColors.adaptiveAccent(isDark),
                title: 'Meaningful Connections',
                description: 'Discover people who appreciate who you are with authentic affirmation.',
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                context,
                icon: Icons.verified_user_rounded,
                iconColor: isDark ? AppColors.accentTeal : AppColors.glacierInk,
                title: 'Verified & Safer Experiences',
                description: 'Live biometric verification, mutual video consent, and privacy shields.',
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                context,
                icon: Icons.auto_awesome_rounded,
                iconColor: isDark ? AppColors.glacierBorder : AppColors.primarySoft,
                title: 'Dates Designed Around You',
                description: 'AI date planning within your exact budget and curated partner venues.',
              ),

              const SizedBox(height: 20),

              // BOTTOM: Primary Action CTA
              PrimaryButton(
                label: isInsideFlow ? 'Get Started' : 'Create Your Account',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _handlePrimaryAction(context, ref),
              ),

              const SizedBox(height: 10),

              // Secondary CTA: "Already a member? Log In"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member? ',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.adaptiveAccent(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              if (!isInsideFlow && state.hasSavedDraft && state.profile.firstName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text('Resume Verification (${state.profile.firstName})'),
                    onPressed: () {
                      final authState = ref.read(authProvider);
                      final target = AppRouter.resolveNextRequiredScreen(authState);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => target),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceMutedDark
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
