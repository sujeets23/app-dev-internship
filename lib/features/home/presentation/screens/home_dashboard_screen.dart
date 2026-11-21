import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/widgets/safety_hud_widget.dart';
import 'package:inclusive_dating/features/companions/presentation/screens/companion_marketplace_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/subscription/domain/models/subscription_model.dart';
import 'package:inclusive_dating/features/settings/presentation/screens/notifications_screen.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';
import 'package:inclusive_dating/features/discovery/domain/models/discovery_profile.dart';
import 'package:inclusive_dating/features/discovery/presentation/providers/discovery_provider.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final Function(int) onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.watch(isProfileVerifiedProvider);
    final billingAsync = ref.watch(billingProfileProvider);
    final discoveryState = ref.watch(discoveryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.softWhite,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.softLavender,
          onRefresh: () async {
            ref.invalidate(billingProfileProvider);
            await ref.read(discoveryProvider.notifier).loadDeck();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: TOP HEADER
                _buildTopHeader(context, onTabSelected: onTabSelected),

                // Persistent Safety Escrow HUD (shows if active companion booking exists)
                const SafetyHudWidget(),

                const SizedBox(height: 8),

                // Welcome Greeting Section
                _buildWelcomeGreetingSection(context),

                const SizedBox(height: 16),

                // SECTION 2: FEATURED DISCOVERY SECTION
                _buildFeaturedDiscoverySection(
                  context,
                  ref: ref,
                  discoveryState: discoveryState,
                  onTabSelected: onTabSelected,
                ),

                const SizedBox(height: 24),

                // SECTION 3: MATCHES SECTION
                _buildMatchesSection(context, onTabSelected: onTabSelected),

                const SizedBox(height: 24),

                // SECTION 5: AI DATE PLANNER FEATURE CARD
                _buildAiDatePlannerCard(context, onTabSelected: onTabSelected),

                const SizedBox(height: 20),

                // SECTION 4: MESSAGES SECTION
                _buildMessagesSection(context, onTabSelected: onTabSelected),

                const SizedBox(height: 20),

                // SECTION 6: COMPANION MARKETPLACE FEATURE CARD
                _buildCompanionMarketplaceCard(context),

                const SizedBox(height: 20),

                // SECTION 7: IDENTITY ASSURANCE VERIFICATION STATUS CARD
                _buildVerificationStatusCard(context, isVerified: isVerified),

                const SizedBox(height: 20),

                // SECTION 8: SUBSCRIPTION PREVIEW CARD
                _buildSubscriptionPreviewCard(context, billingAsync: billingAsync),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP HEADER
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context, {required Function(int) onTabSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.25),
        border: Border(
          bottom: BorderSide(
            color: AppColors.softLavender.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Date² Logo on the left - prominently visible, never cropped
          const Date2LogoWidget(
            height: 38,
            showContainer: false,
          ),

          const Spacer(),

          // Notification Icon with Badge on the right
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.charcoal, size: 26),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.blushPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // User Profile Thumbnail
          GestureDetector(
            onTap: () => onTabSelected(4), // Navigate to Profile
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blushPink.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 17,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WELCOME GREETING SECTION
  // ---------------------------------------------------------------------------
  Widget _buildWelcomeGreetingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Good evening, Alex',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  fontSize: 24,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 6),
              const Text('✨', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Ready to find your meaningful vibe and connections today?',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. FEATURED DISCOVERY SECTION
  // ---------------------------------------------------------------------------
  Widget _buildFeaturedDiscoverySection(
    BuildContext context, {
    required WidgetRef ref,
    required DiscoveryState discoveryState,
    required Function(int) onTabSelected,
  }) {
    // If deck has profiles, use the top profile; else use curated showcase
    final profile = discoveryState.currentProfile;
    final name = profile?.name ?? 'Aarya Sen';
    final age = profile?.age ?? 24;
    final bio = profile?.bio ??
        'Queer visual artist & tea lover. Looking for deep conversations and gallery dates ✨';
    final matchScore = profile?.matchPercentage ?? 94;
    final pronouns = profile?.pronouns ?? 'She/Her';
    final location = '${profile?.distanceKm ?? 3} km away';
    final imageUrl = (profile?.photoUrls.isNotEmpty ?? false)
        ? profile!.photoUrls.first
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEATURED DISCOVERY',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(1), // Go to Discover tab
                child: Row(
                  children: [
                    Text(
                      'Explore Deck',
                      style: TextStyle(
                        color: AppColors.charcoal.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.charcoal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large attractive profile card
          Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softLavender.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile Photo
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.softLavender,
                      child: const Center(
                        child: Icon(Icons.person, size: 60, color: AppColors.blushPink),
                      ),
                    ),
                  ),

                  // Gradient Scrim Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.charcoal.withValues(alpha: 0.2),
                          AppColors.charcoal.withValues(alpha: 0.85),
                        ],
                        stops: const [0.4, 0.65, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Top Compatibility Badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.butterYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppColors.charcoal),
                          const SizedBox(width: 4),
                          Text(
                            '$matchScore% Compatibility',
                            style: const TextStyle(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Verified Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),

                  // Bottom Profile Details & Action Buttons
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Age
                        Row(
                          children: [
                            Text(
                              '$name, $age',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pronouns,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.peach),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Short Introduction
                        Text(
                          bio,
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons: Pass, Like, and Discover
                        Row(
                          children: [
                            // Pass Button
                            InkWell(
                              onTap: () {
                                ref.read(discoveryProvider.notifier).swipe(SwipeDirection.left);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Passed profile'),
                                    duration: Duration(milliseconds: 600),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.black54, size: 26),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Like Button
                            InkWell(
                              onTap: () {
                                ref.read(discoveryProvider.notifier).swipe(SwipeDirection.right);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Liked $name! ❤️'),
                                    backgroundColor: AppColors.blushPink,
                                    duration: const Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.blushPink, AppColors.coral],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blushPink.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Full Discover Button
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.butterYellow,
                                  foregroundColor: AppColors.charcoal,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => onTabSelected(1), // Go to Discover tab
                                icon: const Icon(Icons.style_outlined, size: 18),
                                label: const Text(
                                  'Discover More',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. MATCHES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMatchesSection(BuildContext context, {required Function(int) onTabSelected}) {
    final matches = [
      {
        'id': 'match_1',
        'name': 'Aarya',
        'age': '24',
        'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        'isNew': true,
        'score': '94%',
      },
      {
        'id': 'match_2',
        'name': 'Zayan',
        'age': '26',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'isNew': true,
        'score': '88%',
      },
      {
        'id': 'match_3',
        'name': 'Tara',
        'age': '23',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        'isNew': false,
        'score': '82%',
      },
      {
        'id': 'match_4',
        'name': 'Rohan',
        'age': '27',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'isNew': true,
        'score': '91%',
      },
      {
        'id': 'match_5',
        'name': 'Mia',
        'age': '25',
        'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
        'isNew': false,
        'score': '85%',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT MATCHES',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(2), // Switch to Matches tab
                child: Text(
                  'View All (${matches.length})',
                  style: const TextStyle(
                    color: AppColors.blushPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final m = matches[index];
              final isNew = m['isNew'] as bool;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: 'conv_${m['id']}',
                        participantName: m['name'] as String,
                        participantAvatar: m['image'] as String,
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
                            gradient: isNew
                                ? const LinearGradient(
                                    colors: [AppColors.blushPink, AppColors.butterYellow],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      AppColors.softLavender,
                                      AppColors.softLavender.withValues(alpha: 0.5),
                                    ],
                                  ),
                            boxShadow: isNew
                                ? [
                                    BoxShadow(
                                      color: AppColors.blushPink.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(m['image'] as String),
                          ),
                        ),
                        if (isNew)
                          Positioned(
                            bottom: 0,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.butterYellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: AppColors.charcoal,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m['name'] as String,
                      style: const TextStyle(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      m['score'] as String,
                      style: TextStyle(
                        color: AppColors.charcoal.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. MESSAGES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMessagesSection(BuildContext context, {required Function(int) onTabSelected}) {
    final conversations = [
      {
        'id': 'conv_1',
        'userId': 'user_1',
        'name': 'Aarya Sen',
        'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        'lastMessage': 'Are we still on for the pottery workshop this Saturday? ☕',
        'time': '12m ago',
        'unread': 1,
        'isOnline': true,
      },
      {
        'id': 'conv_2',
        'userId': 'user_2',
        'name': 'Zayan Khan',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'lastMessage': 'Loved your music recommendations! Especially the indie playlist.',
        'time': '1h ago',
        'unread': 2,
        'isOnline': true,
      },
      {
        'id': 'conv_3',
        'userId': 'user_3',
        'name': 'Tara Iyer',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        'lastMessage': 'The cafe near the art district was so queer-friendly!',
        'time': 'Yesterday',
        'unread': 0,
        'isOnline': false,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT CONVERSATIONS',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(2), // Switch to Matches tab
                child: Text(
                  'All Chats',
                  style: TextStyle(
                    color: AppColors.charcoal.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.softLavender.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softLavender.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.softLavender.withValues(alpha: 0.5),
                indent: 68,
              ),
              itemBuilder: (context, index) {
                final c = conversations[index];
                final unread = c['unread'] as int;
                final isOnline = c['isOnline'] as bool;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: c['id'] as String,
                          participantName: c['name'] as String,
                          participantAvatar: c['avatar'] as String,
                          isVerified: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Avatar with online status
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(c['avatar'] as String),
                            ),
                            if (isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Message details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c['name'] as String,
                                    style: TextStyle(
                                      color: AppColors.charcoal,
                                      fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    c['time'] as String,
                                    style: TextStyle(
                                      color: unread > 0 ? AppColors.blushPink : Colors.black45,
                                      fontSize: 11,
                                      fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                c['lastMessage'] as String,
                                style: TextStyle(
                                  color: unread > 0 ? AppColors.charcoal : Colors.black54,
                                  fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Unread Badge
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: const BoxDecoration(
                              color: AppColors.blushPink,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. AI DATE PLANNER FEATURE CARD
  // ---------------------------------------------------------------------------
  Widget _buildAiDatePlannerCard(BuildContext context, {required Function(int) onTabSelected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE5D5FF), Color(0xFFF8C0AE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.peach.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Sparkle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      SizedBox(width: 5),
                      Text(
                        'AI DATE PLANNER',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.butterYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '10% OFF VOUCHERS',
                    style: TextStyle(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Mandatory Headline
            Text(
              'Your next date starts here.',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 22,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),

            // Explanatory Text
            const Text(
              'Generate personalized multi-stop itineraries strictly within ₹500–₹5,000 budgets with verified queer-friendly cafe discount passes.',
              style: TextStyle(
                color: Color(0xFF3B3347),
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Mandatory Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.butterYellow,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black26,
                ),
                onPressed: () => onTabSelected(3), // Navigate to AI Date Planner module
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text(
                  'Generate Date Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. COMPANION MARKETPLACE FEATURE CARD
  // ---------------------------------------------------------------------------
  Widget _buildCompanionMarketplaceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF28DB7), Color(0xFFED907B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.blushPink.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.charcoal),
                      SizedBox(width: 5),
                      Text(
                        'SAFETY ESCROW & VERIFIED',
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PLATONIC ONLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Mandatory Headline
            Text(
              'Never attend an event alone.',
              style: AppTypography.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 22,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            const Text(
              'Book vetted, respectful companions for weddings, concerts, art galas & public dinners. Featuring QR/OTP check-in & live GPS Safety Escrow.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Mandatory Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompanionMarketplaceScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.charcoal),
                label: const Text(
                  'Explore Companions',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. IDENTITY ASSURANCE & BIOMETRIC VERIFICATION STATUS CARD
  // ---------------------------------------------------------------------------
  Widget _buildVerificationStatusCard(BuildContext context, {required bool isVerified}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isVerified ? const Color(0xFFE8F5E9) : AppColors.softLavender.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isVerified ? AppColors.success : AppColors.softLavender,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isVerified ? AppColors.success : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVerified ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified
                        ? 'Identity Assurance Verified ✓'
                        : 'Identity Verification Incomplete',
                    style: TextStyle(
                      color: isVerified ? AppColors.success : AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isVerified
                        ? 'Google ML Kit landmarks & zero-persistence liveness passed.'
                        : 'Complete your quick 3-step liveness scan to get verified and unlock 3x more mutual matches.',
                    style: TextStyle(
                      color: AppColors.charcoal.withValues(alpha: 0.75),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  if (!isVerified) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.butterYellow,
                        foregroundColor: AppColors.charcoal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BiometricVerificationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Verify Now',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. SUBSCRIPTION PREVIEW CARD
  // ---------------------------------------------------------------------------
  Widget _buildSubscriptionPreviewCard(
    BuildContext context, {
    required AsyncValue<UserBillingProfile> billingAsync,
  }) {
    final billingProfile = billingAsync.value;
    final currentTier = billingProfile?.activeTier ?? SubscriptionTier.free;
    final isPro = currentTier == SubscriptionTier.pro;
    final tierName = isPro
        ? 'Pro Tier Active ✨'
        : (currentTier == SubscriptionTier.basic ? 'Basic Tier' : 'Free Plan');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.softLavender.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blushPink, AppColors.butterYellow],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.charcoal, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierName,
                    style: const TextStyle(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPro
                        ? 'Unlimited swipes, Incognito Shield & AI date planner active.'
                        : 'Unlock unlimited swipes, 10% cafe vouchers & AI itinerary planner.',
                    style: TextStyle(
                      color: AppColors.charcoal.withValues(alpha: 0.7),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.butterYellow,
                foregroundColor: AppColors.charcoal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionPricingScreen(),
                  ),
                );
              },
              child: const Text(
                'Explore Premium',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
