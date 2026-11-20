class DiscoveryProfile {
  final String id;
  final String name;
  final int age;
  final List<String> photoUrls;
  final String bio;
  final String gender;
  final String pronouns;
  final String orientation;
  final List<String> preferences;
  final List<String> interests;
  final int distanceKm;
  final bool isVerified;
  final int matchPercentage;

  const DiscoveryProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.photoUrls,
    required this.bio,
    required this.gender,
    required this.pronouns,
    required this.orientation,
    required this.preferences,
    required this.interests,
    required this.distanceKm,
    required this.isVerified,
    required this.matchPercentage,
  });

  factory DiscoveryProfile.fromJson(Map<String, dynamic> json) {
    return DiscoveryProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      bio: json['bio'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Non-binary',
      pronouns: json['pronouns'] as String? ?? 'They/Them',
      orientation: json['orientation'] as String? ?? 'Pansexual',
      preferences: List<String>.from(json['preferences'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      distanceKm: json['distance_km'] as int? ?? 3,
      isVerified: json['is_verified'] as bool? ?? false,
      matchPercentage: json['match_percentage'] as int? ?? 85,
    );
  }
}

enum SwipeDirection { left, right, up }

class SwipeResult {
  final bool isMatch;
  final DiscoveryProfile profile;
  final String? conversationId;

  const SwipeResult({
    required this.isMatch,
    required this.profile,
    this.conversationId,
  });
}
