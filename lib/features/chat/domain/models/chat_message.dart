enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isFlagged;
  final Map<String, dynamic>? itinerarySnippet; // For shared AI Date plans!
  final Map<String, dynamic>? gameScorecardSnippet; // For shared game results!
  final bool isVanish;
  final int? ttlSeconds;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.status,
    this.isFlagged = false,
    this.itinerarySnippet,
    this.gameScorecardSnippet,
    this.isVanish = false,
    this.ttlSeconds,
  });

  bool get isMe => senderId == 'current_user';

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isFlagged,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool? isVanish,
    int? ttlSeconds,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isFlagged: isFlagged ?? this.isFlagged,
      itinerarySnippet: itinerarySnippet ?? this.itinerarySnippet,
      gameScorecardSnippet: gameScorecardSnippet ?? this.gameScorecardSnippet,
      isVanish: isVanish ?? this.isVanish,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
    );
  }
}

class ChatConversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final String lastMessageText;
  final DateTime lastTimestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isVerified;

  const ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.lastMessageText,
    required this.lastTimestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.isVerified,
  });
}
