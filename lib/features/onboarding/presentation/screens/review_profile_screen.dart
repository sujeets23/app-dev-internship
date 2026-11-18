import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/avatar_picker_widget.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/section_review_card.dart';

/// Screen 7: Review Profile
class ReviewProfileScreen extends ConsumerWidget {
  const ReviewProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;

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
                    const SizedBox(height: 20),

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
                                      color: AppColors.primary,
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

                    // Section 2: Gender Identity
                    SectionReviewCard(
                      title: 'Gender Identity',
                      icon: Icons.diversity_3_rounded,
                      onEdit: () => notifier.goToStep(2, fromReview: true),
                      content: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.displayGender,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                              color: AppColors.secondaryLight.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.displayPronouns,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.secondaryDark,
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
                              color: AppColors.accentLight.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.displayOrientation,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section 5: Connection Preferences
                    SectionReviewCard(
                      title: 'Connection Intent',
                      icon: Icons.explore_outlined,
                      onEdit: () => notifier.goToStep(5, fromReview: true),
                      content: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.connectionPreferences.map((intent) {
                          return Chip(
                            label: Text(intent),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor:
                                AppColors.primaryLight.withValues(alpha: 0.6),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
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
        color: AppColors.primaryLight,
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
