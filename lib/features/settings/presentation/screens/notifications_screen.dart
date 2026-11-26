import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Mutual Match Celebration! 🎉',
        'subtitle': 'You and Aarya liked each other\'s profiles. Start a conversation or propose an AI Date Plan!',
        'time': '10m ago',
        'icon': Icons.favorite,
        'color': isDark ? AppColors.accent : AppColors.primary,
        'unread': true,
      },
      {
        'title': '10% Subko Coffee Partner Voucher Ready ☕',
        'subtitle': 'Your AI Date Plan generated a 10% instant bill discount pass for Bandra West.',
        'time': '1h ago',
        'icon': Icons.confirmation_number_outlined,
        'color': AppColors.accentTeal,
        'unread': true,
      },
      {
        'title': 'Safety Escrow Verified 🛡️',
        'subtitle': 'Companion check-in completed. Live GPS protection and emergency SOS active.',
        'time': '1d ago',
        'icon': Icons.security,
        'color': AppColors.success,
        'unread': false,
      },
      {
        'title': 'Biometric Assurance Badge Activated ✨',
        'subtitle': 'Your face landmarks and liveness checks passed successfully.',
        'time': '2d ago',
        'icon': Icons.verified,
        'color': AppColors.success,
        'unread': false,
      },
    ];

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
          'Notifications',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final unread = n['unread'] as bool;
          final badgeColor = n['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unread
                  ? (isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight)
                  : (isDark ? AppColors.surfaceDark : AppColors.surface),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unread
                    ? (isDark ? AppColors.accent.withValues(alpha: 0.45) : AppColors.glacierBorder)
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isDark
                      ? badgeColor.withValues(alpha: 0.2)
                      : AppColors.surface,
                  child: Icon(n['icon'] as IconData, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              n['title'] as String,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            n['time'] as String,
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['subtitle'] as String,
                        style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
