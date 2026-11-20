import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
    final List<Widget> screens = [
      HomeDashboardScreen(onTabSelected: _onTabSelected),
      const DiscoverScreen(),
      const MatchesScreen(),
      const DatePlannerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            backgroundColor: AppColors.surfaceDark,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.neonLime,
            unselectedItemColor: AppColors.textMutedDark,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.style_outlined),
                activeIcon: Icon(Icons.style),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Matches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'Date Planner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
