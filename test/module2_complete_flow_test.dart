import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/features/discovery/data/discovery_service.dart';
import 'package:inclusive_dating/features/discovery/domain/models/discovery_profile.dart';
import 'package:inclusive_dating/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:inclusive_dating/features/games/domain/models/game_models.dart';
import 'package:inclusive_dating/features/onboarding/data/onboarding_local_storage.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/gender_identity.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/pronouns.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/sexual_orientation.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Module 2: Feature 1 — Spectrum Identity Onboarding Domain & Validation', () {
    test('OnboardingProfile holds sex, interests, matchPreferences and computes completion percentage', () {
      final profile = OnboardingProfile(
        firstName: 'Taylor',
        dateOfBirth: DateTime(1998, 7, 20),
        bio: 'Pottery lover and indie vinyl enthusiast.',
        sex: 'Trans',
        isSexVisible: true,
        genderIdentity: const GenderIdentity(option: 'Non-binary'),
        pronouns: const Pronouns(option: 'They/Them'),
        sexualOrientation: const SexualOrientation(option: 'Queer'),
        interests: const ['Coffee Roasts', 'Indie Rock', 'Ceramics'],
        matchSexPreferences: const ['Female', 'Trans', 'Others'],
      );

      expect(profile.sex, 'Trans');
      expect(profile.isSexVisible, isTrue);
      expect(profile.interests.length, 3);
      expect(profile.matchSexPreferences.length, 3);
      expect(profile.completionPercentInt, greaterThanOrEqualTo(90));
    });

    test('OnboardingProfile JSON serialization preserves all Module 2 fields', () {
      final original = OnboardingProfile(
        firstName: 'Alex',
        dateOfBirth: DateTime(1996, 5, 12),
        bio: 'Graphic designer exploring city cafes.',
        sex: 'Others',
        isSexVisible: false,
        interests: const ['Specialty Coffee', 'Architecture', 'Cycling'],
        matchSexPreferences: const ['Male', 'Female', 'Trans', 'Others'],
        minAgePreference: 21,
        maxAgePreference: 35,
        maxDistanceKm: 25,
        isIncognitoEnabled: true,
      );

      final json = original.toJson();
      final restored = OnboardingProfile.fromJson(json);

      expect(restored.sex, 'Others');
      expect(restored.isSexVisible, isFalse);
      expect(restored.interests, ['Specialty Coffee', 'Architecture', 'Cycling']);
      expect(restored.matchSexPreferences, ['Male', 'Female', 'Trans', 'Others']);
      expect(restored.minAgePreference, 21);
      expect(restored.maxAgePreference, 35);
      expect(restored.maxDistanceKm, 25);
      expect(restored.isIncognitoEnabled, isTrue);
    });

    test('OnboardingOptions provides 4-option Sex and 8-category Interests', () {
      expect(OnboardingOptions.sexOptions, ['Male', 'Female', 'Trans', 'Others']);
      expect(OnboardingOptions.interestCategories.keys.length, 8);
      expect(OnboardingOptions.interestCategories.containsKey('Food & Cafes'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Music'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Movies'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Gaming'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Travel'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Outdoors'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Sports'), isTrue);
      expect(OnboardingOptions.interestCategories.containsKey('Art'), isTrue);
    });
  });

  group('Module 2: Feature 2 — Incognito Privacy Shield & Stack Isolation', () {
    test('MockDiscoveryService isolates queue: hides Straight profiles when shield is ON', () async {
      final service = MockDiscoveryService();

      // Normal mixed deck
      final regularDeck = await service.fetchDeck(incognitoShield: false);
      final hasStraight = regularDeck.any((p) => p.orientation == 'Straight');
      expect(hasStraight, isTrue);

      // Incognito Shield Active
      final shieldedDeck = await service.fetchDeck(incognitoShield: true);
      final hasStraightShielded = shieldedDeck.any((p) => p.orientation == 'Straight');
      expect(hasStraightShielded, isFalse);
      expect(shieldedDeck.every((p) => p.orientation != 'Straight'), isTrue);
    });

    test('IncognitoNotifier toggles and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(incognitoShieldProvider), isFalse);

      await container.read(incognitoShieldProvider.notifier).toggle();
      expect(container.read(incognitoShieldProvider), isTrue);

      await container.read(incognitoShieldProvider.notifier).set(false);
      expect(container.read(incognitoShieldProvider), isFalse);
    });
  });

  group('Module 2: Feature 3 — Discovery Swipe Deck & Swiping Logic', () {
    test('Swiping right produces match, moves to history, and updates deck', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(discoveryProvider.notifier);
      await notifier.loadDeck();
      // Allow any microtasks scheduled during notifier build to settle
      await Future.delayed(const Duration(milliseconds: 350));

      final initialCount = container.read(discoveryProvider).deck.length;
      expect(initialCount, greaterThan(0));

      final firstProfile = container.read(discoveryProvider).currentProfile;
      expect(firstProfile, isNotNull);

      // Perform Swipe Right (Like)
      final result = await notifier.swipe(SwipeDirection.right);
      expect(result, isNotNull);
      expect(result!.isMatch, isTrue);
      expect(container.read(discoveryProvider).history.length, 1);
      expect(container.read(discoveryProvider).deck.length, initialCount - 1);

      // Perform Undo
      notifier.undoSwipe();
      expect(container.read(discoveryProvider).deck.length, initialCount);
      expect(container.read(discoveryProvider).history.length, 0);
      expect(container.read(discoveryProvider).currentProfile?.id, firstProfile!.id);
    });
  });

  group('Module 2: Feature 4 — Personal Information Management', () {
    test('Updating full profile syncs with OnboardingNotifier and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = OnboardingLocalStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          onboardingLocalStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(onboardingProvider.notifier);
      const profile = OnboardingProfile(
        firstName: 'Sam',
        bio: 'Architect & art lover',
        sex: 'Male',
        isSexVisible: true,
        interests: ['Architecture', 'Modern Art', 'Baking'],
        matchSexPreferences: ['Female', 'Trans'],
      );

      notifier.updateFullProfile(profile);

      final stateProfile = container.read(onboardingProvider).profile;
      expect(stateProfile.firstName, 'Sam');
      expect(stateProfile.sex, 'Male');
      expect(stateProfile.interests.length, 3);
      expect(stateProfile.matchSexPreferences.length, 2);

      // Verify persistence in local storage
      final loaded = storage.loadProfileDraft();
      expect(loaded?.firstName, 'Sam');
      expect(loaded?.sex, 'Male');
    });
  });

  group('Module 2: Feature 5 — Icebreaker Games (2 Truths, Trivia, Would You Rather)', () {
    test('TwoTruthsRound correctly flags lie index', () {
      const round = TwoTruthsRound(
        id: 'r1',
        authorName: 'Aarya',
        authorAvatar: 'https://example.com/avatar.jpg',
        statements: ['Truth 1', 'Truth 2', 'Lie 1'],
        lieIndex: 2,
        explanation: 'Statement 3 is the lie!',
      );

      expect(round.lieIndex, 2);
      expect(round.statements[round.lieIndex], 'Lie 1');
    });

    test('TriviaQuestion defines recommendation and category', () {
      const q = TriviaQuestion(
        question: 'Ideal first date?',
        options: ['Cafe', 'Pottery', 'Concert', 'Dinner'],
        recommendedIndex: 1,
        vibeCategory: 'First Date Style',
      );

      expect(q.options[q.recommendedIndex], 'Pottery');
      expect(q.vibeCategory, 'First Date Style');
    });

    test('WouldYouRatherQuestion calculates percentage distribution', () {
      const dilemma = WouldYouRatherQuestion(
        id: 'd1',
        optionA: 'Cozy indoors',
        optionB: 'Sunset rooftop',
        percentA: 58,
        percentB: 42,
        category: 'Date Vibe',
      );

      expect(dilemma.percentA + dilemma.percentB, 100);
      expect(dilemma.percentA, 58);
    });
  });
}
