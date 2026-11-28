import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/matches_screen.dart';

/// Interactive Social & Community Feed Screen (Matching Case Study UI)
/// Features:
/// 1. Top Bar: Brand Wordmark (DaTe²), Search 🔍, Stories/Gallery 🖼️ with red dot, Chat 💬 with "9+" badge.
/// 2. Stories / Active Statuses Rail:
///    - "Your Story" with pink/coral gradient "+" badge.
///    - "alexinspo" with vibrant red ring + "LIVE" top pill badge.
///    - "sofiacreates" with vibrant spring-green active ring.
///    - "nicoletriller" with teal/cyan active ring.
///    - More active friend circles.
/// 3. Sub-Navigation Tabs: "For you" (with solid black underline indicator), "Following", "Clips".
/// 4. Community Feed Card:
///    - Header with user avatar, username ("alexinspo"), "Suggested for you", black pill "Follow" button & "⋮".
///    - Caption text with blue hashtags (#napoleonhill #goals #inspiration #motivation #date2) & timestamp.
///    - Large full-width lifestyle media photo (rooftop sunset party with friends & drinks).
///    - Engagement stats row: 30.2k Likes, 220 Comments, 3 Shares, Bookmark & Reply.
class HomeFeedScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeFeedScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  int _selectedSubTab = 0; // 0: For you, 1: Following, 2: Clips

  // Interactive like states for feed posts
  final Set<String> _likedPostIds = {};
  final Set<String> _followedUserIds = {};

  final List<_StoryItem> _stories = const [
    _StoryItem(
      id: 'story_self',
      username: 'Your Story',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      isCurrentUser: true,
    ),
    _StoryItem(
      id: 'story_alex',
      username: 'alexinspo',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      isLive: true,
      ringColor: Color(0xFFFF2D55),
    ),
    _StoryItem(
      id: 'story_sofia',
      username: 'sofiacreates',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      ringColor: Color(0xFF34C759),
    ),
    _StoryItem(
      id: 'story_nicole',
      username: 'nicoletriller',
      avatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      ringColor: Color(0xFF30D5C8),
    ),
    _StoryItem(
      id: 'story_aarya',
      username: 'aarya_vibe',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      ringColor: Color(0xFFFF9500),
    ),
    _StoryItem(
      id: 'story_zayan',
      username: 'zayan_music',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      ringColor: Color(0xFFAF52DE),
    ),
  ];

  final List<_FeedPost> _posts = const [
    _FeedPost(
      id: 'post_1',
      userId: 'alexinspo',
      userName: 'alexinspo',
      userAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      subtitle: 'Suggested for you',
      caption:
          'In 2026, there will be a variety of new fashion trends coming your wayand...',
      hashtags: [
        '#napoleonhill',
        '#goals',
        '#inspiration',
        '#motivation',
        '#date2'
      ],
      timeAgo: '1 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=900', // Rooftop sunset gathering with friends & wine
      likesCount: '30.2k',
      commentsCount: '220',
      sharesCount: '3',
    ),
    _FeedPost(
      id: 'post_2',
      userId: 'sofiacreates',
      userName: 'sofiacreates',
      userAvatar:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      subtitle: 'Active now • Koramangala',
      caption:
          'Golden hour dates hit different when you find someone who loves artisanal gelato and vinyl records as much as you do 🍨✨',
      hashtags: [
        '#dateplanner',
        '#gelatolovers',
        '#goldenhour',
        '#weekendvibes'
      ],
      timeAgo: '3 hours ago',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=900', // Cozy cafe date
      likesCount: '14.8k',
      commentsCount: '94',
      sharesCount: '12',
    ),
    _FeedPost(
      id: 'post_3',
      userId: 'nicoletriller',
      userName: 'nicoletriller',
      userAvatar:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      subtitle: 'Verified • Bandra',
      caption:
          'Weekend getaway checklist: vintage sunglasses, indie roadtrip playlist, and good company on the mountain pass 🏔️🚗',
      hashtags: ['#mountains', '#roadtrip', '#escape', '#vibeharmony'],
      timeAgo: '5 hours ago',
      imageUrl:
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=900', // Scenic road trip adventure
      likesCount: '22.1k',
      commentsCount: '156',
      sharesCount: '28',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const canvasBg = Colors.white;

    return Scaffold(
      backgroundColor: canvasBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. TOP APP BAR
            SliverToBoxAdapter(
              child: _buildTopAppBar(context),
            ),

            // 2. STORIES / ACTIVE USERS RAIL
            SliverToBoxAdapter(
              child: _buildStoriesRail(),
            ),

            // 3. SUB-NAVIGATION TABS ("For you", "Following", "Clips")
            SliverToBoxAdapter(
              child: _buildSubTabs(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),

            // 4. FEED POSTS LIST
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _posts[index];
                  return _buildFeedPostCard(post);
                },
                childCount: _posts.length,
              ),
            ),

            // Extra space at bottom to float above bottom navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP APP BAR (Logo, Search, Gallery, Chat "9+")
  // ===========================================================================
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo Wordmark (Clean DaTe²)
          const Date2LogoWidget(
            height: 38,
            showContainer: false,
          ),

          // Action Icons Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Icon 🔍
              IconButton(
                onPressed: () {
                  _showSearchDialog(context);
                },
                icon: const Icon(
                  Icons.search_rounded,
                  size: 26,
                  color: Color(0xFF141416),
                ),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 14),

              // Photos / Stories Icon 🖼️ with unread notification dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      _showMomentsBottomSheet(context);
                    },
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      size: 24,
                      color: Color(0xFF141416),
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2D55),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Chat Bubble 💬 with "9+" Red Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(3); // Jump to Chat Tab
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MatchesScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 25,
                      color: Color(0xFF141416),
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  Positioned(
                    top: -1,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Text(
                        '9+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. STORIES / ACTIVE USERS RAIL
  // ===========================================================================
  Widget _buildStoriesRail() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _stories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final story = _stories[index];
          return _buildStoryAvatar(story);
        },
      ),
    );
  }

  Widget _buildStoryAvatar(_StoryItem story) {
    return GestureDetector(
      onTap: () {
        _showStoryViewer(context, story);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 66,
            height: 66,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Story Ring
                if (!story.isCurrentUser)
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: story.ringColor ?? const Color(0xFF30D5C8),
                        width: 2.5,
                      ),
                    ),
                  ),

                // Avatar Image
                CircleAvatar(
                  radius: 29,
                  backgroundColor: const Color(0xFFEDE8E0),
                  backgroundImage: NetworkImage(story.avatarUrl),
                ),

                // "Your Story" Plus Badge
                if (story.isCurrentUser)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3366), Color(0xFFFF6644)],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // "LIVE" Badge for Alexinspo
                if (story.isLive)
                  Positioned(
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2D55), Color(0xFFFF5252)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2D55).withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Username Label
          SizedBox(
            width: 72,
            child: Text(
              story.username,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF141416),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. SUB-NAVIGATION TABS ("For you", "Following", "Clips")
  // ===========================================================================
  Widget _buildSubTabs() {
    final tabs = ['For you', 'Following', 'Clips'];

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 4),
      child: Column(
        children: [
          Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedSubTab == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSubTab = index);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 32, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF141416)
                              : const Color(0xFF8E8E93),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Active Underline Indicator Bar
                      if (isSelected)
                        Container(
                          width: 32,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141416),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 3),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Divider(height: 1, color: Color(0xFFF0ECE4)),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. COMMUNITY FEED POST CARD
  // ===========================================================================
  Widget _buildFeedPostCard(_FeedPost post) {
    final isLiked = _likedPostIds.contains(post.id);
    final isFollowed = _followedUserIds.contains(post.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header: User info + Follow button + More options ⋮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                // Avatar with story ring
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF2D55), Color(0xFFFF9500)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 17.5,
                      backgroundImage: NetworkImage(post.userAvatar),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF141416),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        post.subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // "Follow" Pill Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFollowed) {
                        _followedUserIds.remove(post.userId);
                      } else {
                        _followedUserIds.add(post.userId);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: isFollowed
                          ? const Color(0xFFF2EFE9)
                          : const Color(0xFF141416),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFollowed ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isFollowed
                            ? const Color(0xFF141416)
                            : Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // More Options ⋮
                IconButton(
                  onPressed: () => _showPostOptions(context, post),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Color(0xFF8E8E93),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Caption & Hashtags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.caption,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF141416),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: post.hashtags.map((tag) {
                    return Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF007AFF),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 5),
                Text(
                  post.timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Full-Width Media Image
          GestureDetector(
            onDoubleTap: () {
              setState(() => _likedPostIds.add(post.id));
            },
            child: Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Engagement Bar (Likes, Comments, Shares, Reply)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                // Heart Like
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isLiked) {
                        _likedPostIds.remove(post.id);
                      } else {
                        _likedPostIds.add(post.id);
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: isLiked
                            ? const Color(0xFFFF2D55)
                            : const Color(0xFF141416),
                        size: 24,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        post.likesCount,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141416),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Comments
                GestureDetector(
                  onTap: () => _showCommentsSheet(context, post),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF141416),
                        size: 22,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        post.commentsCount,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141416),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Share
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      color: Color(0xFF141416),
                      size: 23,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      post.sharesCount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF141416),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Reply Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F1EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply_rounded, size: 15, color: Color(0xFF141416)),
                      SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141416),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INTERACTION BOTTOM SHEETS & MODALS
  // ===========================================================================
  void _showStoryViewer(BuildContext context, _StoryItem story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Color(0xFF141416),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(
                  story.avatarUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(story.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    story.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (story.isLive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search people, hashtags, venues...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xFFF4F1EA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMomentsBottomSheet(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moments & Stories gallery opened (Demo Mode)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showPostOptions(BuildContext context, _FeedPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline_rounded),
              title: const Text('Save Post'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share to Chat'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred_rounded,
                  color: Colors.red),
              title:
                  const Text('Report Post', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, _FeedPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Comments (${post.commentsCount})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('No comments yet. Be the first to start the conversation!'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StoryItem {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isCurrentUser;
  final bool isLive;
  final Color? ringColor;

  const _StoryItem({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isCurrentUser = false,
    this.isLive = false,
    this.ringColor,
  });
}

class _FeedPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String subtitle;
  final String caption;
  final List<String> hashtags;
  final String timeAgo;
  final String imageUrl;
  final String likesCount;
  final String commentsCount;
  final String sharesCount;

  const _FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.subtitle,
    required this.caption,
    required this.hashtags,
    required this.timeAgo,
    required this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
  });
}
