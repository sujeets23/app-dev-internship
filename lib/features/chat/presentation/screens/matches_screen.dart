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
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Matches & Chats',
          style: AppTypography.headlineMedium.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.neonLime),
            tooltip: 'Safety & Moderation Center',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🛡️ All messages & calls are protected with AI Safety Shields.'),
                  backgroundColor: AppColors.electricViolet,
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search matched connections...',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
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
                          color: AppColors.neonLime,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_newMatches.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final match = _newMatches[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: 'conv_${match['name']}',
                                participantName: match['name']!,
                                participantAvatar: match['avatar']!,
                                isVerified: true,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.electricViolet,
                                        AppColors.softPink,
                                        AppColors.neonLime,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
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
                                      color: AppColors.neonLime,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.backgroundDark,
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
                              style: const TextStyle(
                                color: Colors.white,
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
                  color: AppColors.textMutedDark,
                  letterSpacing: 1.2,
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
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conv = filtered[index];
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
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                                        color: AppColors.neonLime,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.backgroundDark,
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (conv.isVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: AppColors.neonLime,
                                          size: 16,
                                        ),
                                      ],
                                      const Spacer(),
                                      Text(
                                        _formatTime(conv.lastTimestamp),
                                        style: const TextStyle(
                                          color: AppColors.textMutedDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv.lastMessageText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: conv.unreadCount > 0
                                                ? Colors.white
                                                : AppColors.textMutedDark,
                                            fontWeight: conv.unreadCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (conv.unreadCount > 0)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.neonLime,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${conv.unreadCount}',
                                            style: const TextStyle(
                                              color: Colors.black,
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
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.electricViolet),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${dt.day}/${dt.month}';
  }
}
