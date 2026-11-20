import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_dating/core/constants/app_constants.dart';
import '../domain/models/onboarding_profile.dart';

/// Handles saving and restoring onboarding progress from local storage
class OnboardingLocalStorage {
  final SharedPreferences _prefs;

  OnboardingLocalStorage(this._prefs);

  /// Saves the current profile state
  Future<bool> saveProfileDraft(OnboardingProfile profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      return await _prefs.setString(AppConstants.keyProfileDraft, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the saved profile draft, or null if none exists
  OnboardingProfile? loadProfileDraft() {
    try {
      final jsonString = _prefs.getString(AppConstants.keyProfileDraft);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return OnboardingProfile.fromJson(map);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Saves the user's active step index (0 = Welcome, 1 = Basic Profile, ..., 6 = Review, 7 = Complete)
  Future<bool> saveCurrentStep(int stepIndex) async {
    return await _prefs.setInt(AppConstants.keyCurrentStep, stepIndex);
  }

  /// Retrieves the saved step index
  int loadCurrentStep() {
    return _prefs.getInt(AppConstants.keyCurrentStep) ?? 0;
  }

  /// Marks profile as completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(AppConstants.keyIsCompleted, completed);
  }

  /// Checks if onboarding is already completed
  bool isCompleted() {
    return _prefs.getBool(AppConstants.keyIsCompleted) ?? false;
  }

  /// Clears onboarding data to start fresh
  Future<void> clearAll() async {
    await _prefs.remove(AppConstants.keyProfileDraft);
    await _prefs.remove(AppConstants.keyCurrentStep);
    await _prefs.remove(AppConstants.keyIsCompleted);
  }
}
