import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/games/presentation/screens/games_lobby_screen.dart';
import '../../domain/models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'incoming_call_screen.dart';
import 'outgoing_call_screen.dart';

/// Module 3 Feature 1, 2, 3 + Section 6: Chat Workspace
/// Specialized 4-Mode Workspace:
/// - Mode A: AI Wingman (icebreakers, witty replies, coach advice)
/// - Mode B: Date Planner (in-chat modal, multi-stop proposal card with accept, vote on stops, request refinements)
/// - Mode C: Vanish Mode (ephemeral theme, 10s/30s/60s TTL, simulated screenshot detection alert)
/// - Mode D: VC Mode (mutual video consent handshake, incoming/outgoing call, TFLite NSFW moderation HUD)
/// Plus: Shared interests badges in header & Game Scorecard card rendering.
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String participantAvatar;
  final bool isVerified;
  final List<String>? sharedInterests;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    required this.participantAvatar,
    this.isVerified = false,
    this.sharedInterests,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mode C: Vanish Mode State
  bool _isVanishMode = false;
  int _vanishTtlSeconds = 10;
  bool _screenshotAlertVisible = false;
  String? _screenshotAlertText;

  // Mode B: Date Proposal Interaction State
  bool _isDateAccepted = false;
  final Set<int> _upvotedStops = {};
  final Set<int> _downvotedStops = {};
  bool _showStopVoting = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    ref.read(conversationMessagesProvider(widget.conversationId).notifier).sendMessage(
          text,
          isVanish: _isVanishMode,
          ttlSeconds: _isVanishMode ? _vanishTtlSeconds : null,
        );
    _scrollToBottom();
  }

  void _simulateScreenshot() {
    setState(() {
      _screenshotAlertVisible = true;
      _screenshotAlertText =
          '⚠️ Screenshot Alert! ${widget.participantName} captured a screen of this ephemeral conversation.';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1326),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text(
              'Screenshot Detected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Date² Vanish Shield detected an active screen capture event by ${widget.participantName}. In accordance with ephemeral security standards, both participants are alerted and message TTL remains strictly enforced.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glanceableCyan,
              foregroundColor: AppColors.encreDeep,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Understood',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(conversationMessagesProvider(widget.conversationId));
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;

    // Ephemeral styling for Vanish Mode
    final bgColor = _isVanishMode
        ? const Color(0xFF0D111A)
        : (isDark ? AppColors.backgroundDark : AppColors.background);
    final surfaceColor = _isVanishMode
        ? const Color(0xFF141926)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = _isVanishMode
        ? const Color(0xFFFF5252)
        : AppColors.adaptiveAccent(isDark);

    final displayInterests = widget.sharedInterests ??
        const ['Coffee Roasts', 'Indie Rock', 'Art Gallery'];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(widget.participantAvatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.participantName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          color: isDark ? AppColors.accent : AppColors.accentTeal,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _isVanishMode
                        ? '👻 Vanish Mode Active • ${_vanishTtlSeconds}s TTL'
                        : 'Online • End-to-end moderated',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _isVanishMode
                          ? const Color(0xFFFF5252)
                          : (isDark ? AppColors.accent : AppColors.accentInk),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Shared Interests Header Badges
                  if (displayInterests.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: displayInterests.take(2).map((interest) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.glanceableCyan
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.glanceableCyan
                                  .withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.glanceableCyan,
                                size: 8,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                interest,
                                style: const TextStyle(
                                  color: AppColors.glanceableCyan,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: accent),
            tooltip: 'Mutual Consent Video Call',
            onPressed: () => _showMutualVideoConsentModal(context),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () => _showChatOptionsSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Safety Banner / Ephemeral Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: _isVanishMode
                ? const Color(0xFF26141D)
                : AppColors.adaptiveHighlightBg(isDark),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isVanishMode ? Icons.auto_delete_rounded : Icons.shield,
                  color: _isVanishMode
                      ? const Color(0xFFFF5252)
                      : (isDark ? AppColors.accent : AppColors.accentInk),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _isVanishMode
                      ? 'Ephemeral Encryption Active • Messages wipe automatically'
                      : 'AI Real-Time Safety & Toxic Content Shield Active',
                  style: AppTypography.bodySmall.copyWith(
                    color: _isVanishMode
                        ? const Color(0xFFFF8A80)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.glacierInk),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Screenshot Alert Banner if triggered
          if (_screenshotAlertVisible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: AppColors.error,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _screenshotAlertText ??
                          '⚠️ Screenshot Detected: ${widget.participantName} took a capture!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _screenshotAlertVisible = false),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),

          // Section 6: CHAT WORKSPACE TOOLBAR (4 Interactive Modes)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: _isVanishMode
                      ? const Color(0xFF2A344A)
                      : AppColors.adaptiveBorder(isDark),
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // Mode A: AI Wingman
                  _buildWorkspacePill(
                    icon: Icons.smart_toy_rounded,
                    label: 'AI Wingman',
                    badge: 'ASSIST',
                    color: AppColors.glanceableCyan,
                    isDark: isDark,
                    onTap: () => _showAiWingmanDrawer(context),
                  ),
                  const SizedBox(width: 8),

                  // Mode B: Date Planner
                  _buildWorkspacePill(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date Planner',
                    badge: 'ITINERARY',
                    color: AppColors.accentTeal,
                    isDark: isDark,
                    onTap: () => _showInteractiveDatePlannerModal(context),
                  ),
                  const SizedBox(width: 8),

                  // Mode C: Vanish Mode
                  _buildWorkspacePill(
                    icon: Icons.auto_delete_outlined,
                    label: _isVanishMode
                        ? 'Vanish ON (${_vanishTtlSeconds}s)'
                        : 'Vanish Mode',
                    badge: _isVanishMode ? 'ACTIVE' : 'EPHEMERAL',
                    color: _isVanishMode
                        ? const Color(0xFFFF5252)
                        : (isDark ? Colors.white70 : AppColors.textSecondary),
                    isActive: _isVanishMode,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _isVanishMode = !_isVanishMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isVanishMode
                              ? '👻 Vanish Mode activated: messages auto-delete after $_vanishTtlSeconds seconds.'
                              : 'Standard Mode restored.'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: _isVanishMode
                              ? const Color(0xFF26141D)
                              : AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Mode D: VC Mode
                  _buildWorkspacePill(
                    icon: Icons.videocam_rounded,
                    label: 'VC Mode',
                    badge: 'HD CALL',
                    color: accent,
                    isDark: isDark,
                    onTap: () => _showMutualVideoConsentModal(context),
                  ),
                ],
              ),
            ),
          ),

          // Vanish Mode Interactive Controls Bar (When active)
          if (_isVanishMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1124),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF4A2040), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Color(0xFFFF80AB), size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'TTL:',
                    style: TextStyle(
                      color: Color(0xFFFF80AB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  for (final ttl in [10, 30, 60]) ...[
                    GestureDetector(
                      onTap: () => setState(() => _vanishTtlSeconds = ttl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: _vanishTtlSeconds == ttl
                              ? const Color(0xFFFF4081)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFF4081),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${ttl}s',
                          style: TextStyle(
                            color: _vanishTtlSeconds == ttl
                                ? Colors.white
                                : const Color(0xFFFF80AB),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Screenshot Simulator
                  InkWell(
                    onTap: _simulateScreenshot,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Colors.orange, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Simulate Screenshot',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages View
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg);
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: accent),
              ),
              error: (err, _) => Center(
                child: Text('Error loading messages: $err',
                    style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),

          // Message Input Field Composer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                top: BorderSide(
                  color: _isVanishMode
                      ? const Color(0xFF2A344A)
                      : AppColors.adaptiveBorder(isDark),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.date_range_outlined, color: accent),
                    tooltip: 'Propose AI Date Plan',
                    onPressed: () =>
                        _showInteractiveDatePlannerModal(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: _isVanishMode
                            ? 'Vanish mode message (${_vanishTtlSeconds}s)...'
                            : 'Type a message...',
                        hintStyle: TextStyle(
                            color: _isVanishMode
                                ? const Color(0xFFFF8A80).withValues(alpha: 0.6)
                                : mutedColor),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: _isVanishMode
                                ? const Color(0xFF4A2040)
                                : AppColors.adaptiveBorder(isDark),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: _isVanishMode
                                ? const Color(0xFF4A2040)
                                : AppColors.adaptiveBorder(isDark),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: accent,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(Icons.send,
                          color: _isVanishMode
                              ? Colors.white
                              : AppColors.adaptiveOnAccent(isDark),
                          size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspacePill({
    required IconData icon,
    required String label,
    required String badge,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.25)
              : (isDark ? AppColors.surfaceMutedDark : AppColors.surfaceWarm),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? color
                : (isDark ? AppColors.borderDark : AppColors.borderWarm),
            width: isActive ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isMe = msg.isMe;
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isMe && !msg.isFlagged
                  ? (msg.isVanish
                      ? const LinearGradient(
                          colors: [Color(0xFF880E4F), Color(0xFFC2185B)],
                        )
                      : AppColors.encrePrismGradient)
                  : null,
              color: isMe
                  ? null
                  : (msg.isFlagged
                      ? AppColors.error.withValues(alpha: 0.14)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: msg.isFlagged
                  ? Border.all(color: AppColors.error.withValues(alpha: 0.55))
                  : (isMe
                      ? (isDark
                          ? Border.all(color: AppColors.encreBorderDark)
                          : null)
                      : Border.all(
                          color: AppColors.adaptiveBorder(isDark),
                          width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vanish Mode Ephemeral Indicator
                if (msg.isVanish) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_delete_rounded,
                          color: Color(0xFFFF80AB), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Vanish Mode • ${msg.ttlSeconds ?? 10}s auto-destruct',
                        style: const TextStyle(
                          color: Color(0xFFFF80AB),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Interactive Date Planner Itinerary Card
                if (msg.itinerarySnippet != null) ...[
                  _buildItineraryCard(msg.itinerarySnippet!),
                  const SizedBox(height: 8),
                ],

                // Interactive Icebreaker Game Scorecard Card
                if (msg.gameScorecardSnippet != null) ...[
                  _buildGameScorecardCard(msg.gameScorecardSnippet!),
                  const SizedBox(height: 8),
                ],

                // Text Bubble
                Text(
                  msg.text,
                  style: TextStyle(
                    color: msg.isFlagged
                        ? AppColors.error
                        : (isMe
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)),
                    fontSize: 14,
                    height: 1.35,
                    fontStyle:
                        msg.isFlagged ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  msg.status == MessageStatus.read
                      ? Icons.done_all
                      : (msg.status == MessageStatus.delivered
                          ? Icons.done_all
                          : Icons.done),
                  size: 13,
                  color: msg.status == MessageStatus.read
                      ? AppColors.accentTeal
                      : (isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Mode B: Interactive In-Chat Date Itinerary Card
  /// Supports: Accept Date, Vote on Stops (thumbs up/down), Request Refinements
  Widget _buildItineraryCard(Map<String, dynamic> snippet) {
    final title = snippet['title'] ?? 'Bandra Cozy Sunset & Coffee';
    final neighborhood = snippet['neighborhood'] ?? 'Bandra West';
    final summary = snippet['summary'] ??
        'Subko Specialty Coffee ➔ Seaside Walk ➔ Artisan Gelato';
    final budget = snippet['budget'] ?? '1500';
    final stops = snippet['stops'] as List<dynamic>? ??
        [
          'Stop 1: Subko Specialty Coffee & Sourdough',
          'Stop 2: Bandra Seaside Sunset Walk',
          'Stop 3: Coppetto Artisan Gelato',
        ];
    final voucher = snippet['partnerDiscount'] ?? '10% Partner Voucher Applied';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.encreElevated.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDateAccepted
              ? AppColors.accentTeal
              : AppColors.accent.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isDateAccepted ? Icons.check_circle : Icons.auto_awesome,
                color: _isDateAccepted ? AppColors.accentTeal : AppColors.accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _isDateAccepted
                        ? AppColors.accentTeal
                        : AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '📍 $neighborhood • Budget: ₹$budget',
                style: const TextStyle(
                  color: AppColors.glanceableCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                voucher,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // Multi-Stop voting & details list
          Text(
            'ITINERARY STOPS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < stops.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${stops[i]}',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                  if (_showStopVoting) ...[
                    // Thumb Up
                    InkWell(
                      onTap: () {
                        setState(() {
                          _upvotedStops.add(i);
                          _downvotedStops.remove(i);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          _upvotedStops.contains(i)
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: _upvotedStops.contains(i)
                              ? AppColors.glanceableCyan
                              : Colors.white60,
                        ),
                      ),
                    ),
                    // Thumb Down
                    InkWell(
                      onTap: () {
                        setState(() {
                          _downvotedStops.add(i);
                          _upvotedStops.remove(i);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          _downvotedStops.contains(i)
                              ? Icons.thumb_down
                              : Icons.thumb_down_alt_outlined,
                          size: 16,
                          color: _downvotedStops.contains(i)
                              ? Colors.redAccent
                              : Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Interactive Action Buttons: Accept Date, Vote on Stops, Request Refinements
          if (_isDateAccepted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentTeal),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: AppColors.accentTeal, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Date Accepted by Both! See you Saturday ✨',
                    style: TextStyle(
                      color: AppColors.accentTeal,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.glanceableCyan,
                      foregroundColor: AppColors.encreDeep,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text(
                      'Accept Date',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() => _isDateAccepted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🎉 Date proposal accepted! Added to both calendars.'),
                          backgroundColor: AppColors.accentTeal,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      _showStopVoting ? Icons.close : Icons.how_to_vote_outlined,
                      size: 14,
                    ),
                    label: Text(
                      _showStopVoting ? 'Done' : 'Vote Stops',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() => _showStopVoting = !_showStopVoting);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                _textController.text =
                    'Hey ${widget.participantName}, could we tweak Stop 2 to something closer to Bandra West? 😊';
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: Text(
                    'Request Refinements ✏️',
                    style: TextStyle(
                      color: AppColors.glanceableCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Interactive Icebreaker Game Scorecard Card in Chat
  Widget _buildGameScorecardCard(Map<String, dynamic> snippet) {
    final gameTitle = snippet['gameTitle'] ?? 'Two Truths & a Lie Scorecard';
    final score = snippet['score'] ?? '3/3 Lies Caught (100% Match!)';
    final badge = snippet['badge'] ?? 'Lie Detective 🕵️‍♂️';
    final highlights = snippet['highlights'] ??
        'Nailed the street food allergy and Paris backpacking trip!';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.encreElevated.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameTitle,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            highlights,
            style: const TextStyle(color: Colors.white, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glanceableCyan,
                foregroundColor: AppColors.encreDeep,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.videogame_asset_rounded, size: 16),
              label: const Text(
                'Play Another Icebreaker Game',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GamesLobbyScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Mode A: AI Wingman Assistant Drawer
  /// Features context-aware icebreakers, witty reply suggestions, and private coach guidance.
  void _showAiWingmanDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.glanceableCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_rounded,
                            color: AppColors.glanceableCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date² AI Wingman',
                              style: AppTypography.headlineMedium.copyWith(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Smart icebreakers & witty replies for ${widget.participantName}',
                              style: TextStyle(color: mutedColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 1: Context-Aware Icebreakers
                  Text(
                    'CONTEXT-AWARE ICEBREAKERS',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.glanceableCyan,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'I noticed you love indie rock! What is the latest album or track you had on repeat? 🎸',
                    category: 'Music Interest',
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'Subko or Blue Tokai: which one makes the superior cold brew in your book? ☕',
                    category: 'Coffee Debate',
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'If you could teleport anywhere this evening for an impromptu dinner, where would we go? ✨',
                    category: 'Vibe Check',
                    textColor: textColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Witty Reply Suggestions
                  Text(
                    'WITTY REPLIES',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentTeal,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'Haha honestly, that sounds like the plot of a chaotic indie movie! 😂',
                    category: 'Humor & Banter',
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'Consider me intrigued! Tell me more before I make any final judgments 😉',
                    category: 'Playful Tease',
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildWingmanSuggestionTile(
                    ctx: ctx,
                    text:
                        'I am 100% holding you to that promise next time we meet up ✨',
                    category: 'Date Setup',
                    textColor: textColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 18),

                  // Section 3: AI Coach Guidance
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.encreElevated
                          : AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.encreBorderDark
                            : AppColors.borderWarm,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_outlined,
                                color: AppColors.glanceableCyan, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AI Dating Coach Guidance',
                              style: TextStyle(
                                color: AppColors.glanceableCyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Focus on mutual interests before diving into intense topics.\n'
                          '• Keep flirting natural, affirming, and respectful of boundaries.\n'
                          '• Always propose initial in-person dates at verified public partner venues.',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWingmanSuggestionTile({
    required BuildContext ctx,
    required String text,
    required String category,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.encreElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveBorder(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.glanceableCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.glanceableCyan,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 12.5, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glanceableCyan,
              foregroundColor: AppColors.encreDeep,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(54, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _textController.text = text;
              });
            },
            child: const Text('Insert',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Mode B: Interactive In-Chat Date Planner Modal
  /// Configures budget, neighborhood, date vibe, date & time, and generates multi-stop itinerary card.
  void _showInteractiveDatePlannerModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    double budgetVal = 1500;
    String selectedNeighborhood = 'Bandra West';
    String selectedVibe = 'Cozy Sunset & Coffee';
    final neighborhoods = [
      'Bandra West',
      'Colaba',
      'Juhu',
      'BKC',
      'Indiranagar',
      'Koramangala'
    ];
    final vibes = [
      'Cozy Sunset & Coffee',
      'Rooftop Cocktails',
      'Board Games & Brews',
      'Art Gallery Stroll',
      'Pottery & Pastries'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_today_rounded,
                            color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In-Chat AI Date Planner',
                              style: AppTypography.headlineMedium.copyWith(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Generate curated date plans with ${widget.participantName}',
                              style: TextStyle(color: mutedColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Budget Slider (₹500 - ₹5000)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BUDGET TARGET',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${budgetVal.round()}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: budgetVal,
                    min: 500,
                    max: 5000,
                    divisions: 18,
                    activeColor: accent,
                    onChanged: (val) {
                      setModalState(() => budgetVal = val);
                    },
                  ),

                  // Neighborhood Selector
                  Text(
                    'NEIGHBORHOOD',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: neighborhoods.map((n) {
                        final isSel = selectedNeighborhood == n;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(n),
                            selected: isSel,
                            onSelected: (_) =>
                                setModalState(() => selectedNeighborhood = n),
                            selectedColor: accent.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: isSel ? accent : textColor,
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Date Vibe Selector
                  Text(
                    'DATE VIBE',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: vibes.map((v) {
                        final isSel = selectedVibe == v;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(v),
                            selected: isSel,
                            onSelected: (_) =>
                                setModalState(() => selectedVibe = v),
                            selectedColor: accent.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: isSel ? accent : textColor,
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Generate & Send Itinerary Card Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: AppColors.adaptiveOnAccent(isDark),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Generate & Send Date Proposal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref
                          .read(conversationMessagesProvider(
                                  widget.conversationId)
                              .notifier)
                          .sendMessage(
                            'Hey ${widget.participantName}, I planned an awesome date for us on Date²! Check out the stops below ✨',
                            itinerarySnippet: {
                              'title': '$selectedNeighborhood $selectedVibe',
                              'neighborhood': selectedNeighborhood,
                              'summary':
                                  'Subko Specialty Coffee ➔ Seaside Sunset Walk ➔ Craft Gelato Tasting',
                              'budget': '${budgetVal.round()}',
                              'stops': [
                                'Stop 1: Subko Specialty Coffee ($selectedNeighborhood)',
                                'Stop 2: Seaside Sunset Promenade Walk',
                                'Stop 3: Artisan Dessert & Craft Tasting',
                              ],
                              'partnerDiscount':
                                  '10% Date² Partner Voucher Applied',
                            },
                          );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Mode D: Mutual Video-Call Consent Handshake Modal
  void _showMutualVideoConsentModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: accent,
                child: Icon(
                  Icons.call_made_rounded,
                  color: AppColors.adaptiveOnAccent(isDark),
                ),
              ),
              title: Text('Call ${widget.participantName}',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Start outgoing WebRTC call with mutual consent',
                  style: TextStyle(color: mutedColor, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutgoingCallScreen(
                      channelId: widget.conversationId,
                      participantName: widget.participantName,
                      participantAvatar: widget.participantAvatar,
                    ),
                  ),
                );
              },
            ),
            Divider(color: AppColors.adaptiveBorder(isDark)),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: isDark
                    ? AppColors.encreElevated
                    : AppColors.glacierLight,
                child: Icon(
                  Icons.call_received_rounded,
                  color: isDark ? AppColors.accent : AppColors.glacierInk,
                ),
              ),
              title: Text(
                  'Simulate Incoming Call from ${widget.participantName}',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Experience incoming ringing and accept screen',
                  style: TextStyle(color: mutedColor, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomingCallScreen(
                      callerName: widget.participantName,
                      callerAvatar: widget.participantAvatar,
                      channelId: widget.conversationId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptionsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accent = AppColors.adaptiveAccent(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.shield_outlined, color: accent),
            title: Text('Safety & Verification Details',
                style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Profile verified with Live Biometric Assurance.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.warning),
            title: Text('Unmatch User', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined,
                color: AppColors.error),
            title: const Text('Report Safety Concern',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Incident reported to Trust & Safety team.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
