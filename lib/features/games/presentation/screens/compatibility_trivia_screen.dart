import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import '../../domain/models/game_models.dart';

/// Interactive Game 2: Compatibility Trivia
/// 5 multi-choice questions assessing lifestyle, dating habits, and romantic vibes.
/// Computes compatibility percentage and generates a shareable scorecard.
class CompatibilityTriviaScreen extends ConsumerStatefulWidget {
  final String? matchName;

  const CompatibilityTriviaScreen({super.key, this.matchName});

  @override
  ConsumerState<CompatibilityTriviaScreen> createState() =>
      _CompatibilityTriviaScreenState();
}

class _CompatibilityTriviaScreenState
    extends ConsumerState<CompatibilityTriviaScreen> {
  int _currentIndex = 0;
  final Map<int, int> _userAnswers = {};

  final List<TriviaQuestion> _questions = const [
    TriviaQuestion(
      question: 'Your ideal Saturday morning starts with:',
      options: [
        'Sleeping in peacefully until 11 AM',
        'Early pour-over coffee & a sunrise jog',
        'Baking pastries & listening to indie vinyl',
        'Spontaneous farmers market stroll with friends',
      ],
      recommendedIndex: 2,
      vibeCategory: 'Morning Routine',
    ),
    TriviaQuestion(
      question: 'When planning a first date, you prefer:',
      options: [
        'Cozy corner in a quiet specialty cafe',
        'Interactive activity like pottery or gallery hopping',
        'Lively indie concert or comedy gig',
        'Cooking a multi-course dinner at home',
      ],
      recommendedIndex: 1,
      vibeCategory: 'First Date Style',
    ),
    TriviaQuestion(
      question: 'Your primary emotional love language is:',
      options: [
        'Quality Time (undivided attention & deep talks)',
        'Words of Affirmation (genuine thoughtful notes)',
        'Physical Touch (warm embraces & hand holding)',
        'Acts of Service (bringing tea when stressed)',
      ],
      recommendedIndex: 0,
      vibeCategory: 'Love Language',
    ),
    TriviaQuestion(
      question: 'How do you handle social battery depletion?',
      options: [
        'Completely unplug with a book/game for 24 hours',
        'Low-key one-on-one hangout with my person',
        'Go for a long solo walk with my favorite playlist',
        'Cook a comforting meal and watch a comfort movie',
      ],
      recommendedIndex: 1,
      vibeCategory: 'Social Battery',
    ),
    TriviaQuestion(
      question: 'Your dream romantic getaway looks like:',
      options: [
        'Cozy secluded cabin in misty pine hills',
        'Bustling cultural city with art museums & street food',
        'Tropical beach bungalow listening to waves',
        'Scenic cross-country road trip with zero itinerary',
      ],
      recommendedIndex: 0,
      vibeCategory: 'Travel Vibe',
    ),
  ];

  TriviaQuestion get _currentQ => _questions[_currentIndex];

  void _selectOption(int index) {
    setState(() {
      _userAnswers[_currentIndex] = index;
    });
  }

  void _next() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate score
    int matchPoints = 0;
    _userAnswers.forEach((qIdx, ansIdx) {
      if (ansIdx == _questions[qIdx].recommendedIndex) {
        matchPoints += 20;
      } else {
        matchPoints += 15; // Partial compatibility vibe
      }
    });

    final compatibilityPct = matchPoints.clamp(60, 98);

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.glanceableCyan.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.glanceableCyan,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$compatibilityPct%',
                  style: const TextStyle(
                    color: AppColors.glanceableCyanDeep,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'High Vibe Alignment!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You and your matches share $compatibilityPct% lifestyle & relationship harmony based on 5 core values.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post Scorecard to Chat'),
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
                      'I just completed Compatibility Trivia with you! Here is our lifestyle harmony score ✨',
                      gameScorecardSnippet: {
                        'gameTitle': 'Compatibility Trivia',
                        'score': '$compatibilityPct% Vibe Match',
                        'badge': compatibilityPct >= 80
                            ? 'Soul Connection ✨'
                            : 'Dynamic Harmony 💫',
                        'highlights':
                            'Alikeness across first date preferences, social batteries & travel vibes!',
                      },
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Compatibility Scorecard ($compatibilityPct% Vibe Match) posted into your chat thread!',
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
    final q = _currentQ;
    final selectedOption = _userAnswers[_currentIndex];

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
          'Compatibility Trivia',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUESTION ${_currentIndex + 1} OF ${_questions.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.vibeCategory,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.glanceableCyanDeep,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.glanceableCyan,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                q.question,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              // Options List
              Expanded(
                child: ListView.separated(
                  itemCount: q.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = q.options[index];
                    final isSelected = selectedOption == index;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _selectOption(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.glanceableCyan
                                      .withValues(alpha: 0.15)
                                  : AppColors.glacierLight)
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.glanceableCyan
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.glanceableCyan
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.glanceableCyan
                                      : (isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.border),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: AppColors.encreDeep,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
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
                  onPressed: selectedOption == null ? null : _next,
                  child: Text(
                    _currentIndex + 1 < _questions.length
                        ? 'Next Question'
                        : 'Calculate Compatibility',
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
