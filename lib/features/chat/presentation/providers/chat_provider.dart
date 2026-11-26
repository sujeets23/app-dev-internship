import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_service.dart';
import '../../domain/models/chat_message.dart';

final chatServiceProvider = Provider<IChatService>((ref) {
  return MockChatService();
});

final conversationsProvider =
    FutureProvider.autoDispose<List<ChatConversation>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.fetchConversations();
});

class ConversationNotifier extends AsyncNotifier<List<ChatMessage>> {
  final String conversationId;
  StreamSubscription<ChatMessage>? _sub;

  ConversationNotifier(this.conversationId);

  IChatService get _service => ref.read(chatServiceProvider);

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() {
      _sub?.cancel();
    });

    final initial = await _service.fetchMessages(conversationId);

    _sub = _service.messageStream.listen((msg) {
      if (msg.conversationId == conversationId) {
        final current = state.value ?? [];
        state = AsyncValue.data([...current, msg]);
      }
    });

    return initial;
  }

  Future<void> sendMessage(
    String text, {
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  }) async {
    if (text.trim().isEmpty &&
        itinerarySnippet == null &&
        gameScorecardSnippet == null) {
      return;
    }
    try {
      final sentMsg = await _service.sendMessage(
        conversationId: conversationId,
        text: text,
        itinerarySnippet: itinerarySnippet,
        gameScorecardSnippet: gameScorecardSnippet,
        isVanish: isVanish,
        ttlSeconds: ttlSeconds,
      );

      final current = state.value ?? [];
      if (!current.any((m) => m.id == sentMsg.id)) {
        state = AsyncValue.data([...current, sentMsg]);
      }

      if (isVanish) {
        final duration = Duration(seconds: ttlSeconds ?? 10);
        Timer(duration, () {
          final msgs = state.value ?? [];
          state =
              AsyncValue.data(msgs.where((m) => m.id != sentMsg.id).toList());
        });
      }
    } catch (_) {}
  }
}

final conversationMessagesProvider =
    AsyncNotifierProvider.family<ConversationNotifier, List<ChatMessage>, String>(
  (arg) => ConversationNotifier(arg),
);
