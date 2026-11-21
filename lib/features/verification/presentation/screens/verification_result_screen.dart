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
                      size: 54,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                if (isSuccess && result?.verificationId != null) ...[
                  const SizedBox(height: 18),
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

                const SizedBox(height: 36),

                if (isSuccess)
                  PrimaryButton(
                    label: 'Continue to App',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                else ...[
                  PrimaryButton(
                    label: 'Retry Live Verification',
                    icon: Icons.refresh_rounded,
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
