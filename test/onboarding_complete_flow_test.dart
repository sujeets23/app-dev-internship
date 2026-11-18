import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/features/onboarding/data/onboarding_local_storage.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingNotifier Complete Flow & Validation Tests', () {
    late ProviderContainer container;
    late OnboardingLocalStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = OnboardingLocalStorage(prefs);
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          onboardingLocalStorageProvider.overrideWithValue(storage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Full successful onboarding sequence', () async {
      final notifier = container.read(onboardingProvider.notifier);

      // 1. Welcome -> Start
      expect(container.read(onboardingProvider).currentStep, 0);
      notifier.startOnboarding();
      expect(container.read(onboardingProvider).currentStep, 1);

      // 2. Basic Profile Step validation
      // Failing validation when empty
      expect(notifier.nextStep(), isFalse);
      expect(container.read(onboardingProvider).errors.containsKey('firstName'), isTrue);

      // Fill Basic Profile with valid data
      notifier.updateBasicProfile(
        firstName: 'Sam',
        dateOfBirth: DateTime(1996, 4, 12),
        presetAvatarId: 'avatar_ocean',
        bio: 'Avid reader and trail hiker.',
      );
      expect(notifier.nextStep(), isTrue);
      expect(container.read(onboardingProvider).currentStep, 2);

      // 3. Gender Identity Step
      expect(notifier.nextStep(), isFalse); // No selection
      expect(container.read(onboardingProvider).errors.containsKey('gender'), isTrue);

      notifier.updateGenderIdentity('Non-binary');
      expect(notifier.nextStep(), isTrue);
      expect(container.read(onboardingProvider).currentStep, 3);

      // 4. Pronouns Step
      expect(notifier.nextStep(), isFalse); // No selection
      expect(container.read(onboardingProvider).errors.containsKey('pronouns'), isTrue);

      notifier.updatePronouns('They/Them');
      expect(notifier.nextStep(), isTrue);
      expect(container.read(onboardingProvider).currentStep, 4);

      // 5. Sexual Orientation Step
      expect(notifier.nextStep(), isFalse); // No selection
      expect(container.read(onboardingProvider).errors.containsKey('orientation'), isTrue);

      notifier.updateSexualOrientation(
        OnboardingOptions.selfDescribeOption,
        customDescription: 'Panromantic Asexual',
      );
      expect(notifier.nextStep(), isTrue);
      expect(container.read(onboardingProvider).currentStep, 5);

      // 6. Connection Preferences Step (Multi-select)
      expect(notifier.nextStep(), isFalse); // Empty selection
      expect(container.read(onboardingProvider).errors.containsKey('preferences'), isTrue);

      notifier.toggleConnectionPreference('Platonic friendship');
      notifier.toggleConnectionPreference('Social companionship');
      expect(container.read(onboardingProvider).profile.connectionPreferences.length, 2);
      expect(notifier.nextStep(), isTrue);
      expect(container.read(onboardingProvider).currentStep, 6); // Review Step

      // 7. Review Step: Edit Gender and Jump Back
      notifier.goToStep(2, fromReview: true);
      expect(container.read(onboardingProvider).currentStep, 2);
      expect(container.read(onboardingProvider).editingFromReview, isTrue);

      // Change gender
      notifier.updateGenderIdentity('Genderfluid');
      expect(notifier.nextStep(), isTrue);
      // Directly returns to Review step (6)
      expect(container.read(onboardingProvider).currentStep, 6);
      expect(container.read(onboardingProvider).editingFromReview, isFalse);
      expect(container.read(onboardingProvider).profile.genderIdentity?.option, 'Genderfluid');

      // 8. Complete Profile
      await notifier.completeProfile();
      expect(container.read(onboardingProvider).currentStep, 7); // Success Screen
      expect(container.read(onboardingProvider).profile.isCompleted, isTrue);
      expect(storage.isCompleted(), isTrue);
      expect(storage.loadProfileDraft()?.firstName, 'Sam');
    });

    test('Self-describe empty custom text validation', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.goToStep(2); // Gender Identity

      notifier.updateGenderIdentity(
        OnboardingOptions.selfDescribeOption,
        customDescription: '',
      );
      expect(notifier.nextStep(), isFalse);
      expect(container.read(onboardingProvider).errors.containsKey('genderCustom'), isTrue);

      notifier.updateGenderIdentity(
        OnboardingOptions.selfDescribeOption,
        customDescription: 'Agender spectrum',
      );
      expect(notifier.nextStep(), isTrue);
    });

    test('Under 18 years old validation fails', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.goToStep(1); // Basic profile

      final now = DateTime.now();
      notifier.updateBasicProfile(
        firstName: 'Jordan',
        dateOfBirth: DateTime(now.year - 16, now.month, now.day),
        presetAvatarId: 'avatar_sunset',
      );

      expect(notifier.nextStep(), isFalse);
      expect(container.read(onboardingProvider).errors['dob'],
          'You must be at least 18 years old to join');
    });
  });
}
