import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/onboarding_options.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/selection_pill_tile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 5: Sexual Orientation
class SexualOrientationScreen extends ConsumerStatefulWidget {
  const SexualOrientationScreen({super.key});

  @override
  ConsumerState<SexualOrientationScreen> createState() =>
      _SexualOrientationScreenState();
}

class _SexualOrientationScreenState
    extends ConsumerState<SexualOrientationScreen> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final orientation =
        ref.read(onboardingProvider).profile.sexualOrientation;
    _customController =
        TextEditingController(text: orientation?.customDescription ?? '');
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
    final orientation = state.profile.sexualOrientation;
    final errors = state.errors;

    final isSelfDescribed = orientation?.isSelfDescribed ?? false;

    return OnboardingStepScaffold(
      currentStep: 4,
      totalSteps: 6,
      title: 'What is your orientation?',
      subtitle:
          'Share how you experience attraction. You can always update or adjust your visibility later in settings.',
      nextButtonLabel:
          state.editingFromReview ? 'Update Orientation' : 'Continue',
      onBack: () => notifier.previousStep(),
      onNext: () {
        if (isSelfDescribed) {
          notifier.updateSexualOrientation(
            OnboardingOptions.selfDescribeOption,
            customDescription: _customController.text.trim(),
          );
        }
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errors.containsKey('orientation')) ...[
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
                      errors['orientation']!,
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

          // Orientation options list
          ...OnboardingOptions.sexualOrientations.map((option) {
            final isSelected = orientation?.option == option;
            return SelectionPillTile(
              title: option,
              isSelected: isSelected,
              onTap: () {
                notifier.updateSexualOrientation(
                  option,
                  customDescription: option == OnboardingOptions.selfDescribeOption
                      ? _customController.text
                      : null,
                );
              },
            );
          }),

          // Expandable custom description if self-describe chosen
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: isSelfDescribed
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: CustomTextField(
                      controller: _customController,
                      label: 'Describe your orientation',
                      hint: 'e.g. Demisexual, Graysexual, Sapiosexual...',
                      errorText: errors['orientationCustom'],
                      maxLength: 50,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                      onChanged: (val) {
                        notifier.updateSexualOrientation(
                          OnboardingOptions.selfDescribeOption,
                          customDescription: val,
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
