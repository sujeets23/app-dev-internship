import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/billing_ledger_screen.dart';
import 'privacy_settings_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';
import 'legal_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildSectionHeader('SECURITY & VERIFICATION'),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Identity Assurance',
            subtitle: 'Live ML face verification status',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BiometricVerificationScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy & Incognito Shield',
            subtitle: 'Deck isolation & visibility preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('SUBSCRIPTION & PAYMENTS'),
          _buildSettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Subscription Plans',
            subtitle: 'Free, Basic (₹50/mo), Pro (₹100/mo)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPricingScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.receipt_long_outlined,
            title: 'Billing Ledger & UPI Mandates',
            subtitle: 'Transaction receipts & 1-tap AutoPay cancellation',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingLedgerScreen()),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('PREFERENCES'),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Push Notifications',
            subtitle: 'Matches, chat alerts & escrow updates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('SUPPORT & TRUST'),
          _buildSettingsTile(
            icon: Icons.support_agent,
            title: 'Help & 24/7 Safety Hotline',
            subtitle: 'Emergency assistance & FAQs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About Date²',
            subtitle: 'Version 1.0.0 • Inclusive manifesto',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'User safety & platform agreements',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Volatile biometric data zeroing compliance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Log out Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out of Date²'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session signed out successfully.')),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.neonLime,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.neonLime, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }
}
