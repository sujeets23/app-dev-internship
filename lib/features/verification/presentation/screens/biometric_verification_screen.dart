import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/biometric_verification_model.dart';
import '../providers/biometric_verification_provider.dart';
import 'verification_result_screen.dart';
import 'companion_kyc_screen.dart';

class BiometricVerificationScreen extends ConsumerStatefulWidget {
  final bool isCompanionFlow;
  const BiometricVerificationScreen({super.key, this.isCompanionFlow = false});

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
      duration: const Duration(milliseconds: 2200),
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

    // Auto-navigate to result screen when verified or failed
    ref.listen<BiometricVerificationState>(biometricVerificationProvider,
        (previous, next) {
      if (next.status == BiometricVerificationStatus.verified ||
          next.status == BiometricVerificationStatus.failed) {
        if (next.status == BiometricVerificationStatus.verified) {
          ref.read(authProvider.notifier).setFaceVerified(
                next.result?.verificationId ?? 'VERIF-B3D-PROOF',
              );
        }

        if (widget.isCompanionFlow &&
            next.status == BiometricVerificationStatus.verified) {
          // Return proof back to companion KYC flow
          Navigator.of(context).pop(next.result?.verificationId);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VerificationResultScreen(result: next.result),
            ),
          );
        }
      }
    });

    final bool isCompliant =
        state.alignmentStatus == FaceAlignmentStatus.aligned;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Identity Assurance & Shield',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          if (!widget.isCompanionFlow)
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
        child: state.permissionState == CameraPermissionState.denied
            ? _buildPermissionDeniedView(notifier)
            : Column(
                children: [
                  // Verification Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.status == BiometricVerificationStatus.challenging
                                  ? 'STEP 2: ACTIVE LIVENESS'
                                  : 'STEP 1: FACE ALIGNMENT',
                              style: const TextStyle(
                                color: AppColors.neonLime,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${(state.progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.neonLime,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera Viewport with Guided Oval & Face Feedback
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Viewport Container
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF19122F),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isCompliant
                                  ? AppColors.neonLime
                                  : (state.alignmentStatus ==
                                          FaceAlignmentStatus.poorLighting
                                      ? Colors.amber
                                      : AppColors.error),
                              width: 2.2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Camera Simulation Silhouette
                                Center(
                                  child: Icon(
                                    Icons.face_retouching_natural_rounded,
                                    size: 210,
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),

                                // Laser Scanning Bar
                                AnimatedBuilder(
                                  animation: _scanController,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(
                                        0,
                                        (_scanController.value * 2) - 1,
                                      ),
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: AppColors.neonLime,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.neonLime
                                                  .withValues(alpha: 0.7),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Oval Face Guide Overlay
                                CustomPaint(
                                  painter: _FaceOvalPainter(
                                    borderColor: isCompliant
                                        ? AppColors.neonLime
                                        : (state.alignmentStatus ==
                                                FaceAlignmentStatus.poorLighting
                                            ? Colors.amber
                                            : AppColors.error),
                                  ),
                                ),

                                // Landmark Points Mesh
                                ...state.landmarkPoints.map((point) {
                                  return Positioned(
                                    left: (280 * point.x).toDouble(),
                                    top: (360 * point.y).toDouble(),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: state.currentActionCompleted
                                            ? const Color(0xFF22C55E)
                                            : AppColors.neonLime,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.neonLime
                                                .withValues(alpha: 0.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                // Processing Overlay Spinner
                                if (state.status ==
                                    BiometricVerificationStatus.processing)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.neonLime,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Validating volatile biometric proof...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Floating Environmental Badges
                        Positioned(
                          top: 22,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusBadge(
                                label: 'Lighting',
                                isOk: state.isLightingGood,
                                icon: Icons.light_mode_outlined,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(
                                label: state.isFaceTooFar
                                    ? 'Too Far'
                                    : (state.isFaceTooClose
                                        ? 'Too Close'
                                        : 'Distance'),
                                isOk: state.isDistanceGood,
                                icon: Icons.straighten_rounded,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(
                                label: 'Centered',
                                isOk: state.isCentered,
                                icon: Icons.center_focus_strong_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real-Time Guidance & Instruction Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1433),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: state.currentActionCompleted
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.25)
                                    : AppColors.primary.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.currentActionCompleted
                                    ? Icons.check_circle_rounded
                                    : (state.status ==
                                            BiometricVerificationStatus
                                                .challenging
                                        ? Icons.record_voice_over_rounded
                                        : Icons.face_rounded),
                                color: state.currentActionCompleted
                                    ? const Color(0xFF22C55E)
                                    : AppColors.neonLime,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.status ==
                                            BiometricVerificationStatus
                                                .challenging
                                        ? 'CHALLENGE ${state.currentChallengeIndex + 1} OF ${state.challenges.length}'
                                        : 'GUIDED ALIGNMENT',
                                    style: const TextStyle(
                                      color: AppColors.neonLime,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    state.statusMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined,
                                color: Colors.white38, size: 14),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Processed in volatile RAM. Strip metadata & zero-wipe immediately.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Interactive Alignment Adjustment & Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: state.status == BiometricVerificationStatus.aligning
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Alignment simulator toggles
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSmallToggle(
                                      label: state.isLightingGood
                                          ? 'Light: OK'
                                          : 'Light: Dim',
                                      isActive: state.isLightingGood,
                                      onTap: () {
                                        notifier.updateFaceAlignment(
                                          lighting: !state.isLightingGood,
                                          centered: state.isCentered,
                                          tooClose: state.isFaceTooClose,
                                          tooFar: state.isFaceTooFar,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSmallToggle(
                                      label: state.isFaceTooFar
                                          ? 'Too Far'
                                          : (state.isFaceTooClose
                                              ? 'Too Close'
                                              : 'Distance: OK'),
                                      isActive: state.isDistanceGood,
                                      onTap: () {
                                        if (state.isDistanceGood) {
                                          notifier.updateFaceAlignment(
                                            lighting: state.isLightingGood,
                                            centered: state.isCentered,
                                            tooFar: true,
                                            tooClose: false,
                                          );
                                        } else if (state.isFaceTooFar) {
                                          notifier.updateFaceAlignment(
                                            lighting: state.isLightingGood,
                                            centered: state.isCentered,
                                            tooFar: false,
                                            tooClose: true,
                                          );
                                        } else {
                                          notifier.updateFaceAlignment(
                                            lighting: state.isLightingGood,
                                            centered: state.isCentered,
                                            tooFar: false,
                                            tooClose: false,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSmallToggle(
                                      label: state.isCentered
                                          ? 'Centered'
                                          : 'Off-Center',
                                      isActive: state.isCentered,
                                      onTap: () {
                                        notifier.updateFaceAlignment(
                                          lighting: state.isLightingGood,
                                          centered: !state.isCentered,
                                          tooClose: state.isFaceTooClose,
                                          tooFar: state.isFaceTooFar,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              PrimaryButton(
                                label: 'Start Liveness Check',
                                icon: Icons.play_arrow_rounded,
                                backgroundColor: isCompliant
                                    ? AppColors.neonLime
                                    : Colors.white24,
                                textColor: isCompliant
                                    ? const Color(0xFF120826)
                                    : Colors.white54,
                                onPressed: isCompliant
                                    ? () => notifier.startLivenessVerification()
                                    : null,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Confirm Action ✓',
                                  textColor: Colors.white,
                                  borderColor: Colors.white30,
                                  onPressed: state.status ==
                                          BiometricVerificationStatus
                                              .challenging
                                      ? () => notifier.completeCurrentAction()
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Capture & Verify',
                                  backgroundColor: AppColors.primary,
                                  textColor: Colors.white,
                                  onPressed: state.status ==
                                          BiometricVerificationStatus
                                              .challenging
                                      ? () => notifier
                                          .submitBiometricVerification()
                                      : null,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
      ),
    );
  }

  Widget _buildSmallToggle({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.neonLime.withValues(alpha: 0.15)
              : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.neonLime : Colors.white24,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.neonLime : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required bool isOk,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOk
            ? const Color(0xFF1B6A45).withValues(alpha: 0.90)
            : const Color(0xFF8B1D1D).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOk ? const Color(0xFF22C55E) : Colors.redAccent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(BiometricVerificationNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera Access Required',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To perform 3D liveness assurance without saving facial data, Date² requires live camera access. Frames are processed strictly in volatile memory.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Grant Camera Permission',
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              onPressed: () => notifier.requestCameraPermission(),
            ),
          ],
        ),
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
      ..color = borderColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.68,
      height: size.height * 0.72,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceOvalPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
