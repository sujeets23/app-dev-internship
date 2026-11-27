import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/features/auth/presentation/providers/auth_provider.dart';
import 'package:inclusive_dating/features/chat/data/chat_service.dart';
import 'package:inclusive_dating/features/chat/domain/models/call_session.dart';
import 'package:inclusive_dating/features/chat/domain/models/chat_message.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/video_call_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';
import 'package:inclusive_dating/features/games/presentation/screens/games_lobby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Module 3: Feature 1 — Real-Time WebSocket Chat & Text Moderation', () {
    test('ChatMessage model holds itinerary, scorecard and vanish TTL metadata', () {
      final msg = ChatMessage(
        id: 'msg_101',
        conversationId: 'conv_1',
        senderId: 'current_user',
        text: 'Hey! Here is our date plan ☕',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        itinerarySnippet: const {
          'title': 'Bandra Cozy Sunset & Coffee',
          'budget': '1500',
        },
        gameScorecardSnippet: const {
          'gameTitle': 'Two Truths & a Lie',
          'score': '3/3 Caught',
        },
        isVanish: true,
        ttlSeconds: 10,
      );

      expect(msg.isMe, isTrue);
      expect(msg.isVanish, isTrue);
      expect(msg.ttlSeconds, 10);
      expect(msg.itinerarySnippet!['title'], 'Bandra Cozy Sunset & Coffee');
      expect(msg.gameScorecardSnippet!['score'], '3/3 Caught');
    });

    test('MockChatService flags toxic keywords instantly with UI redaction flag', () async {
      final service = MockChatService();

      final cleanMsg = await service.sendMessage(
        conversationId: 'conv_1',
        text: 'Looking forward to our coffee date this weekend!',
      );
      expect(cleanMsg.isFlagged, isFalse);

      final toxicMsg = await service.sendMessage(
        conversationId: 'conv_1',
        text: 'You idiot, I hate that place!',
      );
      expect(toxicMsg.isFlagged, isTrue);
    });

    test('MockChatService.addMatch dynamically registers new mutual matches into conversation list', () async {
      final service = MockChatService();

      final initialList = await service.fetchConversations();
      final initialCount = initialList.length;

      service.addMatch(
        name: 'Maya',
        avatar: 'https://example.com/maya.jpg',
        matchId: 'user_maya',
        isVerified: true,
      );

      final updatedList = await service.fetchConversations();
      expect(updatedList.length, initialCount + 1);
      expect(updatedList.first.participantName, 'Maya');
      expect(updatedList.first.isVerified, isTrue);
      expect(updatedList.first.isOnline, isTrue);
    });
  });

  group('Module 3: Feature 2 & 3 — Mutual Consent Video Call & On-Device Moderation', () {
    test('VideoCallNotifier initiates call with mutual consent and tracks session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(videoCallProvider.notifier);

      await notifier.initiateCall(
        matchId: 'user_1',
        matchName: 'Aarya',
        matchAvatar: 'https://example.com/aarya.jpg',
      );

      final session = container.read(videoCallProvider);
      expect(session, isNotNull);
      expect(session!.matchName, 'Aarya');
      expect(session.status, CallStatus.connected);
    });

    test('triggerSafetyViolation terminates peer connection and locks session with warning', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(videoCallProvider.notifier);

      await notifier.initiateCall(
        matchId: 'user_1',
        matchName: 'Aarya',
        matchAvatar: 'https://example.com/aarya.jpg',
      );

      await notifier.triggerSafetyViolation(reason: 'Explicit Visual Pattern (98% confidence)');

      final session = container.read(videoCallProvider);
      expect(session!.status, CallStatus.terminatedByModeration);
      expect(session.moderationWarning, contains('Connection safely terminated'));
    });
  });

  group('Section 6: Chat Workspace 4 Specialized Modes', () {
    test('ConversationNotifier sends Vanish mode messages and auto-destructs them on TTL expiry', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(conversationMessagesProvider('conv_1').notifier);
      await container.read(conversationMessagesProvider('conv_1').future);

      // Send Vanish message with 1 second TTL for test speed
      await notifier.sendMessage(
        'This secret message will self-destruct!',
        isVanish: true,
        ttlSeconds: 1,
      );

      var messages = container.read(conversationMessagesProvider('conv_1')).value!;
      expect(messages.any((m) => m.text == 'This secret message will self-destruct!'), isTrue);

      // Wait for timer to expire
      await Future.delayed(const Duration(milliseconds: 1200));

      messages = container.read(conversationMessagesProvider('conv_1')).value!;
      expect(messages.any((m) => m.text == 'This secret message will self-destruct!'), isFalse);
    });

    test('ConversationNotifier sends Date Proposal Itinerary Snippet into chat stream', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(conversationMessagesProvider('conv_1').notifier);
      await container.read(conversationMessagesProvider('conv_1').future);

      await notifier.sendMessage(
        'Check out our date itinerary!',
        itinerarySnippet: const {
          'title': 'Bandra Cozy Sunset & Coffee',
          'neighborhood': 'Bandra West',
          'budget': '1500',
          'stops': [
            'Stop 1: Subko Specialty Coffee',
            'Stop 2: Seaside Walk',
          ],
        },
      );

      final messages = container.read(conversationMessagesProvider('conv_1')).value!;
      final dateMsg = messages.firstWhere((m) => m.itinerarySnippet != null);
      expect(dateMsg.itinerarySnippet!['title'], 'Bandra Cozy Sunset & Coffee');
      expect(dateMsg.itinerarySnippet!['neighborhood'], 'Bandra West');
    });

    test('ConversationNotifier sends Game Scorecard Snippet into chat stream', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(conversationMessagesProvider('conv_1').notifier);
      await container.read(conversationMessagesProvider('conv_1').future);

      await notifier.sendMessage(
        'Here is my game scorecard!',
        gameScorecardSnippet: const {
          'gameTitle': 'Compatibility Trivia',
          'score': '85% Vibe Match',
          'badge': 'Soul Connection ✨',
        },
      );

      final messages = container.read(conversationMessagesProvider('conv_1')).value!;
      final gameMsg = messages.firstWhere((m) => m.gameScorecardSnippet != null);
      expect(gameMsg.gameScorecardSnippet!['gameTitle'], 'Compatibility Trivia');
      expect(gameMsg.gameScorecardSnippet!['score'], '85% Vibe Match');
    });

    test('MockChatService resolves participant alias, marks read, reconnects & deletes messages cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = MockChatService(prefs);

      expect(service.resolveConversationId('Aarya'), 'conv_1');
      await service.markConversationRead('conv_1');
      final afterRead = await service.fetchConversations();
      final aaryaConv = afterRead.firstWhere((c) => c.id == 'conv_1');
      expect(aaryaConv.unreadCount, 0);

      final sent = await service.sendMessage(
        conversationId: 'conv_1',
        text: 'Temporary message for deletion',
      );
      expect(sent.canDeleteForEveryone, isTrue);

      await service.deleteMessagesForEveryone(
        conversationId: 'conv_1',
        messageIds: [sent.id],
      );
      final msgsAfterEveryone = await service.fetchMessages('conv_1');
      final tombstone = msgsAfterEveryone.firstWhere((m) => m.id == sent.id);
      expect(tombstone.isDeletedForEveryone, isTrue);
      expect(tombstone.text, 'You deleted this message');

      await service.deleteMessagesForMe(
        conversationId: 'conv_1',
        messageIds: [sent.id],
      );
      final msgsAfterMe = await service.fetchMessages('conv_1');
      expect(msgsAfterMe.any((m) => m.id == sent.id), isFalse);

      final statuses = <ChatConnectionStatus>[];
      final sub = service.connectionStatusStream.listen(statuses.add);
      await service.simulateReconnect();
      await sub.cancel();
      expect(
        statuses,
        containsAllInOrder([
          ChatConnectionStatus.offline,
          ChatConnectionStatus.reconnecting,
          ChatConnectionStatus.connected,
        ]),
      );

      service.dispose();
    });

    test('VideoCallNotifier speaker toggle and moderation session lock work end-to-end', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final callNotifier = container.read(videoCallProvider.notifier);
      await callNotifier.initiateCall(
        matchId: 'conv_1',
        matchName: 'Aarya',
        matchAvatar: 'https://example.com/aarya.jpg',
      );

      expect(container.read(videoCallProvider)?.isSpeakerOn, isTrue);
      callNotifier.toggleSpeaker();
      expect(container.read(videoCallProvider)?.isSpeakerOn, isFalse);

      await callNotifier.triggerSafetyViolation(
        reason: 'Demo TFLite NSFW frame flagged',
      );
      expect(
        container.read(videoCallProvider)?.status,
        CallStatus.terminatedByModeration,
      );
      expect(
        container.read(moderationLockProvider)['conv_1'],
        'Demo TFLite NSFW frame flagged',
      );
    });
  });

  group('Module 3 & Games UI Interactions', () {
    testWidgets('ChatScreen sends, long-press deletes for everyone, toggles AI Chat & Vanish Mode at 360x780', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              optionalSharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const MaterialApp(
              home: ChatScreen(
                conversationId: 'conv_1',
                participantName: 'Aarya',
                participantAvatar: 'https://example.com/aarya.png',
                isVerified: true,
                sharedInterests: ['Indie Coffee', 'Pottery'],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));

        await tester.enterText(
          find.byType(TextField).first,
          'Smoke test delete message',
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('Smoke test delete message'), findsOneWidget);

        await tester.longPress(find.text('Smoke test delete message'));
        await tester.pump(const Duration(milliseconds: 200));

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Delete for everyone'), findsOneWidget);
        expect(find.text('Delete for me'), findsOneWidget);

        await tester.tap(find.text('Delete for everyone'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('You deleted this message'), findsWidgets);

        await tester.tap(find.text('Vanish Mode'));
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.textContaining('Vanish Mode Active'), findsOneWidget);

        await tester.tap(find.text('AI Chat'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Date² AI Chat (Demo)'), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
      }, createHttpClient: (_) => _TransparentImageHttpClient());
    });

    testWidgets('GamesLobbyScreen renders and switches cleanly between Match and Solo modes at 360x780', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              optionalSharedPreferencesProvider.overrideWithValue(prefs),
            ],
            child: const MaterialApp(
              home: Scaffold(body: GamesLobbyScreen()),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('With a Match'), findsOneWidget);
        expect(find.text('Solo Mode'), findsOneWidget);

        await tester.tap(find.text('Solo Mode'));
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('Two Truths & a Lie'), findsOneWidget);
      }, createHttpClient: (_) => _TransparentImageHttpClient());
    });
  });
}

class _TransparentImageHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TransparentImageRequest();
}

class _TransparentImageRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _DummyHeaders();

  @override
  Future<HttpClientResponse> close() async => _TransparentImageResponse();
}

class _DummyHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _TransparentImageResponse extends Fake implements HttpClientResponse {
  static const List<int> _transparentPng = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
