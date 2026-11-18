/// Predefined options for inclusive onboarding
class OnboardingOptions {
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
