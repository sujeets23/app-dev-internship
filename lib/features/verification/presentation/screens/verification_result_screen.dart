import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import '../../domain/models/biometric_verification_model.dart';
import 'biometric_verification_screen.dart';
import 'government_id_verification_screen.dart';

class VerificationResultScreen extends ConsumerWidget {
  final BiometricVerificationResult? result;
  final bool isCompanionFlow;

  const VerificationResultScreen({
    super.key,
    required this.result,
    this.isCompanionFlow = false,
  });

  FaceVerificationStatus get _effectiveStatus {
    if (result == null) return FaceVerificationStatus.pending;
    if (result!.isSuccess) return FaceVerificationStatus.verified;
    return result!.resultStatus;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _effectiveStatus;
    final bool isSuccess = status == FaceVerificationStatus.verified;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final Color badgeColor = switch (status) {
      FaceVerificationStatus.verified => AppColors.success,
      FaceVerificationStatus.pending ||
      FaceVerificationStatus.processing =>
        AppColors.adaptiveAccent(isDark),
      FaceVerificationStatus.retryRequired => AppColors.warning,
      FaceVerificationStatus.rejected ||
      FaceVerificationStatus.failed =>
        AppColors.error,
    };

    final IconData badgeIcon = switch (status) {
      FaceVerificationStatus.verified => Icons.verified_user_rounded,
      FaceVerificationStatus.pending => Icons.hourglass_top_rounded,
      FaceVerificationStatus.processing => Icons.sync_rounded,
      FaceVerificationStatus.retryRequired => Icons.refresh_rounded,
      FaceVerificationStatus.rejected ||
      FaceVerificationStatus.failed =>
        Icons.gpp_bad_rounded,
    };

    final String headline = switch (status) {
      FaceVerificationStatus.verified => 'Liveness Check Passed (Demo)',
      FaceVerificationStatus.pending => 'Verification Pending',
      FaceVerificationStatus.processing => 'Processing Verification...',
      FaceVerificationStatus.retryRequired => 'Retry Required',
      FaceVerificationStatus.rejected => 'Verification Rejected',
      FaceVerificationStatus.failed => 'Verification Incomplete',
    };

    final screen = Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeColor,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      badgeIcon,
                      color: badgeColor,
                      size: 54,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  result?.message ?? status.defaultDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                if (result?.isDemoResult ?? true) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveHighlightBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.glacierBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.adaptiveAccent(isDark), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isSuccess
                                ? 'Demo Liveness Passed: Active camera liveness does NOT verify legal identity alone. Complete Government ID verification next and connect backend 512-d embedding matching for production.'
                                : 'Demo Verification Status: Connect backend biometric endpoints to evaluate live server scores.',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.glacierInk,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isSuccess && result?.verificationId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceMutedDark
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security,
                                color: AppColors.adaptiveAccent(isDark),
                                size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Proof ID: ${result!.verificationId}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.adaptiveAccent(isDark),
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (result?.cryptographicProofHash != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            result!.cryptographicProofHash!,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiary,
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceMutedDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_rounded,
                          color: secondaryTextColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Biometric Privacy: Temporary camera files are deleted and raw frame buffers are cleared after evaluation. No selfies are saved permanently.',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (isSuccess && !isCompanionFlow)
                  PrimaryButton(
                    label: 'Proceed to Government ID',
                    icon: Icons.badge_outlined,
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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BiometricVerificationScreen(
                            isCompanionFlow: isCompanionFlow,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Do This Later',
                    textColor: primaryTextColor,
                    borderColor:
                        isDark ? AppColors.borderDark : AppColors.border,
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );

    if (isCompanionFlow) return screen;
    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.faceResult,
      child: screen,
    );
  }
}
