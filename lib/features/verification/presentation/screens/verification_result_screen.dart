import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import '../../domain/models/biometric_verification_model.dart';
import 'biometric_verification_screen.dart';

class VerificationResultScreen extends ConsumerWidget {
  final BiometricVerificationResult? result;

  const VerificationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSuccess = result?.isSuccess ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Status Icon Badge
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSuccess ? AppColors.accent : AppColors.error,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isSuccess ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                    color: isSuccess ? AppColors.accent : AppColors.error,
                    size: 58,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                isSuccess ? 'Identity Verified!' : 'Verification Failed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                result?.message ??
                    (isSuccess
                        ? 'Your profile now features the Verified Badge.'
                        : 'Face alignment or liveness verification was incomplete.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),

              if (isSuccess && result?.verificationId != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Proof ID: ${result!.verificationId}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              if (isSuccess)
                PrimaryButton(
                  label: 'Proceed to Matches',
                  backgroundColor: AppColors.accent,
                  textColor: const Color(0xFF120826),
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                )
              else ...[
                PrimaryButton(
                  label: 'Retry Verification',
                  backgroundColor: AppColors.primary,
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const BiometricVerificationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Return to Settings',
                  textColor: Colors.white,
                  borderColor: Colors.white24,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
