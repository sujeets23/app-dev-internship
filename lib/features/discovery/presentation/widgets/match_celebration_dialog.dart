import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/core/widgets/secondary_button.dart';
import '../../domain/models/discovery_profile.dart';

class MatchCelebrationDialog extends StatelessWidget {
  final SwipeResult match;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;

  const MatchCelebrationDialog({
    super.key,
    required this.match,
    required this.onSendMessage,
    required this.onKeepSwiping,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Match Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'IT\'S A MUTUAL MATCH!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profile Pictures Heart Overlay
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 40,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.accent,
                      child: const CircleAvatar(
                        radius: 43,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.secondary,
                      child: CircleAvatar(
                        radius: 43,
                        backgroundImage: NetworkImage(
                          match.profile.photoUrls.isNotEmpty
                              ? match.profile.photoUrls.first
                              : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'You and ${match.profile.name} liked each other',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${match.profile.matchPercentage}% Compatibility based on shared values',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton(
              label: 'Send a Message',
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              icon: Icons.chat_bubble_rounded,
              onPressed: onSendMessage,
            ),

            const SizedBox(height: 12),

            SecondaryButton(
              label: 'Keep Swiping',
              textColor: Colors.white,
              borderColor: Colors.white24,
              onPressed: onKeepSwiping,
            ),
          ],
        ),
      ),
    );
  }
}
