import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

Future<bool?> showSosConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
      final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
      final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
      final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

      return AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emergency SOS',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to trigger Emergency SOS?',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              '• Your live high-precision GPS coordinates will be instantly dispatched to Date² Safety Operations.\n• Emergency contacts will be notified via SMS.\n• Escrow funds will be immediately placed on safety hold.',
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('TRIGGER EMERGENCY SOS', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
}
