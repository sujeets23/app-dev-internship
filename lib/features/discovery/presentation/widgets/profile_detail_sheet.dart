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
    final accent = AppColors.adaptiveAccent(isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderWarm,
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
                      borderRadius: BorderRadius.circular(20),
                      child: PageView.builder(
                        itemCount: profile.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            profile.photoUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: isDark
                                  ? AppColors.encreElevated
                                  : AppColors.glacierLight,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified_rounded,
                        color: isDark ? AppColors.accent : AppColors.accentTeal,
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
                    _buildPill(
                      profile.gender,
                      isDark ? AppColors.encreElevated : AppColors.glacierLight,
                      isDark ? AppColors.accent : AppColors.glacierInk,
                    ),
                    _buildPill(
                      profile.pronouns,
                      isDark ? AppColors.surfaceMutedDark : AppColors.surfaceWarm,
                      isDark ? AppColors.textSecondaryDark : AppColors.primarySoft,
                    ),
                    _buildPill(
                      profile.orientation,
                      isDark
                          ? AppColors.accentTeal.withValues(alpha: 0.16)
                          : AppColors.accentLight,
                      isDark ? AppColors.accent : AppColors.accentInk,
                    ),
                    _buildPill(
                      '${profile.distanceKm} km away',
                      isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted,
                      isDark ? AppColors.textTertiaryDark : AppColors.textSecondary,
                    ),
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
                        color: isDark ? AppColors.encreElevated : AppColors.glacierSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.glacierBorder,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: accent,
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
                      backgroundColor:
                          isDark ? AppColors.encreElevated : AppColors.glacierLight,
                      labelStyle: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.glacierInk,
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
              color: isDark ? AppColors.backgroundDark : AppColors.surface,
              boxShadow: AppColors.softShadow,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
