import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/subscription/presentation/screens/subscription_pricing_screen.dart';
import 'package:inclusive_dating/features/settings/presentation/screens/settings_screen.dart';
import 'package:inclusive_dating/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.watch(isProfileVerifiedProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Avatar with verified badge
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.electricViolet, AppColors.softPink, AppColors.neonLime],
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                      ),
                    ),
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.neonLime,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.black, size: 20),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Name, Pronouns & Age
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Alex, 25',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('they/them', style: TextStyle(color: AppColors.softPink, fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Text(
              'Mumbai, India • Non-Binary • Queer',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            ),

            const SizedBox(height: 16),

            // Biometric Verification Status Chip
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (!isVerified) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BiometricVerificationScreen(),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.neonLime.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isVerified ? AppColors.neonLime : Colors.orangeAccent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user : Icons.warning_amber_rounded,
                      color: isVerified ? AppColors.neonLime : Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVerified
                          ? 'Identity Assurance: Verified Live ML'
                          : 'Identity Assurance: Unverified (Tap to verify)',
                      style: TextStyle(
                        color: isVerified ? AppColors.neonLime : Colors.orangeAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Edit Profile Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Profile & Preferences'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // Profile Sections (Bio & Interests)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ABOUT ME',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Designer & creative thinker. Big on analog photography, indie poetry, specialty coffees, and queer social events across the city. Looking for meaningful dating & creative friendships.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Interests Wrap
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INTERESTS & PASSIONS',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Art Exhibitions',
                      'Analog Film',
                      'Specialty Coffee',
                      'Indie Music',
                      'Queer Literature',
                      'Baking',
                    ].map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Shortcuts
            _buildProfileMenuItem(
              icon: Icons.shield_moon_outlined,
              title: 'Incognito Privacy Shield',
              subtitle: 'Control Discovery isolation & visibility',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
                );
              },
            ),
            _buildProfileMenuItem(
              icon: Icons.workspace_premium_outlined,
              title: 'Subscriptions & Billing',
              subtitle: 'Manage Pro plan, UPI mandates & receipts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPricingScreen()),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.neonLime),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
        onTap: onTap,
      ),
    );
  }
}
