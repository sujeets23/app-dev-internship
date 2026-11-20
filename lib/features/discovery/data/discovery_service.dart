import 'dart:async';
import '../domain/models/discovery_profile.dart';

abstract class IDiscoveryService {
  Future<List<DiscoveryProfile>> fetchDeck({bool incognitoShield = false});
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
  Future<List<DiscoveryProfile>> fetchDeck({bool incognitoShield = false}) async {
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

/// Rich Mock Discovery Service with diverse inclusive profiles
class MockDiscoveryService implements IDiscoveryService {
  @override
  Future<List<DiscoveryProfile>> fetchDeck({bool incognitoShield = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      const DiscoveryProfile(
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
        interests: ['Ceramics', 'Indie Rock', 'Coffee', 'Hiking', 'Film Photography'],
        distanceKm: 4,
        isVerified: true,
        matchPercentage: 94,
      ),
      const DiscoveryProfile(
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
        interests: ['Architecture', 'Vinyl', 'Modern Art', 'Baking', 'Cycling'],
        distanceKm: 7,
        isVerified: true,
        matchPercentage: 88,
      ),
      const DiscoveryProfile(
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
        interests: ['Botany', 'Chai', 'Literature', 'Yoga', 'Birdwatching'],
        distanceKm: 2,
        isVerified: false,
        matchPercentage: 91,
      ),
      const DiscoveryProfile(
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
        interests: ['Gaming', 'Cooking', 'Travel', 'Cinema', 'Board Games'],
        distanceKm: 11,
        isVerified: true,
        matchPercentage: 83,
      ),
    ];
  }

  @override
  Future<SwipeResult> sendSwipe({
    required String profileId,
    required SwipeDirection direction,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Simulate match on swipe right for high engagement
    final bool isMatch = direction == SwipeDirection.right || direction == SwipeDirection.up;
    return SwipeResult(
      isMatch: isMatch,
      profile: const DiscoveryProfile(
        id: 'user_1',
        name: 'Aarya',
        age: 24,
        photoUrls: ['https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800'],
        bio: 'Indie music lover & weekend pottery.',
        gender: 'Non-binary',
        pronouns: 'They/Them',
        orientation: 'Pansexual',
        preferences: ['Dating'],
        interests: ['Ceramics', 'Indie Rock'],
        distanceKm: 4,
        isVerified: true,
        matchPercentage: 94,
      ),
      conversationId: isMatch ? 'conv_match_$profileId' : null,
    );
  }
}
