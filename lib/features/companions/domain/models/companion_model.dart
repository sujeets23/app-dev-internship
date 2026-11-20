class CompanionModel {
  final String id;
  final String name;
  final int age;
  final String avatarUrl;
  final List<String> photos;
  final String tagLine;
  final String bio;
  final double hourlyRate;
  final List<String> languages;
  final List<String> specialties; // e.g., Gallery & Arts, Business Dinner, Tech Events
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isBackgroundChecked;
  final List<CompanionReview> reviews;

  const CompanionModel({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarUrl,
    required this.photos,
    required this.tagLine,
    required this.bio,
    required this.hourlyRate,
    required this.languages,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    this.isVerified = true,
    this.isBackgroundChecked = true,
    this.reviews = const [],
  });
}

class CompanionReview {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  const CompanionReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
