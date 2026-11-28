import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/selection_pill_tile.dart';
import 'package:inclusive_dating/core/widgets/sf_pattern_widgets.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 6: Matching Preferences & Intent
/// Configures who the user wants to meet (4-option Sex checkboxes), Age range, Distance, and Intent.
class MatchingPreferencesScreen extends ConsumerWidget {
  const MatchingPreferencesScreen({super.key});

  IconData _getIconForTitle(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite_rounded;
      case 'favorite_border':
        return Icons.favorite_outline_rounded;
      case 'local_cafe_outlined':
        return Icons.local_cafe_outlined;
      case 'people_outline':
        return Icons.people_outline_rounded;
      case 'explore_outlined':
        return Icons.explore_outlined;
      default:
        return Icons.bubble_chart_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;
    final matchSexPreferences = profile.matchSexPreferences;
    final selectedIntents = profile.connectionPreferences;
    final errors = state.errors;

    return OnboardingStepScaffold(
      currentStep: 6,
      totalSteps: 6,
      title: 'Matching preferences',
      subtitle:
          'Set your preferences so Date² can curate matches aligned with your intentions and lifestyle.',
      nextButtonLabel:
          state.editingFromReview ? 'Update Preferences' : 'Review Profile',
      onBack: () => notifier.previousStep(),
      onNext: () {
        if (matchSexPreferences.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please select at least one sex preference for matching.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
        if (selectedIntents.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please select at least one connection intent.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Who do you want to be matched with? (Strict 4 options)
          Text(
            'WHO DO YOU WANT TO BE MATCHED WITH?',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select all that apply to tailor your discovery queue.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: OnboardingOptions.sexOptions.map((sex) {
              final isSelected = matchSexPreferences.contains(sex);
              return FilterChip(
                label: Text(sex),
                selected: isSelected,
                onSelected: (_) {
                  notifier.toggleMatchSexPreference(sex);
                },
                selectedColor: AppColors.sfCoral,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.sfCharcoal),
                ),
                backgroundColor:
                    isDark ? AppColors.surfaceDark : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.sfCoral
                        : (isDark ? AppColors.borderDark : const Color(0xFFE8E3DA)),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),

          if (errors.containsKey('matchSex')) ...[
            const SizedBox(height: 10),
            Text(
              errors['matchSex']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Section 2: Distance Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MAXIMUM DISTANCE',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glanceableCyan.withValues(alpha: 0.15)
                      : AppColors.glacierLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${profile.maxDistanceKm} km',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.glanceableCyan
                        : AppColors.encreDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.glanceableCyan,
              inactiveTrackColor:
                  isDark ? AppColors.surfaceVariantDark : AppColors.border,
              thumbColor: AppColors.glanceableCyanDeep,
              overlayColor: AppColors.glanceableCyan.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: profile.maxDistanceKm.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (val) {
                notifier.updateDiscoveryPreferences(
                  maxDistanceKm: val.round(),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: Age Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AGE PREFERENCE',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glanceableCyan.withValues(alpha: 0.15)
                      : AppColors.glacierLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${profile.minAgePreference} - ${profile.maxAgePreference}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.glanceableCyan
                        : AppColors.encreDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(
              profile.minAgePreference.toDouble(),
              profile.maxAgePreference.toDouble(),
            ),
            min: 18,
            max: 65,
            divisions: 47,
            activeColor: AppColors.glanceableCyan,
            inactiveColor:
                isDark ? AppColors.surfaceVariantDark : AppColors.border,
            onChanged: (RangeValues values) {
              notifier.updateDiscoveryPreferences(
                minAge: values.start.round(),
                maxAge: values.end.round(),
              );
            },
          ),

          const SizedBox(height: 28),

          // Section 4: Connection Intent (Dating vs Platonic)
          Text(
            'CONNECTION INTENT',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Be upfront with your intentions so you connect with like-minded people.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          if (errors.containsKey('preferences')) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errors['preferences']!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Multi-select pill cards
          ...OnboardingOptions.connectionPreferences.map((pref) {
            final title = pref['title']!;
            final subtitle = pref['subtitle']!;
            final iconName = pref['icon']!;
            final isSelected = selectedIntents.contains(title);

            return SelectionPillTile(
              title: title,
              subtitle: subtitle,
              leadingIcon: _getIconForTitle(iconName),
              isSelected: isSelected,
              isMultiSelect: true,
              onTap: () {
                notifier.toggleConnectionPreference(title);
              },
            );
          }),

          const SizedBox(height: 24),

          // SF PATTERN: Overlapping Candy Tokens with Heart Cutouts (Screen 4 Pattern)
          const SfCandyTokensPattern(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
