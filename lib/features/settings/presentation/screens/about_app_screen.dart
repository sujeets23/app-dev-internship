import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
          'About Date²',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
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
                errorBuilder: (_, __, ___) => const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.neonLime,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.appTagline,
                style: const TextStyle(
                  color: AppColors.softPink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Version 1.0.0 (Production Release)',
                style: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildValueRow(
                      Icons.diversity_1,
                      'Radical Inclusivity',
                      'Express yourself without binary boundaries. Custom pronouns, orientations, and authentic connection intents.',
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildValueRow(
                      Icons.shield_outlined,
                      'Identity Assurance & Zero-Persistence',
                      'ML Kit liveness verification with zero permanent facial image storage.',
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildValueRow(
                      Icons.handshake_outlined,
                      'On-Demand Companion Escrow',
                      'Vetted companions for public events with secure escrow and live GPS tracking.',
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildValueRow(
                      Icons.auto_awesome,
                      'AI Date Planning',
                      'Curated date timelines with partner discount vouchers honoring real budgets.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                '© 2026 Date² Technologies Inc. All rights reserved.',
                style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neonLime, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
