import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/avatar_picker_widget.dart';
import 'package:inclusive_dating/core/widgets/custom_text_field.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 2: Basic Profile (First name, DOB, photo, bio)
class BasicProfileScreen extends ConsumerStatefulWidget {
  const BasicProfileScreen({super.key});

  @override
  ConsumerState<BasicProfileScreen> createState() => _BasicProfileScreenState();
}

class _BasicProfileScreenState extends ConsumerState<BasicProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(onboardingProvider).profile;
    _nameController = TextEditingController(text: profile.firstName);
    _bioController = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - AppConstants.minAge, now.month, now.day);
    final minDate = DateTime(now.year - AppConstants.maxAge, 1, 1);
    final initialDate = ref.read(onboardingProvider).profile.dateOfBirth ??
        DateTime(now.year - 24, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(maxDate) ? maxDate : initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'SELECT YOUR DATE OF BIRTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Theme.of(context).cardTheme.color ?? Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(onboardingProvider.notifier).updateBasicProfile(dateOfBirth: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final profile = state.profile;
    final errors = state.errors;

    return OnboardingStepScaffold(
      currentStep: 1,
      totalSteps: 6,
      title: 'The Essentials',
      subtitle: 'Introduce yourself with the basics so your potential connections can get to know you.',
      nextButtonLabel: state.editingFromReview ? 'Update Profile' : 'Continue',
      onBack: () => notifier.previousStep(),
      onNext: () {
        // Sync controllers first
        notifier.updateBasicProfile(
          firstName: _nameController.text.trim(),
          bio: _bioController.text.trim(),
        );
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Selector
          AvatarPickerWidget(
            imagePath: profile.profileImagePath,
            presetAvatarId: profile.presetAvatarId,
            onImageSelected: (path) {
              notifier.updateBasicProfile(
                profileImagePath: path,
                clearImage: path == null,
              );
            },
            onPresetAvatarSelected: (avatarId) {
              notifier.updateBasicProfile(
                presetAvatarId: avatarId,
              );
            },
          ),
          if (errors.containsKey('photo')) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                errors['photo']!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // First Name
          CustomTextField(
            controller: _nameController,
            label: 'First Name',
            hint: 'What should others call you?',
            errorText: errors['firstName'],
            textCapitalization: TextCapitalization.words,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            onChanged: (val) {
              notifier.updateBasicProfile(firstName: val.trim());
            },
          ),

          const SizedBox(height: 20),

          // Date of Birth
          Text(
            'Date of Birth',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDateOfBirth(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: errors.containsKey('dob')
                      ? AppColors.error
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: errors.containsKey('dob') ? 1.6 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      profile.dateOfBirth != null
                          ? '${profile.formattedDateOfBirth} (${profile.age} years old)'
                          : 'Select your birthday (18+ only)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: profile.dateOfBirth != null
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                            : AppColors.textTertiary,
                        fontWeight: profile.dateOfBirth != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (errors.containsKey('dob')) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                errors['dob']!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Bio
          CustomTextField(
            controller: _bioController,
            label: 'About You (Short Bio)',
            hint: 'Share a little about yourself, your hobbies, or what brings you here...',
            maxLines: 4,
            maxLength: AppConstants.maxBioLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (val) {
              notifier.updateBasicProfile(bio: val);
            },
          ),
        ],
      ),
    );
  }
}
