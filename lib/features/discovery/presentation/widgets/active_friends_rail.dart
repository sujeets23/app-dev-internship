import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';
import 'package:inclusive_dating/features/date_planner/presentation/screens/date_planner_screen.dart';
import 'package:inclusive_dating/features/games/presentation/screens/two_truths_game_screen.dart';
import '../../domain/models/active_friend.dart';

/// Interactive Active Friends Section on Home Page
/// Displays real-time online connections, live activity statuses, and quick engagement controls.
class ActiveFriendsRail extends ConsumerStatefulWidget {
  const ActiveFriendsRail({super.key});

  @override
  ConsumerState<ActiveFriendsRail> createState() => _ActiveFriendsRailState();
}

class _ActiveFriendsRailState extends ConsumerState<ActiveFriendsRail> {
  bool _onlyOnline = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const allFriends = ActiveFriend.mockFriends;
    final displayedFriends = _onlyOnline
        ? allFriends.where((f) => f.isOnline).toList()
        : allFriends;
    final onlineCount = allFriends.where((f) => f.isOnline).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderWarm,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00E676),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FRIENDS & ACTIVE CONNECTIONS',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$onlineCount Online',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() => _onlyOnline = !_onlyOnline);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      _onlyOnline ? 'Show All' : 'Online Only',
                      style: const TextStyle(
                        color: AppColors.glanceableCyanDeep,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Friends Scroll
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: displayedFriends.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final friend = displayedFriends[index];
                return _buildFriendItem(context, friend, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(
      BuildContext context, ActiveFriend friend, bool isDark) {
    final ringColor = friend.isOnline
        ? const Color(0xFF00E676)
        : (isDark ? AppColors.borderDark : AppColors.borderWarm);

    return InkWell(
      onTap: () => _showFriendQuickSheet(context, friend, isDark),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with glowing online status ring
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: friend.isOnline ? 2.2 : 1.2,
                    ),
                    boxShadow: friend.isOnline
                        ? [
                            BoxShadow(
                              color: ringColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      friend.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => CircleAvatar(
                        backgroundColor: AppColors.encreElevated,
                        child: Text(friend.name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                // Tiny live green dot badge
                if (friend.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),

            // Friend Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    friend.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (friend.isVerified) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.glanceableCyan,
                    size: 11,
                  ),
                ],
              ],
            ),

            // Live Activity Snippet
            Text(
              friend.isOnline ? friend.activityStatus : friend.lastActive,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: friend.isOnline ? FontWeight.w600 : FontWeight.w500,
                color: friend.isOnline
                    ? (isDark ? AppColors.glanceableCyan : AppColors.accentInk)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive Active Friend Quick Engagement Sheet
  void _showFriendQuickSheet(
      BuildContext context, ActiveFriend friend, bool isDark) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile Header
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(friend.avatarUrl),
                      ),
                      if (friend.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: surfaceColor,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              friend.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (friend.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.glanceableCyan,
                                size: 16,
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.glanceableCyan
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${friend.compatibilityPct}% Match',
                                style: const TextStyle(
                                  color: AppColors.glanceableCyan,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              friend.isOnline
                                  ? Icons.fiber_manual_record
                                  : Icons.access_time_rounded,
                              size: 11,
                              color: friend.isOnline
                                  ? const Color(0xFF00E676)
                                  : mutedColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              friend.isOnline
                                  ? 'Active now'
                                  : 'Active ${friend.lastActive}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: friend.isOnline
                                    ? const Color(0xFF00E676)
                                    : mutedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Live Activity Pill Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.encreElevated
                      : AppColors.glacierLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.glanceableCyan.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: AppColors.glanceableCyan, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE ACTIVITY',
                            style: TextStyle(
                              fontSize: 9.5,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.glanceableCyan
                                  : AppColors.encreDeep,
                            ),
                          ),
                          Text(
                            friend.activityStatus,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Shared Interests Badges
              if (friend.sharedInterests.isNotEmpty) ...[
                Text(
                  'SHARED INTERESTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: friend.sharedInterests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.glanceableCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              AppColors.glanceableCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.glanceableCyan, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            interest,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.glanceableCyan
                                  : AppColors.encreDeep,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 4 Quick Engagement Action Buttons
              Row(
                children: [
                  // Action 1: Open Chat
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.glanceableCyan,
                        foregroundColor: AppColors.encreDeep,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: const Text(
                        'Open Chat',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        ref.read(chatServiceProvider).addMatch(
                              name: friend.name,
                              avatar: friend.avatarUrl,
                              matchId: friend.id,
                              isVerified: friend.isVerified,
                            );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: friend.conversationId,
                              participantName: friend.name,
                              participantAvatar: friend.avatarUrl,
                              isVerified: friend.isVerified,
                              sharedInterests: friend.sharedInterests,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action 2: Wave Hello
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(
                            color: AppColors.adaptiveBorder(isDark)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Text('👋', style: TextStyle(fontSize: 14)),
                      label: const Text(
                        'Wave Hello',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        // Send wave message
                        ref
                            .read(conversationMessagesProvider(
                                    friend.conversationId)
                                .notifier)
                            .sendMessage(
                                '👋 Hey ${friend.name}! Sent a friendly wave from Home.');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Text('👋',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text('Waved hello to ${friend.name}!'),
                              ],
                            ),
                            backgroundColor: AppColors.encreDeep,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  // Action 3: Challenge in 2 Truths & a Lie
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(
                            color: AppColors.adaptiveBorder(isDark)),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.videogame_asset_rounded,
                          size: 15, color: AppColors.glanceableCyan),
                      label: const Text(
                        'Challenge in Game',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TwoTruthsGameScreen(matchName: friend.name),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action 4: Propose Date Plan
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(
                            color: AppColors.adaptiveBorder(isDark)),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.date_range_rounded,
                          size: 15, color: AppColors.accentTeal),
                      label: const Text(
                        'Plan Date',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DatePlannerScreen(
                              targetConversationId: friend.conversationId,
                              matchName: friend.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
