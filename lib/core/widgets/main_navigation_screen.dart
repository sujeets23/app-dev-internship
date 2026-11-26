import 'package:flutter/material.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:inclusive_dating/features/discovery/presentation/screens/discover_screen.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/matches_screen.dart';
import 'package:inclusive_dating/features/date_planner/presentation/screens/date_planner_screen.dart';
import 'package:inclusive_dating/features/profile/presentation/screens/profile_screen.dart';

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
      HomeDashboardScreen(onTabSelected: _onTabSelected),
      const DiscoverScreen(),
      const MatchesScreen(),
      const DatePlannerScreen(),
      const ProfileScreen(),
    ];

    return VerificationRouteGuard(
      requiredStep: AuthFlowStep.completed,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
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
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.adaptiveAccent(isDark),
              unselectedItemColor: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.style_outlined),
                  activeIcon: Icon(Icons.style_rounded),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Matches',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Date Planner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
