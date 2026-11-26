import 'dart:math';
import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import '../../domain/models/discovery_profile.dart';

class SwipeableCard extends StatefulWidget {
  final DiscoveryProfile profile;
  final Function(SwipeDirection) onSwiped;
  final VoidCallback onTapInfo;

  const SwipeableCard({
    super.key,
    required this.profile,
    required this.onSwiped,
    required this.onTapInfo,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  Offset _dragOffset = Offset.zero;
  int _activePhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double dragRatio = (_dragOffset.dx / (screenSize.width * 0.5)).clamp(-1.0, 1.0);
    final double rotation = dragRatio * (pi / 16);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_dragOffset.dx > 120) {
          widget.onSwiped(SwipeDirection.right);
        } else if (_dragOffset.dx < -120) {
          widget.onSwiped(SwipeDirection.left);
        } else if (_dragOffset.dy < -140) {
          widget.onSwiped(SwipeDirection.up);
        } else {
          setState(() {
            _dragOffset = Offset.zero;
          });
        }
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo Viewer with Tap Navigation
                  GestureDetector(
                    onTapUp: (details) {
                      final width = context.size?.width ?? screenSize.width;
                      if (details.localPosition.dx > width / 2) {
                        if (_activePhotoIndex + 1 < widget.profile.photoUrls.length) {
                          setState(() => _activePhotoIndex++);
                        }
                      } else {
                        if (_activePhotoIndex > 0) {
                          setState(() => _activePhotoIndex--);
                        }
                      }
                    },
                    child: Image.network(
                      widget.profile.photoUrls.isNotEmpty
                          ? widget.profile.photoUrls[_activePhotoIndex]
                          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceMutedDark,
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white24, size: 80),
                        ),
                      ),
                    ),
                  ),

                  // Photo Indicator Dots at Top
                  if (widget.profile.photoUrls.length > 1)
                    Positioned(
                      top: 14,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: List.generate(
                          widget.profile.photoUrls.length,
                          (index) => Expanded(
                            child: Container(
                              height: 3.5,
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              decoration: BoxDecoration(
                                color: index == _activePhotoIndex
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom Gradient Scrim
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.45, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Profile Card Info
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.profile.name}, ${widget.profile.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            ),
                            if (widget.profile.isVerified) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.accent,
                                size: 24,
                              ),
                            ],
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: widget.onTapInfo,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.profile.pronouns} • ${widget.profile.gender}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.profile.matchPercentage}% MATCH',
                                style: const TextStyle(
                                  color: AppColors.encreDeep,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.profile.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Swipe Stamp Feedback (LIKE / NOPE / SUPERLIKE)
                  if (dragRatio > 0.25)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: Transform.rotate(
                        angle: -0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accent, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'LIKE',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (dragRatio < -0.25)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Transform.rotate(
                        angle: 0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.secondary, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOPE',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
