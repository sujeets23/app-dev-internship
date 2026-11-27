import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import '../../data/chat_service.dart';
import '../../domain/models/chat_message.dart';

final chatServiceProvider = Provider<IChatService>((ref) {
  final prefs = ref.watch(optionalSharedPreferencesProvider);
  final service = MockChatService(prefs);
  ref.onDispose(service.dispose);
  return service;
});

final conversationsProvider =
    FutureProvider.autoDispose<List<ChatConversation>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.fetchConversations();
});

final chatConnectionStatusProvider =
    StreamProvider.autoDispose<ChatConnectionStatus>((ref) async* {
  final service = ref.watch(chatServiceProvider);
  yield service.currentConnectionStatus;
  yield* service.connectionStatusStream;
});

final chatTypingStatusProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, conversationId) async* {
  final service = ref.watch(chatServiceProvider);
  final canonical = service.resolveConversationId(conversationId);
  yield false;
  yield* service.typingStatusStream.map((map) => map[canonical] ?? false);
});

/// Tracks local moderation session locks after reported NSFW / safety violations.
class ModerationLockNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void lockSession(String targetId, String reason) {
    state = Map<String, String>.from(state)..[targetId] = reason;
  }

  void unlockSession(String targetId) {
    state = Map<String, String>.from(state)..remove(targetId);
  }
}

final moderationLockProvider =
    NotifierProvider<ModerationLockNotifier, Map<String, String>>(
  ModerationLockNotifier.new,
);

class ConversationNotifier extends AsyncNotifier<List<ChatMessage>> {
  final String conversationId;
  StreamSubscription<ChatMessage>? _sub;
  final Set<Timer> _vanishTimers = {};

  ConversationNotifier(this.conversationId);

  IChatService get _service => ref.read(chatServiceProvider);

  String get _canonicalId => _service.resolveConversationId(conversationId);

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() {
      _sub?.cancel();
      for (final timer in _vanishTimers) {
        timer.cancel();
      }
      _vanishTimers.clear();
    });

    final initial = await _service.fetchMessages(_canonicalId);

    _sub = _service.messageStream.listen((msg) {
      if (msg.conversationId == _canonicalId) {
        final current = state.value ?? [];
        if (!current.any((m) => m.id == msg.id)) {
          state = AsyncValue.data([...current, msg]);
          ref.invalidate(conversationsProvider);
        }
      }
    });

    return initial;
  }

  Future<void> markAsRead() async {
    await _service.markConversationRead(_canonicalId);
    final updated = await _service.fetchMessages(_canonicalId);
    state = AsyncValue.data(updated);
    ref.invalidate(conversationsProvider);
  }

  Future<void> sendMessage(
    String text, {
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToPreview,
    String? attachmentType,
    String? attachmentLabel,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  }) async {
    if (text.trim().isEmpty &&
        itinerarySnippet == null &&
        gameScorecardSnippet == null &&
        attachmentLabel == null) {
      return;
    }
    try {
      final sentMsg = await _service.sendMessage(
        conversationId: _canonicalId,
        text: text,
        replyToMessageId: replyToMessageId,
        replyToSenderName: replyToSenderName,
        replyToPreview: replyToPreview,
        attachmentType: attachmentType,
        attachmentLabel: attachmentLabel,
        itinerarySnippet: itinerarySnippet,
        gameScorecardSnippet: gameScorecardSnippet,
        isVanish: isVanish,
        ttlSeconds: ttlSeconds,
      );

      final current = state.value ?? [];
      if (!current.any((m) => m.id == sentMsg.id)) {
        state = AsyncValue.data([...current, sentMsg]);
      }
      ref.invalidate(conversationsProvider);

      if (isVanish) {
        final duration = Duration(seconds: ttlSeconds ?? 10);
        late final Timer timer;
        timer = Timer(duration, () {
          _vanishTimers.remove(timer);
          final msgs = state.value ?? [];
          state =
              AsyncValue.data(msgs.where((m) => m.id != sentMsg.id).toList());
        });
        _vanishTimers.add(timer);
      }
    } catch (_) {}
  }

  Future<void> deleteForMe(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    await _service.deleteMessagesForMe(
      conversationId: _canonicalId,
      messageIds: messageIds,
    );
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((m) => !messageIds.contains(m.id)).toList(),
    );
    ref.invalidate(conversationsProvider);
  }

  Future<void> deleteForEveryone(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    await _service.deleteMessagesForEveryone(
      conversationId: _canonicalId,
      messageIds: messageIds,
    );
    final refreshed = await _service.fetchMessages(_canonicalId);
    state = AsyncValue.data(refreshed);
    ref.invalidate(conversationsProvider);
  }
}

final conversationMessagesProvider =
    AsyncNotifierProvider.family<ConversationNotifier, List<ChatMessage>, String>(
  (arg) => ConversationNotifier(arg),
);
