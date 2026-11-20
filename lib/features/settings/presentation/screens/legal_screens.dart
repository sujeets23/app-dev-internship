import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Date² Terms of Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Last Updated: November 2026', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
            SizedBox(height: 16),
            Text(
              '1. Community Safety & Zero Tolerance\nDate² enforces strict zero-tolerance policies against harassment, discrimination, or hate speech. Content violating community safety guidelines will be automatically flagged and removed.\n\n'
              '2. Mutual Video Consent\nMembers agree that live video audio feeds require mutual consent prior to connection. Video frames are scanned every 2 seconds by on-device TFLite models to detect non-consensual explicit conduct.\n\n'
              '3. Platonic Companion Escrow\nAll companion bookings made via the Date² Companion Marketplace are strictly platonic and restricted to authorized public venues. Users must check in using OTP/QR verification and adhere to safety GPS geofencing.\n\n'
              '4. Subscriptions & UPI AutoPay\nUsers may subscribe to Basic or Pro monthly tiers via Razorpay and authorized UPI intents. Recurring mandates may be cancelled at any time through the Billing Ledger.\n\n'
              '5. Account Verification\nMembers agree to complete identity assurance verification using live camera liveness actions. Spoofed or fraudulent accounts will be permanently suspended.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Date² Biometric & Data Privacy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Effective Date: November 2026', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
            SizedBox(height: 16),
            Text(
              '1. Volatile Biometric Data Processing\nWe process all biometric verification images strictly in volatile memory. Raw biometric selfies are never permanently stored on local file systems or uploaded to persistent cloud object storage. Image EXIF and location metadata are stripped before any transmission, and temporary memory buffers are zeroed out immediately upon server verification.\n\n'
              '2. Incognito Privacy Shield\nUsers who activate the Incognito Privacy Shield have their profiles isolated from general discovery decks. Your card will only be shown to candidates you have affirmatively liked.\n\n'
              '3. GPS Tracking for Companion Escrow\nLive GPS location tracking operates ONLY during authorized active companion bookings with explicit user permission. Location data is encrypted in transit and purged upon booking completion.\n\n'
              '4. Payment Credentials Security\nPayments are processed via PCI-DSS certified gateways (Razorpay). Date² never stores UPI PINs, credit card CVVs, or sensitive banking credentials.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
