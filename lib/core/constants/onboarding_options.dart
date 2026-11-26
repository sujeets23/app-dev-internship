/// Predefined options for inclusive onboarding
class OnboardingOptions {
  // Strict 4-option Sex
  static const List<String> sexOptions = [
    'Male',
    'Female',
    'Trans',
    'Others',
  ];

  // Gender Identity options
  static const List<String> genderIdentities = [
    'Woman',
    'Man',
    'Non-binary',
    'Transgender',
    'Genderfluid',
    'Agender',
    'Prefer to self-describe',
    'Prefer not to say',
  ];

  static const String selfDescribeOption = 'Prefer to self-describe';
  static const String preferNotToSayOption = 'Prefer not to say';

  // Pronouns options
  static const List<String> standardPronouns = [
    'She/Her',
    'He/Him',
    'They/Them',
    'Custom pronouns',
  ];

  static const String customPronounsOption = 'Custom pronouns';

  // Sexual Orientation options
  static const List<String> sexualOrientations = [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Queer',
    'Questioning',
    'Prefer to self-describe',
    'Prefer not to say',
  ];

  // Categorized Interests (8 categories, minimum 3 required)
  static const Map<String, List<String>> interestCategories = {
    'Food & Cafes': [
      'Coffee Roasts',
      'Street Food',
      'Baking',
      'Fine Dining',
      'Vegan Eats',
      'Cocktails',
      'Matcha',
      'Cooking',
    ],
    'Music': [
      'Indie Rock',
      'R&B / Soul',
      'Electronic',
      'Vinyl Records',
      'Live Gigs',
      'Hip Hop',
      'Jazz',
      'Pop',
    ],
    'Movies': [
      'Indie Cinema',
      'Sci-Fi',
      'Documentaries',
      'Anime',
      'Horror',
      'Classic Film',
      'Arthouse',
      'Comedy',
    ],
    'Gaming': [
      'PC Gaming',
      'Board Games',
      'Console / PS5',
      'Nintendo Switch',
      'Co-op Games',
      'Tabletop RPGs',
      'Retro Games',
      'Esports',
    ],
    'Travel': [
      'Backpacking',
      'Road Trips',
      'Weekend Getaways',
      'Solo Travel',
      'Cultural Trips',
      'City Breaks',
      'Beach Vacations',
      'Mountain Treks',
    ],
    'Outdoors': [
      'Hiking',
      'Camping',
      'Cycling',
      'Rock Climbing',
      'Nature Walks',
      'Gardening',
      'Botanical Gardens',
      'Stargazing',
    ],
    'Sports': [
      'Yoga',
      'Running',
      'Badminton',
      'Swimming',
      'Gym / Lifting',
      'Football',
      'Pilates',
      'Martial Arts',
    ],
    'Art': [
      'Museums & Galleries',
      'Pottery / Ceramics',
      'Film Photography',
      'Painting',
      'Graphic Design',
      'Architecture',
      'Poetry',
      'Sculpture',
    ],
  };

  // Connection Preferences (Intent)
  static const List<Map<String, String>> connectionPreferences = [
    {
      'title': 'Dating',
      'subtitle': 'Open to meeting new people and going on dates',
      'icon': 'favorite_border',
    },
    {
      'title': 'Long-term relationship',
      'subtitle': 'Looking for a committed, lasting emotional bond',
      'icon': 'favorite',
    },
    {
      'title': 'Casual dating',
      'subtitle': 'Connecting with no high pressure or commitments',
      'icon': 'local_cafe_outlined',
    },
    {
      'title': 'Platonic friendship',
      'subtitle': 'Seeking genuine friends, shared activities, and talk',
      'icon': 'people_outline',
    },
    {
      'title': 'Social companionship',
      'subtitle': 'Safe company for events, dining, hobbies, or community',
      'icon': 'explore_outlined',
    },
  ];
}
