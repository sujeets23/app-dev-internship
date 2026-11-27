import 'package:flutter/material.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/discovery/presentation/screens/discover_screen.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/matches_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/widgets/safety_hud_widget.dart';
import 'package:inclusive_dating/features/games/presentation/screens/games_lobby_screen.dart';

/// Feature 5: Home Page Hub containing the three primary tabs:
/// 1. MATCH: Discovery profiles, 60fps swipe deck, verified Face Scan badge, likes, incognito shield.
/// 2. CHAT: Horizontal rail of new matches, active real-time conversation list, unread indicators.
/// 3. GAME: Interactive icebreaker games (2 Truths & a Lie, Compatibility Trivia, Would You Rather).
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> screens = [
      const DiscoverScreen(),       // MATCH TAB
      const MatchesScreen(),        // CHAT TAB
      const GamesLobbyScreen(),     // GAME TAB
    ];

    final int safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.completed,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        body: Column(
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.encreDeep.withValues(alpha: isDark ? 0.28 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              onTap: _onTabSelected,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.glanceableCyanDeep,
              unselectedItemColor: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.style_outlined),
                  activeIcon: Icon(Icons.style_rounded),
                  label: 'MATCH',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'CHAT',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_esports_outlined),
                  activeIcon: Icon(Icons.sports_esports_rounded),
                  label: 'GAME',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
