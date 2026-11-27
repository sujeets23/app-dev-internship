import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import '../../domain/models/game_models.dart';

/// Interactive Game 3: Rapid-Fire Would You Rather
/// Tap between two lifestyle/dating dilemmas, reveal community voting consensus,
/// and generate a shareable game scorecard for chat.
class WouldYouRatherScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  final String? matchName;

  const WouldYouRatherScreen({
    super.key,
    this.conversationId,
    this.matchName,
  });

  @override
  ConsumerState<WouldYouRatherScreen> createState() =>
      _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends ConsumerState<WouldYouRatherScreen> {
  int _currentIndex = 0;
  final Map<int, String> _choices = {}; // 'A' or 'B'
  bool _revealed = false;

  final List<WouldYouRatherQuestion> _dilemmas = const [
    WouldYouRatherQuestion(
      id: 'wyr_1',
      optionA: 'Cozy rainy day date watching movies indoors',
      optionB: 'Golden hour sunset date on a vibrant rooftop',
      percentA: 58,
      percentB: 42,
      category: 'Date Vibe',
    ),
    WouldYouRatherQuestion(
      id: 'wyr_2',
      optionA: 'Spontaneous midnight drive with our favorite playlist',
      optionB: 'Meticulously planned weekend getaway with brunch spots',
      percentA: 64,
      percentB: 36,
      category: 'Spontaneity',
    ),
    WouldYouRatherQuestion(
      id: 'wyr_3',
      optionA: 'Partner who is an extraordinary home chef',
      optionB: 'Partner who is an extraordinary conversationalist & planner',
      percentA: 47,
      percentB: 53,
      category: 'Partner Traits',
    ),
    WouldYouRatherQuestion(
      id: 'wyr_4',
      optionA: 'Never have specialty coffee again',
      optionB: 'Never have dessert or sweet pastries again',
      percentA: 31,
      percentB: 69,
      category: 'Tough Choices',
    ),
    WouldYouRatherQuestion(
      id: 'wyr_5',
      optionA: 'Browse vintage bookstores & vinyl shops for hours',
      optionB: 'Explore modern art exhibitions & artisan design markets',
      percentA: 52,
      percentB: 48,
      category: 'Weekend Activity',
    ),
  ];

  WouldYouRatherQuestion get _currentDilemma => _dilemmas[_currentIndex];

  void _choose(String choice) {
    if (_revealed) return;
    setState(() {
      _choices[_currentIndex] = choice;
      _revealed = true;
    });
  }

  void _next() {
    if (_currentIndex + 1 < _dilemmas.length) {
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
    } else {
      _showScorecard();
    }
  }

  void _showScorecard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  Icons.compare_arrows_rounded,
                  color: AppColors.glanceableCyanDeep,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dilemmas Resolved!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You aligned with the community majority on 4 of 5 dilemma choices! Great conversation starters unlocked.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post Answers to Match Chat'),
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

                final targetConvId = widget.conversationId ?? 'conv_1';
                final targetLabel = widget.matchName ?? 'Aarya';

                // Post scorecard message to chosen match chat
                ref
                    .read(conversationMessagesProvider(targetConvId).notifier)
                    .sendMessage(
                      'I just finished Rapid-Fire Would You Rather${widget.matchName != null ? " with $targetLabel" : ""}! Send your picks next ✨',
                      gameScorecardSnippet: {
                        'gameTitle': 'Would You Rather',
                        'score': '5/5 Dilemmas Answered',
                        'badge': 'Bold Decision Maker ⚡',
                        'highlights':
                            'Turn-based dilemma picks ready to compare with $targetLabel!',
                      },
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Would You Rather answers shared to $targetLabel\'s chat!',
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
    final d = _currentDilemma;
    final userChoice = _choices[_currentIndex];

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
          'Would You Rather',
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
                    'DILEMMA ${_currentIndex + 1} OF ${_dilemmas.length}',
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
                      d.category,
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
                  value: (_currentIndex + 1) / _dilemmas.length,
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.glanceableCyan,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Would You Rather...',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Dilemma Cards
              Expanded(
                child: Column(
                  children: [
                    // OPTION A
                    Expanded(
                      child: _buildChoiceCard(
                        context,
                        choiceKey: 'A',
                        text: d.optionA,
                        percentage: d.percentA,
                        isSelected: userChoice == 'A',
                        isRevealed: _revealed,
                        isDark: isDark,
                      ),
                    ),

                    // "OR" Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // OPTION B
                    Expanded(
                      child: _buildChoiceCard(
                        context,
                        choiceKey: 'B',
                        text: d.optionB,
                        percentage: d.percentB,
                        isSelected: userChoice == 'B',
                        isRevealed: _revealed,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Button
              if (_revealed) ...[
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
                    onPressed: _next,
                    child: Text(
                      _currentIndex + 1 < _dilemmas.length
                          ? 'Next Dilemma'
                          : 'View Scorecard',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    'Tap Option A or B to vote & reveal community percentages',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(
    BuildContext context, {
    required String choiceKey,
    required String text,
    required int percentage,
    required bool isSelected,
    required bool isRevealed,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _choose(choiceKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.glanceableCyan.withValues(alpha: 0.16)
                  : AppColors.glacierLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.glanceableCyan
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.glanceableCyan.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.glanceableCyan
                        : (isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OPTION $choiceKey',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.encreDeep
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
                const Spacer(),
                if (isRevealed)
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? AppColors.glanceableCyanDeep
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            if (isRevealed) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSelected
                        ? AppColors.glanceableCyan
                        : (isDark
                            ? AppColors.textTertiaryDark
                            : Colors.grey[400]!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
