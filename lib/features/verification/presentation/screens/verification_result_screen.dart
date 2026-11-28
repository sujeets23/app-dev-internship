import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
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
    final bool isRetry = status == FaceVerificationStatus.retryRequired ||
        status == FaceVerificationStatus.failed ||
        status == FaceVerificationStatus.rejected;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.figmaInk;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.figmaInk.withValues(alpha: 0.72);

    final Color badgeColor = switch (status) {
      FaceVerificationStatus.verified => AppColors.figmaSuccess,
      FaceVerificationStatus.pending ||
      FaceVerificationStatus.processing =>
        AppColors.figmaPrimary,
      FaceVerificationStatus.retryRequired => const Color(0xFFE67E22),
      FaceVerificationStatus.rejected ||
      FaceVerificationStatus.failed =>
        AppColors.figmaError,
    };

    final IconData badgeIcon = switch (status) {
      FaceVerificationStatus.verified => Icons.check_circle_rounded,
      FaceVerificationStatus.pending => Icons.hourglass_top_rounded,
      FaceVerificationStatus.processing => Icons.sync_rounded,
      FaceVerificationStatus.retryRequired => Icons.refresh_rounded,
      FaceVerificationStatus.rejected ||
      FaceVerificationStatus.failed =>
        Icons.info_outline_rounded,
    };

    final String headline = switch (status) {
      FaceVerificationStatus.verified => 'Face check\ncomplete.',
      FaceVerificationStatus.pending => 'Verification Pending',
      FaceVerificationStatus.processing => 'Processing Verification...',
      FaceVerificationStatus.retryRequired => 'Let\'s try that\nagain.',
      FaceVerificationStatus.rejected => 'Verification Rejected',
      FaceVerificationStatus.failed => 'Verification Incomplete',
    };

    final String eyebrow = isSuccess
        ? 'IDENTITY ASSURED'
        : (isRetry ? 'QUICK ADJUSTMENT' : 'ONE QUICK MOMENT');

    final screen = Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.figmaCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.figmaInk,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'FACE CHECK',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontFamilyFallback: AppTypography.sansFallbacks,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.figmaInk.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Squircle Icon Container
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.figmaSuccess.withValues(alpha: 0.12)
                        : (isRetry
                            ? AppColors.figmaErrorBg
                            : AppColors.figmaSoft),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      badgeIcon,
                      color: badgeColor,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Eyebrow
                Text(
                  eyebrow,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontFamilyFallback: AppTypography.sansFallbacks,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isSuccess
                        ? AppColors.figmaSuccess
                        : (isRetry
                            ? AppColors.figmaError
                            : AppColors.figmaPrimary),
                  ),
                ),

                const SizedBox(height: 6),

                // Headline
                Text(
                  headline,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontFamilyFallback: AppTypography.sansFallbacks,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.15,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Dynamic/Expected Status Message (Guarantees test finder match)
                Text(
                  result?.message ?? status.defaultDescription,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontFamilyFallback: AppTypography.sansFallbacks,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Reassurance / Guidance Card
                if (isSuccess) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.figmaSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 18,
                              color: AppColors.figmaSuccess,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Biometric verification passed',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.figmaInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your live selfie confirmed real presence. In production, this matches your encrypted profile embeddings.',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            height: 1.4,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.figmaInk.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isRetry) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.figmaErrorBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.figmaError.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: AppColors.figmaError,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips for a successful face scan',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.figmaInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Ensure bright, even lighting across your face\n• Keep your device steady at eye level\n• Hold your entire face inside the oval frame',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            height: 1.45,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.figmaInk.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isSuccess && result?.verificationId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.figmaInk.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.security,
                          color: AppColors.figmaPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Proof ID: ${result!.verificationId}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.figmaPrimary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                if (isSuccess && !isCompanionFlow)
                  PrimaryButton(
                    label: 'Proceed to Government ID',
                    icon: Icons.arrow_forward_rounded,
                    backgroundColor: AppColors.figmaPrimary,
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
                    backgroundColor: AppColors.figmaPrimary,
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

                // Footer Privacy Note
                Center(
                  child: Text(
                    'Biometric data is processed locally and discarded immediately.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.figmaInk.withValues(alpha: 0.45),
                    ),
                  ),
                ),
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
