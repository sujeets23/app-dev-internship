import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../../domain/models/discovery_profile.dart';

class ProfileDetailSheet extends StatelessWidget {
  final DiscoveryProfile profile;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const ProfileDetailSheet({
    super.key,
    required this.profile,
    required this.onLike,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF160E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: [
                // Photo Gallery
                if (profile.photoUrls.isNotEmpty)
                  SizedBox(
                    height: 380,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: PageView.builder(
                        itemCount: profile.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            profile.photoUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primarySubtle,
                              child: const Icon(Icons.person, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Name, Age & Verified Badge
                Row(
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Identity Badges (Gender, Pronouns, Distance)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPill(profile.gender, AppColors.primaryLight, AppColors.primary),
                    _buildPill(profile.pronouns, AppColors.secondaryLight, AppColors.secondaryDark),
                    _buildPill(profile.orientation, AppColors.primaryLight, AppColors.primaryViolet),
                    _buildPill('${profile.distanceKm} km away', AppColors.surfaceMuted, AppColors.textSecondary),
                  ],
                ),

                const SizedBox(height: 20),

                // Bio
                Text(
                  'About Me',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.bio,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Interests & Hobbies
                Text(
                  'Interests & Passions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF261A4D) : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Connection Preferences
                Text(
                  'Looking For',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: profile.preferences.map((pref) {
                    return Chip(
                      label: Text(pref),
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.25),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Bottom Action Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF140D2A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded, color: AppColors.error),
                    label: const Text('Pass', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPass();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Like Profile',
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    icon: Icons.favorite_rounded,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onLike();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
