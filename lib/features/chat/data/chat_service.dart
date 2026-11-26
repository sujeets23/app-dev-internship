import 'dart:async';
import '../domain/models/chat_message.dart';

abstract class IChatService {
  Stream<ChatMessage> get messageStream;
  Future<List<ChatConversation>> fetchConversations();
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  });
  Future<bool> requestVideoConsent(String matchId);
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
  });
  void addMatch({
    required String name,
    required String avatar,
    required String matchId,
    bool isVerified = false,
  });
}

/// Production WebSocket & REST Service (targets WebSocket /v1/chat/stream, POST /v1/matches/{id}/video-consent, POST /v1/moderation/incident)
class ProductionChatService implements IChatService {
  final String baseUrl;
  ProductionChatService({this.baseUrl = 'https://api.date2.app'});

  @override
  Stream<ChatMessage> get messageStream => throw UnimplementedError('Backend server offline');

  @override
  Future<List<ChatConversation>> fetchConversations() =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<bool> requestVideoConsent(String matchId) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  void addMatch({
    required String name,
    required String avatar,
    required String matchId,
    bool isVerified = false,
  }) {}
}

/// Rich Mock WebSocket & Moderation Service
class MockChatService implements IChatService {
  final StreamController<ChatMessage> _streamController =
      StreamController<ChatMessage>.broadcast();

  // Toxic keywords for on-device safety moderation
  static const List<String> _flaggedKeywords = [
    'hate',
    'idiot',
    'harass',
    'threat',
    'offensive',
  ];

  final Map<String, List<ChatMessage>> _messageStorage = {};

  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'conv_1',
      participantId: 'user_1',
      participantName: 'Aarya',
      participantAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      lastMessageText: 'That rooftop cafe in Bandra sounds dreamy! Let us go this Saturday ✨',
      lastTimestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      unreadCount: 1,
      isOnline: true,
      isVerified: true,
    ),
    ChatConversation(
      id: 'conv_2',
      participantId: 'user_2',
      participantName: 'Zayan',
      participantAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      lastMessageText: 'Loved the art recommendation. Which gallery first?',
      lastTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      isVerified: true,
    ),
    ChatConversation(
      id: 'conv_3',
      participantId: 'user_3',
      participantName: 'Tara',
      participantAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      lastMessageText: 'Are you free for tea tomorrow afternoon?',
      lastTimestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
      isVerified: false,
    ),
  ];

  @override
  Stream<ChatMessage> get messageStream => _streamController.stream;

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_conversations);
  }

  @override
  void addMatch({
    required String name,
    required String avatar,
    required String matchId,
    bool isVerified = false,
  }) {
    final existingIndex = _conversations.indexWhere((c) => c.participantName == name);
    if (existingIndex < 0) {
      _conversations.insert(
        0,
        ChatConversation(
          id: 'conv_$matchId',
          participantId: 'user_$matchId',
          participantName: name,
          participantAvatar: avatar,
          lastMessageText: 'You and $name liked each other! Say hello 👋',
          lastTimestamp: DateTime.now(),
          unreadCount: 0,
          isOnline: true,
          isVerified: isVerified,
        ),
      );
    }
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_messageStorage.containsKey(conversationId)) {
      _messageStorage[conversationId] = [
        ChatMessage(
          id: 'm1',
          conversationId: conversationId,
          senderId: 'user_1',
          text: 'Hey! Loved seeing your profile. Your music taste is spot on 🎶',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'm2',
          conversationId: conversationId,
          senderId: 'current_user',
          text:
              'Thank you! Always happy to meet a fellow indie fan. How has your week been?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'm3',
          conversationId: conversationId,
          senderId: 'user_1',
          text:
              'That rooftop cafe in Bandra sounds dreamy! Let us go this Saturday ✨',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          status: MessageStatus.delivered,
        ),
      ];
    }
    return List<ChatMessage>.from(_messageStorage[conversationId]!);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  }) async {
    // Ensure conversation messages are initialized
    if (!_messageStorage.containsKey(conversationId)) {
      await fetchMessages(conversationId);
    }

    // Safety & Content Moderation Check
    final bool isToxic =
        _flaggedKeywords.any((k) => text.toLowerCase().contains(k));

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'current_user',
      text: isToxic
          ? '🛡️ [Message removed by AI Moderation: Violates community safety guidelines]'
          : text,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
      isFlagged: isToxic,
      itinerarySnippet: itinerarySnippet,
      gameScorecardSnippet: gameScorecardSnippet,
      isVanish: isVanish,
      ttlSeconds: ttlSeconds,
    );

    _messageStorage[conversationId]?.add(msg);
    _streamController.add(msg);

    if (isVanish) {
      Timer(Duration(seconds: ttlSeconds ?? 10), () {
        _messageStorage[conversationId]?.removeWhere((m) => m.id == msg.id);
      });
    }

    // Update conversation last message in list
    final idx = _conversations.indexWhere((c) =>
        c.id == conversationId ||
        c.participantName.toLowerCase() ==
            conversationId.replaceAll('conv_', '').toLowerCase());
    if (idx >= 0) {
      final old = _conversations[idx];
      _conversations[idx] = ChatConversation(
        id: old.id,
        participantId: old.participantId,
        participantName: old.participantName,
        participantAvatar: old.participantAvatar,
        lastMessageText: text.isNotEmpty
            ? text
            : (itinerarySnippet != null
                ? 'Shared Date Plan 🍷'
                : 'Shared Game Scorecard 🏆'),
        lastTimestamp: DateTime.now(),
        unreadCount: old.unreadCount,
        isOnline: old.isOnline,
        isVerified: old.isVerified,
      );
    }

    // Auto-reply simulation after 3s if not flagged and not vanish
    if (!isToxic &&
        itinerarySnippet == null &&
        gameScorecardSnippet == null &&
        !isVanish) {
      Timer(const Duration(seconds: 3), () {
        final reply = ChatMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: 'user_1',
          text: 'Sounds wonderful! Can\'t wait 😊',
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        );
        _streamController.add(reply);
      });
    }

    return msg;
  }

  @override
  Future<bool> requestVideoConsent(String matchId) async {
    // Simulate mutual-consent confirmation
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // Match consented
  }

  @override
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
  }) async {
    // POST /v1/moderation/incident stub
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
