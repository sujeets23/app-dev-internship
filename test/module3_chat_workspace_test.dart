import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/features/chat/data/chat_service.dart';
import 'package:inclusive_dating/features/chat/domain/models/call_session.dart';
import 'package:inclusive_dating/features/chat/domain/models/chat_message.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/video_call_provider.dart';

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
  });
}
