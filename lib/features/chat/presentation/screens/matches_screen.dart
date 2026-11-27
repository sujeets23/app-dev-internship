import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock list of active mutual matches
  final List<Map<String, String>> _newMatches = [
    {
      'id': 'match_1',
      'name': 'Aarya',
      'age': '24',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      'isNew': 'true',
    },
    {
      'id': 'match_2',
      'name': 'Zayan',
      'age': '26',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'isNew': 'true',
    },
    {
      'id': 'match_3',
      'name': 'Tara',
      'age': '23',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'isNew': 'false',
    },
    {
      'id': 'match_4',
      'name': 'Rohan',
      'age': '27',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'isNew': 'false',
    },
    {
      'id': 'match_5',
      'name': 'Mia',
      'age': '25',
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'isNew': 'true',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Matches & Chats',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shield_outlined,
              color: accent,
            ),
            tooltip: 'Safety & Moderation Center',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🛡️ All messages & calls are protected with AI Safety Shields.'),
                  backgroundColor: isDark ? AppColors.encreElevated : AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search matched connections...',
                  hintStyle: TextStyle(color: mutedTextColor),
                  prefixIcon: Icon(Icons.search, color: mutedTextColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: mutedTextColor, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: cardBg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.adaptiveBorder(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: accent,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // New Matches Tray
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'NEW MATCHES',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_newMatches.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.encreDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _newMatches.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final match = _newMatches[index];
                      return GestureDetector(
                        onTap: () {
                          final resolvedId = ref
                              .read(chatServiceProvider)
                              .resolveConversationId(match['name']!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: resolvedId,
                                participantName: match['name']!,
                                participantAvatar: match['avatar']!,
                                isVerified: true,
                              ),
                            ),
                          ).then((_) => ref.invalidate(conversationsProvider));
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.cyanPrismGradient,
                                  ),
                                  child: CircleAvatar(
                                    radius: 34,
                                    backgroundImage: NetworkImage(match['avatar']!),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: bgColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              match['name']!,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Messages Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'MESSAGES',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // Conversations List
          conversationsAsync.when(
            data: (conversations) {
              final filtered = conversations.where((c) {
                return c.participantName.toLowerCase().contains(_searchQuery) ||
                    c.lastMessageText.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: mutedTextColor),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conv = filtered[index];
                    final isTyping = ref
                        .watch(chatTypingStatusProvider(conv.id))
                        .maybeWhen(data: (v) => v, orElse: () => false);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conv.id,
                              participantName: conv.participantName,
                              participantAvatar: conv.participantAvatar,
                              isVerified: conv.isVerified,
                            ),
                          ),
                        ).then((_) => ref.invalidate(conversationsProvider));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.adaptiveBorder(isDark),
                          ),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(conv.participantAvatar),
                                ),
                                if (conv.isOnline)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardBg,
                                          width: 2,
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
                                        conv.participantName,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (conv.isVerified) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          color: accent,
                                          size: 16,
                                        ),
                                      ],
                                      const Spacer(),
                                      Text(
                                        _formatTime(conv.lastTimestamp),
                                        style: TextStyle(
                                          color: mutedTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isTyping
                                              ? '${conv.participantName} is typing...'
                                              : conv.lastMessageText,
                                          style: TextStyle(
                                            color: isTyping
                                                ? AppColors.accentTeal
                                                : (conv.unreadCount > 0
                                                    ? textColor
                                                    : mutedTextColor),
                                            fontStyle: isTyping
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            fontWeight: conv.unreadCount > 0 || isTyping
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (conv.unreadCount > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${conv.unreadCount}',
                                            style: TextStyle(
                                              color: AppColors.adaptiveOnAccent(isDark),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: accent)),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text('Failed to load chats: $err', style: TextStyle(color: mutedTextColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
