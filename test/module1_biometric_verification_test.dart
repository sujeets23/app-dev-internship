import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/verification/data/biometric_privacy_guard.dart';
import 'package:inclusive_dating/features/verification/data/biometric_verification_service.dart';
import 'package:inclusive_dating/features/verification/data/face_liveness_detector.dart';
import 'package:inclusive_dating/features/verification/data/web_face_landmarker_bridge.dart';
import 'package:inclusive_dating/features/verification/domain/liveness_state_machine.dart';
import 'package:inclusive_dating/features/verification/domain/models/biometric_verification_model.dart';
import 'package:inclusive_dating/features/verification/presentation/providers/biometric_verification_provider.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/biometric_verification_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/companion_kyc_screen.dart';
import 'package:inclusive_dating/features/verification/presentation/screens/verification_result_screen.dart';

void main() {
  group('Module 1: Biometric Verification Domain, Privacy & Service Tests', () {
    late MockBiometricVerificationService mockService;
    late ProductionBiometricVerificationService prodService;

    setUp(() {
      mockService = MockBiometricVerificationService();
      prodService = ProductionBiometricVerificationService();
    });

    test('Generates randomized liveness challenges including all 3 actions', () {
      final challenges = mockService.generateChallengeSequence();
      expect(challenges.length, 3);
      expect(challenges, containsAll(BiometricLivenessAction.values));
    });

    test('CRITICAL PRIVACY: Best-effort volatile memory clear & reference drop', () {
      final dummyBuffer = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final frame = BiometricFrameData(
        rawBytes: dummyBuffer,
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [FaceLandmarkPoint(0.5, 0.5)],
      );

      expect(frame.rawBytes, isNotNull);
      frame.secureWipe();
      expect(frame.rawBytes, isNull);
      expect(dummyBuffer, everyElement(0));
    });

    test('CRITICAL PRIVACY: Strips JPEG APP1 EXIF metadata segment in memory', () {
      // Minimal synthetic JPEG: SOI + APP1(EXIF length 8) + SOS + payload
      final jpegWithExif = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0xFF, 0xE1, 0x00, 0x08, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00, // APP1 Exif
        0xFF, 0xDA, 0x00, 0x04, 0x11, 0x22, // SOS + data
        0xFF, 0xD9, // EOI
      ]);

      final stripped = BiometricPrivacyGuard.stripExifMetadataInMemory(jpegWithExif);
      expect(stripped.length, lessThan(jpegWithExif.length));
      // Contains SOI & SOS without APP1 (0xE1)
      expect(stripped[0], 0xFF);
      expect(stripped[1], 0xD8);
      expect(stripped[2], 0xFF);
      expect(stripped[3], 0xDA);
    });

    test('CRITICAL PRIVACY: Deletes temporary capture files immediately', () async {
      final tempFile = File('${Directory.systemTemp.path}/date2_temp_test.tmp');
      await tempFile.writeAsBytes([1, 2, 3]);
      expect(await tempFile.exists(), isTrue);

      await BiometricPrivacyGuard.deleteTempFileIfExists(tempFile.path);
      expect(await tempFile.exists(), isFalse);
    });

    test('Embedding interface explicitly documents no 512-d model bundled', () async {
      const extractor = PendingTfliteEmbeddingExtractor();
      expect(extractor.isModelBundled, isFalse);
      final res = await extractor.extractEmbedding(Uint8List.fromList([1, 2]));
      expect(res.isAvailable, isFalse);
      expect(res.embeddingVector, isNull);
    });

    test('Validates biometric frame cleanly as Demo Result & wipes buffer', () async {
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
      expect(result.isDemoResult, isTrue);
      expect(result.resultStatus, FaceVerificationStatus.verified);
      expect(result.verificationId, startsWith('VERIF-B3D-'));
      expect(frame.rawBytes, isNull);
    });

    test('Rejects poor lighting & off-center frames and triggers retryRequired/failed', () async {
      final framePoorLight = BiometricFrameData(
        rawBytes: Uint8List.fromList([1, 2, 3]),
        isLightingAdequate: false,
        isDistanceAdequate: true,
        isFaceCentered: true,
        landmarks: const [],
      );
      final lightRes = await mockService.verifyBiometric(
        frameData: framePoorLight,
        completedAction: BiometricLivenessAction.turnLeft,
      );
      expect(lightRes.isSuccess, isFalse);
      expect(lightRes.resultStatus, FaceVerificationStatus.retryRequired);
      expect(framePoorLight.rawBytes, isNull);

      final frameOffCenter = BiometricFrameData(
        rawBytes: Uint8List.fromList([1, 2, 3]),
        isLightingAdequate: true,
        isDistanceAdequate: true,
        isFaceCentered: false,
        landmarks: const [],
      );
      final centerRes = await mockService.verifyBiometric(
        frameData: frameOffCenter,
        completedAction: BiometricLivenessAction.turnRight,
      );
      expect(centerRes.isSuccess, isFalse);
      expect(centerRes.resultStatus, FaceVerificationStatus.failed);
      expect(frameOffCenter.rawBytes, isNull);
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

      await expectLater(
        () => prodService.verifyBiometric(
          frameData: frame,
          completedAction: BiometricLivenessAction.blinkTwice,
        ),
        throwsA(isA<UnimplementedError>()),
      );
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
      expect(submission.frontIdBytes, isNull);
      expect(submission.backIdBytes, isNull);
    });
  });

  group('Module 1: Pure-Dart Active Liveness State Machine Tests', () {
    FaceAnalysisResult alignedFrame({
      double yaw = 0.0,
      double eyeOpen = 0.9,
    }) {
      return FaceAnalysisResult(
        hasFace: true,
        faceCount: 1,
        meanLuma: 130.0,
        alignmentStatus: FaceAlignmentStatus.aligned,
        headEulerAngleY: yaw,
        leftEyeOpenProbability: eyeOpen,
        rightEyeOpenProbability: eyeOpen,
      );
    }

    test('Requires stable alignment frames before starting & progresses through blink, turnLeft, turnRight', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = ActiveLivenessStateMachine(
        initialSequence: const [
          BiometricLivenessAction.blinkTwice,
          BiometricLivenessAction.turnLeft,
          BiometricLivenessAction.turnRight,
        ],
      );

      expect(machine.snapshot.phase, LivenessMachinePhase.waitingForAlignment);
      // Cannot start before 2 stable aligned frames
      machine.beginChallenges(t0);
      expect(machine.snapshot.phase, LivenessMachinePhase.waitingForAlignment);

      machine.processFrame(alignedFrame(), now: t0);
      machine.processFrame(alignedFrame(), now: t0.add(const Duration(milliseconds: 200)));
      machine.beginChallenges(t0.add(const Duration(milliseconds: 300)));
      expect(machine.snapshot.phase, LivenessMachinePhase.runningChallenge);
      expect(machine.snapshot.currentChallenge, BiometricLivenessAction.blinkTwice);

      // Blink 1: open -> closed -> open
      machine.processFrame(alignedFrame(eyeOpen: 0.15), now: t0.add(const Duration(seconds: 1)));
      machine.processFrame(alignedFrame(eyeOpen: 0.85), now: t0.add(const Duration(seconds: 2)));
      expect(machine.snapshot.blinkCyclesCompleted, 1);
      expect(machine.snapshot.currentChallenge, BiometricLivenessAction.blinkTwice);

      // Blink 2: open -> closed -> open -> advances to turnLeft
      machine.processFrame(alignedFrame(eyeOpen: 0.15), now: t0.add(const Duration(seconds: 3)));
      machine.processFrame(alignedFrame(eyeOpen: 0.85), now: t0.add(const Duration(seconds: 4)));
      expect(machine.snapshot.currentChallenge, BiometricLivenessAction.turnLeft);

      // Head turn left ~15°
      machine.processFrame(alignedFrame(yaw: 15.0), now: t0.add(const Duration(seconds: 5)));
      expect(machine.snapshot.currentChallenge, BiometricLivenessAction.turnRight);

      // Head turn right ~15°
      machine.processFrame(alignedFrame(yaw: -15.0), now: t0.add(const Duration(seconds: 6)));
      expect(machine.snapshot.phase, LivenessMachinePhase.completed);
      expect(machine.snapshot.areAllChallengesCompleted, isTrue);
    });

    test('Times out cleanly when challenge exceeds allowed duration & handles interruption', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = ActiveLivenessStateMachine(
        challengeTimeout: const Duration(seconds: 10),
        initialSequence: const [BiometricLivenessAction.blinkTwice],
      );

      machine.processFrame(alignedFrame(), now: t0);
      machine.processFrame(alignedFrame(), now: t0);
      machine.beginChallenges(t0);
      expect(machine.snapshot.phase, LivenessMachinePhase.runningChallenge);

      // Advance past 10s timeout via evaluateTimeout without synthetic frame data
      final timedOutSnap = machine.evaluateTimeout(now: t0.add(const Duration(seconds: 12)));
      expect(timedOutSnap.phase, LivenessMachinePhase.timedOut);

      // Reset & test interruption
      machine.reset();
      machine.markInterrupted('Camera backgrounded');
      expect(machine.snapshot.phase, LivenessMachinePhase.interrupted);
    });
  });

  group('Module 1: Riverpod Notifier & State Machine Tests', () {
    test('Starts unaligned with capture disabled until face alignment is satisfied', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.noFaceDetected);
      expect(state.isLightingGood, isFalse);
      expect(state.isCentered, isFalse);
      expect(state.isReadyToCapture, isFalse);
      expect(state.canStartChallenges, isFalse);
    });

    test('Updates face alignment feedback dynamically from real frame signals', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricVerificationProvider.notifier);

      notifier.updateFaceAlignment(lighting: false, centered: true);
      var state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.poorLighting);
      expect(state.statusMessage, 'Improve lighting');

      notifier.updateFaceAlignment(lighting: true, centered: true, tooFar: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.tooFar);
      expect(state.statusMessage, 'Move closer');

      notifier.updateFaceAlignment(lighting: true, centered: true, tooClose: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.tooClose);
      expect(state.statusMessage, 'Move farther away');

      notifier.updateFaceAlignment(lighting: true, centered: true);
      state = container.read(biometricVerificationProvider);
      expect(state.alignmentStatus, FaceAlignmentStatus.aligned);
    });

    test('Permission denial transitions cleanly and camera interruption fails safely', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricVerificationProvider.notifier);
      notifier.setPermissionDenied(permanent: true);

      var state = container.read(biometricVerificationProvider);
      expect(state.permissionState, CameraPermissionState.permanentlyDenied);
      expect(state.status, BiometricVerificationStatus.failed);

      notifier.retry();
      notifier.handleCameraInterruption('Camera disconnected');
      state = container.read(biometricVerificationProvider);
      expect(state.machinePhase, LivenessMachinePhase.interrupted);
      expect(state.result?.resultStatus, FaceVerificationStatus.retryRequired);
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
      expect(find.text('Centered'), findsOneWidget);
      expect(find.text('Start Liveness Check'), findsOneWidget);
    });

    testWidgets('Renders VerificationResultScreen across all 6 result statuses',
        (tester) async {
      for (final status in FaceVerificationStatus.values) {
        final result = BiometricVerificationResult(
          isSuccess: status == FaceVerificationStatus.verified,
          resultStatus: status,
          isDemoResult: true,
          message: 'Status message for ${status.name}',
          confidenceScore: status == FaceVerificationStatus.verified ? 0.96 : 0.0,
          verificationId:
              status == FaceVerificationStatus.verified ? 'VERIF-B3D-TEST' : null,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: VerificationResultScreen(result: result),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Status message for ${status.name}'), findsOneWidget);
      }
    });

    testWidgets('Renders CompanionKycScreen and progresses through country-aware ID step',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CompanionKycScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Companion KYC Verification'), findsOneWidget);
      expect(find.text('Trust & Safety Escrow'), findsOneWidget);
      expect(find.text('Continue to ID Capture'), findsOneWidget);

      await tester.tap(find.text('Continue to ID Capture'));
      await tester.pumpAndSettle();

      expect(find.text('Upload Government ID'), findsOneWidget);
      expect(find.text('Front View of Aadhaar Card'), findsOneWidget);
      expect(find.text('Back View of Aadhaar Card'), findsOneWidget);
    });
  });

  group('Module 1: Web MediaPipe Telemetry Mapping & Bridge State Tests', () {
    test('mapWebLandmarkerMetricsToAnalysis detects no-face, lighting, distance, centering & aligned signals', () {
      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: false,
          faceCount: 0,
          meanLuma: 120.0,
          widthRatio: 0.0,
          centerX: 0.5,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.noFaceDetected,
      );

      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: true,
          faceCount: 2,
          meanLuma: 120.0,
          widthRatio: 0.35,
          centerX: 0.5,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.multipleFaces,
      );

      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: true,
          faceCount: 1,
          meanLuma: 28.0,
          widthRatio: 0.35,
          centerX: 0.5,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.poorLighting,
      );

      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: true,
          faceCount: 1,
          meanLuma: 125.0,
          widthRatio: 0.15,
          centerX: 0.5,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.tooFar,
      );

      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: true,
          faceCount: 1,
          meanLuma: 125.0,
          widthRatio: 0.78,
          centerX: 0.5,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.tooClose,
      );

      expect(
        mapWebLandmarkerMetricsToAnalysis(
          hasFace: true,
          faceCount: 1,
          meanLuma: 125.0,
          widthRatio: 0.38,
          centerX: 0.80,
          centerY: 0.5,
          headYawDeg: 0.0,
          leftEyeOpen: 1.0,
          rightEyeOpen: 1.0,
        ).alignmentStatus,
        FaceAlignmentStatus.offCenterHorizontal,
      );

      final aligned = mapWebLandmarkerMetricsToAnalysis(
        hasFace: true,
        faceCount: 1,
        meanLuma: 135.0,
        widthRatio: 0.40,
        centerX: 0.50,
        centerY: 0.48,
        headYawDeg: 14.5,
        leftEyeOpen: 0.18,
        rightEyeOpen: 0.19,
        landmarks: const [FaceLandmarkPoint(0.5, 0.5, 'noseTip')],
      );
      expect(aligned.alignmentStatus, FaceAlignmentStatus.aligned);
      expect(aligned.headEulerAngleY, 14.5);
      expect(aligned.normalizedLandmarks, hasLength(1));
    });

    test('BiometricVerificationNotifier handles web permission, unavailability & challenge progress', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(biometricVerificationProvider.notifier);

      notifier.setCheckingPermissionState('Requesting webcam...');
      expect(
        container.read(biometricVerificationProvider).permissionState,
        CameraPermissionState.checking,
      );

      notifier.setHardwareUnavailableState('No webcam found');
      var s = container.read(biometricVerificationProvider);
      expect(s.permissionState, CameraPermissionState.unavailable);
      expect(s.result, isNull);
      expect(s.isHardwareSupported, isFalse);

      notifier.setGrantedAligningState();
      s = container.read(biometricVerificationProvider);
      expect(s.permissionState, CameraPermissionState.granted);
      expect(s.isHardwareSupported, isTrue);
      expect(s.canStartChallenges, isFalse);

      // Feed 2 real aligned frames -> enables challenge button
      final aligned = mapWebLandmarkerMetricsToAnalysis(
        hasFace: true,
        faceCount: 1,
        meanLuma: 130.0,
        widthRatio: 0.38,
        centerX: 0.5,
        centerY: 0.5,
        headYawDeg: 0.0,
        leftEyeOpen: 0.9,
        rightEyeOpen: 0.9,
      );
      notifier.onFaceAnalysisFrame(aligned);
      notifier.onFaceAnalysisFrame(aligned);
      expect(
        container.read(biometricVerificationProvider).canStartChallenges,
        isTrue,
      );
    });
  });
}
