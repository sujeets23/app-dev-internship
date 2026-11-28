import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/features/chat/domain/models/chat_message.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'compatibility_trivia_screen.dart';
import 'this_or_that_game_screen.dart';
import 'two_truths_game_screen.dart';
import 'would_you_rather_screen.dart';

/// Feature 5 (GAME Tab): Interactive Icebreaker Games Lobby
/// Supports Solo & Turn-Based Match modes for all 3 games and posts
/// completed scorecards directly into the chosen match's chat thread.
class GamesLobbyScreen extends ConsumerStatefulWidget {
  final String? defaultMatchConversationId;
  final String? defaultMatchName;

  const GamesLobbyScreen({
    super.key,
    this.defaultMatchConversationId,
    this.defaultMatchName,
  });

  @override
  ConsumerState<GamesLobbyScreen> createState() => _GamesLobbyScreenState();
}

class _GamesLobbyScreenState extends ConsumerState<GamesLobbyScreen> {
  bool _isMatchMode = true;
  late String _selectedConversationId;
  late String _selectedMatchName;

  @override
  void initState() {
    super.initState();
    _selectedConversationId = widget.defaultMatchConversationId ?? 'conv_1';
    _selectedMatchName = widget.defaultMatchName ?? 'Aarya';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final convs = ref
        .watch(conversationsProvider)
        .maybeWhen(data: (v) => v, orElse: () => const <ChatConversation>[]);
    final accent = AppColors.adaptiveAccent(isDark);
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Icebreaker Games',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Play solo practice or turn-based rounds with a match and share your scorecard straight to chat.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Solo vs Match Mode Selector Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.adaptiveBorder(isDark)),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('With a Match')),
                            selected: _isMatchMode,
                            selectedColor: AppColors.glanceableCyan,
                            labelStyle: TextStyle(
                              color: _isMatchMode
                                  ? AppColors.encreDeep
                                  : textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (_) =>
                                setState(() => _isMatchMode = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Solo Mode')),
                            selected: !_isMatchMode,
                            selectedColor: AppColors.glanceableCyan,
                            labelStyle: TextStyle(
                              color: !_isMatchMode
                                  ? AppColors.encreDeep
                                  : textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (_) =>
                                setState(() => _isMatchMode = false),
                          ),
                        ),
                      ],
                    ),
                    if (_isMatchMode) ...[
                      const SizedBox(height: 12),
                      Text(
                        'PLAYING TURN-BASED ROUND WITH:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (convs.isEmpty)
                        Text(
                          '$_selectedMatchName (Demo Match)',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: convs.map((c) {
                              final isSel =
                                  _selectedConversationId == c.id ||
                                      _selectedMatchName == c.participantName;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  avatar: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(c.participantAvatar),
                                  ),
                                  label: Text(c.participantName),
                                  selected: isSel,
                                  selectedColor: isDark
                                      ? AppColors.encreElevated
                                      : AppColors.glacierLight,
                                  side: BorderSide(
                                    color: isSel
                                        ? accent
                                        : AppColors.adaptiveBorder(isDark),
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedConversationId = c.id;
                                      _selectedMatchName = c.participantName;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Featured Game: This or That (Unmute Break The Ice)
              _buildGameCard(
                context,
                title: 'This or That',
                tag: 'BREAK THE ICE',
                description: _isMatchMode
                    ? 'Pick your escape between Beach or Mountains and reveal where you and $_selectedMatchName align or clash.'
                    : 'Compare your lifestyle escapes and reveal community harmony answers.',
                icon: Icons.flare_rounded,
                iconColor: const Color(0xFFFF5C38),
                tagColor: const Color(0xFFFF5C38),
                badgeText: 'Live Reveal • Match Mode',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ThisOrThatGameScreen(
                        conversationId:
                            _isMatchMode ? _selectedConversationId : null,
                        matchName: _isMatchMode ? _selectedMatchName : null,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Game 1: 2 Truths & a Lie
              _buildGameCard(
                context,
                title: '2 Truths & a Lie',
                tag: 'POPULAR ICEBREAKER',
                description: _isMatchMode
                    ? 'Spot $_selectedMatchName\'s lie across 3 rounds & send your own 2 Truths + 1 Lie turn.'
                    : 'Read 3 statements and spot the lie in solo intuition practice mode.',
                icon: Icons.psychology_alt_rounded,
                iconColor: AppColors.glanceableCyanDeep,
                tagColor: AppColors.glanceableCyanDeep,
                badgeText: '3 Rounds • Turn-Based Mode',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TwoTruthsGameScreen(
                        conversationId:
                            _isMatchMode ? _selectedConversationId : null,
                        matchName: _isMatchMode ? _selectedMatchName : null,
                      ),
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
                description: _isMatchMode
                    ? 'Compare 5 lifestyle & date answers with $_selectedMatchName to compute your harmony score.'
                    : 'Answer 5 dating lifestyle scenario questions in solo reflection mode.',
                icon: Icons.quiz_rounded,
                iconColor: isDark ? AppColors.accent : AppColors.primary,
                tagColor: isDark ? AppColors.accent : AppColors.primary,
                badgeText: '5 Questions • % Match Result',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompatibilityTriviaScreen(
                        conversationId:
                            _isMatchMode ? _selectedConversationId : null,
                        matchName: _isMatchMode ? _selectedMatchName : null,
                      ),
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
                description: _isMatchMode
                    ? 'Compare 5 rapid-fire dilemmas side by side with $_selectedMatchName & community picks.'
                    : 'Explore 5 spontaneous date & lifestyle dilemmas with live community stats.',
                icon: Icons.compare_arrows_rounded,
                iconColor: AppColors.warning,
                tagColor: AppColors.warning,
                badgeText: '5 Dilemmas • Consensus',
                isDark: isDark,
                onPlay: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WouldYouRatherScreen(
                        conversationId:
                            _isMatchMode ? _selectedConversationId : null,
                        matchName: _isMatchMode ? _selectedMatchName : null,
                      ),
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
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: AppColors.glanceableCyanDeep,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        badgeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Play'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.glanceableCyan,
                  foregroundColor: AppColors.encreDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
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
