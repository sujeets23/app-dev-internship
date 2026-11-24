import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import '../../domain/models/biometric_verification_model.dart';
import 'biometric_verification_screen.dart';
import 'government_id_verification_screen.dart';

class VerificationResultScreen extends ConsumerWidget {
  final BiometricVerificationResult? result;

  const VerificationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSuccess = result?.isSuccess ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Status Icon Badge
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSuccess ? AppColors.success : AppColors.error,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isSuccess
                          ? Icons.verified_user_rounded
                          : Icons.gpp_bad_rounded,
                      color: isSuccess ? AppColors.success : AppColors.error,
                      size: 54,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  isSuccess ? 'Identity Verified!' : 'Verification Incomplete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  result?.message ??
                      (isSuccess
                          ? 'Your identity has been confirmed via 3D active liveness. Your profile now proudly displays the Verified Shield Badge.'
                          : 'Face alignment or liveness verification was incomplete. Please ensure good lighting and clear face alignment.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                // Proof Badge
                if (isSuccess && result?.verificationId != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.security,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Proof ID: ${result!.verificationId}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (result?.cryptographicProofHash != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            result!.cryptographicProofHash!,
                            style: TextStyle(
                              color: isDark ? Colors.white38 : AppColors.textTertiary,
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Volatile RAM Guarantee Note
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_rounded, color: isDark ? Colors.white54 : AppColors.textSecondary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zero-Persistence Guarantee: All raw facial frames have been wiped from volatile memory. No selfies are saved to device storage or databases.',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (isSuccess)
                  PrimaryButton(
                    label: 'Proceed to Government ID',
                    icon: Icons.badge_outlined,
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const GovernmentIdVerificationScreen(),
                        ),
                      );
                    },
                  )
                else ...[
                  PrimaryButton(
                    label: 'Retry Live Verification',
                    icon: Icons.refresh_rounded,
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiometricVerificationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Do This Later',
                    textColor: Colors.white,
                    borderColor: Colors.white24,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
