import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/onboarding_local_storage.dart';
import '../../domain/models/gender_identity.dart';
import '../../domain/models/onboarding_profile.dart';
import '../../domain/models/pronouns.dart';
import '../../domain/models/sexual_orientation.dart';
import 'onboarding_state.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main()');
});

/// Provider for Local Storage repository
final onboardingLocalStorageProvider = Provider<OnboardingLocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalStorage(prefs);
});

/// NotifierProvider for Onboarding workflow
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<OnboardingState> {
  OnboardingLocalStorage get _storage => ref.read(onboardingLocalStorageProvider);

  @override
  OnboardingState build() {
    final storage = ref.watch(onboardingLocalStorageProvider);
    final savedProfile = storage.loadProfileDraft();
    final savedStep = storage.loadCurrentStep();
    final isCompleted = storage.isCompleted();

    if (isCompleted && savedProfile != null) {
      return OnboardingState(
        currentStep: 7, // Success screen
        profile: savedProfile.copyWith(isCompleted: true),
        hasSavedDraft: true,
      );
    } else if (savedProfile != null) {
      return OnboardingState(
        currentStep: savedStep > 0 && savedStep <= 6 ? savedStep : 0,
        profile: savedProfile,
        hasSavedDraft: true,
      );
    }
    return OnboardingState.initial();
  }

  /// Start or resume onboarding from Welcome screen
  void startOnboarding() {
    state = state.copyWith(
      currentStep: 1,
      clearErrors: true,
    );
    _persistState();
  }

  /// Jump directly to any specific step (e.g. from Review Screen)
  void goToStep(int stepIndex, {bool fromReview = false}) {
    if (stepIndex < 0 || stepIndex > 7) return;
    state = state.copyWith(
      currentStep: stepIndex,
      editingFromReview: fromReview,
      clearErrors: true,
    );
    _persistState();
  }

  /// Navigate to previous step
  bool previousStep() {
    if (state.currentStep <= 0) {
      return false;
    }

    if (state.editingFromReview) {
      // If we jumped into an edit step from review, back takes us directly back to Review
      state = state.copyWith(
        currentStep: 6,
        editingFromReview: false,
        clearErrors: true,
      );
      _persistState();
      return true;
    }

    state = state.copyWith(
      currentStep: state.currentStep - 1,
      clearErrors: true,
    );
    _persistState();
    return true;
  }

  /// Update Basic Profile (Screen 2)
  void updateBasicProfile({
    String? firstName,
    DateTime? dateOfBirth,
    String? profileImagePath,
    String? presetAvatarId,
    String? bio,
    bool clearImage = false,
  }) {
    final updated = state.profile.copyWith(
      firstName: firstName,
      dateOfBirth: dateOfBirth,
      profileImagePath: profileImagePath,
      presetAvatarId: presetAvatarId,
      bio: bio,
      clearProfileImagePath: clearImage,
    );
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Update Gender Identity (Screen 3)
  void updateGenderIdentity(String option, {String? customDescription}) {
    final identity = GenderIdentity(
      option: option,
      customDescription: customDescription,
    );

    // Auto-sync sex classification for downstream discovery and compatibility filtering
    String? resolvedSex = state.profile.sex;
    if (option == 'Man') {
      resolvedSex = 'Male';
    } else if (option == 'Woman') {
      resolvedSex = 'Female';
    } else if (option == 'Transgender') {
      resolvedSex = 'Trans';
    } else if (resolvedSex == null || resolvedSex.isEmpty || resolvedSex == 'Male' || resolvedSex == 'Female') {
      resolvedSex = 'Others';
    }

    final updated = state.profile.copyWith(
      genderIdentity: identity,
      sex: resolvedSex,
    );

    // Clear step 2 validation errors immediately upon valid selection
    final updatedErrors = Map<String, String>.from(state.errors);
    updatedErrors.remove('gender');
    updatedErrors.remove('sex');
    if (!identity.isSelfDescribed ||
        (customDescription != null && customDescription.trim().isNotEmpty)) {
      updatedErrors.remove('genderCustom');
    }

    state = state.copyWith(profile: updated, errors: updatedErrors);
    _persistState();
  }

  /// Update Pronouns (Screen 4)
  void updatePronouns(String option, {String? customPronouns}) {
    final pronouns = Pronouns(
      option: option,
      customPronouns: customPronouns,
    );
    final updated = state.profile.copyWith(pronouns: pronouns);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Update Sexual Orientation (Screen 5)
  void updateSexualOrientation(String option, {String? customDescription}) {
    final orientation = SexualOrientation(
      option: option,
      customDescription: customDescription,
    );
    final updated = state.profile.copyWith(sexualOrientation: orientation);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Update Sex (strictly 4 options: Male, Female, Trans, Others)
  void updateSex(String sex, {bool? isVisible}) {
    final updated = state.profile.copyWith(
      sex: sex,
      isSexVisible: isVisible ?? state.profile.isSexVisible,
    );
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Toggle Sex visibility on profile
  void toggleSexVisibility(bool isVisible) {
    final updated = state.profile.copyWith(isSexVisible: isVisible);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Toggle an Interest tag (min 3 required)
  void toggleInterest(String interest) {
    final current = List<String>.from(state.profile.interests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    final updated = state.profile.copyWith(interests: current);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Set full list of interests
  void setInterests(List<String> interests) {
    final updated = state.profile.copyWith(interests: interests);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Toggle a Matching Sex Preference (Male, Female, Trans, Others)
  void toggleMatchSexPreference(String sex) {
    final current = List<String>.from(state.profile.matchSexPreferences);
    if (current.contains(sex)) {
      current.remove(sex);
    } else {
      current.add(sex);
    }
    final updated = state.profile.copyWith(matchSexPreferences: current);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Set matching sex preferences list
  void setMatchSexPreferences(List<String> preferences) {
    final updated = state.profile.copyWith(matchSexPreferences: preferences);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Update Discovery Preferences (Age range, Distance)
  void updateDiscoveryPreferences({
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
  }) {
    final updated = state.profile.copyWith(
      minAgePreference: minAge ?? state.profile.minAgePreference,
      maxAgePreference: maxAge ?? state.profile.maxAgePreference,
      maxDistanceKm: maxDistanceKm ?? state.profile.maxDistanceKm,
    );
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Toggle Incognito Privacy Shield
  void toggleIncognito(bool enabled) {
    final updated = state.profile.copyWith(isIncognitoEnabled: enabled);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Update full profile state (used by Personal Info screen)
  void updateFullProfile(OnboardingProfile profile) {
    state = state.copyWith(profile: profile);
    _persistState();
  }

  /// Update Connection Preferences (Screen 6 - Multiple selection supported)
  void toggleConnectionPreference(String preference) {
    final current = List<String>.from(state.profile.connectionPreferences);
    if (current.contains(preference)) {
      current.remove(preference);
    } else {
      current.add(preference);
    }
    final updated = state.profile.copyWith(connectionPreferences: current);
    state = state.copyWith(profile: updated);
    _persistState();
  }

  /// Validates the current step and advances if valid
  bool nextStep() {
    final errors = _validateStep(state.currentStep);
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return false;
    }

    state = state.copyWith(clearErrors: true);

    // If user was editing from review, jump directly back to review
    if (state.editingFromReview) {
      state = state.copyWith(
        currentStep: 6,
        editingFromReview: false,
      );
      _persistState();
      return true;
    }

    if (state.currentStep < 7) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      _persistState();
      return true;
    }

    return true;
  }

  /// Validates specific step
  Map<String, String> _validateStep(int step) {
    final errors = <String, String>{};

    switch (step) {
      case 1: // Screen 2: Basic Profile
        final name = state.profile.firstName.trim();
        if (name.isEmpty) {
          errors['firstName'] = 'Please enter your first name';
        } else if (name.length < 2) {
          errors['firstName'] = 'Name must be at least 2 characters';
        } else if (name.length > 30) {
          errors['firstName'] = 'Name cannot exceed 30 characters';
        }

        if (state.profile.dateOfBirth == null) {
          errors['dob'] = 'Please select your date of birth';
        } else {
          final age = state.profile.age;
          if (age == null || age < 18) {
            errors['dob'] = 'You must be at least 18 years old to join';
          }
        }

        final hasPhoto = (state.profile.profileImagePath != null &&
                state.profile.profileImagePath!.isNotEmpty) ||
            state.profile.presetAvatarId != null;
        if (!hasPhoto) {
          errors['photo'] = 'Please upload a photo or choose an avatar to continue';
        }
        break;

      case 2: // Screen 3: Gender Identity
        final gender = state.profile.genderIdentity;
        if (gender == null || gender.option.isEmpty) {
          errors['gender'] = 'Please select a gender identity option';
        } else if (gender.isSelfDescribed &&
            (gender.customDescription == null ||
                gender.customDescription!.trim().isEmpty)) {
          errors['genderCustom'] = 'Please describe your gender identity';
        }
        break;

      case 3: // Screen 4: Pronouns
        final pronouns = state.profile.pronouns;
        if (pronouns == null || pronouns.option.isEmpty) {
          errors['pronouns'] = 'Please select your pronouns';
        } else if (pronouns.isCustom &&
            (pronouns.customPronouns == null ||
                pronouns.customPronouns!.trim().isEmpty)) {
          errors['pronounsCustom'] = 'Please enter your custom pronouns';
        }
        break;

      case 4: // Screen 5: Sexual Orientation
        final orientation = state.profile.sexualOrientation;
        if (orientation == null || orientation.option.isEmpty) {
          errors['orientation'] = 'Please select your sexual orientation';
        } else if (orientation.isSelfDescribed &&
            (orientation.customDescription == null ||
                orientation.customDescription!.trim().isEmpty)) {
          errors['orientationCustom'] =
              'Please describe your sexual orientation';
        }
        break;

      case 5: // Screen 6: Connection Preferences
        if (state.profile.connectionPreferences.isEmpty) {
          errors['preferences'] =
              'Please select at least one connection preference';
        }
        break;

      default:
        break;
    }

    return errors;
  }

  /// Complete Profile (Screen 7)
  Future<void> completeProfile() async {
    state = state.copyWith(isSaving: true);

    final completedProfile = state.profile.copyWith(isCompleted: true);
    await _storage.saveProfileDraft(completedProfile);
    await _storage.setOnboardingCompleted(true);
    await _storage.saveCurrentStep(7);

    // Artificial short delay for smooth, satisfying UI transition
    await Future.delayed(const Duration(milliseconds: 350));

    state = state.copyWith(
      profile: completedProfile,
      currentStep: 7, // Success Screen
      isSaving: false,
    );
  }

  /// Resets onboarding data completely
  Future<void> resetOnboarding() async {
    await _storage.clearAll();
    state = OnboardingState.initial();
  }

  void _persistState() {
    _storage.saveProfileDraft(state.profile);
    _storage.saveCurrentStep(state.currentStep);
  }
}
