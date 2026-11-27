import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/security_check_intro_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/widgets/safety_hud_widget.dart';
import 'package:inclusive_dating/features/companions/presentation/screens/companion_marketplace_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/subscription/domain/models/subscription_model.dart';
import 'package:inclusive_dating/features/settings/presentation/screens/notifications_screen.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';
import 'package:inclusive_dating/features/discovery/domain/models/discovery_profile.dart';
import 'package:inclusive_dating/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:inclusive_dating/features/discovery/presentation/widgets/active_friends_rail.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final Function(int) onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.watch(isProfileVerifiedProvider) ||
        ref.watch(authProvider).isFullyVerified;
    final billingAsync = ref.watch(billingProfileProvider);
    final discoveryState = ref.watch(discoveryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.adaptiveAccent(isDark),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
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

                const SizedBox(height: 12),

                // Active Friends & Live Connections Rail
                const ActiveFriendsRail(),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceMutedDark : AppColors.glacierLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.adaptiveBorder(isDark),
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
                icon: Icon(Icons.notifications_outlined, color: textColor, size: 26),
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
                    color: AppColors.accentTeal,
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
                border: Border.all(
                  color: AppColors.adaptiveAccent(isDark),
                  width: 2,
                ),
                boxShadow: AppColors.softShadow,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 6),
              const Text('✨', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Ready to find your meaningful vibe and connections today?',
            style: TextStyle(
              color: mutedColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.adaptiveAccent(isDark);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

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
                  color: accent,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(1), // Go to Discover tab
                child: Row(
                  children: [
                    Text(
                      'Explore Deck',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: textColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large curated profile card
          Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile Photo
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.glacierLight,
                      child: const Center(
                        child: Icon(Icons.person, size: 60, color: AppColors.primary),
                      ),
                    ),
                  ),

                  // Gradient Scrim Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.encreDeep.withValues(alpha: 0.2),
                          AppColors.encreDeep.withValues(alpha: 0.86),
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
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppColors.encreDeep),
                          const SizedBox(width: 4),
                          Text(
                            '$matchScore% Compatibility',
                            style: const TextStyle(
                              color: AppColors.encreDeep,
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
                        color: AppColors.primary.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.accent,
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
                                borderRadius: BorderRadius.circular(10),
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
                            const Icon(Icons.location_on, size: 14, color: AppColors.accent),
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
                                  color: Colors.white.withValues(alpha: 0.94),
                                  shape: BoxShape.circle,
                                  boxShadow: AppColors.softShadow,
                                ),
                                child: const Icon(Icons.close_rounded, color: AppColors.primary, size: 24),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Like Button
                            InkWell(
                              onTap: () {
                                ref.read(discoveryProvider.notifier).swipe(SwipeDirection.right);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Liked $name!'),
                                    backgroundColor: AppColors.primary,
                                    duration: const Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accent, width: 1.4),
                                  boxShadow: AppColors.primaryShadow,
                                ),
                                child: const Icon(Icons.favorite_rounded, color: AppColors.accent, size: 24),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Full Discover Button
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.encreDeep,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => onTabSelected(1), // Go to Discover tab
                                icon: const Icon(Icons.style_outlined, size: 18),
                                label: const Text(
                                  'Discover More',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.adaptiveAccent(isDark);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
                  color: accent,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(2), // Switch to Matches tab
                child: Text(
                  'View All (${matches.length})',
                  style: TextStyle(
                    color: isDark ? AppColors.accentTeal : AppColors.glacierInk,
                    fontWeight: FontWeight.w700,
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
            separatorBuilder: (_, _) => const SizedBox(width: 16),
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
                                ? AppColors.cyanPrismGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.adaptiveBorder(isDark),
                                      AppColors.adaptiveBorder(isDark),
                                    ],
                                  ),
                            boxShadow: isNew ? AppColors.softShadow : null,
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
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? AppColors.backgroundDark : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: AppColors.encreDeep,
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
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      m['score'] as String,
                      style: TextStyle(
                        color: mutedColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.adaptiveAccent(isDark);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;

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
                  color: accent,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => onTabSelected(2), // Switch to Matches tab
                child: Text(
                  'All Chats',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.adaptiveBorder(isDark)),
              boxShadow: AppColors.softShadow,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: AppColors.adaptiveBorder(isDark),
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
                  borderRadius: BorderRadius.circular(18),
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
                                    border: Border.all(color: cardBg, width: 2),
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
                                      color: textColor,
                                      fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    c['time'] as String,
                                    style: TextStyle(
                                      color: unread > 0 ? accent : mutedColor,
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
                                  color: unread > 0 ? textColor : mutedColor,
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
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unread',
                              style: TextStyle(
                                color: AppColors.adaptiveOnAccent(isDark),
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
  // 5. AI DATE PLANNER FEATURE CARD (Glanceable Glacier Card)
  // ---------------------------------------------------------------------------
  Widget _buildAiDatePlannerCard(BuildContext context, {required Function(int) onTabSelected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bodyColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark ? null : AppColors.glacierPrismGradient,
          color: isDark ? AppColors.encreElevated : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
            width: 1.1,
          ),
          boxShadow: AppColors.softShadow,
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
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.adaptiveAccent(isDark),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'AI DATE PLANNER',
                        style: TextStyle(
                          color: AppColors.adaptiveAccent(isDark),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '10% OFF VOUCHERS',
                    style: TextStyle(
                      color: AppColors.encreDeep,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Your next date starts here.',
              style: AppTypography.displaySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'Generate personalized multi-stop itineraries strictly within ₹500–₹5,000 budgets with verified queer-friendly cafe discount passes.',
              style: TextStyle(
                color: bodyColor,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adaptiveAccent(isDark),
                  foregroundColor: AppColors.adaptiveOnAccent(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => onTabSelected(3), // Navigate to AI Date Planner module
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text(
                  'Generate Date Plan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
  // 6. COMPANION MARKETPLACE FEATURE CARD (Glanceable Encre Dark Banner)
  // ---------------------------------------------------------------------------
  Widget _buildCompanionMarketplaceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.encrePrismGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.encreBorderDark, width: 1.1),
          boxShadow: AppColors.primaryShadow,
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
                    color: AppColors.encreElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.encreBorderDark),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
                      SizedBox(width: 5),
                      Text(
                        'SAFETY ESCROW & VERIFIED',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PLATONIC ONLY',
                    style: TextStyle(
                      color: AppColors.encreDeep,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Never attend an event alone.',
              style: AppTypography.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),

            const Text(
              'Book vetted, respectful companions for weddings, concerts, art galas & public dinners. Featuring QR/OTP check-in & live GPS Safety Escrow.',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompanionMarketplaceScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.primary),
                label: const Text(
                  'Explore Companions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isVerified
              ? (isDark
                  ? AppColors.success.withValues(alpha: 0.14)
                  : AppColors.successLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceWarm),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isVerified
                ? AppColors.success.withValues(alpha: 0.6)
                : AppColors.adaptiveBorder(isDark),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppColors.success
                    : AppColors.adaptiveAccent(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVerified ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                color: isVerified ? Colors.white : AppColors.adaptiveOnAccent(isDark),
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
                      color: isVerified ? AppColors.success : textColor,
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
                      color: mutedColor,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  if (!isVerified) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adaptiveAccent(isDark),
                        foregroundColor: AppColors.adaptiveOnAccent(isDark),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityCheckIntroScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Verify Now',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.adaptiveBorder(isDark), width: 1.1),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.cyanPrismGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.encreDeep, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tierName,
                    style: TextStyle(
                      color: textColor,
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
                      color: mutedColor,
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
                backgroundColor: isDark ? AppColors.accent : AppColors.secondary,
                foregroundColor: isDark ? AppColors.encreDeep : AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
