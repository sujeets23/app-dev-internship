import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/features/onboarding/data/onboarding_local_storage.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/gender_identity.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/pronouns.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/sexual_orientation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingProfile Domain Model Tests', () {
    test('Calculates age correctly from dateOfBirth', () {
      final now = DateTime.now();
      final dob25 = DateTime(now.year - 25, now.month, now.day);
      final profile25 = OnboardingProfile(dateOfBirth: dob25);
      expect(profile25.age, 25);
      expect(profile25.hasValidAge, isTrue);

      final dob17 = DateTime(now.year - 17, now.month, now.day);
      final profile17 = OnboardingProfile(dateOfBirth: dob17);
      expect(profile17.age, 17);
      expect(profile17.hasValidAge, isFalse);
    });

    test('GenderIdentity returns custom description when self-described', () {
      const standard = GenderIdentity(option: 'Non-binary');
      expect(standard.displayValue, 'Non-binary');

      const custom = GenderIdentity(
        option: OnboardingOptions.selfDescribeOption,
        customDescription: 'Two-Spirit',
      );
      expect(custom.displayValue, 'Two-Spirit');
    });

    test('Pronouns returns custom pronouns when custom option chosen', () {
      const standard = Pronouns(option: 'They/Them');
      expect(standard.displayValue, 'They/Them');

      const custom = Pronouns(
        option: OnboardingOptions.customPronounsOption,
        customPronouns: 'Ze/Zir',
      );
      expect(custom.displayValue, 'Ze/Zir');
    });

    test('SexualOrientation returns custom description when self-described', () {
      const standard = SexualOrientation(option: 'Pansexual');
      expect(standard.displayValue, 'Pansexual');

      const custom = SexualOrientation(
        option: OnboardingOptions.selfDescribeOption,
        customDescription: 'Demisexual',
      );
      expect(custom.displayValue, 'Demisexual');
    });

    test('Serializes to and from JSON correctly', () {
      final profile = OnboardingProfile(
        firstName: 'Taylor',
        dateOfBirth: DateTime(2000, 5, 15),
        presetAvatarId: 'avatar_sunset',
        bio: 'Artist and tea enthusiast looking for meaningful connection.',
        genderIdentity: const GenderIdentity(option: 'Non-binary'),
        pronouns: const Pronouns(option: 'They/Them'),
        sexualOrientation: const SexualOrientation(option: 'Bisexual'),
        connectionPreferences: const ['Dating', 'Platonic friendship'],
        isCompleted: true,
      );

      final json = profile.toJson();
      final restored = OnboardingProfile.fromJson(json);

      expect(restored.firstName, 'Taylor');
      expect(restored.dateOfBirth, DateTime(2000, 5, 15));
      expect(restored.presetAvatarId, 'avatar_sunset');
      expect(restored.bio, 'Artist and tea enthusiast looking for meaningful connection.');
      expect(restored.genderIdentity?.option, 'Non-binary');
      expect(restored.pronouns?.option, 'They/Them');
      expect(restored.sexualOrientation?.option, 'Bisexual');
      expect(restored.connectionPreferences, ['Dating', 'Platonic friendship']);
      expect(restored.isCompleted, isTrue);
    });
  });

  group('OnboardingLocalStorage Tests', () {
    test('Saves and loads profile draft correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = OnboardingLocalStorage(prefs);

      expect(storage.loadProfileDraft(), isNull);
      expect(storage.isCompleted(), isFalse);

      final profile = OnboardingProfile(
        firstName: 'Alex',
        dateOfBirth: DateTime(1998, 10, 20),
        presetAvatarId: 'avatar_ocean',
      );

      await storage.saveProfileDraft(profile);
      await storage.saveCurrentStep(2);

      final loaded = storage.loadProfileDraft();
      expect(loaded, isNotNull);
      expect(loaded?.firstName, 'Alex');
      expect(storage.loadCurrentStep(), 2);

      await storage.setOnboardingCompleted(true);
      expect(storage.isCompleted(), isTrue);

      await storage.clearAll();
      expect(storage.loadProfileDraft(), isNull);
      expect(storage.isCompleted(), isFalse);
    });
  });
}
