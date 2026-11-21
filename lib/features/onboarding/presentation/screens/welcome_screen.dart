import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/core/widgets/main_navigation_screen.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
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
                          ? AppColors.surfaceMutedDark
                          : AppColors.softLavender.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.8,
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
                  color: isDark ? AppColors.neonLime : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 14),

              // Editorial Photography & Brand Hero Visual
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.deepViolet,
                      AppColors.blushPink,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/date2_logo.png',
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        'Authentic Dating & Verified Companionship',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // MAIN SECTION: Editorial Headline
              Text(
                'Meet someone who gets you.',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.charcoal,
                  letterSpacing: -0.5,
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
                      : AppColors.secondaryText,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // FEATURES: Three Concise Benefits
              _buildBenefitItem(
                context,
                icon: Icons.favorite_rounded,
                iconColor: AppColors.primary,
                title: 'Meaningful Connections',
                description: 'Discover people who appreciate who you are with authentic affirmation.',
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                context,
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.neonLime,
                title: 'Verified & Safer Experiences',
                description: 'Live biometric verification, mutual video consent, and privacy shields.',
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(
                context,
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.blushPink,
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
                      color: isDark ? AppColors.textSecondaryDark : AppColors.secondaryText,
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
                        color: isDark ? AppColors.neonLime : AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
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
                    style: TextStyle(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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
                      ref.read(onboardingProvider.notifier).goToStep(step > 0 ? step : 1);
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
                  color: isDark ? Colors.white : AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.secondaryText,
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
