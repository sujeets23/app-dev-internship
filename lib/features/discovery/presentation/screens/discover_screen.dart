import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/date2_logo_widget.dart';
import '../../domain/models/discovery_profile.dart';
import '../providers/discovery_provider.dart';
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
              Navigator.of(dialogCtx).pop();
              notifier.clearMatchDialog();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat opened with ${next.latestMatch!.profile.name}!'),
                  backgroundColor: AppColors.primary,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: state.isIncognitoEnabled
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: state.isIncognitoEnabled
                    ? Border.all(color: AppColors.primary, width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isIncognitoEnabled
                        ? Icons.shield_rounded
                        : Icons.location_on_outlined,
                    color: state.isIncognitoEnabled
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.isIncognitoEnabled ? 'Incognito' : 'Nearby (10km)',
                    style: TextStyle(
                      color: state.isIncognitoEnabled
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            onPressed: () {
              final newMode = !state.isIncognitoEnabled;
              notifier.toggleIncognito(newMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newMode
                        ? '🛡️ Incognito Shield Enabled: Your profile is hidden from the public deck.'
                        : '🌐 Incognito Disabled: Your profile is visible to compatible matches.',
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferences: Age 20-32 • Max Distance 25km'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : state.deck.isEmpty
                ? _buildEmptyState(context, notifier, isDark)
                : Column(
                    children: [
                      // Active Card Viewport
                      Expanded(
                        child: Stack(
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
                              iconColor: AppColors.peach,
                              size: 46,
                              onTap: state.history.isNotEmpty
                                  ? () => notifier.undoSwipe()
                                  : null,
                            ),

                            // Pass
                            _buildActionButton(
                              context: context,
                              icon: Icons.close_rounded,
                              iconColor: AppColors.secondary,
                              size: 58,
                              onTap: () => notifier.swipe(SwipeDirection.left),
                            ),

                            // Superlike
                            _buildActionButton(
                              context: context,
                              icon: Icons.star_rounded,
                              iconColor: AppColors.primary,
                              size: 48,
                              onTap: () => notifier.swipe(SwipeDirection.up),
                            ),

                            // Like
                            _buildActionButton(
                              context: context,
                              icon: Icons.favorite_rounded,
                              iconColor: AppColors.primary,
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
        icon: Icon(icon, color: onTap != null ? iconColor : Colors.white24),
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
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'ve seen everyone for now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon or expand your distance & orientation filters to explore more people.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Deck'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => notifier.loadDeck(),
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
