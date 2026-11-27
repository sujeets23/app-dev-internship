/// Domain model representing a matched friend with active status,
/// real-time presence, and live activities.
class ActiveFriend {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String activityStatus;
  final String lastActive;
  final bool isVerified;
  final List<String> sharedInterests;
  final String conversationId;
  final String bioSnippet;
  final int compatibilityPct;

  const ActiveFriend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    required this.activityStatus,
    required this.lastActive,
    this.isVerified = true,
    this.sharedInterests = const [],
    required this.conversationId,
    this.bioSnippet = '',
    this.compatibilityPct = 90,
  });

  /// Rich mock pool of active friends with diverse live statuses
  static const List<ActiveFriend> mockFriends = [
    ActiveFriend(
      id: 'friend_1',
      name: 'Aarya',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      isOnline: true,
      activityStatus: 'Brewing Coffee ☕',
      lastActive: 'Just now',
      isVerified: true,
      sharedInterests: ['Ceramics', 'Coffee Roasts', 'Indie Rock'],
      conversationId: 'conv_1',
      bioSnippet: 'Specialty pour-overs & wheel-thrown ceramics regular.',
      compatibilityPct: 94,
    ),
    ActiveFriend(
      id: 'friend_2',
      name: 'Zayan',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      isOnline: true,
      activityStatus: 'Boygenius 🎵',
      lastActive: 'Active now',
      isVerified: true,
      sharedInterests: ['Architecture', 'Vinyl Records', 'Museums'],
      conversationId: 'conv_2',
      bioSnippet: 'Architect and vinyl collector. Ready for a gallery walk.',
      compatibilityPct: 88,
    ),
    ActiveFriend(
      id: 'friend_3',
      name: 'Tara',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      isOnline: true,
      activityStatus: 'Playing Trivia 🎮',
      lastActive: 'Active now',
      isVerified: true,
      sharedInterests: ['Botanical Gardens', 'Poetry', 'Nature Walks'],
      conversationId: 'conv_3',
      bioSnippet: 'Botanical educator. Always up for a masala chai date.',
      compatibilityPct: 91,
    ),
    ActiveFriend(
      id: 'friend_4',
      name: 'Kabir',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      isOnline: true,
      activityStatus: 'Songwriting 🎸',
      lastActive: 'Just now',
      isVerified: true,
      sharedInterests: ['Indie Rock', 'Songwriting', 'Film Photography'],
      conversationId: 'conv_user_8',
      bioSnippet: 'Songwriter in Bandra. Let us swap indie playlists.',
      compatibilityPct: 93,
    ),
    ActiveFriend(
      id: 'friend_5',
      name: 'Maya',
      avatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      isOnline: true,
      activityStatus: 'At Art Gallery 🎨',
      lastActive: 'Active now',
      isVerified: true,
      sharedInterests: ['Indie Cinema', 'Hiking', 'Arthouse'],
      conversationId: 'conv_user_5',
      bioSnippet: 'Filmmaker exploring arthouse cinema and trail hikes.',
      compatibilityPct: 92,
    ),
    ActiveFriend(
      id: 'friend_6',
      name: 'Samira',
      avatarUrl:
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400',
      isOnline: false,
      activityStatus: 'Sunset Yoga 🧘',
      lastActive: '5m ago',
      isVerified: true,
      sharedInterests: ['Yoga', 'Baking', 'Nature Walks'],
      conversationId: 'conv_user_10',
      bioSnippet: 'Yoga teacher and sourdough baker. Seeking good vibes.',
      compatibilityPct: 95,
    ),
    ActiveFriend(
      id: 'friend_7',
      name: 'Rohan',
      avatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
      isOnline: true,
      activityStatus: 'In Vanish Mode 👻',
      lastActive: 'Active now',
      isVerified: true,
      sharedInterests: ['PC Gaming', 'Cooking', 'Road Trips'],
      conversationId: 'conv_user_4',
      bioSnippet: 'Game designer & amateur pasta chef.',
      compatibilityPct: 83,
    ),
    ActiveFriend(
      id: 'friend_8',
      name: 'Nia',
      avatarUrl:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      isOnline: true,
      activityStatus: 'DJ Rehearsal 🎧',
      lastActive: 'Just now',
      isVerified: true,
      sharedInterests: ['Electronic Music', 'Night Cycling', 'Street Art'],
      conversationId: 'conv_user_13',
      bioSnippet: 'Sound designer curating ambient electronic tracks.',
      compatibilityPct: 92,
    ),
    ActiveFriend(
      id: 'friend_9',
      name: 'Dev',
      avatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400',
      isOnline: false,
      activityStatus: 'Coastal Cycling 🚴',
      lastActive: '12m ago',
      isVerified: true,
      sharedInterests: ['Cycling', 'Architecture', 'Podcasts'],
      conversationId: 'conv_user_11',
      bioSnippet: 'Cycling through coastal routes and designing UX.',
      compatibilityPct: 86,
    ),
  ];
}
