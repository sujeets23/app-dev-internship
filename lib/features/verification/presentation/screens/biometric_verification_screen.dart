import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import '../../domain/models/biometric_verification_model.dart';
import '../providers/biometric_verification_provider.dart';
import 'verification_result_screen.dart';
import 'companion_kyc_screen.dart';

class BiometricVerificationScreen extends ConsumerStatefulWidget {
  const BiometricVerificationScreen({super.key});

  @override
  ConsumerState<BiometricVerificationScreen> createState() =>
      _BiometricVerificationScreenState();
}

class _BiometricVerificationScreenState
    extends ConsumerState<BiometricVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biometricVerificationProvider);
    final notifier = ref.read(biometricVerificationProvider.notifier);

    // Auto-navigate to result when completed
    ref.listen<BiometricVerificationState>(biometricVerificationProvider,
        (previous, next) {
      if (next.status == BiometricVerificationStatus.verified ||
          next.status == BiometricVerificationStatus.failed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerificationResultScreen(result: next.result),
          ),
        );
      }
    });

    final bool isCompliant = state.isLightingGood && state.isDistanceGood;

    return Scaffold(
      backgroundColor: const Color(0xFF0C071C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Identity Assurance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanionKycScreen()),
              );
            },
            child: const Text(
              'Companion KYC',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 6,
                ),
              ),
            ),

            // Live Camera Viewport with Face Oval
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated Live Camera View
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1736),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isCompliant ? AppColors.accent : AppColors.error,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background gradient / camera texture
                          const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 200,
                              color: Colors.white10,
                            ),
                          ),

                          // Animated Scanning Laser Bar
                          AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) {
                              return Align(
                                alignment: Alignment(0, (_scanController.value * 2) - 1),
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.8),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Oval Face Mask Overlay
                          CustomPaint(
                            painter: _FaceOvalPainter(
                              borderColor: isCompliant ? AppColors.accent : AppColors.error,
                            ),
                          ),

                          // Landmark Points Overlay
                          ...state.landmarkPoints.map((point) {
                            return Positioned(
                              left: (300 * point.x).toDouble(),
                              top: (400 * point.y).toDouble(),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Validation Badges Top Floating
                  Positioned(
                    top: 36,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusBadge(
                          label: 'Lighting',
                          isOk: state.isLightingGood,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(
                          label: 'Distance',
                          isOk: state.isDistanceGood,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(
                          label: 'Centered',
                          isOk: state.isCentered,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Liveness Challenge Instruction Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1433),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIVENESS VERIFICATION',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.statusMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🔒 Volatile Memory Assurance: Biometric frames are stripped of metadata and discarded immediately after processing.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Manual Simulation Controls for Quality Checks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: state.isLightingGood ? 'Dim Light' : 'Fix Light',
                      textColor: Colors.white,
                      borderColor: Colors.white24,
                      onPressed: () => notifier.toggleLighting(!state.isLightingGood),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Verify Now',
                      backgroundColor: AppColors.accent,
                      textColor: const Color(0xFF120826),
                      onPressed: state.status == BiometricVerificationStatus.scanning
                          ? () => notifier.submitBiometricVerification()
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required bool isOk}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOk
            ? const Color(0xFF22A06B).withValues(alpha: 0.85)
            : Colors.red.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceOvalPainter extends CustomPainter {
  final Color borderColor;
  _FaceOvalPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.70,
      height: size.height * 0.75,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceOvalPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
