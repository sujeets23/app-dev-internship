import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Mutual Match Celebration! 🎉',
        'subtitle': 'You and Aarya liked each other\'s profiles. Start a conversation or propose an AI Date Plan!',
        'time': '10m ago',
        'icon': Icons.favorite,
        'color': AppColors.softPink,
        'unread': true,
      },
      {
        'title': '10% Subko Coffee Partner Voucher Ready ☕',
        'subtitle': 'Your AI Date Plan generated a 10% instant bill discount pass for Bandra West.',
        'time': '1h ago',
        'icon': Icons.confirmation_number_outlined,
        'color': AppColors.neonLime,
        'unread': true,
      },
      {
        'title': 'Safety Escrow Verified 🛡️',
        'subtitle': 'Companion check-in completed. Live GPS protection and emergency SOS active.',
        'time': '1d ago',
        'icon': Icons.security,
        'color': AppColors.electricViolet,
        'unread': false,
      },
      {
        'title': 'Biometric Assurance Badge Activated ✨',
        'subtitle': 'Your face landmarks and liveness checks passed successfully.',
        'time': '2d ago',
        'icon': Icons.verified,
        'color': AppColors.neonLime,
        'unread': false,
      },
    ];

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
          'Notifications',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final unread = n['unread'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unread ? AppColors.surfaceDark : AppColors.cardBackgroundDark,
              borderRadius: BorderRadius.circular(14),
              border: unread
                  ? Border.all(color: (n['color'] as Color).withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: (n['color'] as Color).withValues(alpha: 0.2),
                  child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            n['time'] as String,
                            style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['subtitle'] as String,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
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
