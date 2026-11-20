import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/companions/presentation/widgets/safety_hud_widget.dart';
import 'package:inclusive_dating/features/companions/presentation/screens/companion_marketplace_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/settings/presentation/screens/notifications_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final Function(int) onTabSelected;

  const HomeDashboardScreen({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.watch(isProfileVerifiedProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: AppColors.neonLime),
            tooltip: 'Subscriptions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPricingScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Persistent Safety Escrow HUD (shows if active booking exists)
            const SafetyHudWidget(),

            // Greeting & Intro Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Alex ✨',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your inclusive, verified dating & platonic companion space.',
                    style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Identity Assurance Verification Status Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isVerified
                      ? const LinearGradient(
                          colors: [Color(0xFF1E3A2F), Color(0xFF14241E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [AppColors.electricViolet, Color(0xFF6E28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isVerified ? AppColors.neonLime : Colors.white24,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user : Icons.gpp_maybe,
                      color: isVerified ? AppColors.neonLime : AppColors.softPink,
                      size: 36,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified
                                ? 'Identity Assurance Verified ✓'
                                : 'Complete Biometric Verification',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isVerified
                                ? 'Liveness & Google ML Kit face landmarks passed.'
                                : 'Unlock verified badges & 3x more mutual matches.',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (!isVerified)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonLime,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BiometricVerificationScreen(),
                            ),
                          );
                        },
                        child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Service Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'DATE² ECOSYSTEM',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonLime,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      title: 'Discover Deck',
                      subtitle: 'Swipe & Match',
                      icon: Icons.style,
                      gradient: const [Color(0xFF5000F4), Color(0xFF7B2CBF)],
                      onTap: () => onTabSelected(1), // Switch to Discover
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      title: 'Date Planner',
                      subtitle: 'AI Budgets & 10% Off',
                      icon: Icons.auto_awesome,
                      gradient: const [Color(0xFF6A0DAD), Color(0xFF9D4EDD)],
                      onTap: () => onTabSelected(3), // Switch to Date Planner
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      title: 'Companion Escrow',
                      subtitle: 'Platonic Event Booking',
                      icon: Icons.people_outline,
                      gradient: const [Color(0xFF240046), Color(0xFF3C096C)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanionMarketplaceScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      title: 'Micro-Plans',
                      subtitle: '₹50/mo & ₹29 Unlocks',
                      icon: Icons.bolt,
                      gradient: const [Color(0xFF10002B), Color(0xFF240046)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionPricingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Jump into Matches snippet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT CONNECTIONS',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onTabSelected(2), // Switch to Matches
                    child: const Text('View All', style: TextStyle(color: AppColors.softPink, fontSize: 12)),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildConnectionAvatar('Aarya', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', true),
                  _buildConnectionAvatar('Zayan', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', true),
                  _buildConnectionAvatar('Tara', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', false),
                  _buildConnectionAvatar('Rohan', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', true),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.neonLime, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionAvatar(String name, String url, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(url),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.neonLime,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundDark, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
