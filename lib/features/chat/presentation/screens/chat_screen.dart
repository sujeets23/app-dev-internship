import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/date_planner/domain/models/date_plan_model.dart';
import 'package:inclusive_dating/features/date_planner/presentation/providers/date_planner_provider.dart';
import 'package:inclusive_dating/features/date_planner/presentation/screens/voucher_screen.dart';
import 'package:inclusive_dating/features/games/presentation/screens/games_lobby_screen.dart';
import '../../data/chat_service.dart';
import '../../domain/models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'incoming_call_screen.dart';
import 'outgoing_call_screen.dart';

/// Module 3 Feature 1, 2, 3 + Section 4 Chat Workspace:
/// - Polished chat threads with date separators, typing indicator, reply quotes,
///   connection status & reconnection demo, rich attachments, empty state
/// - WhatsApp-inspired message selection & delete flow ("Delete for everyone" vs
///   "Delete for me" vs "Cancel") with tombstone states
/// - 4 Workspace Modes:
///   A: AI Chat (interest-based prompts, witty replies, Private AI Coach thread)
///   B: Date Planner (budget, neighborhood, vibe, date/time, multi-stop vote/accept/refine)
///   C: Vanish Mode (header toggle or swipe-up, Glanceable dark ephemeral theme, TTL, client-side limitation guide)
///   D: VC Mode (mutual video consent handshake, local moderation session lock)
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

  final Set<String> _selectedMessageIds = {};
  ChatMessage? _replyingToMessage;
  int _lastMessageCount = 0;

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

  // Private AI Coach thread inside Mode A drawer
  final List<Map<String, String>> _coachThread = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(conversationMessagesProvider(widget.conversationId).notifier)
          .markAsRead();
    });
  }

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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final replyTo = _replyingToMessage;
    _textController.clear();
    setState(() => _replyingToMessage = null);

    ref
        .read(conversationMessagesProvider(widget.conversationId).notifier)
        .sendMessage(
          text,
          replyToMessageId: replyTo?.id,
          replyToSenderName:
              replyTo?.isMe == true ? 'You' : widget.participantName,
          replyToPreview: replyTo == null
              ? null
              : (replyTo.text.isNotEmpty
                  ? replyTo.text
                  : (replyTo.attachmentLabel ?? 'Attachment')),
          isVanish: _isVanishMode,
          ttlSeconds: _isVanishMode ? _vanishTtlSeconds : null,
        );
    _scrollToBottom();
  }

  void _toggleVanishMode({bool? enable}) {
    setState(() {
      _isVanishMode = enable ?? !_isVanishMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVanishMode
              ? 'Vanish Mode activated (${_vanishTtlSeconds}s local demo expiry).'
              : 'Standard Mode restored.',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor:
            _isVanishMode ? AppColors.encreElevated : AppColors.primary,
      ),
    );
  }

  void _toggleSelectMessage(ChatMessage msg) {
    setState(() {
      if (_selectedMessageIds.contains(msg.id)) {
        _selectedMessageIds.remove(msg.id);
      } else {
        _selectedMessageIds.add(msg.id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedMessageIds.clear());
  }

  Future<void> _showDeleteConfirmationSheet(List<ChatMessage> allMessages) async {
    final selected = allMessages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    if (selected.isEmpty) return;

    final bool canDeleteAllForEveryone =
        selected.every((m) => m.canDeleteForEveryone);
    final isDark = Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final previewSnippet = selected.length == 1
        ? (selected.first.text.isNotEmpty
            ? selected.first.text
            : (selected.first.attachmentLabel ?? 'Media / Shared Card'))
        : '${selected.length} messages selected';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.adaptiveBorder(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.length == 1
                              ? 'Delete message?'
                              : 'Delete ${selected.length} messages?',
                          style: AppTypography.headlineSmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          previewSnippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: mutedColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.encreElevated : AppColors.glacierSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.adaptiveBorder(isDark)),
                ),
                child: Text(
                  canDeleteAllForEveryone
                      ? 'Demo behaviour: "Delete for everyone" replaces your recent message with a deleted tombstone. Real delivery revocation requires live backend sync.'
                      : 'Delete for everyone is only available for your own recent messages within 15 minutes. You can remove these messages from your device with "Delete for me".',
                  style: TextStyle(color: mutedColor, fontSize: 11.5, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              if (canDeleteAllForEveryone) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    label: const Text(
                      'Delete for everyone',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      final ids = selected.map((m) => m.id).toList();
                      Navigator.pop(ctx);
                      _clearSelection();
                      await ref
                          .read(conversationMessagesProvider(
                                  widget.conversationId)
                              .notifier)
                          .deleteForEveryone(ids);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  label: const Text(
                    'Delete for me',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    final ids = selected.map((m) => m.id).toList();
                    Navigator.pop(ctx);
                    _clearSelection();
                    await ref
                        .read(conversationMessagesProvider(
                                widget.conversationId)
                            .notifier)
                        .deleteForMe(ids);
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateScreenshot() {
    setState(() {
      _screenshotAlertVisible = true;
      _screenshotAlertText =
          'Screenshot Alert (Demo): Capture event flagged in ephemeral thread with ${widget.participantName}.';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Screenshot & Ephemeral Limits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Supported mobile platforms can trigger OS screenshot notifications when a capture occurs. Limitations: client-side vanish deletion clears local UI state after expiry, but cannot prevent external cameras, OS backups, or screenshots already saved on another device.',
          style: TextStyle(
            color: AppColors.textSecondaryDark,
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
    final connectionStatus = ref
        .watch(chatConnectionStatusProvider)
        .maybeWhen(data: (v) => v, orElse: () => ChatConnectionStatus.connected);
    final isPeerTyping = ref
        .watch(chatTypingStatusProvider(widget.conversationId))
        .maybeWhen(data: (v) => v, orElse: () => false);
    final locks = ref.watch(moderationLockProvider);
    final canonicalId = ref
        .read(chatServiceProvider)
        .resolveConversationId(widget.conversationId);
    final sessionLockReason = locks[canonicalId] ?? locks[widget.conversationId];

    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;

    final bgColor = _isVanishMode
        ? AppColors.encreDeep
        : (isDark ? AppColors.backgroundDark : AppColors.background);
    final surfaceColor = _isVanishMode
        ? AppColors.encreDark
        : (isDark ? AppColors.surfaceDark : AppColors.surface);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent =
        _isVanishMode ? AppColors.error : AppColors.adaptiveAccent(isDark);

    final displayInterests = widget.sharedInterests ??
        const ['Coffee Roasts', 'Indie Rock', 'Art Gallery'];

    final allMessages = messagesAsync.value ?? const <ChatMessage>[];
    final bool isSelectionMode = _selectedMessageIds.isNotEmpty;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isSelectionMode) {
          _clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: isSelectionMode
            ? _buildSelectionAppBar(allMessages, isDark, textColor, accent)
            : _buildDefaultAppBar(
                context,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
                accent: accent,
                connectionStatus: connectionStatus,
                isPeerTyping: isPeerTyping,
                displayInterests: displayInterests,
                sessionLockReason: sessionLockReason,
              ),
        body: Column(
          children: [
            // Safety Banner / Ephemeral Warning / Connection Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: _isVanishMode
                  ? AppColors.encreElevated
                  : (connectionStatus != ChatConnectionStatus.connected
                      ? AppColors.warningLight
                      : AppColors.adaptiveHighlightBg(isDark)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isVanishMode
                        ? Icons.auto_delete_rounded
                        : (connectionStatus == ChatConnectionStatus.reconnecting
                            ? Icons.sync_rounded
                            : Icons.shield),
                    color: _isVanishMode
                        ? AppColors.error
                        : (connectionStatus != ChatConnectionStatus.connected
                            ? AppColors.warning
                            : (isDark ? AppColors.accent : AppColors.accentInk)),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _isVanishMode
                          ? 'Vanish Mode (Demo) • Local UI removes messages after ${_vanishTtlSeconds}s'
                          : (connectionStatus == ChatConnectionStatus.offline
                              ? 'Demo WS Disconnected • Queuing outgoing messages...'
                              : (connectionStatus ==
                                      ChatConnectionStatus.reconnecting
                                  ? 'Reconnecting WebSocket & flushing queue...'
                                  : 'AI Safety & NLP Moderation Shield Active (Demo Stream)')),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: _isVanishMode
                            ? AppColors.textSecondaryDark
                            : (connectionStatus !=
                                    ChatConnectionStatus.connected
                                ? AppColors.encreDeep
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.glacierInk)),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (sessionLockReason != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: AppColors.error.withValues(alpha: 0.14),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'VC Mode locked after moderation incident ($sessionLockReason).',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(moderationLockProvider.notifier)
                            .unlockSession(canonicalId);
                        ref
                            .read(moderationLockProvider.notifier)
                            .unlockSession(widget.conversationId);
                      },
                      child: const Text(
                        'Reset Demo Lock',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

            // Screenshot Alert Banner if triggered
            if (_screenshotAlertVisible)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: AppColors.error,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _screenshotAlertText ??
                            'Screenshot Detected (Demo): Capture logged.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          setState(() => _screenshotAlertVisible = false),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),

            // CHAT WORKSPACE TOOLBAR (4 Interactive Modes)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: _isVanishMode
                        ? AppColors.encreBorderDark
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
                    _buildWorkspacePill(
                      icon: Icons.smart_toy_rounded,
                      label: 'AI Chat',
                      badge: 'COACH',
                      color: AppColors.glanceableCyan,
                      isDark: isDark,
                      onTap: () =>
                          _showAiWingmanDrawer(context, displayInterests),
                    ),
                    const SizedBox(width: 8),
                    _buildWorkspacePill(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date Planner',
                      badge: 'ITINERARY',
                      color: AppColors.accentTeal,
                      isDark: isDark,
                      onTap: () => _showInteractiveDatePlannerModal(context),
                    ),
                    const SizedBox(width: 8),
                    _buildWorkspacePill(
                      icon: Icons.auto_delete_outlined,
                      label: _isVanishMode
                          ? 'Vanish ON (${_vanishTtlSeconds}s)'
                          : 'Vanish Mode',
                      badge: _isVanishMode ? 'ACTIVE' : 'EPHEMERAL',
                      color: _isVanishMode
                          ? AppColors.error
                          : (isDark ? Colors.white70 : AppColors.textSecondary),
                      isActive: _isVanishMode,
                      isDark: isDark,
                      onTap: () => _toggleVanishMode(),
                    ),
                    const SizedBox(width: 8),
                    _buildWorkspacePill(
                      icon: Icons.videocam_rounded,
                      label: sessionLockReason != null ? 'VC Locked' : 'VC Mode',
                      badge: sessionLockReason != null ? 'LOCKED' : 'HD CALL',
                      color: sessionLockReason != null ? AppColors.error : accent,
                      isDark: isDark,
                      onTap: () => _showMutualVideoConsentModal(
                        context,
                        sessionLockReason: sessionLockReason,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vanish Mode Interactive Controls Bar (When active)
            if (_isVanishMode)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.encreElevated,
                  border: Border(
                    bottom: BorderSide(color: AppColors.encreBorderDark, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.accent, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'TTL:',
                      style: TextStyle(
                        color: AppColors.accent,
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
                                ? AppColors.error
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _vanishTtlSeconds == ttl
                                  ? AppColors.error
                                  : AppColors.accent.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${ttl}s',
                            style: TextStyle(
                              color: _vanishTtlSeconds == ttl
                                  ? Colors.white
                                  : AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    InkWell(
                      onTap: _simulateScreenshot,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.warning, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                color: AppColors.warning, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Capture Limits',
                              style: TextStyle(
                                color: AppColors.warning,
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

            // Messages View with swipe-up trigger for Vanish Mode
            Expanded(
              child: NotificationListener<OverscrollNotification>(
                onNotification: (notification) {
                  if (notification.overscroll > 28 && !_isVanishMode) {
                    _toggleVanishMode(enable: true);
                  }
                  return false;
                },
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.length > _lastMessageCount) {
                      _lastMessageCount = messages.length;
                      _scrollToBottom();
                    } else {
                      _lastMessageCount = messages.length;
                    }

                    if (messages.isEmpty && !isPeerTyping) {
                      return _buildEmptyChatState(
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        accent: accent,
                      );
                    }

                    final totalItems =
                        messages.length + (isPeerTyping ? 1 : 0);

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: totalItems,
                      itemBuilder: (context, index) {
                        if (index == messages.length && isPeerTyping) {
                          return _buildTypingBubble(isDark);
                        }
                        final msg = messages[index];
                        final bool showDateHeader = index == 0 ||
                            !_isSameDay(
                                messages[index - 1].timestamp, msg.timestamp);
                        return Column(
                          children: [
                            if (showDateHeader)
                              _buildDateSeparator(
                                  msg.timestamp, isDark, mutedColor),
                            _buildMessageItem(msg),
                          ],
                        );
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
            ),

            // Reply Quote Preview Bar
            if (_replyingToMessage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(color: AppColors.adaptiveBorder(isDark)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _replyingToMessage!.isMe
                                ? 'Replying to Yourself'
                                : 'Replying to ${widget.participantName}',
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _replyingToMessage!.text.isNotEmpty
                                ? _replyingToMessage!.text
                                : (_replyingToMessage!.attachmentLabel ??
                                    'Shared card'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: mutedColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: mutedColor),
                      onPressed: () =>
                          setState(() => _replyingToMessage = null),
                    ),
                  ],
                ),
              ),

            // Message Input Field Composer + Rich Attachment Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: _isVanishMode
                        ? AppColors.encreBorderDark
                        : AppColors.adaptiveBorder(isDark),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline_rounded,
                          color: accent),
                      tooltip: 'Attachments & Actions',
                      onPressed: () => _showAttachmentsSheet(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: _isVanishMode
                              ? 'Vanish message (${_vanishTtlSeconds}s)...'
                              : 'Type a message...',
                          hintStyle: TextStyle(
                            color: _isVanishMode
                                ? AppColors.textSecondaryDark
                                    .withValues(alpha: 0.7)
                                : mutedColor,
                          ),
                          filled: true,
                          fillColor: bgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.adaptiveBorder(isDark),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.adaptiveBorder(isDark),
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
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(
    List<ChatMessage> allMessages,
    bool isDark,
    Color textColor,
    Color accent,
  ) {
    final selected =
        allMessages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    final canReply =
        selected.length == 1 && !selected.first.isDeletedForEveryone;
    final canCopy = selected.length == 1 &&
        !selected.first.isDeletedForEveryone &&
        selected.first.text.isNotEmpty;

    return AppBar(
      backgroundColor: isDark ? AppColors.encreElevated : AppColors.glacierLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: textColor),
        onPressed: _clearSelection,
      ),
      title: Text(
        '${selected.length} selected',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      actions: [
        if (canReply)
          IconButton(
            tooltip: 'Reply',
            icon: Icon(Icons.reply_rounded, color: textColor),
            onPressed: () {
              final target = selected.first;
              _clearSelection();
              setState(() => _replyingToMessage = target);
            },
          ),
        if (canCopy)
          IconButton(
            tooltip: 'Copy Text',
            icon: Icon(Icons.copy_rounded, color: textColor, size: 20),
            onPressed: () async {
              final txt = selected.first.text;
              await Clipboard.setData(ClipboardData(text: txt));
              _clearSelection();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        IconButton(
          tooltip: 'Delete message',
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          onPressed: () => _showDeleteConfirmationSheet(allMessages),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(
    BuildContext context, {
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color accent,
    required ChatConnectionStatus connectionStatus,
    required bool isPeerTyping,
    required List<String> displayInterests,
    required String? sessionLockReason,
  }) {
    final statusText = _isVanishMode
        ? 'Vanish Mode Active • ${_vanishTtlSeconds}s TTL'
        : (isPeerTyping
            ? '${widget.participantName} is typing...'
            : (connectionStatus == ChatConnectionStatus.reconnecting
                ? 'Reconnecting demo stream...'
                : 'Online • End-to-end moderated'));

    return AppBar(
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
                  statusText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _isVanishMode
                        ? AppColors.error
                        : (isPeerTyping
                            ? AppColors.accentTeal
                            : (isDark ? AppColors.accent : AppColors.accentInk)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (displayInterests.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: displayInterests.take(2).map((interest) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color:
                              AppColors.glanceableCyan.withValues(alpha: 0.18),
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
          icon: Icon(Icons.videocam,
              color: sessionLockReason != null ? AppColors.error : accent),
          tooltip: 'Mutual Consent Video Call',
          onPressed: () => _showMutualVideoConsentModal(
            context,
            sessionLockReason: sessionLockReason,
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: textColor),
          onPressed: () => _showChatOptionsSheet(context),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateSeparator(DateTime date, bool isDark, Color mutedColor) {
    final now = DateTime.now();
    final String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.glacierLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.adaptiveBorder(isDark)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.adaptiveBorder(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentTeal,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.participantName} is typing...',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState({
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required Color accent,
  }) {
    final starters = [
      'Hey ${widget.participantName}! Excited to match with you 👋',
      'Coffee or sunset walk this weekend? ☕',
      'Want to play a quick round of 2 Truths & a Lie?',
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage(widget.participantAvatar),
            ),
            const SizedBox(height: 14),
            Text(
              'Start chatting with ${widget.participantName}',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No messages here yet. Pick an instant icebreaker below or compose your own.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            const SizedBox(height: 18),
            for (final prompt in starters) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActionChip(
                  backgroundColor:
                      isDark ? AppColors.encreElevated : AppColors.glacierLight,
                  side: BorderSide(color: accent.withValues(alpha: 0.45)),
                  label: Text(
                    prompt,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(conversationMessagesProvider(
                                widget.conversationId)
                            .notifier)
                        .sendMessage(
                          prompt,
                          isVanish: _isVanishMode,
                          ttlSeconds: _isVanishMode ? _vanishTtlSeconds : null,
                        );
                  },
                ),
              ),
            ],
          ],
        ),
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final isSelected = _selectedMessageIds.contains(msg.id);

    return GestureDetector(
      onLongPress: () => _toggleSelectMessage(msg),
      onTap: () {
        if (_selectedMessageIds.isNotEmpty) {
          _toggleSelectMessage(msg);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
            : EdgeInsets.zero,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.glanceableCyan.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
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
                gradient: isMe && !msg.isFlagged && !msg.isDeletedForEveryone
                    ? (msg.isVanish
                        ? const LinearGradient(
                            colors: [
                              AppColors.encreElevated,
                              AppColors.primary,
                            ],
                          )
                        : AppColors.encrePrismGradient)
                    : null,
                color: msg.isDeletedForEveryone
                    ? (isDark
                        ? AppColors.surfaceMutedDark
                        : AppColors.surfaceMuted)
                    : (isMe
                        ? (msg.isFlagged
                            ? AppColors.error.withValues(alpha: 0.14)
                            : null)
                        : (msg.isFlagged
                            ? AppColors.error.withValues(alpha: 0.14)
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface))),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isSelected
                    ? Border.all(color: AppColors.glanceableCyan, width: 1.8)
                    : (msg.isFlagged
                        ? Border.all(
                            color: AppColors.error.withValues(alpha: 0.55))
                        : (isMe
                            ? (msg.isVanish
                                ? Border.all(
                                    color:
                                        AppColors.error.withValues(alpha: 0.7))
                                : (isDark
                                    ? Border.all(
                                        color: AppColors.encreBorderDark)
                                    : null))
                            : Border.all(
                                color: AppColors.adaptiveBorder(isDark),
                                width: 1.0,
                              ))),
              ),
              child: msg.isDeletedForEveryone
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.block_rounded,
                          size: 15,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isMe
                                ? 'You deleted this message'
                                : 'This message was deleted',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply Quote Header
                        if (msg.replyToPreview != null) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppColors.adaptiveHighlightBg(isDark),
                              borderRadius: BorderRadius.circular(8),
                              border: const Border(
                                left: BorderSide(
                                  color: AppColors.glanceableCyan,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.replyToSenderName ?? 'Reply',
                                  style: const TextStyle(
                                    color: AppColors.glanceableCyan,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  msg.replyToPreview!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Vanish Mode Ephemeral Indicator
                        if (msg.isVanish) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_delete_rounded,
                                  color: AppColors.error, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                'Vanish • ${msg.ttlSeconds ?? 10}s auto-wipe (Demo)',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Attachment Preview Card
                        if (msg.attachmentLabel != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.glanceableCyan
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  msg.attachmentType == 'location'
                                      ? Icons.location_on_rounded
                                      : Icons.photo_library_rounded,
                                  color: AppColors.glanceableCyan,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    msg.attachmentLabel!,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                        if (msg.text.isNotEmpty)
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
                              fontStyle: msg.isFlagged
                                  ? FontStyle.italic
                                  : FontStyle.normal,
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
                    msg.status == MessageStatus.sending
                        ? Icons.schedule_rounded
                        : (msg.status == MessageStatus.read ||
                                msg.status == MessageStatus.delivered
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
      ),
    );
  }

  /// Mode B: Interactive In-Chat Date Itinerary Card
  Widget _buildItineraryCard(Map<String, dynamic> snippet) {
    final title = snippet['title'] ?? 'Bandra Cozy Sunset & Coffee';
    final neighborhood = snippet['neighborhood'] ?? 'Bandra West';
    final summary = snippet['summary'] ??
        'Subko Specialty Coffee ➔ Seaside Walk ➔ Artisan Gelato';
    final budget = snippet['budget'] ?? '1500';
    final dateTimeLabel = snippet['dateTime'] as String?;
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
        color: AppColors.encreElevated.withValues(alpha: 0.92),
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
          if (dateTimeLabel != null) ...[
            const SizedBox(height: 3),
            Text(
              dateTimeLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            summary,
            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$neighborhood • Budget: ₹$budget',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.glanceableCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                voucher,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
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
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                  if (_showStopVoting) ...[
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
                              ? AppColors.error
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
                    'Date Proposal Accepted! ✨',
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
                          content: Text('Date proposal accepted!'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    _textController.text =
                        'Hey ${widget.participantName}, could we refine Stop 2 to a spot closer to $neighborhood?';
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6),
                    child: Text(
                      'Request Refinements',
                      style: TextStyle(
                        color: AppColors.glanceableCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    final plan = DatePlan(
                      id: 'dp_chat_${DateTime.now().millisecondsSinceEpoch}',
                      title: title.toString(),
                      neighborhood: neighborhood.toString(),
                      vibe: 'Curated',
                      dietary: 'Inclusive',
                      budgetLimit: double.tryParse(budget.toString()) ?? 1500,
                      totalEstimatedCost:
                          double.tryParse(budget.toString()) ?? 1500,
                      stops: const [],
                      digitalVoucherCode: 'DATE2-PARTNER-10OFF',
                      createdAt: DateTime.now(),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoucherScreen(plan: plan),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6),
                    child: Text(
                      'Open 10% Voucher',
                      style: TextStyle(
                        color: AppColors.accentTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
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
        'Great round playing interactive icebreakers together!';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.encreElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameTitle,
                      style: const TextStyle(
                        color: AppColors.accent,
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
                  color: AppColors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score,
                  style: const TextStyle(
                    color: AppColors.accent,
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
                    builder: (_) => GamesLobbyScreen(
                      defaultMatchConversationId: widget.conversationId,
                      defaultMatchName: widget.participantName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Attachment Actions Modal
  void _showAttachmentsSheet(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accent = AppColors.adaptiveAccent(isDark);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share in Chat (Demo Mode)',
                style: AppTypography.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  child: Icon(Icons.photo_camera_outlined, color: accent),
                ),
                title: Text('Send Demo Photo Snapshot',
                    style: TextStyle(color: textColor)),
                subtitle: const Text('Local preview attachment'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(conversationMessagesProvider(widget.conversationId)
                          .notifier)
                      .sendMessage(
                        'Here is a cozy snapshot from my favorite weekend spot 📸',
                        attachmentType: 'image',
                        attachmentLabel: 'Weekend Coffee Pour-Over.jpg (Demo)',
                        isVanish: _isVanishMode,
                        ttlSeconds: _isVanishMode ? _vanishTtlSeconds : null,
                      );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  child: Icon(Icons.location_on_outlined, color: accent),
                ),
                title: Text('Suggest Public Meetup Pin',
                    style: TextStyle(color: textColor)),
                subtitle:
                    const Text('Subko Specialty Coffee • Verified Public Venue'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(conversationMessagesProvider(widget.conversationId)
                          .notifier)
                      .sendMessage(
                        'Would you like to meet at this public partner cafe?',
                        attachmentType: 'location',
                        attachmentLabel:
                            'Public Venue: Subko Coffee, Bandra West',
                        isVanish: _isVanishMode,
                        ttlSeconds: _isVanishMode ? _vanishTtlSeconds : null,
                      );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  child: Icon(Icons.calendar_today_rounded, color: accent),
                ),
                title: Text('Propose AI Date Itinerary',
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showInteractiveDatePlannerModal(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  child: Icon(Icons.sports_esports_outlined, color: accent),
                ),
                title: Text('Start Icebreaker Game',
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GamesLobbyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mode A: AI Chat Assistant & Private AI Coach Thread
  void _showAiWingmanDrawer(
      BuildContext context, List<String> sharedInterests) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final coachController = TextEditingController();

    final topInterest =
        sharedInterests.isNotEmpty ? sharedInterests.first : 'coffee';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) => DraggableScrollableSheet(
            initialChildSize: 0.78,
            minChildSize: 0.5,
            maxChildSize: 0.94,
            expand: false,
            builder: (_, scrollController) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveBorder(isDark),
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
                            color:
                                AppColors.glanceableCyan.withValues(alpha: 0.15),
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
                                'Date² AI Chat (Demo)',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Interest-aware prompts & private coach for ${widget.participantName}',
                                style: TextStyle(color: mutedColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'INTEREST-BASED ICEBREAKERS',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.glanceableCyanDeep,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildWingmanSuggestionTile(
                      ctx: ctx,
                      text:
                          'I noticed you are into $topInterest! What is your favorite local spot for that?',
                      category: 'Shared: $topInterest',
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    _buildWingmanSuggestionTile(
                      ctx: ctx,
                      text:
                          'Quick vote: cozy pour-over cafe or sunset art gallery walk this weekend?',
                      category: 'Date Bridge',
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
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
                          'Consider me intrigued — tell me the story behind that before we plan Saturday!',
                      category: 'Warm Banter',
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),
                    // Private AI Coach Thread
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.encreElevated
                            : AppColors.glacierSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.encreBorderDark
                              : AppColors.glacierBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology_outlined,
                                  color: AppColors.glanceableCyanDeep, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Private AI Coach Thread (Local Only)',
                                style: TextStyle(
                                  color: AppColors.glanceableCyanDeep,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask privately how to phrase an invite or keep momentum without awkwardness.',
                            style: TextStyle(color: mutedColor, fontSize: 11.5),
                          ),
                          const SizedBox(height: 10),
                          if (_coachThread.isEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                'How do I suggest a casual date?',
                                'What should I reply next?',
                              ].map((q) {
                                return ActionChip(
                                  label: Text(q, style: const TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    setSheetState(() {
                                      _coachThread.add({
                                        'user': q,
                                        'coach':
                                            'Coach Tip: Keep it specific & low-pressure — try "Hey ${widget.participantName}, would you be up for $topInterest around 5 PM this Saturday?"',
                                      });
                                    });
                                  },
                                );
                              }).toList(),
                            )
                          else ...[
                            for (final turn in _coachThread) ...[
                              Text(
                                'You: ${turn['user']}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                turn['coach']!,
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: coachController,
                                  style:
                                      TextStyle(color: textColor, fontSize: 12),
                                  decoration: const InputDecoration(
                                    hintText: 'Ask AI Coach...',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.glanceableCyan,
                                  foregroundColor: AppColors.encreDeep,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                onPressed: () {
                                  final ask = coachController.text.trim();
                                  if (ask.isEmpty) return;
                                  coachController.clear();
                                  setSheetState(() {
                                    _coachThread.add({
                                      'user': ask,
                                      'coach':
                                          'Coach Tip: Acknowledge their message, reference $topInterest, and suggest a verified public cafe nearby.',
                                    });
                                  });
                                },
                                child: const Text('Ask',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(coachController.dispose);
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
                      color: AppColors.glanceableCyanDeep,
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

  /// Mode B: Interactive In-Chat Date Planner Modal (with Date & Time picker)
  void _showInteractiveDatePlannerModal(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    double budgetVal = 1500;
    String selectedNeighborhood = 'Bandra West, Mumbai';
    String selectedVibe = 'Romantic';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 18, minute: 0);

    final neighborhoods = [
      'Bandra West, Mumbai',
      'Colaba & Fort, Mumbai',
      'Indiranagar, Bengaluru',
      'Koramangala, Bengaluru',
      'Hauz Khas, New Delhi',
      'Koregaon Park, Pune',
    ];
    final vibes = [
      'Romantic',
      'Casual',
      'Adventure',
      'Foodie',
      'Relaxed',
    ];

    showModalBottomSheet<void>(
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveBorder(isDark),
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
                                'Build & dispatch a date plan for ${widget.participantName}',
                                style:
                                    TextStyle(color: mutedColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    Text(
                      'DATE & TIME',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.event, size: 15, color: accent),
                            label: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: modalCtx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 60)),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time,
                                size: 15, color: accent),
                            label: Text(
                              selectedTime.format(modalCtx),
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: modalCtx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setModalState(() => selectedTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      onPressed: () async {
                        final formattedTime = selectedTime.format(modalCtx);
                        final formattedDate =
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at $formattedTime';
                        Navigator.pop(ctx);

                        final plan = await ref
                            .read(datePlannerServiceProvider)
                            .generateDatePlan(
                              budget: budgetVal,
                              neighborhood: selectedNeighborhood,
                              vibe: selectedVibe,
                              dietary: 'Any',
                            );

                        if (!mounted) return;
                        ref
                            .read(conversationMessagesProvider(
                                    widget.conversationId)
                                .notifier)
                            .sendMessage(
                              'Hey ${widget.participantName}, I planned a $selectedVibe date for us on $formattedDate! Check out the stops below ✨',
                              itinerarySnippet: {
                                'title': plan.title,
                                'neighborhood': plan.neighborhood,
                                'dateTime': formattedDate,
                                'summary': plan.stops
                                    .map((s) => s.venueName)
                                    .join(' ➔ '),
                                'budget':
                                    '${plan.totalEstimatedCost.round()}',
                                'stops': plan.stops
                                    .map((s) =>
                                        'Stop ${s.stepNumber}: ${s.venueName} (₹${s.estimatedCost.round()})')
                                    .toList(),
                                'partnerDiscount':
                                    '10% Date² Partner Voucher',
                              },
                            );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Mode D: Mutual Video-Call Consent Handshake Modal
  void _showMutualVideoConsentModal(
    BuildContext context, {
    required String? sessionLockReason,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    if (sessionLockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'VC Mode is locked due to moderation incident: $sessionLockReason',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
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
                  'Demo WebRTC mutual-consent video flow (STUN/TURN signaling pending backend)',
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
                  'Test incoming ringing & accept/decline consent flow',
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark || _isVanishMode;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accent = AppColors.adaptiveAccent(isDark);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.sync_rounded, color: accent),
            title: Text('Test WebSocket Reconnect (Demo)',
                style: TextStyle(color: textColor)),
            subtitle: const Text(
              'Simulates offline -> reconnecting -> connected backoff',
              style: TextStyle(fontSize: 11),
            ),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(chatServiceProvider).simulateReconnect();
            },
          ),
          ListTile(
            leading: Icon(Icons.shield_outlined, color: accent),
            title: Text('Safety & Verification Details',
                style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo Moderation Active: Real WebSocket & server NLP moderation require backend APIs.',
                  ),
                ),
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
            leading:
                const Icon(Icons.report_problem_outlined, color: AppColors.error),
            title: const Text('Report Safety Concern',
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(ctx);
              await ref.read(chatServiceProvider).reportIncident(
                    matchId: widget.conversationId,
                    reason: 'User safety report in chat thread',
                    confidence: '1.0',
                  );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Incident recorded in Demo Trust & Safety log.'),
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
