import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/discovery/presentation/providers/discovery_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoOn = ref.watch(incognitoShieldProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final accent = AppColors.adaptiveAccent(isDark);

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
          'Privacy & Shields',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Incognito Shield Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: incognitoOn
                  ? (isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight)
                  : cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: incognitoOn
                    ? (isDark ? AppColors.accent : AppColors.glacierBorder)
                    : border,
                width: incognitoOn ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      incognitoOn ? Icons.shield_moon : Icons.shield_outlined,
                      color: incognitoOn ? accent : textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Incognito Privacy Shield',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Switch(
                      value: incognitoOn,
                      activeColor: isDark ? AppColors.accent : AppColors.primary,
                      onChanged: (val) {
                        ref.read(incognitoShieldProvider.notifier).set(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'When Incognito Shield is active, your profile is hidden from the public discovery pool and only visible to accounts that you explicitly like. Backend discovery isolation is active.',
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Volatile Biometric Guarantee Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.memory,
                      color: isDark ? AppColors.accent : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Volatile Biometric Memory Guarantee',
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• Biometric camera frames are processed strictly in volatile RAM.\n• Never permanently stored on disk or uploaded to persistent cloud object storage.\n• Image EXIF and device metadata are stripped before any transmission.\n• Image buffers are immediately wiped and zeroed out upon verification response.',
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Video Stream Moderation Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REAL-TIME VIDEO STREAM SAFETY',
                  style: TextStyle(
                    color: isDark ? AppColors.accent : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Date² runs on-device TensorFlow Lite NSFW classification every 2 seconds during active video calls. Connections with detected violations are terminated instantly to safeguard all members.',
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
