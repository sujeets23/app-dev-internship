import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'biometric_verification_screen.dart';
import 'government_id_verification_screen.dart';

class SecurityCheckIntroScreen extends ConsumerWidget {
  const SecurityCheckIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final Widget content = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Security Check',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'SAFETY FIRST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.figmaPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Figma Squircle Shield Header
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.figmaPrimary.withValues(alpha: 0.18)
                      : const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColors.figmaPrimary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'REAL PEOPLE. REAL CONNECTION.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.accent : AppColors.figmaPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A safer space\nstarts with you.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A quick identity check helps keep Date² genuine. It only takes a moment.',
                style: AppTypography.bodyMedium.copyWith(
                  color: mutedTextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Figma 3 Feature Cards
              _buildFigmaFeatureCard(
                icon: Icons.face_retouching_natural_rounded,
                title: 'A quick face check',
                subtitle: 'Follow a few simple on-screen prompts.',
                cardBg: cardBg,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildFigmaFeatureCard(
                icon: Icons.badge_outlined,
                title: 'Have your ID ready',
                subtitle: 'Choose a valid government-issued ID.',
                cardBg: cardBg,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildFigmaFeatureCard(
                icon: Icons.lock_outline_rounded,
                title: 'Private by design',
                subtitle: 'Your verification details never appear on your profile.',
                cardBg: cardBg,
                textColor: textColor,
                mutedTextColor: mutedTextColor,
                isDark: isDark,
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'VERIFICATION PIPELINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.adaptiveAccent(isDark),
                        letterSpacing: 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(authState.verificationProgress * 100).toInt()}% DONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.adaptiveAccent(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: authState.verificationProgress,
                  backgroundColor: isDark
                      ? AppColors.surfaceMutedDark
                      : AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.adaptiveAccent(isDark),
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 22),

              _buildStepCard(
                context: context,
                stepNumber: '1',
                title: 'Email Address Verified',
                subtitle: authState.email ?? 'Verified email address',
                isCompleted: authState.isEmailVerified,
                icon: Icons.mark_email_read_rounded,
                cardBg: cardBg,
                textColor: textColor,
              ),

              _buildStepCard(
                context: context,
                stepNumber: '2',
                title: kIsWeb
                    ? 'Live Webcam Face Scan (Demo Mode)'
                    : 'Live 3D Face Scan',
                subtitle: kIsWeb
                    ? 'Browser getUserMedia webcam oval alignment with distance and lighting checks (2D landmarks).'
                    : 'Front-camera oval alignment with distance and ambient lighting quality checks.',
                isCompleted: authState.isFaceVerified,
                icon: Icons.face_rounded,
                cardBg: cardBg,
                textColor: textColor,
              ),

              _buildStepCard(
                context: context,
                stepNumber: '3',
                title: 'Active Liveness Detection',
                subtitle:
                    'Randomized on-device prompts (blink twice, turn head ~15° left/right).',
                isCompleted: authState.isFaceVerified,
                icon: Icons.visibility_rounded,
                cardBg: cardBg,
                textColor: textColor,
              ),

              _buildStepCard(
                context: context,
                stepNumber: '4',
                title: 'Government ID Verification',
                subtitle:
                    'Country-aware document selection, rear-camera capture or PDF/image upload.',
                isCompleted: authState.isDocVerified,
                icon: Icons.badge_outlined,
                cardBg: cardBg,
                textColor: textColor,
              ),

              const SizedBox(height: 16),

              // Privacy & Camera Permission Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.privacy_tip_outlined,
                            color: AppColors.success, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Strict Biometric Privacy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Camera frames are processed strictly in memory and never saved to your gallery or permanent storage. Future backend uploads require transient embedding extraction without raw-selfie storage.',
                                style: TextStyle(
                                  color: mutedTextColor,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: AppColors.adaptiveAccent(isDark), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Camera Permission Needed Next',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'On the next screen, we request camera access exclusively for guided face scan and Government ID framing.',
                                style: TextStyle(
                                  color: mutedTextColor,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                label: authState.isFaceVerified
                    ? 'Continue to Government ID'
                    : 'Start Live Face Scan',
                icon: authState.isFaceVerified
                    ? Icons.badge_outlined
                    : Icons.camera_alt_rounded,
                backgroundColor: AppColors.figmaPrimary,
                onPressed: () {
                  if (authState.isFaceVerified) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GovernmentIdVerificationScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BiometricVerificationScreen(),
                      ),
                    );
                  }
                },
              ),
              if (!authState.isFaceVerified) ...[
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Bypass Face Scan (QA Testing)',
                  icon: Icons.fast_forward_rounded,
                  onPressed: () {
                    ref.read(authProvider.notifier).setFaceVerified('VERIF-B3D-QA-BYPASS');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GovernmentIdVerificationScreen(),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 14),
              Center(
                child: Text(
                  "You'll need to allow camera access.",
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.securityCheck,
      child: content,
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required IconData icon,
    required Color cardBg,
    required Color textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.6)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: isCompleted ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.adaptiveHighlightBg(isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : icon,
              color: isCompleted
                  ? AppColors.success
                  : AppColors.adaptiveAccent(isDark),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$stepNumber. $title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '✓',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color textColor,
    required Color mutedTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceMutedDark : AppColors.figmaSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE5DEE6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.figmaPrimary.withValues(alpha: 0.18)
                  : const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.figmaPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
