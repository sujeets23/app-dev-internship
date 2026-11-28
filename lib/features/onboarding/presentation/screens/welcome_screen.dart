import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/sf_pattern_widgets.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/signup_screen.dart';
import '../providers/onboarding_provider.dart';

/// Screen 1: Welcome & Brand Introduction (SF Pro & Playful Badges Redesign)
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
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.sfCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP: Prominent Date² Wordmark & Tagline Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Date2LogoWidget(
                    height: 38,
                    showContainer: false,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.encreElevated
                          : AppColors.sfCoral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.sfCoral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.adaptiveAccent(isDark)
                            : AppColors.sfCoral,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Brand Tagline
              const Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 20),

              // SF PATTERN: Floating Speech Bubbles & Playful Badges (Screen 2 Pattern)
              const SfWelcomeBadgesPattern(),

              const SizedBox(height: 20),

              // MAIN HEADLINE: Bold SF Pro Typography
              Text(
                'Meet someone who gets you.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontFamilyFallback: AppTypography.sansFallbacks,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.sfCharcoal,
                  letterSpacing: -0.9,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              // Supporting Text
              Text(
                'Real connections. Memorable dates. Safe companionship. All on your terms.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF6E6E73),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // LOWER SF PATTERN: Coral Comfort Pill + Link Coin (Screen 2 Pattern)
              const SfWelcomeBottomBadgesPattern(),

              const SizedBox(height: 28),

              // BOTTOM: Primary Action CTA (Black Stadium Pill)
              PrimaryButton(
                label: isInsideFlow ? 'Get Started' : 'Create Your Account',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _handlePrimaryAction(context, ref),
              ),

              const SizedBox(height: 14),

              // Secondary CTA: "Already a member? Log In"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member? ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF8E8E93),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: isDark ? AppColors.adaptiveAccent(isDark) : AppColors.sfCoral,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (!isInsideFlow && state.hasSavedDraft && state.profile.firstName.isNotEmpty) ...[
                const SizedBox(height: 10),
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

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
