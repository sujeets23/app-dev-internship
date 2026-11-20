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

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.status,
    this.isFlagged = false,
    this.itinerarySnippet,
  });

  bool get isMe => senderId == 'current_user';
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
