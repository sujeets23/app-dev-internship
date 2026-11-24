import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/features/verification/data/biometric_verification_service.dart';
import 'package:inclusive_dating/features/verification/domain/models/biometric_verification_model.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/companion_kyc_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/verification_result_screen.dart';

void main() {
  group('Module 1: Biometric Verification Domain & Service Tests', () {
    late MockBiometricVerificationService mockService;
    late ProductionBiometricVerificationService prodService;

    setUp(() {
      mockService = MockBiometricVerificationService();
      prodService = ProductionBiometricVerificationService();
    });

    test('Generates randomized liveness challenges', () {
      final challenges = mockService.generateChallengeSequence();
      expect(challenges, isNotEmpty);
      expect(challenges.length, greaterThanOrEqualTo(2));
      for (final action in challenges) {
        expect(BiometricLivenessAction.values.contains(action), isTrue);
      }
    });

    test('CRITICAL PRIVACY: Volatile memory zero-wipe clears raw bytes', () {
      final dummyBuffer = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [FaceLandmarkPoint(0.5, 0.5)],
      );

      expect(frame.rawBytes, isNotNull);
      expect(frame.rawBytes!.length, 8);

      frame.secureWipe();

      expect(frame.rawBytes, isNull);
    });

    test('Validates biometric frame with adequate lighting & distance', () async {
      final dummyBuffer = Uint8List.fromList([10, 20, 30, 40]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [FaceLandmarkPoint(0.5, 0.5)],
      );

      final result = await mockService.verifyBiometric(
        frameData: frame,
        completedAction: BiometricLivenessAction.blinkTwice,
      );

      expect(result.isSuccess, isTrue);
      expect(result.confidenceScore, greaterThan(0.95));
      expect(result.verificationId, startsWith('VERIF-B3D-'));
      expect(result.cryptographicProofHash, isNotNull);

      // Buffer must be wiped even without explicit test call
      expect(frame.rawBytes, isNull);
    });

    test('Rejects frame with poor lighting and wipes memory', () async {
      final dummyBuffer = Uint8List.fromList([1, 2, 3]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: false,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [FaceLandmarkPoint(0.5, 0.5)],
      );

      final result = await mockService.verifyBiometric(
        frameData: frame,
        completedAction: BiometricLivenessAction.turnLeft,
      );

      expect(result.isSuccess, isFalse);
      expect(result.message, contains('lighting'));
      expect(frame.rawBytes, isNull);
    });

    test('Rejects frame when face is not centered and wipes memory', () async {
      final dummyBuffer = Uint8List.fromList([1, 2, 3]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: false,
        landmarks: const [],
      );

      final result = await mockService.verifyBiometric(
        frameData: frame,
        completedAction: BiometricLivenessAction.turnRight,
      );

      expect(result.isSuccess, isFalse);
      expect(result.message, contains('centered'));
      expect(frame.rawBytes, isNull);
    });

    test('Production service wipes memory even on unimplemented backend', () async {
      final dummyBuffer = Uint8List.fromList([255, 255, 255]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [],
      );

      expect(
        () => prodService.verifyBiometric(
          frameData: frame,
          completedAction: BiometricLivenessAction.blinkTwice,
        ),
        throwsA(isA<UnimplementedError>()),
      );

      // Verify that finally block executed and wiped buffer
      expect(frame.rawBytes, isNull);
    });

    test('Companion KYC submission zeroes out document image buffers', () async {
      final front = Uint8List.fromList([1, 2, 3]);
      final back = Uint8List.fromList([4, 5, 6]);

      final submission = CompanionKycSubmission(
        idType: 'Aadhaar Card',
        frontIdBytes: front,
        backIdBytes: back,
        selfieVerificationProofId: 'VERIF-B3D-1234',
        policeClearanceAffirmed: true,
        legalFullName: 'Test User',
        documentNumber: '1234-5678-9012',
      );

      final res = await mockService.submitCompanionKyc(submission);
      expect(res['success'], isTrue);
      expect(res['kyc_reference_id'], isNotNull);

      // Ensure buffers are wiped
      expect(submission.frontIdBytes, isNull);
      expect(submission.backIdBytes, isNull);
    });
  });

  group('Module 1: Riverpod Notifier & State Machine Tests', () {
    test('Initializes in aligning state with ready badges', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(biometricVerificationProvider);
      expect(state.status, BiometricVerificationStatus.aligning);
      expect(state.isLightingGood, isTrue);
      expect(state.isDistanceGood, isTrue);
      expect(state.isCentered, isTrue);
      expect(state.alignmentStatus, FaceAlignmentStatus.aligned);
    });

    test('Updates face alignment feedback dynamically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricVerificationProvider.notifier);

      // Test lighting failure
      notifier.updateFaceAlignment(lighting: false, centered: true);
      var state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.poorLighting);
      expect(state.statusMessage, 'Improve lighting');

      // Test distance too far
      notifier.updateFaceAlignment(lighting: true, centered: true, tooFar: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.tooFar);
      expect(state.statusMessage, 'Move closer');

      // Test distance too close
      notifier.updateFaceAlignment(lighting: true, centered: true, tooClose: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.tooClose);
      expect(state.statusMessage, 'Move slightly back');

      // Test aligned
      notifier.updateFaceAlignment(lighting: true, centered: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.aligned);
    });

    test('Permission denial transitions to failed state with clear message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricVerificationProvider.notifier);
      notifier.setPermissionDenied();

      final state = container.read(biometricVerificationProvider);
      expect(state.permissionState, CameraPermissionState.denied);
      expect(state.status, BiometricVerificationStatus.failed);
      expect(state.statusMessage, contains('permission denied'));
    });
  });

  group('Module 1: UI & Widget Tests', () {
    testWidgets('Renders BiometricVerificationScreen with overlay & badges',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BiometricVerificationScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Identity Assurance & Shield'), findsOneWidget);
      expect(find.text('Lighting'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Centered'), findsWidgets);
      expect(find.text('Start Liveness Check'), findsOneWidget);
    });

    testWidgets('Renders VerificationResultScreen in success state',
        (tester) async {
      const result = BiometricVerificationResult(
        isSuccess: true,
        message: 'Identity Verified. Liveness action successfully confirmed.',
        confidenceScore: 0.985,
        verificationId: 'VERIF-B3D-TEST',
        cryptographicProofHash: 'sha256:abc123test',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VerificationResultScreen(result: result),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Identity Verified!'), findsOneWidget);
      expect(find.text('Proof ID: VERIF-B3D-TEST'), findsOneWidget);
      expect(find.text('Proceed to Government ID'), findsOneWidget);
      expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
    });

    testWidgets('Renders VerificationResultScreen in failure state with retry',
        (tester) async {
      const result = BiometricVerificationResult(
        isSuccess: false,
        message: 'Verification failed: Insufficient lighting.',
        confidenceScore: 0.38,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VerificationResultScreen(result: result),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Verification Incomplete'), findsOneWidget);
      expect(find.text('Verification failed: Insufficient lighting.'), findsOneWidget);
      expect(find.text('Retry Live Verification'), findsOneWidget);
      expect(find.text('Do This Later'), findsOneWidget);
    });

    testWidgets('Renders CompanionKycScreen and progresses through wizard',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: CompanionKycScreen(),
        ),
      );
      await tester.pump();

      // Screen 1: Introduction
      expect(find.text('Companion KYC Verification'), findsOneWidget);
      expect(find.text('Trust & Safety Escrow'), findsOneWidget);
      expect(find.text('Continue to ID Capture'), findsOneWidget);

      // Tap Continue to ID Capture
      await tester.tap(find.text('Continue to ID Capture'));
      await tester.pumpAndSettle();

      // Screen 2: Gov ID
      expect(find.text('Upload Government ID'), findsOneWidget);
      expect(find.text('Front View of Aadhaar Card'), findsOneWidget);
      expect(find.text('Back View of Aadhaar Card'), findsOneWidget);
    });
  });
}
