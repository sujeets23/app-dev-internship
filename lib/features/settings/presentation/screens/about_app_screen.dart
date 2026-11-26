import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

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
          'About Date²',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 60,
                color: textPrimary,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (context, error, stackTrace) => Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.adaptiveAccent(isDark),
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: isDark ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Version 1.0.0 (Production Release)',
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    _buildValueRow(
                      context,
                      Icons.diversity_1,
                      'Radical Inclusivity',
                      'Express yourself without binary boundaries. Custom pronouns, orientations, and authentic connection intents.',
                    ),
                    Divider(color: border, height: 24),
                    _buildValueRow(
                      context,
                      Icons.shield_outlined,
                      'Identity Assurance & Zero-Persistence',
                      'ML Kit liveness verification with zero permanent facial image storage.',
                    ),
                    Divider(color: border, height: 24),
                    _buildValueRow(
                      context,
                      Icons.handshake_outlined,
                      'On-Demand Companion Escrow',
                      'Vetted companions for public events with secure escrow and live GPS tracking.',
                    ),
                    Divider(color: border, height: 24),
                    _buildValueRow(
                      context,
                      Icons.auto_awesome,
                      'AI Date Planning',
                      'Curated date timelines with partner discount vouchers honoring real budgets.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Text(
                '© 2026 Date² Technologies Inc. All rights reserved.',
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueRow(BuildContext context, IconData icon, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.adaptiveAccent(isDark), size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
