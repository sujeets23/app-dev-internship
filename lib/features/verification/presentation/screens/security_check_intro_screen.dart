import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'biometric_verification_screen.dart';

class SecurityCheckIntroScreen extends ConsumerWidget {
  const SecurityCheckIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security Check',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5000F4), Color(0xFFFFCCDF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Identity Assurance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Date² is an affirming, verified community. Complete these 3 steps to eliminate bots and protect all members.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress Overview Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VERIFICATION PIPELINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                      letterSpacing: 0.9,
                    ),
                  ),
                  Text(
                    '${(authState.verificationProgress * 100).toInt()}% COMPLETED',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: authState.verificationProgress,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 22),

              // Step 1: Email Verified Badge
              _buildStepCard(
                stepNumber: '1',
                title: 'Email Address Verified',
                subtitle: authState.email ?? 'Verified email address',
                isCompleted: authState.isEmailVerified,
                icon: Icons.mark_email_read_rounded,
              ),

              // Step 2: Live Face Scan
              _buildStepCard(
                stepNumber: '2',
                title: 'Live 3D Face Scan',
                subtitle:
                    'Oval alignment with distance and ambient lighting quality checks.',
                isCompleted: authState.isFaceVerified,
                icon: Icons.face_rounded,
              ),

              // Step 3: Active Liveness Detection
              _buildStepCard(
                stepNumber: '3',
                title: 'Active Liveness Detection',
                subtitle:
                    'Randomized anti-spoofing challenges (blink twice, turn head 15°).',
                isCompleted: authState.isFaceVerified,
                icon: Icons.visibility_rounded,
              ),

              // Step 4: Government ID Verification
              _buildStepCard(
                stepNumber: '4',
                title: 'Government ID Verification',
                subtitle:
                    'Official country-aware photo ID capture and document alignment.',
                isCompleted: authState.isDocVerified,
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 18),

              // Privacy & Camera Permission Guarantee
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.privacy_tip_outlined,
                        color: Color(0xFF22C55E), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Strict Biometric Privacy Mandate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera access is required for real-time 3D landmark analysis. Images are processed in volatile memory and wiped immediately. No raw selfies are stored.',
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
              ),

              const SizedBox(height: 28),

              // Continue Button
              PrimaryButton(
                label: authState.isFaceVerified
                    ? 'Continue to Government ID'
                    : 'Start Live Face Scan',
                icon: Icons.camera_alt_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BiometricVerificationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF22C55E).withValues(alpha: 0.6)
              : AppColors.border,
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
                  ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : icon,
              color: isCompleted
                  ? const Color(0xFF22C55E)
                  : AppColors.primary,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '✓',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
}
