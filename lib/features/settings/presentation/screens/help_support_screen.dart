import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & 24/7 Safety',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
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
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.redAccent, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '24/7 Emergency Trust & Safety',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Instant response line for any safety emergencies.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling 24/7 Trust & Safety Response Line...')),
                      );
                    },
                    child: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqTile(
              'How does Companion Safety Escrow work?',
              'When you book a platonic companion for public events, your payment is held safely in Date² Escrow. Funds are released to the companion only after you both check in at the public venue via OTP/QR and complete the booking safely.',
            ),
            _buildFaqTile(
              'Is my facial biometric data saved permanently?',
              'No. We enforce strict zero-persistence privacy. Raw camera frames are analyzed in volatile memory for liveness and Google ML Kit face landmarks. Temporary buffers are completely zeroed out after verification.',
            ),
            _buildFaqTile(
              'How does Mutual Video Consent work?',
              'Before any live video or audio feed connects, both participants must accept the Mutual Video Call request. An on-device TFLite NSFW classifier scans frames in a background isolate every 2 seconds to protect both members.',
            ),
            _buildFaqTile(
              'How do I cancel my UPI AutoPay mandate?',
              'Go to Settings > Billing Ledger & UPI Mandates. You can cancel your recurring mandate at any time with a single tap without cancellation fees.',
            ),

            const SizedBox(height: 28),

            // Contact Form
            Text(
              'CONTACT SUPPORT TEAM',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Subject or category',
                      hintStyle: const TextStyle(color: AppColors.textMutedDark),
                      filled: true,
                      fillColor: AppColors.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'How can our team help you?',
                      hintStyle: const TextStyle(color: AppColors.textMutedDark),
                      filled: true,
                      fillColor: AppColors.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support ticket submitted. We will reply within 2 hours.'),
                          backgroundColor: AppColors.electricViolet,
                        ),
                      );
                    },
                    child: const Text('Send Message to Support'),
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

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        iconColor: AppColors.neonLime,
        collapsedIconColor: Colors.white54,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(answer, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
