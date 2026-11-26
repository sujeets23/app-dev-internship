import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/custom_text_field.dart';
import 'package:inclusive_dating/core/widgets/selection_pill_tile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 2: Sex & Gender Identity
/// Features a strict 4-option Sex selector (Male, Female, Trans, Others) with visibility toggle,
/// followed by inclusive spectrum gender identity options.
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
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;
    final gender = profile.genderIdentity;
    final errors = state.errors;

    final isSelfDescribed = gender?.isSelfDescribed ?? false;

    return OnboardingStepScaffold(
      currentStep: 2,
      totalSteps: 6,
      title: 'How do you identify?',
      subtitle:
          'Date² is built on respectful identity affirmation. Select your sex and spectrum gender identity to help us tailor your experience.',
      nextButtonLabel: state.editingFromReview ? 'Update Identity' : 'Continue',
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
          // Error banners if any
          if (errors.containsKey('sex')) ...[
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
                      errors['sex']!,
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

          if (errors.containsKey('gender')) ...[
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

          // SECTION 1: STRICT 4-OPTION SEX SELECTOR
          Text(
            'SEX',
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
            'Select strictly one of the four categories below as per specifications.',
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
            children: OnboardingOptions.sexOptions.map((option) {
              final isSelected = profile.sex == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    notifier.updateSex(option);
                  }
                },
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.encreDeep
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                ),
                selectedColor: AppColors.glanceableCyan,
                backgroundColor:
                    isDark ? AppColors.surfaceDark : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.glanceableCyan
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Visibility Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      profile.isSexVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Show sex on profile',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Visible to discovery candidates',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: profile.isSexVisible,
                  activeColor: AppColors.glanceableCyanDeep,
                  activeTrackColor: AppColors.glanceableCyan,
                  onChanged: (val) {
                    notifier.toggleSexVisibility(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // SECTION 2: GENDER IDENTITY SPECTRUM
          Text(
            'GENDER IDENTITY SPECTRUM',
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
            'Choose the identity term that best affirms who you are.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Render spectrum options list
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

          // Self-describe custom text field
          if (isSelfDescribed) ...[
            const SizedBox(height: 8),
            CustomTextField(
              controller: _customController,
              label: 'Describe your gender identity',
              hint: 'e.g. Demiboy, Two-Spirit, Genderqueer',
              errorText: errors['genderCustom'],
              onChanged: (val) {
                notifier.updateGenderIdentity(
                  OnboardingOptions.selfDescribeOption,
                  customDescription: val,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
