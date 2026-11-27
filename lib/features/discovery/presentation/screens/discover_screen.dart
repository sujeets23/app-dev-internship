import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/routing/app_router.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/screens/companion_marketplace_screen.dart';
import 'package:inclusive_dating/features/date_planner/presentation/screens/date_planner_screen.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import '../../domain/models/discovery_profile.dart';
import '../providers/discovery_provider.dart';
import '../widgets/active_friends_rail.dart';
import '../widgets/incognito_privacy_shield_dialog.dart';
import '../widgets/match_celebration_dialog.dart';
import '../widgets/profile_detail_sheet.dart';
import '../widgets/swipeable_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    final notifier = ref.read(discoveryProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for mutual matches
    ref.listen<DiscoveryState>(discoveryProvider, (previous, next) {
      if (next.latestMatch != null && previous?.latestMatch != next.latestMatch) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => MatchCelebrationDialog(
            match: next.latestMatch!,
            onSendMessage: () {
              final matchedProfile = next.latestMatch!.profile;
              Navigator.of(dialogCtx).pop();
              notifier.clearMatchDialog();

              // Register match with chat service
              final convId = ref.read(chatServiceProvider).addMatch(
                    name: matchedProfile.name,
                    avatar: matchedProfile.photoUrls.first,
                    matchId: matchedProfile.id,
                    isVerified: matchedProfile.isVerified,
                  );
              ref.invalidate(conversationsProvider);

              // Navigate directly to Chat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversationId: convId,
                    participantName: matchedProfile.name,
                    participantAvatar: matchedProfile.photoUrls.first,
                    isVerified: matchedProfile.isVerified,
                    sharedInterests:
                        matchedProfile.interests.take(3).toList(),
                  ),
                ),
              );
            },
            onKeepSwiping: () {
              Navigator.of(dialogCtx).pop();
              notifier.clearMatchDialog();
            },
          ),
        );
      }
    });

    final accent = AppColors.adaptiveAccent(isDark);
    final profile = ref.watch(onboardingProvider).profile;
    final userInterests = profile.interests;
    final maxDistanceKm = profile.maxDistanceKm;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Date2LogoWidget(
              height: 30,
              showContainer: false,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => IncognitoPrivacyShieldSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: state.isIncognitoEnabled
                      ? AppColors.adaptiveHighlightBg(isDark)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.isIncognitoEnabled
                        ? accent
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isIncognitoEnabled
                          ? Icons.shield_rounded
                          : Icons.location_on_outlined,
                      color: state.isIncognitoEnabled
                          ? accent
                          : AppColors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isIncognitoEnabled
                          ? 'Incognito'
                          : 'Nearby (${maxDistanceKm}km)',
                      style: TextStyle(
                        color: state.isIncognitoEnabled
                            ? accent
                            : AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Incognito Shield Toggle
          IconButton(
            tooltip: 'Incognito Privacy Shield',
            icon: Icon(
              state.isIncognitoEnabled
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              color: state.isIncognitoEnabled
                  ? accent
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimary),
            ),
            onPressed: () => IncognitoPrivacyShieldSheet.show(context),
          ),
          IconButton(
            tooltip: 'Matching Preferences',
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.matchingPreferences);
            },
          ),
          IconButton(
            tooltip: 'My Profile',
            icon: Icon(
              Icons.person_outline_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Friends & Active Connections Rail
            const ActiveFriendsRail(),

            // Quick Access Modules Rail (Companions, AI Date Planner, Subscriptions)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  _buildQuickModuleChip(
                    context,
                    icon: Icons.diversity_1_rounded,
                    label: 'Companions (Escrow)',
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const CompanionMarketplaceScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickModuleChip(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Date Planner',
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DatePlannerScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickModuleChip(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: 'Plans & Boosts',
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const SubscriptionPricingScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Card Viewport / Loading / Empty
            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: accent),
                    )
                  : state.deck.isEmpty
                      ? _buildEmptyState(context, notifier, isDark)
                      : Stack(
                          children: [
                            // Next Card in Deck preview
                            if (state.deck.length > 1)
                              Positioned.fill(
                                child: Transform.scale(
                                  scale: 0.94,
                                  child: Opacity(
                                    opacity: 0.65,
                                    child: SwipeableCard(
                                      key: ValueKey(state.deck[1].id),
                                      profile: state.deck[1],
                                      userInterests: userInterests,
                                      onSwiped: (_) {},
                                      onTapInfo: () {},
                                    ),
                                  ),
                                ),
                              ),

                            // Top Active Card
                            Positioned.fill(
                              child: SwipeableCard(
                                key: ValueKey(state.deck.first.id),
                                profile: state.deck.first,
                                userInterests: userInterests,
                                nextProfile: state.deck.length > 1
                                    ? state.deck[1]
                                    : null,
                                onSwiped: (dir) => notifier.swipe(dir),
                                onTapInfo: () => _openProfileSheet(
                                  context,
                                  state.deck.first,
                                  notifier,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),

            if (!state.isLoading && state.deck.isNotEmpty)
              // Swipe Action Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Undo
                    _buildActionButton(
                      context: context,
                      icon: Icons.undo_rounded,
                      iconColor: AppColors.warning,
                      size: 46,
                      onTap: state.history.isNotEmpty
                          ? () => notifier.undoSwipe()
                          : null,
                    ),

                    // Pass
                    _buildActionButton(
                      context: context,
                      icon: Icons.close_rounded,
                      iconColor: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      size: 58,
                      onTap: () => notifier.swipe(SwipeDirection.left),
                    ),

                    // Superlike
                    _buildActionButton(
                      context: context,
                      icon: Icons.star_rounded,
                      iconColor: isDark
                          ? AppColors.accentTeal
                          : AppColors.glacierInk,
                      size: 48,
                      onTap: () => notifier.swipe(SwipeDirection.up),
                    ),

                    // Like
                    _buildActionButton(
                      context: context,
                      icon: Icons.favorite_rounded,
                      iconColor: AppColors.adaptiveAccent(isDark),
                      size: 58,
                      onTap: () => notifier.swipe(SwipeDirection.right),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required double size,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: onTap != null ? iconColor.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.border),
          width: 1.5,
        ),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onTap != null
              ? iconColor
              : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary)
                  .withValues(alpha: 0.45),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DiscoveryNotifier notifier,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.adaptiveHighlightBg(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: AppColors.adaptiveAccent(isDark),
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'ve seen everyone for now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon or expand your distance & orientation filters to explore more people.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Deck'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adaptiveAccent(isDark),
                foregroundColor: AppColors.adaptiveOnAccent(isDark),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => notifier.loadDeck(resetCache: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickModuleChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final accent = AppColors.adaptiveAccent(isDark);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfileSheet(
    BuildContext context,
    DiscoveryProfile profile,
    DiscoveryNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ProfileDetailSheet(
          profile: profile,
          onLike: () => notifier.swipe(SwipeDirection.right),
          onPass: () => notifier.swipe(SwipeDirection.left),
        ),
      ),
    );
  }
}
