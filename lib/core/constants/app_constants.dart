/// Core application constants
class AppConstants {
  static const String appName = 'Date²';
  static const String appTagline = 'Date Smart • Connect Meaningfully';
  static const String welcomeSubtitle =
      'A respectful, affirming space designed to help you find meaningful romantic '
      'connections and safe companionship on your own terms.';

  // Storage Keys
  static const String keyProfileDraft = 'onboarding_profile_draft_v1';
  static const String keyCurrentStep = 'onboarding_current_step_v1';
  static const String keyIsCompleted = 'onboarding_is_completed_v1';

  // Validation
  static const int minAge = 18;
  static const int maxAge = 105;
  static const int minNameLength = 2;
  static const int maxNameLength = 40;
  static const int maxBioLength = 280;
}
