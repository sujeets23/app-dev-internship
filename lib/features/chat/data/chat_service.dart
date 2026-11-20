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
  });
  Future<bool> requestVideoConsent(String matchId);
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
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

  @override
  Stream<ChatMessage> get messageStream => _streamController.stream;

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
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
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
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
        text: 'Thank you! Always happy to meet a fellow indie fan. How has your week been?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        conversationId: conversationId,
        senderId: 'user_1',
        text: 'That rooftop cafe in Bandra sounds dreamy! Let us go this Saturday ✨',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? itinerarySnippet,
  }) async {
    // Safety & Content Moderation Check
    final bool isToxic = _flaggedKeywords.any((k) => text.toLowerCase().contains(k));

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
    );

    _streamController.add(msg);

    // Auto-reply simulation after 3s if not flagged
    if (!isToxic && itinerarySnippet == null) {
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
