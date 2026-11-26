import 'gender_identity.dart';
import 'pronouns.dart';
import 'sexual_orientation.dart';

/// Comprehensive domain model for the user's onboarding profile
class OnboardingProfile {
  final String firstName;
  final DateTime? dateOfBirth;
  final String? profileImagePath;
  final String? presetAvatarId;
  final String bio;
  final String? sex; // Male, Female, Trans, Others
  final bool isSexVisible;
  final GenderIdentity? genderIdentity;
  final Pronouns? pronouns;
  final SexualOrientation? sexualOrientation;
  final List<String> interests;
  final List<String> matchSexPreferences; // Male, Female, Trans, Others
  final int minAgePreference;
  final int maxAgePreference;
  final int maxDistanceKm;
  final List<String> connectionPreferences;
  final bool isIncognitoEnabled;
  final bool isCompleted;

  const OnboardingProfile({
    this.firstName = '',
    this.dateOfBirth,
    this.profileImagePath,
    this.presetAvatarId,
    this.bio = '',
    this.sex,
    this.isSexVisible = true,
    this.genderIdentity,
    this.pronouns,
    this.sexualOrientation,
    this.interests = const [],
    this.matchSexPreferences = const [],
    this.minAgePreference = 18,
    this.maxAgePreference = 50,
    this.maxDistanceKm = 30,
    this.connectionPreferences = const [],
    this.isIncognitoEnabled = false,
    this.isCompleted = false,
  });

  factory OnboardingProfile.empty() => const OnboardingProfile();

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  bool get hasValidAge {
    final a = age;
    return a != null && a >= 18 && a <= 120;
  }

  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateOfBirth!.month - 1]} ${dateOfBirth!.day}, ${dateOfBirth!.year}';
  }

  String get displayGender => genderIdentity?.displayValue ?? 'Not specified';
  String get displayPronouns => pronouns?.displayValue ?? 'Not specified';
  String get displayOrientation => sexualOrientation?.displayValue ?? 'Not specified';
  String get displaySex => sex ?? 'Not specified';

  /// Profile completion score between 0.0 and 1.0 (0% to 100%)
  double get completionPercentage {
    double score = 0.0;
    if (firstName.trim().isNotEmpty) score += 0.15;
    if (dateOfBirth != null) score += 0.15;
    if (bio.trim().isNotEmpty) score += 0.10;
    if (sex != null && sex!.isNotEmpty) score += 0.15;
    if (genderIdentity != null) score += 0.10;
    if (pronouns != null) score += 0.10;
    if (sexualOrientation != null) score += 0.10;
    if (interests.length >= 3) score += 0.15;
    return score > 1.0 ? 1.0 : score;
  }

  int get completionPercentInt => (completionPercentage * 100).round();

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'profileImagePath': profileImagePath,
        'presetAvatarId': presetAvatarId,
        'bio': bio,
        'sex': sex,
        'isSexVisible': isSexVisible,
        'genderIdentity': genderIdentity?.toJson(),
        'pronouns': pronouns?.toJson(),
        'sexualOrientation': sexualOrientation?.toJson(),
        'interests': interests,
        'matchSexPreferences': matchSexPreferences,
        'minAgePreference': minAgePreference,
        'maxAgePreference': maxAgePreference,
        'maxDistanceKm': maxDistanceKm,
        'connectionPreferences': connectionPreferences,
        'isIncognitoEnabled': isIncognitoEnabled,
        'isCompleted': isCompleted,
      };

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      firstName: json['firstName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      profileImagePath: json['profileImagePath'] as String?,
      presetAvatarId: json['presetAvatarId'] as String?,
      bio: json['bio'] as String? ?? '',
      sex: json['sex'] as String?,
      isSexVisible: json['isSexVisible'] as bool? ?? true,
      genderIdentity: json['genderIdentity'] != null
          ? GenderIdentity.fromJson(
              Map<String, dynamic>.from(json['genderIdentity'] as Map))
          : null,
      pronouns: json['pronouns'] != null
          ? Pronouns.fromJson(Map<String, dynamic>.from(json['pronouns'] as Map))
          : null,
      sexualOrientation: json['sexualOrientation'] != null
          ? SexualOrientation.fromJson(
              Map<String, dynamic>.from(json['sexualOrientation'] as Map))
          : null,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      matchSexPreferences: (json['matchSexPreferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      minAgePreference: json['minAgePreference'] as int? ?? 18,
      maxAgePreference: json['maxAgePreference'] as int? ?? 50,
      maxDistanceKm: json['maxDistanceKm'] as int? ?? 30,
      connectionPreferences: (json['connectionPreferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isIncognitoEnabled: json['isIncognitoEnabled'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  OnboardingProfile copyWith({
    String? firstName,
    DateTime? dateOfBirth,
    String? profileImagePath,
    String? presetAvatarId,
    String? bio,
    String? sex,
    bool? isSexVisible,
    GenderIdentity? genderIdentity,
    Pronouns? pronouns,
    SexualOrientation? sexualOrientation,
    List<String>? interests,
    List<String>? matchSexPreferences,
    int? minAgePreference,
    int? maxAgePreference,
    int? maxDistanceKm,
    List<String>? connectionPreferences,
    bool? isIncognitoEnabled,
    bool? isCompleted,
    bool clearProfileImagePath = false,
    bool clearPresetAvatarId = false,
  }) {
    return OnboardingProfile(
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImagePath: clearProfileImagePath
          ? null
          : (profileImagePath ?? this.profileImagePath),
      presetAvatarId: clearPresetAvatarId
          ? null
          : (presetAvatarId ?? this.presetAvatarId),
      bio: bio ?? this.bio,
      sex: sex ?? this.sex,
      isSexVisible: isSexVisible ?? this.isSexVisible,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      pronouns: pronouns ?? this.pronouns,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      interests: interests ?? this.interests,
      matchSexPreferences: matchSexPreferences ?? this.matchSexPreferences,
      minAgePreference: minAgePreference ?? this.minAgePreference,
      maxAgePreference: maxAgePreference ?? this.maxAgePreference,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      connectionPreferences:
          connectionPreferences ?? this.connectionPreferences,
      isIncognitoEnabled: isIncognitoEnabled ?? this.isIncognitoEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
