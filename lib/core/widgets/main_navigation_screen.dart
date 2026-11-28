import 'dart:ui';
import 'package:flutter/material.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/home/presentation/screens/home_feed_screen.dart';
import 'package:inclusive_dating/features/discovery/presentation/screens/discover_screen.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/matches_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/widgets/safety_hud_widget.dart';
import 'package:inclusive_dating/features/games/presentation/screens/games_lobby_screen.dart';
import 'package:inclusive_dating/features/games/presentation/screens/this_or_that_game_screen.dart';
import 'package:inclusive_dating/features/profile/presentation/screens/profile_screen.dart';
import 'package:inclusive_dating/features/date_planner/presentation/screens/date_planner_screen.dart';

/// Main Navigation Hub matching the social feed experience
/// Features:
/// 1. Feed: Social community feed with stories, video clips, and posts.
/// 2. Stream: Interactive icebreaker games & live turn-based rounds.
/// 3. Center Elevated Action: 3D cube glowing gradient FAB for Date Planner & Break The Ice.
/// 4. Match: 60 FPS Discovery Swipe Deck with 16 profiles & Incognito shield.
/// 5. Profile: Inclusive profile settings, preferences, and verified status.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _showCenterActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DDD5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF141416),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Break the ice or create a curated date in seconds.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF2D75), Color(0xFFFF6243)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.flare_rounded, color: Colors.white),
                ),
                title: const Text(
                  'Break the Ice ("This or That")',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text('Compare Beach vs Mountains dilemmas'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThisOrThatGameScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ED8C8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                ),
                title: const Text(
                  'AI Budget Date Planner',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text('Curate a 3-stop itinerary within your budget'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DatePlannerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeFeedScreen(onNavigateTab: _onTabSelected), // TAB 0: FEED
      const GamesLobbyScreen(),                      // TAB 1: STREAM
      const DiscoverScreen(),                        // TAB 2: MATCH
      const MatchesScreen(),                         // TAB 3: CHAT
      const ProfileScreen(),                         // TAB 4: PROFILE
    ];

    final int safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.completed,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                const SafeArea(
                  bottom: false,
                  child: SafetyHudWidget(),
                ),
                Expanded(
                  child: IndexedStack(
                    index: safeIndex,
                    children: screens,
                  ),
                ),
              ],
            ),

            // FLOATING FROSTED BOTTOM NAVIGATION BAR
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: _buildFloatingBottomBar(context, safeIndex: safeIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context, {required int safeIndex}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Frosted Glass Navigation Pill with actual background blur
          Container(
            height: 66,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF16182A).withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 1. Feed (Home)
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        label: 'Feed',
                        isActive: safeIndex == 0,
                        activeColor: const Color(0xFFFF2D55),
                        onTap: () => _onTabSelected(0),
                      ),

                      // 2. Stream (Games)
                      _buildNavItem(
                        index: 1,
                        icon: Icons.smart_display_outlined,
                        label: 'Stream',
                        isActive: safeIndex == 1,
                        activeColor: const Color(0xFFFF2D55),
                        onTap: () => _onTabSelected(1),
                      ),

                      // Central space allocated for raised action button
                      const SizedBox(width: 58),

                      // 4. Match (Swipe Cards)
                      _buildNavItem(
                        index: 2,
                        icon: Icons.style_outlined,
                        activeIcon: Icons.style_rounded,
                        label: 'Match',
                        isActive: safeIndex == 2,
                        activeColor: const Color(0xFF141416),
                        onTap: () => _onTabSelected(2),
                      ),

                      // 5. Profile
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                        isActive: safeIndex == 4,
                        activeColor: const Color(0xFF141416),
                        onTap: () => _onTabSelected(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Center Raised Action Button (Physically elevated above navigation pill)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => _showCenterActionMenu(context),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF2D75), Color(0xFFFF6243)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0xFF16182A) : Colors.white,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2D75).withValues(alpha: 0.38),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? (activeIcon ?? icon) : icon,
              size: 24,
              color: isActive ? activeColor : const Color(0xFF8E8E93),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
