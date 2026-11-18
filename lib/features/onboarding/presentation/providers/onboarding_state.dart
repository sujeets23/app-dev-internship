import '../../domain/models/onboarding_profile.dart';

/// State of the onboarding workflow
class OnboardingState {
  final int currentStep; // 0: Welcome, 1..6: steps, 7: Review, 8: Success
  final OnboardingProfile profile;
  final bool isLoading;
  final bool isSaving;
  final Map<String, String> errors;
  final bool hasSavedDraft;
  final bool editingFromReview;

  const OnboardingState({
    this.currentStep = 0,
    required this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errors = const {},
    this.hasSavedDraft = false,
    this.editingFromReview = false,
  });

  factory OnboardingState.initial() => OnboardingState(
        profile: OnboardingProfile.empty(),
      );

  bool get isWelcome => currentStep == 0;
  bool get isReview => currentStep == 7;
  bool get isSuccess => currentStep == 8;

  // Total flow steps excluding welcome and success (Steps 1 to 7)
  static const int totalQuestions = 7;

  OnboardingState copyWith({
    int? currentStep,
    OnboardingProfile? profile,
    bool? isLoading,
    bool? isSaving,
    Map<String, String>? errors,
    bool? hasSavedDraft,
    bool? editingFromReview,
    bool clearErrors = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errors: clearErrors ? const {} : (errors ?? this.errors),
      hasSavedDraft: hasSavedDraft ?? this.hasSavedDraft,
      editingFromReview: editingFromReview ?? this.editingFromReview,
    );
  }
}
