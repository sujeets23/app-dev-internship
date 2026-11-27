import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/chat_message.dart';

enum ChatConnectionStatus { connected, reconnecting, offline }

abstract class IChatService {
  Stream<ChatMessage> get messageStream;
  Stream<ChatConnectionStatus> get connectionStatusStream;
  Stream<Map<String, bool>> get typingStatusStream;
  ChatConnectionStatus get currentConnectionStatus;

  Future<List<ChatConversation>> fetchConversations();
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToPreview,
    String? attachmentType,
    String? attachmentLabel,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  });
  Future<void> markConversationRead(String conversationId);
  Future<void> deleteMessagesForMe({
    required String conversationId,
    required List<String> messageIds,
  });
  Future<void> deleteMessagesForEveryone({
    required String conversationId,
    required List<String> messageIds,
  });
  Future<void> simulateReconnect();
  Future<bool> requestVideoConsent(String matchId);
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
  });
  String resolveConversationId(String rawIdOrParticipantName);
  String addMatch({
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
  Stream<ChatMessage> get messageStream =>
      throw UnimplementedError('Backend WebSocket /v1/chat/stream offline');

  @override
  Stream<ChatConnectionStatus> get connectionStatusStream =>
      throw UnimplementedError('Backend WebSocket /v1/chat/stream offline');

  @override
  Stream<Map<String, bool>> get typingStatusStream =>
      throw UnimplementedError('Backend WebSocket /v1/chat/stream offline');

  @override
  ChatConnectionStatus get currentConnectionStatus =>
      ChatConnectionStatus.offline;

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
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToPreview,
    String? attachmentType,
    String? attachmentLabel,
    Map<String, dynamic>? itinerarySnippet,
    Map<String, dynamic>? gameScorecardSnippet,
    bool isVanish = false,
    int? ttlSeconds,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<void> markConversationRead(String conversationId) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<void> deleteMessagesForMe({
    required String conversationId,
    required List<String> messageIds,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<void> deleteMessagesForEveryone({
    required String conversationId,
    required List<String> messageIds,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<void> simulateReconnect() =>
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
  String resolveConversationId(String rawIdOrParticipantName) =>
      rawIdOrParticipantName;

  @override
  String addMatch({
    required String name,
    required String avatar,
    required String matchId,
    bool isVerified = false,
  }) =>
      'conv_$matchId';
}

/// Rich Mock WebSocket & Moderation Service with local SharedPreferences persistence.
/// Clearly distinguishes simulated demo streaming/moderation from live backend WebSockets.
class MockChatService implements IChatService {
  static const String _messagesCachePrefix = 'date2_chat_msgs_v1_';

  final SharedPreferences? _prefs;
  final StreamController<ChatMessage> _streamController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<ChatConnectionStatus> _connectionController =
      StreamController<ChatConnectionStatus>.broadcast();
  final StreamController<Map<String, bool>> _typingController =
      StreamController<Map<String, bool>>.broadcast();
  final List<Timer> _activeTimers = [];

  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.connected;
  final Map<String, bool> _typingStatus = {};

  MockChatService([this._prefs]);

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
      participantAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      lastMessageText:
          'That rooftop cafe in Bandra sounds dreamy! Let us go this Saturday ✨',
      lastTimestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      unreadCount: 1,
      isOnline: true,
      isVerified: true,
    ),
    ChatConversation(
      id: 'conv_2',
      participantId: 'user_2',
      participantName: 'Zayan',
      participantAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
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
      participantAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
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
  Stream<ChatConnectionStatus> get connectionStatusStream =>
      _connectionController.stream;

  @override
  Stream<Map<String, bool>> get typingStatusStream => _typingController.stream;

  @override
  ChatConnectionStatus get currentConnectionStatus => _connectionStatus;

  @override
  String resolveConversationId(String rawIdOrParticipantName) {
    final normalized = rawIdOrParticipantName.trim().toLowerCase();
    for (final conv in _conversations) {
      if (conv.id.toLowerCase() == normalized ||
          conv.participantId.toLowerCase() == normalized ||
          conv.participantName.toLowerCase() == normalized ||
          'conv_${conv.participantName.toLowerCase()}' == normalized ||
          'conv_${conv.participantId.toLowerCase()}' == normalized) {
        return conv.id;
      }
    }
    return rawIdOrParticipantName.startsWith('conv_')
        ? rawIdOrParticipantName
        : 'conv_$rawIdOrParticipantName';
  }

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return List.from(_conversations);
  }

  @override
  String addMatch({
    required String name,
    required String avatar,
    required String matchId,
    bool isVerified = false,
  }) {
    final existingIdx = _conversations.indexWhere(
      (c) =>
          c.participantId == matchId ||
          c.participantName.toLowerCase() == name.toLowerCase(),
    );
    if (existingIdx >= 0) {
      return _conversations[existingIdx].id;
    }

    final newId = 'conv_$matchId';
    _conversations.insert(
      0,
      ChatConversation(
        id: newId,
        participantId: matchId.startsWith('user_') ? matchId : 'user_$matchId',
        participantName: name,
        participantAvatar: avatar,
        lastMessageText: 'You and $name liked each other! Say hello 👋',
        lastTimestamp: DateTime.now(),
        unreadCount: 0,
        isOnline: true,
        isVerified: isVerified,
      ),
    );
    return newId;
  }

  List<ChatMessage> _defaultSeedMessages(String canonicalId) {
    final conv = _conversations.firstWhere(
      (c) => c.id == canonicalId,
      orElse: () => ChatConversation(
        id: canonicalId,
        participantId: 'user_1',
        participantName: 'Match',
        participantAvatar: '',
        lastMessageText: '',
        lastTimestamp: DateTime.now(),
        unreadCount: 0,
        isOnline: true,
        isVerified: true,
      ),
    );
    if (canonicalId == 'conv_2') {
      return [
        ChatMessage(
          id: 'm2_1',
          conversationId: canonicalId,
          senderId: conv.participantId,
          text: 'Loved the art recommendation. Which gallery first?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          status: MessageStatus.delivered,
        ),
      ];
    }
    if (canonicalId == 'conv_3') {
      return [
        ChatMessage(
          id: 'm3_1',
          conversationId: canonicalId,
          senderId: conv.participantId,
          text: 'Are you free for tea tomorrow afternoon?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: MessageStatus.delivered,
        ),
      ];
    }
    return [
      ChatMessage(
        id: 'm1',
        conversationId: canonicalId,
        senderId: conv.participantId,
        text: 'Hey! Loved seeing your profile. Your music taste is spot on 🎶',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        conversationId: canonicalId,
        senderId: 'current_user',
        text:
            'Thank you! Always happy to meet a fellow indie fan. How has your week been?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        conversationId: canonicalId,
        senderId: conv.participantId,
        text:
            'That rooftop cafe in Bandra sounds dreamy! Let us go this Saturday ✨',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  void _persistMessages(String canonicalId) {
    if (_prefs == null) return;
    final list = _messageStorage[canonicalId];
    if (list == null) return;
    final persisted =
        list.where((m) => !m.isVanish).map((m) => m.toJson()).toList();
    _prefs.setString('$_messagesCachePrefix$canonicalId', jsonEncode(persisted));
  }

  void _syncConversationPreview(String canonicalId) {
    final idx = _conversations.indexWhere((c) => c.id == canonicalId);
    if (idx < 0) return;
    final old = _conversations[idx];
    final msgs = _messageStorage[canonicalId] ?? const [];
    if (msgs.isEmpty) {
      _conversations[idx] = old.copyWith(
        lastMessageText: 'No messages yet — say hello 👋',
      );
      return;
    }
    final latest = msgs.last;
    final previewText = latest.isDeletedForEveryone
        ? (latest.isMe
            ? 'You deleted this message'
            : 'This message was deleted')
        : (latest.text.isNotEmpty
            ? latest.text
            : (latest.itinerarySnippet != null
                ? 'Shared Date Plan 🍷'
                : (latest.gameScorecardSnippet != null
                    ? 'Shared Game Scorecard 🏆'
                    : (latest.attachmentLabel ?? 'Sent an attachment'))));
    _conversations[idx] = old.copyWith(
      lastMessageText: previewText,
      lastTimestamp: latest.timestamp,
    );
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final canonicalId = resolveConversationId(conversationId);
    if (!_messageStorage.containsKey(canonicalId)) {
      List<ChatMessage>? restored;
      if (_prefs != null) {
        final raw = _prefs.getString('$_messagesCachePrefix$canonicalId');
        if (raw != null && raw.isNotEmpty) {
          try {
            final list = jsonDecode(raw) as List<dynamic>;
            restored = list
                .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } catch (_) {}
        }
      }
      _messageStorage[canonicalId] =
          restored ?? _defaultSeedMessages(canonicalId);
    }
    return List<ChatMessage>.from(_messageStorage[canonicalId]!);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
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
    final canonicalId = resolveConversationId(conversationId);
    if (!_messageStorage.containsKey(canonicalId)) {
      await fetchMessages(canonicalId);
    }

    final bool isToxic =
        _flaggedKeywords.any((k) => text.toLowerCase().contains(k));

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: canonicalId,
      senderId: 'current_user',
      text: isToxic
          ? '🛡️ [Message removed by AI Moderation: Violates community safety guidelines]'
          : text,
      timestamp: DateTime.now(),
      status: _connectionStatus == ChatConnectionStatus.offline
          ? MessageStatus.sending
          : MessageStatus.delivered,
      isFlagged: isToxic,
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

    _messageStorage[canonicalId]?.add(msg);
    if (!isVanish) {
      _syncConversationPreview(canonicalId);
      _persistMessages(canonicalId);
    }
    _streamController.add(msg);

    if (isVanish) {
      final timer = Timer(Duration(seconds: ttlSeconds ?? 10), () {
        _messageStorage[canonicalId]?.removeWhere((m) => m.id == msg.id);
      });
      _activeTimers.add(timer);
    }

    if (!isToxic &&
        itinerarySnippet == null &&
        gameScorecardSnippet == null &&
        !isVanish &&
        _connectionStatus == ChatConnectionStatus.connected) {
      final conv = _conversations.firstWhere(
        (c) => c.id == canonicalId,
        orElse: () => ChatConversation(
          id: canonicalId,
          participantId: 'user_1',
          participantName: 'Match',
          participantAvatar: '',
          lastMessageText: '',
          lastTimestamp: DateTime.now(),
          unreadCount: 0,
          isOnline: true,
          isVerified: true,
        ),
      );

      final typingOnTimer = Timer(const Duration(milliseconds: 450), () {
        if (!_typingController.isClosed) {
          _typingStatus[canonicalId] = true;
          _typingController.add(Map.from(_typingStatus));
        }
      });
      _activeTimers.add(typingOnTimer);

      final replyTimer = Timer(const Duration(seconds: 2), () {
        if (!_typingController.isClosed) {
          _typingStatus[canonicalId] = false;
          _typingController.add(Map.from(_typingStatus));
        }

        final reply = ChatMessage(
          id: 'reply_${DateTime.now().microsecondsSinceEpoch}',
          conversationId: canonicalId,
          senderId: conv.participantId,
          text: attachmentLabel != null
              ? 'Love that! Thanks for sharing 😊'
              : 'Sounds wonderful! Can\'t wait 😊',
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        );
        _messageStorage[canonicalId]?.add(reply);
        _syncConversationPreview(canonicalId);
        _persistMessages(canonicalId);
        if (!_streamController.isClosed) {
          _streamController.add(reply);
        }
      });
      _activeTimers.add(replyTimer);
    }

    return msg;
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final canonicalId = resolveConversationId(conversationId);
    final idx = _conversations.indexWhere((c) => c.id == canonicalId);
    if (idx >= 0 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
    }
    final list = _messageStorage[canonicalId];
    if (list != null) {
      bool changed = false;
      for (int i = 0; i < list.length; i++) {
        if (!list[i].isMe && list[i].status != MessageStatus.read) {
          list[i] = list[i].copyWith(status: MessageStatus.read);
          changed = true;
        }
      }
      if (changed) {
        _persistMessages(canonicalId);
      }
    }
  }

  @override
  Future<void> deleteMessagesForMe({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    final canonicalId = resolveConversationId(conversationId);
    final list = _messageStorage[canonicalId];
    if (list == null) return;
    list.removeWhere((m) => messageIds.contains(m.id));
    _syncConversationPreview(canonicalId);
    _persistMessages(canonicalId);
  }

  @override
  Future<void> deleteMessagesForEveryone({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    final canonicalId = resolveConversationId(conversationId);
    final list = _messageStorage[canonicalId];
    if (list == null) return;
    final now = DateTime.now();
    for (int i = 0; i < list.length; i++) {
      final msg = list[i];
      if (messageIds.contains(msg.id) && msg.canDeleteForEveryone) {
        list[i] = ChatMessage(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          text: 'You deleted this message',
          timestamp: msg.timestamp,
          status: msg.status,
          isDeletedForEveryone: true,
          deletedAt: now,
          isVanish: msg.isVanish,
          ttlSeconds: msg.ttlSeconds,
        );
      }
    }
    _syncConversationPreview(canonicalId);
    _persistMessages(canonicalId);
  }

  @override
  Future<void> simulateReconnect() async {
    _connectionStatus = ChatConnectionStatus.offline;
    if (!_connectionController.isClosed) {
      _connectionController.add(_connectionStatus);
    }
    await Future.delayed(const Duration(milliseconds: 500));

    _connectionStatus = ChatConnectionStatus.reconnecting;
    if (!_connectionController.isClosed) {
      _connectionController.add(_connectionStatus);
    }
    await Future.delayed(const Duration(milliseconds: 700));

    for (final entry in _messageStorage.entries) {
      final msgs = entry.value;
      for (int i = 0; i < msgs.length; i++) {
        if (msgs[i].status == MessageStatus.sending) {
          msgs[i] = msgs[i].copyWith(status: MessageStatus.delivered);
        }
      }
      _persistMessages(entry.key);
    }

    _connectionStatus = ChatConnectionStatus.connected;
    if (!_connectionController.isClosed) {
      _connectionController.add(_connectionStatus);
    }
  }

  @override
  Future<bool> requestVideoConsent(String matchId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<void> reportIncident({
    required String matchId,
    required String reason,
    required String confidence,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  void dispose() {
    for (final t in _activeTimers) {
      t.cancel();
    }
    _activeTimers.clear();
    _streamController.close();
    _connectionController.close();
    _typingController.close();
  }
}
