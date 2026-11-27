import 'dart:math';
import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import '../../domain/models/discovery_profile.dart';

/// 60 FPS Gesture-Driven Discovery Card
/// Features verified face scan badge, distance, shared "What they like" tags,
/// smooth drag rotation, like/pass feedback stamps, and interactive photo browsing.
class SwipeableCard extends StatefulWidget {
  final DiscoveryProfile profile;
  final Function(SwipeDirection) onSwiped;
  final VoidCallback onTapInfo;
  final DiscoveryProfile? nextProfile;
  final List<String> userInterests;

  const SwipeableCard({
    super.key,
    required this.profile,
    required this.onSwiped,
    required this.onTapInfo,
    this.nextProfile,
    this.userInterests = const [],
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  int _activePhotoIndex = 0;
  bool _isSwipingOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefetch next profile images for instant rendering without stutter
    if (widget.nextProfile != null &&
        widget.nextProfile!.photoUrls.isNotEmpty) {
      precacheImage(
        NetworkImage(widget.nextProfile!.photoUrls.first),
        context,
      );
    }
    // Prefetch secondary photos of current profile
    for (int i = 1; i < widget.profile.photoUrls.length; i++) {
      precacheImage(NetworkImage(widget.profile.photoUrls[i]), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double dragRatio =
        (_dragOffset.dx / (screenSize.width * 0.45)).clamp(-1.0, 1.0);
    final double rotation = dragRatio * (pi / 14);

    return GestureDetector(
      onPanUpdate: (details) {
        if (_isSwipingOut) return;
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_isSwipingOut) return;
        if (_dragOffset.dx > 110) {
          _triggerSwipe(SwipeDirection.right);
        } else if (_dragOffset.dx < -110) {
          _triggerSwipe(SwipeDirection.left);
        } else if (_dragOffset.dy < -130) {
          _triggerSwipe(SwipeDirection.up);
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo Viewer with Tap Navigation
                  GestureDetector(
                    onTapUp: (details) {
                      final width = context.size?.width ?? screenSize.width;
                      if (details.localPosition.dx > width / 2) {
                        if (_activePhotoIndex + 1 <
                            widget.profile.photoUrls.length) {
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
                        color: AppColors.encreDeep,
                        child: const Center(
                          child: Icon(Icons.person,
                              color: Colors.white24, size: 80),
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
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
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.88),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.38, 0.62, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Profile Card Info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verified Face Scan Badge
                        if (widget.profile.isVerified) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.glanceableCyan
                                  .withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.glanceableCyan,
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.glanceableCyan,
                                  size: 15,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'VERIFIED FACE SCAN',
                                  style: TextStyle(
                                    color: AppColors.glanceableCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Name, Age & Info Button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.profile.name}, ${widget.profile.age}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 27,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              onPressed: widget.onTapInfo,
                            ),
                          ],
                        ),

                        // Subtitle: Pronouns, Gender & Distance
                        Row(
                          children: [
                            Text(
                              '${widget.profile.pronouns} • ${widget.profile.gender}',
                              style: const TextStyle(
                                color: Color(0xFFD6EEF8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.glanceableCyan,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.profile.distanceKm} km away',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // What They Like (Interest Badges with Shared Interest highlight)
                        if (widget.profile.interests.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.profile.interests
                                .take(3)
                                .map((interest) {
                              final isShared = widget.userInterests.contains(interest) ||
                                  interest == widget.profile.interests.first;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isShared
                                      ? AppColors.glanceableCyan.withValues(alpha: 0.28)
                                      : Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isShared
                                        ? AppColors.glanceableCyan
                                        : Colors.white.withValues(alpha: 0.25),
                                    width: isShared ? 1.2 : 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isShared) ...[
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.glanceableCyan,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      interest,
                                      style: TextStyle(
                                        color: isShared
                                            ? AppColors.glanceableCyan
                                            : Colors.white,
                                        fontSize: 11,
                                        fontWeight: isShared
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Biography snippet
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

                  // Top Compatibility Badge
                  Positioned(
                    top: 24,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.encreDeep.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.glanceableCyan,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.glanceableCyan,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.profile.matchPercentage}% VIBE',
                            style: const TextStyle(
                              color: AppColors.glanceableCyan,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Swipe Stamp Feedback (LIKE / NOPE / SUPERLIKE)
                  if (dragRatio > 0.20)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: Transform.rotate(
                        angle: -0.22,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.encreDeep.withValues(alpha: 0.7),
                            border: Border.all(
                              color: AppColors.glanceableCyan,
                              width: 3.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'LIKE',
                            style: TextStyle(
                              color: AppColors.glanceableCyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (dragRatio < -0.20)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Transform.rotate(
                        angle: 0.22,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.encreDeep.withValues(alpha: 0.7),
                            border: Border.all(
                              color: AppColors.error,
                              width: 3.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'PASS',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_dragOffset.dy < -65 && dragRatio.abs() < 0.35)
                    Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.encreDeep.withValues(alpha: 0.85),
                            border: Border.all(
                              color: AppColors.accentTeal,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'SUPER LIKE',
                            style: TextStyle(
                              color: AppColors.accentTeal,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 2.0,
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

  void _triggerSwipe(SwipeDirection direction) {
    setState(() {
      _isSwipingOut = true;
      if (direction == SwipeDirection.right) {
        _dragOffset = const Offset(500, 20);
      } else if (direction == SwipeDirection.left) {
        _dragOffset = const Offset(-500, 20);
      } else {
        _dragOffset = const Offset(0, -600);
      }
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      widget.onSwiped(direction);
    });
  }
}
