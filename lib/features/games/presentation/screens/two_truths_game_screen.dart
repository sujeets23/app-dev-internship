import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import '../../domain/models/game_models.dart';

/// Interactive Game 1: 2 Truths & a Lie
/// Guess which of the 3 statements is the lie, receive instant reveal animations,
/// track score across 3 rounds, and view the final shareable scorecard.
class TwoTruthsGameScreen extends ConsumerStatefulWidget {
  final String? matchName;

  const TwoTruthsGameScreen({super.key, this.matchName});

  @override
  ConsumerState<TwoTruthsGameScreen> createState() => _TwoTruthsGameScreenState();
}

class _TwoTruthsGameScreenState extends ConsumerState<TwoTruthsGameScreen> {
  int _currentRoundIndex = 0;
  int? _selectedLieIndex;
  bool _revealed = false;
  int _correctGuesses = 0;

  final List<TwoTruthsRound> _rounds = const [
    TwoTruthsRound(
      id: 'round_1',
      authorName: 'Aarya',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      statements: [
        'I have lived in 4 different countries before turning 22.',
        'I once spent a whole summer learning how to make wheel-thrown ceramics.',
        'I have never had a cup of specialty pour-over coffee.',
      ],
      lieIndex: 2,
      explanation: 'Statement #3 is the lie! Aarya is a certified coffee addict and brews pour-overs every morning.',
    ),
    TwoTruthsRound(
      id: 'round_2',
      authorName: 'Zayan',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      statements: [
        'I own more than 350 vinyl records in my personal collection.',
        'I have never been to an art museum in Mumbai.',
        'I designed a sustainable urban pavilion for my university thesis.',
      ],
      lieIndex: 1,
      explanation: 'Statement #2 is the lie! Zayan visits the National Gallery of Modern Art almost every other weekend.',
    ),
    TwoTruthsRound(
      id: 'round_3',
      authorName: 'Tara',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      statements: [
        'I can identify over 80 different species of native Indian trees.',
        'I have run three half-marathons along the Western Ghats.',
        'I secretly dislike masala chai and only drink peppermint tea.',
      ],
      lieIndex: 2,
      explanation: 'Statement #3 is the lie! Tara brews authentic artisanal masala chai every single afternoon.',
    ),
  ];

  TwoTruthsRound get _currentRound => _rounds[_currentRoundIndex];

  void _selectStatement(int index) {
    if (_revealed) return;
    setState(() {
      _selectedLieIndex = index;
    });
  }

  void _confirmGuess() {
    if (_selectedLieIndex == null) return;
    final isCorrect = _selectedLieIndex == _currentRound.lieIndex;
    setState(() {
      _revealed = true;
      if (isCorrect) {
        _correctGuesses++;
      }
    });
  }

  void _nextRound() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _selectedLieIndex = null;
        _revealed = false;
      });
    } else {
      _showScorecard();
    }
  }

  void _showScorecard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pct = ((_correctGuesses / _rounds.length) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.glanceableCyan.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.glanceableCyanDeep,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Game Complete!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You caught $_correctGuesses of ${_rounds.length} lies ($pct% Intuition score)!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Share Result to Chat'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.glanceableCyan,
                foregroundColor: AppColors.encreDeep,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();

                // Post scorecard message to chat
                ref
                    .read(conversationMessagesProvider('conv_1').notifier)
                    .sendMessage(
                      'I just finished playing 2 Truths & a Lie with you! Here is my scorecard 🕵️‍♂️',
                      gameScorecardSnippet: {
                        'gameTitle': 'Two Truths & a Lie',
                        'score':
                            '$_correctGuesses / ${_rounds.length} Caught ($pct%)',
                        'badge': pct >= 66
                            ? 'Master Lie Detective 🕵️‍♂️'
                            : 'Icebreaker Explorer ✨',
                        'highlights':
                            'Found out the truth about wheel-thrown ceramics and living abroad!',
                      },
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Scorecard shared into your match chat: "$_correctGuesses/${_rounds.length} Lies Caught ($pct%)"!',
                    ),
                    backgroundColor: AppColors.encreDeep,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final round = _currentRound;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '2 Truths & a Lie',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.glanceableCyanDeep,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Score: $_correctGuesses/${_rounds.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentRoundIndex + 1) / _rounds.length,
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.glanceableCyan,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Round Author Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(round.authorAvatar),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${round.authorName}'s Turn",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Round ${_currentRoundIndex + 1} of ${_rounds.length} • Spot the LIE',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Which of these 3 statements is a LIE?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Statement Cards
              Expanded(
                child: ListView.separated(
                  itemCount: round.statements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final statement = round.statements[index];
                    final isSelected = _selectedLieIndex == index;
                    final isTheLie = index == round.lieIndex;

                    Color cardBorderColor = isDark
                        ? AppColors.borderDark
                        : AppColors.border;
                    Color cardBgColor =
                        isDark ? AppColors.surfaceDark : AppColors.surface;

                    if (isSelected && !_revealed) {
                      cardBorderColor = AppColors.glanceableCyan;
                      cardBgColor = AppColors.glanceableCyan
                          .withValues(alpha: isDark ? 0.15 : 0.08);
                    } else if (_revealed) {
                      if (isTheLie) {
                        cardBorderColor = AppColors.error;
                        cardBgColor = AppColors.errorLight;
                      } else if (isSelected) {
                        cardBorderColor = Colors.orange;
                        cardBgColor = Colors.orange.withValues(alpha: 0.1);
                      }
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _selectStatement(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cardBorderColor,
                            width: isSelected || (_revealed && isTheLie)
                                ? 2.0
                                : 1.0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.glanceableCyan
                                    .withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.glanceableCyan
                                    : (isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.encreDeep
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statement,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (_revealed) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      isTheLie ? '💥 THE LIE!' : '✓ TRUTH',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isTheLie
                                            ? AppColors.error
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Reveal / Explanation box
              if (_revealed) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.glanceableCyanDeep,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          round.explanation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Bottom Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.glanceableCyan,
                    foregroundColor: AppColors.encreDeep,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _selectedLieIndex == null
                      ? null
                      : (_revealed ? _nextRound : _confirmGuess),
                  child: Text(
                    !_revealed
                        ? 'Confirm Guess'
                        : (_currentRoundIndex + 1 < _rounds.length
                            ? 'Next Round'
                            : 'View Results'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
