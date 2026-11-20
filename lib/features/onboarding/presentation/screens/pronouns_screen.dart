import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/custom_text_field.dart';
import 'package:inclusive_dating/core/widgets/selection_pill_tile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 4: Pronouns
class PronounsScreen extends ConsumerStatefulWidget {
  const PronounsScreen({super.key});

  @override
  ConsumerState<PronounsScreen> createState() => _PronounsScreenState();
}

class _PronounsScreenState extends ConsumerState<PronounsScreen> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final pronouns = ref.read(onboardingProvider).profile.pronouns;
    _customController =
        TextEditingController(text: pronouns?.customPronouns ?? '');
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final pronouns = state.profile.pronouns;
    final errors = state.errors;

    final isCustom = pronouns?.isCustom ?? false;

    return OnboardingStepScaffold(
      currentStep: 3,
      totalSteps: 6,
      title: 'What are your pronouns?',
      subtitle:
          'Your pronouns help others address and respect you accurately across conversations and profiles.',
      nextButtonLabel: state.editingFromReview ? 'Update Pronouns' : 'Continue',
      onBack: () => notifier.previousStep(),
      onNext: () {
        if (isCustom) {
          notifier.updatePronouns(
            OnboardingOptions.customPronounsOption,
            customPronouns: _customController.text.trim(),
          );
        }
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errors.containsKey('pronouns')) ...[
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
                      errors['pronouns']!,
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

          // Render pronoun options
          ...OnboardingOptions.standardPronouns.map((option) {
            final isSelected = pronouns?.option == option;
            return SelectionPillTile(
              title: option,
              isSelected: isSelected,
              onTap: () {
                notifier.updatePronouns(
                  option,
                  customPronouns: option == OnboardingOptions.customPronounsOption
                      ? _customController.text
                      : null,
                );
              },
            );
          }),

          // Expandable Custom Pronouns Text Field
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: isCustom
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: CustomTextField(
                      controller: _customController,
                      label: 'Enter your pronouns',
                      hint: 'e.g. Ze/Hir, She/They, He/They...',
                      errorText: errors['pronounsCustom'],
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      onChanged: (val) {
                        notifier.updatePronouns(
                          OnboardingOptions.customPronounsOption,
                          customPronouns: val,
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
