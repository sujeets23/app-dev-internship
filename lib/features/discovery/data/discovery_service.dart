import 'dart:async';
import '../domain/models/discovery_profile.dart';

abstract class IDiscoveryService {
  Future<List<DiscoveryProfile>> fetchDeck({
    bool incognitoShield = false,
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
    Set<String> excludedIds = const {},
  });
  Future<SwipeResult> sendSwipe({
    required String profileId,
    required SwipeDirection direction,
  });
}

/// Production API Client (targets GET /v1/discovery/deck & POST /v1/discovery/swipe)
class ProductionDiscoveryService implements IDiscoveryService {
  final String baseUrl;
  ProductionDiscoveryService({this.baseUrl = 'https://api.date2.app'});

  @override
  Future<List<DiscoveryProfile>> fetchDeck({
    bool incognitoShield = false,
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
    Set<String> excludedIds = const {},
  }) async {
    throw UnimplementedError('Production server at $baseUrl is offline.');
  }

  @override
  Future<SwipeResult> sendSwipe({
    required String profileId,
    required SwipeDirection direction,
  }) async {
    throw UnimplementedError('Production server at $baseUrl is offline.');
  }
}

/// Rich Mock Discovery Service with diverse inclusive profiles and stack isolation
class MockDiscoveryService implements IDiscoveryService {
  static const List<DiscoveryProfile> _allProfiles = [
    DiscoveryProfile(
      id: 'user_1',
      name: 'Aarya',
      age: 24,
      photoUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
      ],
      bio: 'Indie music lover, specialty pour-overs & weekend pottery. Looking for gentle conversations & genuine soul connections.',
      gender: 'Non-binary',
      pronouns: 'They/Them',
      orientation: 'Pansexual',
      preferences: ['Dating', 'Platonic friendship'],
      interests: ['Ceramics', 'Indie Rock', 'Coffee Roasts', 'Hiking', 'Film Photography'],
      distanceKm: 4,
      isVerified: true,
      matchPercentage: 94,
    ),
    DiscoveryProfile(
      id: 'user_2',
      name: 'Zayan',
      age: 27,
      photoUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
      ],
      bio: 'Architect by day, vinyl collector by night. Enthusiastic about art gallery hopping and queer literature.',
      gender: 'Man',
      pronouns: 'He/Him',
      orientation: 'Queer',
      preferences: ['Long-term relationship'],
      interests: ['Architecture', 'Vinyl Records', 'Museums & Galleries', 'Baking', 'Cycling'],
      distanceKm: 7,
      isVerified: true,
      matchPercentage: 88,
    ),
    DiscoveryProfile(
      id: 'user_3',
      name: 'Tara',
      age: 25,
      photoUrls: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      ],
      bio: 'Environmental educator & botanical garden regular. Let us talk about our favorite books over masala chai.',
      gender: 'Woman',
      pronouns: 'She/Her',
      orientation: 'Bisexual',
      preferences: ['Dating', 'Social companionship'],
      interests: ['Botanical Gardens', 'Coffee Roasts', 'Poetry', 'Yoga', 'Nature Walks'],
      distanceKm: 2,
      isVerified: true,
      matchPercentage: 91,
    ),
    DiscoveryProfile(
      id: 'user_4',
      name: 'Rohan',
      age: 29,
      photoUrls: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800',
      ],
      bio: 'Game designer & amateur pasta chef. Always down for spontaneous weekend road trips and museum dates.',
      gender: 'Genderfluid',
      pronouns: 'They/He',
      orientation: 'Queer',
      preferences: ['Casual dating', 'Platonic friendship'],
      interests: ['PC Gaming', 'Cooking', 'Road Trips', 'Indie Cinema', 'Board Games'],
      distanceKm: 11,
      isVerified: true,
      matchPercentage: 83,
    ),
    DiscoveryProfile(
      id: 'user_5',
      name: 'Maya',
      age: 26,
      photoUrls: [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      ],
      bio: 'Filmmaker and cafe hopper. Looking for deep conversations about arthouse cinema and weekend trail hikes.',
      gender: 'Woman',
      pronouns: 'She/They',
      orientation: 'Lesbian',
      preferences: ['Dating', 'Long-term relationship'],
      interests: ['Indie Cinema', 'Coffee Roasts', 'Hiking', 'Arthouse', 'Film Photography'],
      distanceKm: 5,
      isVerified: true,
      matchPercentage: 92,
    ),
    DiscoveryProfile(
      id: 'user_6',
      name: 'Priya',
      age: 26,
      photoUrls: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
      ],
      bio: 'Product manager and fitness lover. Enjoys trying new restaurants and attending live music concerts.',
      gender: 'Woman',
      pronouns: 'She/Her',
      orientation: 'Straight',
      preferences: ['Dating'],
      interests: ['Fine Dining', 'Live Gigs', 'Running', 'Weekend Getaways'],
      distanceKm: 6,
      isVerified: true,
      matchPercentage: 80,
    ),
    DiscoveryProfile(
      id: 'user_7',
      name: 'Vikram',
      age: 28,
      photoUrls: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800',
      ],
      bio: 'Software engineer and marathon runner. Always excited to explore mountain trails and board games.',
      gender: 'Man',
      pronouns: 'He/Him',
      orientation: 'Straight',
      preferences: ['Dating', 'Long-term relationship'],
      interests: ['Running', 'Board Games', 'Mountain Treks', 'PC Gaming'],
      distanceKm: 8,
      isVerified: false,
      matchPercentage: 76,
    ),
  ];

  @override
  Future<List<DiscoveryProfile>> fetchDeck({
    bool incognitoShield = false,
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
    Set<String> excludedIds = const {},
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<DiscoveryProfile> filtered = _allProfiles.where((p) {
      if (excludedIds.contains(p.id)) return false;
      if (incognitoShield && p.orientation == 'Straight') {
        return false;
      }
      if (minAge != null && p.age < minAge) return false;
      if (maxAge != null && p.age > maxAge) return false;
      if (maxDistanceKm != null && p.distanceKm > maxDistanceKm) return false;
      return true;
    });

    final result = filtered.toList();
    // If strict distance/age filter empties an unseen deck while unswiped non-incognito profiles exist, keep discovery usable
    if (result.isEmpty &&
        excludedIds.isEmpty &&
        (minAge != null || maxAge != null || maxDistanceKm != null)) {
      return _allProfiles
          .where((p) => !incognitoShield || p.orientation != 'Straight')
          .toList();
    }
    return result;
  }

  @override
  Future<SwipeResult> sendSwipe({
    required String profileId,
    required SwipeDirection direction,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final matchedProfile = _allProfiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => _allProfiles.first,
    );

    // Simulate match on swipe right or up
    final bool isMatch =
        direction == SwipeDirection.right || direction == SwipeDirection.up;

    return SwipeResult(
      isMatch: isMatch,
      profile: matchedProfile,
      conversationId: isMatch ? 'conv_match_$profileId' : null,
    );
  }
}
