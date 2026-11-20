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
          'Privacy & Shields',
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
          // Incognito Shield Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: incognitoOn ? AppColors.neonLime : Colors.white10,
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
                      color: incognitoOn ? AppColors.neonLime : Colors.white54,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Incognito Privacy Shield',
                        style: TextStyle(
                          color: incognitoOn ? AppColors.neonLime : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Switch(
                      value: incognitoOn,
                      activeColor: AppColors.neonLime,
                      onChanged: (val) {
                        ref.read(incognitoShieldProvider.notifier).set(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'When Incognito Shield is active, your profile is hidden from the public discovery pool and only visible to accounts that you explicitly like. Backend discovery isolation is active.',
                  style: TextStyle(color: AppColors.textMutedDark, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Volatile Biometric Guarantee Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.memory, color: AppColors.softPink),
                    SizedBox(width: 10),
                    Text(
                      'Volatile Biometric Memory Guarantee',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Biometric camera frames are processed strictly in volatile RAM.\n• Never permanently stored on disk or uploaded to persistent cloud object storage.\n• Image EXIF and device metadata are stripped before any transmission.\n• Image buffers are immediately wiped and zeroed out upon verification response.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Video Stream Moderation Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REAL-TIME VIDEO STREAM SAFETY',
                  style: TextStyle(
                    color: AppColors.neonLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Date² runs on-device TensorFlow Lite NSFW classification every 2 seconds during active video calls. Connections with detected violations are terminated instantly to safeguard all members.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
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
