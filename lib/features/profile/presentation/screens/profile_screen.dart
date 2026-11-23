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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor),
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.blushPink, AppColors.butterYellow],
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
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 20),
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
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.blushPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'they/them',
                    style: TextStyle(color: AppColors.blushPink, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              'Mumbai, India • Non-Binary • Queer',
              style: TextStyle(color: mutedTextColor, fontSize: 13),
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
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.softLavender.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isVerified ? AppColors.success : AppColors.softLavender,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user : Icons.warning_amber_rounded,
                      color: isVerified ? AppColors.success : AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVerified
                          ? 'Identity Assurance: Verified Live ML ✓'
                          : 'Identity Assurance: Unverified (Tap to verify)',
                      style: TextStyle(
                        color: isVerified ? AppColors.success : AppColors.charcoal,
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
                foregroundColor: textColor,
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.softLavender,
                ),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.transparent : AppColors.softLavender,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softLavender.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT ME',
                    style: TextStyle(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Designer & creative thinker. Big on analog photography, indie poetry, specialty coffees, and queer social events across the city. Looking for meaningful dating & creative friendships.',
                    style: TextStyle(color: mutedTextColor, fontSize: 13, height: 1.4),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.transparent : AppColors.softLavender,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softLavender.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERESTS & PASSIONS',
                    style: TextStyle(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
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
                          color: isDark ? AppColors.backgroundDark : AppColors.softLavender.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppColors.electricViolet.withValues(alpha: 0.5)
                                : AppColors.softLavender,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(color: textColor, fontSize: 12),
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
              context: context,
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
              context: context,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.softLavender.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: cardBg,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? Colors.transparent : AppColors.softLavender,
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: isDark ? AppColors.neonLime : AppColors.primary),
          title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle, style: TextStyle(color: mutedTextColor, fontSize: 11)),
          trailing: Icon(Icons.arrow_forward_ios, color: mutedTextColor, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}
