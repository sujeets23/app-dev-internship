import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final fieldBg = isDark ? AppColors.backgroundDark : AppColors.surfaceWarm;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final accent = AppColors.adaptiveAccent(isDark);
    final onAccent = AppColors.adaptiveOnAccent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & 24/7 Safety',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 24/7 Emergency Hotline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.16)
                    : AppColors.errorLight.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: isDark ? 0.8 : 0.45),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: AppColors.error, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Emergency Trust & Safety',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instant response line for any safety emergencies.',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling 24/7 Trust & Safety Response Line...')),
                      );
                    },
                    child: const Text('Call', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.accent : AppColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqTile(
              context,
              'How does Companion Safety Escrow work?',
              'When you book a platonic companion for public events, your payment is held safely in Date² Escrow. Funds are released to the companion only after you both check in at the public venue via OTP/QR and complete the booking safely.',
            ),
            _buildFaqTile(
              context,
              'Is my facial biometric data saved permanently?',
              'No. We enforce strict zero-persistence privacy. Raw camera frames are analyzed in volatile memory for liveness and Google ML Kit face landmarks. Temporary buffers are completely zeroed out after verification.',
            ),
            _buildFaqTile(
              context,
              'How does Mutual Video Consent work?',
              'Before any live video or audio feed connects, both participants must accept the Mutual Video Call request. An on-device TFLite NSFW classifier scans frames in a background isolate every 2 seconds to protect both members.',
            ),
            _buildFaqTile(
              context,
              'How do I cancel my UPI AutoPay mandate?',
              'Go to Settings > Billing Ledger & UPI Mandates. You can cancel your recurring mandate at any time with a single tap without cancellation fees.',
            ),

            const SizedBox(height: 28),

            // Contact Form
            Text(
              'CONTACT SUPPORT TEAM',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.accent : AppColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Subject or category',
                      hintStyle: TextStyle(color: textMuted),
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 3,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'How can our team help you?',
                      hintStyle: TextStyle(color: textMuted),
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: onAccent,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support ticket submitted. We will reply within 2 hours.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: const Text('Send Message to Support', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        iconColor: AppColors.adaptiveAccent(isDark),
        collapsedIconColor: textSecondary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(answer, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
