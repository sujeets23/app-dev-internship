import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/onboarding_options.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/selection_pill_tile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 3: Gender Identity
class GenderIdentityScreen extends ConsumerStatefulWidget {
  const GenderIdentityScreen({super.key});

  @override
  ConsumerState<GenderIdentityScreen> createState() => _GenderIdentityScreenState();
}

class _GenderIdentityScreenState extends ConsumerState<GenderIdentityScreen> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final gender = ref.read(onboardingProvider).profile.genderIdentity;
    _customController = TextEditingController(text: gender?.customDescription ?? '');
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
    final gender = state.profile.genderIdentity;
    final errors = state.errors;

    final isSelfDescribed = gender?.isSelfDescribed ?? false;

    return OnboardingStepScaffold(
      currentStep: 2,
      totalSteps: 6,
      title: 'How do you identify?',
      subtitle:
          'Kindred is built on respectful identity affirmation. Choose the term that best fits who you are.',
      nextButtonLabel: state.editingFromReview ? 'Update Gender' : 'Continue',
      onBack: () => notifier.previousStep(),
      onNext: () {
        if (isSelfDescribed) {
          notifier.updateGenderIdentity(
            OnboardingOptions.selfDescribeOption,
            customDescription: _customController.text.trim(),
          );
        }
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errors.containsKey('gender')) ...[
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
                      errors['gender']!,
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

          // Render options list
          ...OnboardingOptions.genderIdentities.map((option) {
            final isSelected = gender?.option == option;
            return SelectionPillTile(
              title: option,
              isSelected: isSelected,
              onTap: () {
                notifier.updateGenderIdentity(
                  option,
                  customDescription: option == OnboardingOptions.selfDescribeOption
                      ? _customController.text
                      : null,
                );
              },
            );
          }),

          // Expandable custom description if self-describe is chosen
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: isSelfDescribed
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: CustomTextField(
                      controller: _customController,
                      label: 'Describe your gender identity',
                      hint: 'e.g. Two-Spirit, Demi-girl, Gender non-conforming...',
                      errorText: errors['genderCustom'],
                      maxLength: 50,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                      onChanged: (val) {
                        notifier.updateGenderIdentity(
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
