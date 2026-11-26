/// Domain models for the 3 Interactive Icebreaker Games (Feature 5)
library;

class TwoTruthsRound {
  final String id;
  final String authorName;
  final String authorAvatar;
  final List<String> statements;
  final int lieIndex; // 0, 1, or 2
  final String explanation;

  const TwoTruthsRound({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.statements,
    required this.lieIndex,
    required this.explanation,
  });
}

class TriviaQuestion {
  final String question;
  final List<String> options;
  final int recommendedIndex; // For ideal vibe alignment
  final String vibeCategory;

  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.recommendedIndex,
    required this.vibeCategory,
  });
}

class WouldYouRatherQuestion {
  final String id;
  final String optionA;
  final String optionB;
  final int percentA; // Community % choosing A
  final int percentB; // Community % choosing B
  final String category;

  const WouldYouRatherQuestion({
    required this.id,
    required this.optionA,
    required this.optionB,
    required this.percentA,
    required this.percentB,
    required this.category,
  });
}

class GameScorecard {
  final String gameTitle;
  final String subtitle;
  final int score;
  final int totalPossible;
  final int compatibilityPercent;
  final String shareText;

  const GameScorecard({
    required this.gameTitle,
    required this.subtitle,
    required this.score,
    required this.totalPossible,
    required this.compatibilityPercent,
    required this.shareText,
  });
}
