import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/features/verification/data/biometric_verification_service.dart';
import 'package:inclusive_dating/features/verification/domain/models/biometric_verification_model.dart';
import 'package:inclusive_dating/features/discovery/data/discovery_service.dart';
import 'package:inclusive_dating/features/discovery/domain/models/discovery_profile.dart';
import 'package:inclusive_dating/features/chat/data/chat_service.dart';
import 'package:inclusive_dating/features/chat/domain/models/call_session.dart';
import 'package:inclusive_dating/features/companions/data/companion_service.dart';
import 'package:inclusive_dating/features/companions/domain/models/companion_booking.dart';
import 'package:inclusive_dating/features/date_planner/data/date_planner_service.dart';
import 'package:inclusive_dating/features/subscription/data/payment_service.dart';
import 'package:inclusive_dating/features/subscription/domain/models/subscription_model.dart';

void main() {
  group('Module 1: Identity Assurance & Biometric Verification', () {
    final service = MockBiometricVerificationService();

    test('Generates random liveness action sequence', () {
      final challenges = service.generateChallengeSequence();
      expect(challenges, isNotEmpty);
      expect(challenges.length, greaterThanOrEqualTo(2));
    });

    test('Validates biometric frame and volatile memory zeroing', () async {
      final frameData = BiometricFrameData(
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [
          FaceLandmarkPoint(0.35, 0.38),
          FaceLandmarkPoint(0.65, 0.38),
          FaceLandmarkPoint(0.50, 0.52),
          FaceLandmarkPoint(0.50, 0.72),
        ],
      );

      final result = await service.verifyBiometric(
        frameData: frameData,
        completedAction: BiometricLivenessAction.blinkTwice,
      );

      expect(result.isSuccess, isTrue);
      expect(result.confidenceScore, greaterThan(0.95));

      // Verifies zero-persistence volatile memory wipe
      frameData.secureWipe();
      expect(frameData.rawBytes, isNull);
    });
  });

  group('Module 2: Inclusive Discovery Engine & Swiping', () {
    final service = MockDiscoveryService();

    test('Fetches discovery deck with inclusive profiles', () async {
      final deck = await service.fetchDeck();
      expect(deck, isNotEmpty);
      expect(deck.first.name, isNotEmpty);
      expect(deck.first.pronouns, isNotEmpty);
      expect(deck.first.gender, isNotEmpty);
    });

    test('Records swipe right and detects mutual match', () async {
      final result = await service.sendSwipe(
        profileId: 'disc_1',
        direction: SwipeDirection.right,
      );

      expect(result.isMatch, isTrue);
      expect(result.profile.name, contains('Aarya'));
      expect(result.profile.matchPercentage, greaterThan(80));
    });
  });

  group('Module 3: Real-Time Chat, Video Calling & Safety Moderation', () {
    final service = MockChatService();

    test('Fetches conversations and initial message thread', () async {
      final convs = await service.fetchConversations();
      expect(convs, isNotEmpty);

      final messages = await service.fetchMessages(convs.first.id);
      expect(messages, isNotEmpty);
      expect(messages.first.text, isNotEmpty);
    });

    test('Moderation automatically removes flagged toxic content', () async {
      final msg = await service.sendMessage(
        conversationId: 'conv_1',
        text: 'I hate this and will threaten someone',
      );

      expect(msg.isFlagged, isTrue);
      expect(msg.text, contains('AI Moderation'));
    });

    test('Mutual video consent confirmation', () async {
      final consented = await service.requestVideoConsent('user_1');
      expect(consented, isTrue);
    });

    test('Video Call session status transitions and safety termination', () {
      var call = const CallSession(
        callId: 'call_123',
        matchId: 'user_1',
        matchName: 'Aarya',
        matchAvatar: 'https://avatar.url',
        status: CallStatus.requestingConsent,
      );

      expect(call.status, CallStatus.requestingConsent);

      call = call.copyWith(status: CallStatus.connected);
      expect(call.status, CallStatus.connected);

      call = call.copyWith(
        status: CallStatus.terminatedByModeration,
        moderationWarning: 'Violation detected by TFLite classifier',
      );
      expect(call.status, CallStatus.terminatedByModeration);
      expect(call.moderationWarning, contains('TFLite'));
    });
  });

  group('Module 4: Companion Marketplace & Safety Escrow', () {
    final service = MockCompanionService();

    test('Fetches verified companions with categories and rates', () async {
      final companions = await service.fetchCompanions();
      expect(companions, isNotEmpty);
      expect(companions.first.hourlyRate, greaterThan(0));
      expect(companions.first.specialties, isNotEmpty);
      expect(companions.first.isVerified, isTrue);
    });

    test('Creates safety escrow booking with QR and OTP check-in code', () async {
      final booking = await service.createBooking(
        companionId: 'comp_1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        durationHours: 3,
        eventCategory: 'Gallery & Arts',
        venueName: 'Kala Ghoda Art Pavilion',
        venueAddress: 'Fort, Mumbai',
        venueLat: 18.9298,
        venueLng: 72.8331,
        hourlyRate: 850.0,
      );

      expect(booking.totalAmount, 3 * 850.0);
      expect(booking.escrowStatus, EscrowStatus.heldInEscrow);
      expect(booking.checkInOtp, '7492');
      expect(booking.isGpsTrackingActive, isTrue);
    });

    test('Performs OTP check-in successfully', () async {
      final checkedIn = await service.checkInWithOtp(
        bookingId: 'bk_123',
        otp: '7492',
      );

      expect(checkedIn.bookingState, BookingState.inProgress);
      expect(checkedIn.checkInTime, isNotNull);
    });
  });

  group('Module 5: AI Budget Date Planner & Partner Venue Engine', () {
    final service = MockDatePlannerService();

    test('Generates chronological date plan strictly within budget', () async {
      const budget = 2000.0;
      final plan = await service.generateDatePlan(
        budget: budget,
        neighborhood: 'Bandra West, Mumbai',
        vibe: 'Romantic',
        dietary: 'Vegetarian',
      );

      expect(plan.stops, isNotEmpty);
      expect(plan.stops.length, 3);
      expect(plan.totalEstimatedCost, lessThanOrEqualTo(budget));
      expect(plan.stops.any((s) => s.isQueerFriendlyPartner), isTrue);
      expect(plan.digitalVoucherCode, contains('DATE2-PARTNER'));
    });

    test('Redeems 10% partner discount digital voucher', () async {
      final success = await service.redeemVoucher(
        planId: 'dp_1',
        voucherCode: 'DATE2-PARTNER-7892',
      );
      expect(success, isTrue);
    });

    test('Date Planner generates plan with itinerary snippet ready for Chat', () async {
      final plan = await service.generateDatePlan(
        budget: 1500,
        neighborhood: 'Bandra West, Mumbai',
        vibe: 'Romantic',
        dietary: 'Any',
      );

      final snippet = {
        'title': plan.title,
        'summary': plan.stops.map((s) => s.venueName).join(' ➔ '),
        'budget': plan.totalEstimatedCost.toInt().toString(),
      };

      expect(snippet['title'], isNotEmpty);
      expect(snippet['summary'], contains('➔'));
      expect(int.parse(snippet['budget']!), lessThanOrEqualTo(1500));
    });
  });

  group('Module 6: Micro-Subscriptions & Payments Ledger', () {
    final service = MockPaymentService();

    test('Initializes with free tier profile', () async {
      final profile = await service.fetchBillingProfile();
      expect(profile.activeTier, SubscriptionTier.free);
      expect(profile.transactionHistory, isNotEmpty);
    });

    test('Upgrades to Pro Plan via Razorpay test mode & activates AutoPay', () async {
      final txn = await service.processSubscriptionPayment(
        tier: SubscriptionTier.pro,
        paymentMethod: 'Google Pay UPI',
        enableAutoPayMandate: true,
      );

      expect(txn.status, 'Success');
      expect(txn.amount, 100.0);

      final profile = await service.fetchBillingProfile();
      expect(profile.activeTier, SubscriptionTier.pro);
      expect(profile.isAutoPayActive, isTrue);
      expect(profile.autoPayMandateId, isNotNull);
    });

    test('Purchases one-time micro unlock (₹29 Profile Boost)', () async {
      final txn = await service.processMicroUnlock(
        unlockType: 'boost_29',
        amount: 29.0,
        paymentMethod: 'UPI Intent',
      );

      expect(txn.status, 'Success');
      expect(txn.amount, 29.0);
    });

    test('Cancels recurring AutoPay mandate with 1 tap', () async {
      final cancelled = await service.cancelAutoPayMandate('MANDATE_123');
      expect(cancelled, isTrue);

      final profile = await service.fetchBillingProfile();
      expect(profile.isAutoPayActive, isFalse);
      expect(profile.autoPayMandateId, isNull);
    });
  });
}
