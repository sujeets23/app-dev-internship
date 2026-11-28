import 'package:flutter/material.dart';
import 'package:inclusive_dating/features/games/presentation/screens/this_or_that_game_screen.dart';
import '../../domain/models/discovery_profile.dart';

/// Unmute "It's a match." Celebration Screen (Case Study UI)
/// Features:
/// - Editorial sand/cream canvas with subtle ambient pastel glows
/// - Overlapping circular avatars with coral connector badge & participant labels ("You" & match name)
/// - Bold display headline: "It's a match."
/// - Subtitle: "Okay, you clearly like each other. Now for the awkward part."
/// - Bottom card with "Skip the 'hey' and break the ice together."
/// - Primary CTA: "Break the ice" (launches "This or That" game)
/// - Secondary CTA: "I'll risk saying hi" (direct to chat)
class MatchCelebrationDialog extends StatelessWidget {
  final SwipeResult match;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;
  final VoidCallback? onBreakTheIce;

  const MatchCelebrationDialog({
    super.key,
    required this.match,
    required this.onSendMessage,
    required this.onKeepSwiping,
    this.onBreakTheIce,
  });

  @override
  Widget build(BuildContext context) {
    const creamBg = Color(0xFFFAF7F2);
    final partnerName = match.profile.name;
    final partnerAvatar = match.profile.photoUrls.isNotEmpty
        ? match.profile.photoUrls.first
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';
    const userAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: creamBg,
      child: Scaffold(
        backgroundColor: creamBg,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Ambient Glow Orbs in Background
              // Neon lime whisper top-left
              Positioned(
                top: 40,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4F870).withValues(alpha: 0.35),
                  ),
                ),
              ),

              // Soft lavender whisper top-right
              Positioned(
                top: 90,
                right: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD3CEFA).withValues(alpha: 0.45),
                  ),
                ),
              ),

              // Bottom warm coral glow orb
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: RadialGradient(
                      center: Alignment.bottomCenter,
                      radius: 1.2,
                      colors: [
                        const Color(0xFFFF7A52).withValues(alpha: 0.75),
                        const Color(0xFFFF956E).withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar with Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 26,
                            color: Color(0xFF141416),
                          ),
                          onPressed: onKeepSwiping,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEBE6DC)),
                          ),
                          child: Text(
                            '${match.profile.matchPercentage}% Compatibility',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF141416),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Overlapping Avatars ("You" and Match Name)
                    Center(
                      child: SizedBox(
                        height: 155,
                        width: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // "You" Avatar (Left)
                            Positioned(
                              left: 10,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 46,
                                      backgroundImage: NetworkImage(userAvatar),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B6A68),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Match Partner Avatar (Right)
                            Positioned(
                              right: 10,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 46,
                                      backgroundImage:
                                          NetworkImage(partnerAvatar),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    partnerName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B6A68),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Center Coral Orange Connector Badge
                            Positioned(
                              top: 26,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5C38),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5C38)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Big Display Title
                    const Text(
                      'It\'s a match.',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Color(0xFF141416),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Okay, you clearly like each other.\nNow for the awkward part.',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: const Color(0xFF141416).withValues(alpha: 0.68),
                      ),
                    ),

                    const Spacer(),

                    // Bottom Floating Warm Card: Break The Ice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7A52).withValues(alpha: 0.16),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Skip the \'hey\' and break the ice together.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF141416),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Primary Button: "Break the ice"
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (onBreakTheIce != null) {
                                  onBreakTheIce!();
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ThisOrThatGameScreen(
                                        matchName: partnerName,
                                        matchAvatar: partnerAvatar,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF141416),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: const Text(
                                'Break the ice',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Secondary Button: "I'll risk saying hi"
                          GestureDetector(
                            onTap: onSendMessage,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'I\'ll risk saying hi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF141416)
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
