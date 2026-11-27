enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isFlagged;
  final bool isDeletedForEveryone;
  final DateTime? deletedAt;
  final String? replyToMessageId;
  final String? replyToSenderName;
  final String? replyToPreview;
  final String? attachmentType;
  final String? attachmentLabel;
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
    this.isDeletedForEveryone = false,
    this.deletedAt,
    this.replyToMessageId,
    this.replyToSenderName,
    this.replyToPreview,
    this.attachmentType,
    this.attachmentLabel,
    this.itinerarySnippet,
    this.gameScorecardSnippet,
    this.isVanish = false,
    this.ttlSeconds,
  });

  bool get isMe => senderId == 'current_user';

  /// Matches standard 15-minute client-side window for "Delete for everyone".
  bool get canDeleteForEveryone =>
      isMe &&
      !isDeletedForEveryone &&
      DateTime.now().difference(timestamp).inMinutes <= 15;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isFlagged,
    bool? isDeletedForEveryone,
    DateTime? deletedAt,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToPreview,
    String? attachmentType,
    String? attachmentLabel,
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
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedAt: deletedAt ?? this.deletedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToPreview: replyToPreview ?? this.replyToPreview,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
      itinerarySnippet: itinerarySnippet ?? this.itinerarySnippet,
      gameScorecardSnippet: gameScorecardSnippet ?? this.gameScorecardSnippet,
      isVanish: isVanish ?? this.isVanish,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'isFlagged': isFlagged,
        'isDeletedForEveryone': isDeletedForEveryone,
        'deletedAt': deletedAt?.toIso8601String(),
        'replyToMessageId': replyToMessageId,
        'replyToSenderName': replyToSenderName,
        'replyToPreview': replyToPreview,
        'attachmentType': attachmentType,
        'attachmentLabel': attachmentLabel,
        'itinerarySnippet': itinerarySnippet,
        'gameScorecardSnippet': gameScorecardSnippet,
        'isVanish': isVanish,
        'ttlSeconds': ttlSeconds,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: MessageStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MessageStatus.sent,
        ),
        isFlagged: json['isFlagged'] as bool? ?? false,
        isDeletedForEveryone: json['isDeletedForEveryone'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null
            ? DateTime.tryParse(json['deletedAt'] as String)
            : null,
        replyToMessageId: json['replyToMessageId'] as String?,
        replyToSenderName: json['replyToSenderName'] as String?,
        replyToPreview: json['replyToPreview'] as String?,
        attachmentType: json['attachmentType'] as String?,
        attachmentLabel: json['attachmentLabel'] as String?,
        itinerarySnippet: json['itinerarySnippet'] != null
            ? Map<String, dynamic>.from(json['itinerarySnippet'] as Map)
            : null,
        gameScorecardSnippet: json['gameScorecardSnippet'] != null
            ? Map<String, dynamic>.from(json['gameScorecardSnippet'] as Map)
            : null,
        isVanish: json['isVanish'] as bool? ?? false,
        ttlSeconds: json['ttlSeconds'] as int?,
      );
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

  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessageText,
    DateTime? lastTimestamp,
    int? unreadCount,
    bool? isOnline,
    bool? isVerified,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
