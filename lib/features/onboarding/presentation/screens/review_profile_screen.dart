import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/avatar_picker_widget.dart';
import 'package:inclusive_dating/core/widgets/onboarding_progress_bar.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/section_review_card.dart';
import 'interests_selection_screen.dart';
import 'matching_preferences_screen.dart';

/// Screen 7: Review Profile
/// Shows comprehensive review with profile completion meter, spectrum identity details,
/// categorized interests, and matching preferences with inline edit controls.
class ReviewProfileScreen extends ConsumerWidget {
  const ReviewProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;
    final completionPct = profile.completionPercentInt;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          onPressed: () => notifier.previousStep(),
        ),
        title: Text(
          'Review Profile',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar (100% on Review)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: OnboardingProgressBar(
                currentStep: 6,
                totalSteps: 6,
                stepTitle: 'Final Review',
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to step in?',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a moment to review how your profile will appear to the community. You can adjust any detail below.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Completion Meter Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROFILE COMPLETION',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: completionPct >= 80
                                      ? (isDark
                                          ? AppColors.glanceableCyan
                                              .withValues(alpha: 0.18)
                                          : AppColors.glacierLight)
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$completionPct%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: completionPct >= 80
                                        ? AppColors.glanceableCyanDeep
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: profile.completionPercentage,
                              minHeight: 8,
                              backgroundColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.glanceableCyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 1: Basic Profile & Photo
                    SectionReviewCard(
                      title: 'Basic Profile',
                      icon: Icons.person_rounded,
                      onEdit: () => notifier.goToStep(1, fromReview: true),
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileAvatar(profile),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile.firstName}, ${profile.age ?? 18}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.cake_outlined,
                                      size: 14,
                                      color: AppColors.glanceableCyanDeep,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile.formattedDateOfBirth,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (profile.bio.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    profile.bio,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section 2: Sex & Gender Identity
                    SectionReviewCard(
                      title: 'Sex & Gender Identity',
                      icon: Icons.diversity_3_rounded,
                      onEdit: () => notifier.goToStep(2, fromReview: true),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.glanceableCyan
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.glanceableCyan,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  'Sex: ${profile.displaySex} (${profile.isSexVisible ? "Visible" : "Hidden"})',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.glanceableCyan
                                        : AppColors.encreDeep,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Identity: ${profile.displayGender}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Section 3: Pronouns
                    SectionReviewCard(
                      title: 'Pronouns',
                      icon: Icons.tag_rounded,
                      onEdit: () => notifier.goToStep(3, fromReview: true),
                      content: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceWarm,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderWarm,
                              ),
                            ),
                            child: Text(
                              profile.displayPronouns,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.primarySoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section 4: Sexual Orientation
                    SectionReviewCard(
                      title: 'Sexual Orientation',
                      icon: Icons.favorite_border_rounded,
                      onEdit: () => notifier.goToStep(4, fromReview: true),
                      content: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.glanceableCyan.withValues(alpha: 0.14)
                                  : AppColors.accentLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.displayOrientation,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isDark
                                    ? AppColors.glanceableCyan
                                    : AppColors.accentInk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section 5: What Do They Like (Interests)
                    SectionReviewCard(
                      title: 'Interests & Passions',
                      icon: Icons.auto_awesome_rounded,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InterestsSelectionScreen(),
                          ),
                        );
                      },
                      content: profile.interests.isEmpty
                          ? TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const InterestsSelectionScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add your interests (Min 3)'),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.interests.map((interest) {
                                return Chip(
                                  label: Text(interest),
                                  labelStyle:
                                      theme.textTheme.labelMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.glanceableCyan
                                        : AppColors.encreDeep,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.glacierLight,
                                  side: const BorderSide(
                                    color: AppColors.glanceableCyan,
                                    width: 1.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),

                    // Section 6: Matching Preferences & Intent
                    SectionReviewCard(
                      title: 'Matching & Intent',
                      icon: Icons.explore_outlined,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MatchingPreferencesScreen(),
                          ),
                        );
                      },
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profile.matchSexPreferences.isNotEmpty) ...[
                            Text(
                              'Interested in: ${profile.matchSexPreferences.join(', ')}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'Range: ${profile.minAgePreference} - ${profile.maxAgePreference} yrs • Up to ${profile.maxDistanceKm} km',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (profile.connectionPreferences.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  profile.connectionPreferences.map((intent) {
                                return Chip(
                                  label: Text(intent),
                                  labelStyle:
                                      theme.textTheme.labelMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.accent
                                        : AppColors.glacierInk,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: isDark
                                      ? AppColors.encreElevated
                                      : AppColors.glacierLight,
                                  side: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.glacierBorder,
                                    width: 1.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Complete Profile Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1.2,
                  ),
                ),
              ),
              child: PrimaryButton(
                label: 'Complete Profile',
                icon: Icons.check_circle_rounded,
                isLoading: state.isSaving,
                onPressed: () => notifier.completeProfile(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(dynamic profile) {
    if (profile.profileImagePath != null &&
        profile.profileImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 72,
          height: 72,
          child: kIsWeb
              ? Image.network(
                  profile.profileImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _avatarPlaceholder(),
                )
              : Image.file(
                  File(profile.profileImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _avatarPlaceholder(),
                ),
        ),
      );
    } else if (profile.presetAvatarId != null) {
      final preset = AvatarPickerWidget.presetAvatars.firstWhere(
        (p) => p['id'] == profile.presetAvatarId,
        orElse: () => AvatarPickerWidget.presetAvatars.first,
      );
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              preset['color1'] as Color,
              preset['color2'] as Color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            preset['icon'] as IconData,
            color: Colors.white,
            size: 32,
          ),
        ),
      );
    }
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.glacierLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}
