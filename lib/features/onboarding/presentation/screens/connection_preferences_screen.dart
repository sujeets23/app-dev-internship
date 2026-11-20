import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/selection_pill_tile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 6: Connection Preferences (Intent - Multi-select supported)
class ConnectionPreferencesScreen extends ConsumerWidget {
  const ConnectionPreferencesScreen({super.key});

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
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final selectedIntents = state.profile.connectionPreferences;
    final errors = state.errors;

    return OnboardingStepScaffold(
      currentStep: 5,
      totalSteps: 6,
      title: 'What are you looking for?',
      subtitle:
          'Be upfront with your intentions so you connect with people seeking the same experience. You can choose more than one.',
      nextButtonLabel:
          state.editingFromReview ? 'Update Preferences' : 'Review Profile',
      onBack: () => notifier.previousStep(),
      onNext: () => notifier.nextStep(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errors.containsKey('preferences')) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
        ],
      ),
    );
  }
}
