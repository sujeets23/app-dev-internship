import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/auth/presentation/screens/login_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/billing_ledger_screen.dart';
import 'privacy_settings_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';
import 'legal_screens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

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
          'Settings',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildSectionHeader('SECURITY & VERIFICATION', isDark),
          _buildSettingsTile(
            context: context,
            icon: Icons.fingerprint,
            title: 'Biometric Identity Assurance',
            subtitle: 'Live ML face verification status',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityCheckIntroScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
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
          _buildSectionHeader('SUBSCRIPTION & PAYMENTS', isDark),
          _buildSettingsTile(
            context: context,
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
            context: context,
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
          _buildSectionHeader('PREFERENCES', isDark),
          _buildSettingsTile(
            context: context,
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
          _buildSectionHeader('SUPPORT & TRUST', isDark),
          _buildSettingsTile(
            context: context,
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
            context: context,
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
            context: context,
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
            context: context,
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
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.7)),
              backgroundColor: isDark
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.errorLight.withValues(alpha: 0.4),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out of Date²', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.accent : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.accent : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: textMuted, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}
