import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'compatibility_trivia_screen.dart';
import 'two_truths_game_screen.dart';
import 'would_you_rather_screen.dart';

/// Feature 5 (GAME Tab): Interactive Icebreaker Games Lobby
/// Features 3 playable games: 2 Truths & a Lie, Compatibility Trivia, and Would You Rather.
class GamesLobbyScreen extends StatelessWidget {
  const GamesLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Icebreaker Games',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Break the ice with your matches through fun, interactive games. Completed scorecards post directly into your chat!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Game 1: 2 Truths & a Lie
              _buildGameCard(
                context,
                title: '2 Truths & a Lie',
                tag: 'POPULAR ICEBREAKER',
                description:
                    'Read 3 statements from your match and spot the lie. Fast-paced, surprising, and instant conversation starter.',
                icon: Icons.psychology_alt_rounded,
                iconColor: AppColors.glanceableCyanDeep,
                tagColor: AppColors.glanceableCyan,
                badgeText: '3 Rounds • Intuition Score',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TwoTruthsGameScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Game 2: Compatibility Trivia
              _buildGameCard(
                context,
                title: 'Compatibility Trivia',
                tag: 'VIBE HARMONY',
                description:
                    'Answer 5 lifestyle and dating scenario questions to calculate your mutual compatibility vibe percentage.',
                icon: Icons.quiz_rounded,
                iconColor: const Color(0xFF6C5CE7),
                tagColor: const Color(0xFF6C5CE7),
                badgeText: '5 Questions • % Match Result',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CompatibilityTriviaScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Game 3: Would You Rather
              _buildGameCard(
                context,
                title: 'Would You Rather',
                tag: 'RAPID-FIRE DILEMMAS',
                description:
                    'Choose between 5 spontaneous date and lifestyle dilemmas. See live community votes and compare with your match.',
                icon: Icons.compare_arrows_rounded,
                iconColor: const Color(0xFFFF7675),
                tagColor: const Color(0xFFFF7675),
                badgeText: '5 Dilemmas • Community Consensus',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WouldYouRatherScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String tag,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color tagColor,
    required String badgeText,
    required bool isDark,
    required VoidCallback onPlay,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: tagColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
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
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: AppColors.glanceableCyanDeep,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Play'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.glanceableCyan,
                  foregroundColor: AppColors.encreDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPlay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
