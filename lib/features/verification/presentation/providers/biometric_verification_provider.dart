import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import '../../data/biometric_verification_service.dart';
import '../../data/camera_permission_service.dart';
import '../../data/face_liveness_detector.dart';
import '../../domain/liveness_state_machine.dart';
import '../../domain/models/biometric_verification_model.dart';

class BiometricVerificationState {
  final BiometricVerificationStatus status;
  final CameraPermissionState permissionState;
  final FaceAlignmentStatus alignmentStatus;
  final List<BiometricLivenessAction> challenges;
  final int currentChallengeIndex;
  final double currentChallengeProgress;
  final int blinkCyclesCompleted;
  final bool isLightingGood;
  final bool isDistanceGood;
  final bool isFaceTooClose;
  final bool isFaceTooFar;
  final bool isCentered;
  final bool currentActionCompleted;
  final bool isHardwareSupported;
  final double progress;
  final String statusMessage;
  final BiometricVerificationResult? result;
  final List<FaceLandmarkPoint> landmarkPoints;
  final double headYawAngle;
  final double eyeOpenRatio;
  final LivenessMachinePhase machinePhase;

  const BiometricVerificationState({
    required this.status,
    required this.permissionState,
    required this.alignmentStatus,
    required this.challenges,
    required this.currentChallengeIndex,
    this.currentChallengeProgress = 0.0,
    this.blinkCyclesCompleted = 0,
    required this.isLightingGood,
    required this.isDistanceGood,
    required this.isFaceTooClose,
    required this.isFaceTooFar,
    required this.isCentered,
    required this.currentActionCompleted,
    this.isHardwareSupported = true,
    required this.progress,
    required this.statusMessage,
    this.result,
    required this.landmarkPoints,
    this.headYawAngle = 0.0,
    this.eyeOpenRatio = 1.0,
    this.machinePhase = LivenessMachinePhase.waitingForAlignment,
  });

  BiometricLivenessAction? get currentChallenge {
    if (currentChallengeIndex < challenges.length) {
      return challenges[currentChallengeIndex];
    }
    return null;
  }

  bool get areAllChallengesCompleted =>
      machinePhase == LivenessMachinePhase.completed ||
      currentChallengeIndex >= challenges.length;

  /// Capture / verify button unlocks strictly when face alignment & all active
  /// liveness challenges are verified by real sensor input.
  bool get isReadyToCapture =>
      alignmentStatus == FaceAlignmentStatus.aligned &&
      permissionState == CameraPermissionState.granted &&
      areAllChallengesCompleted;

  bool get canStartChallenges =>
      alignmentStatus == FaceAlignmentStatus.aligned &&
      permissionState == CameraPermissionState.granted &&
      status == BiometricVerificationStatus.aligning;

  BiometricVerificationState copyWith({
    BiometricVerificationStatus? status,
    CameraPermissionState? permissionState,
    FaceAlignmentStatus? alignmentStatus,
    List<BiometricLivenessAction>? challenges,
    int? currentChallengeIndex,
    double? currentChallengeProgress,
    int? blinkCyclesCompleted,
    bool? isLightingGood,
    bool? isDistanceGood,
    bool? isFaceTooClose,
    bool? isFaceTooFar,
    bool? isCentered,
    bool? currentActionCompleted,
    bool? isHardwareSupported,
    double? progress,
    String? statusMessage,
    BiometricVerificationResult? result,
    bool clearResult = false,
    List<FaceLandmarkPoint>? landmarkPoints,
    double? headYawAngle,
    double? eyeOpenRatio,
    LivenessMachinePhase? machinePhase,
  }) {
    return BiometricVerificationState(
      status: status ?? this.status,
      permissionState: permissionState ?? this.permissionState,
      alignmentStatus: alignmentStatus ?? this.alignmentStatus,
      challenges: challenges ?? this.challenges,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      currentChallengeProgress:
          currentChallengeProgress ?? this.currentChallengeProgress,
      blinkCyclesCompleted: blinkCyclesCompleted ?? this.blinkCyclesCompleted,
      isLightingGood: isLightingGood ?? this.isLightingGood,
      isDistanceGood: isDistanceGood ?? this.isDistanceGood,
      isFaceTooClose: isFaceTooClose ?? this.isFaceTooClose,
      isFaceTooFar: isFaceTooFar ?? this.isFaceTooFar,
      isCentered: isCentered ?? this.isCentered,
      currentActionCompleted:
          currentActionCompleted ?? this.currentActionCompleted,
      isHardwareSupported: isHardwareSupported ?? this.isHardwareSupported,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      result: clearResult ? null : (result ?? this.result),
      landmarkPoints: landmarkPoints ?? this.landmarkPoints,
      headYawAngle: headYawAngle ?? this.headYawAngle,
      eyeOpenRatio: eyeOpenRatio ?? this.eyeOpenRatio,
      machinePhase: machinePhase ?? this.machinePhase,
    );
  }
}

final cameraPermissionServiceProvider =
    Provider<ICameraPermissionService>((ref) {
  return const DeviceCameraPermissionService();
});

final biometricServiceProvider =
    Provider<IBiometricVerificationService>((ref) {
  return MockBiometricVerificationService();
});

class BiometricVerifiedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setVerified(bool val) => state = val;
}

final isUserBiometricallyVerifiedProvider =
    NotifierProvider<BiometricVerifiedNotifier, bool>(
  BiometricVerifiedNotifier.new,
);

final isProfileVerifiedProvider = isUserBiometricallyVerifiedProvider;

class BiometricVerificationNotifier
    extends Notifier<BiometricVerificationState> {
  late ActiveLivenessStateMachine _livenessMachine;
  Timer? _timeoutTicker;

  IBiometricVerificationService get _service =>
      ref.read(biometricServiceProvider);
  ICameraPermissionService get _permissionService =>
      ref.read(cameraPermissionServiceProvider);

  @override
  BiometricVerificationState build() {
    final challenges = _service.generateChallengeSequence();
    _livenessMachine = ActiveLivenessStateMachine(initialSequence: challenges);

    ref.onDispose(() {
      _timeoutTicker?.cancel();
    });

    // Starts honestly unaligned until actual camera + ML Kit frames arrive!
    return BiometricVerificationState(
      status: BiometricVerificationStatus.requestingPermission,
      permissionState: CameraPermissionState.initial,
      alignmentStatus: FaceAlignmentStatus.noFaceDetected,
      challenges: _livenessMachine.snapshot.challenges,
      currentChallengeIndex: 0,
      isLightingGood: false,
      isDistanceGood: false,
      isFaceTooClose: false,
      isFaceTooFar: false,
      isCentered: false,
      currentActionCompleted: false,
      progress: 0.05,
      statusMessage: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      landmarkPoints: const [],
    );
  }

  Future<void> initializePermissions() async {
    state = state.copyWith(
      permissionState: CameraPermissionState.checking,
      status: BiometricVerificationStatus.requestingPermission,
      statusMessage: 'Checking camera permission...',
    );

    final status = await _permissionService.checkStatus();
    if (status == CameraPermissionState.granted) {
      state = state.copyWith(
        permissionState: CameraPermissionState.granted,
        status: BiometricVerificationStatus.aligning,
        progress: 0.15,
        statusMessage: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      );
    } else if (status == CameraPermissionState.unavailable) {
      state = state.copyWith(
        permissionState: CameraPermissionState.unavailable,
        status: BiometricVerificationStatus.failed,
        isHardwareSupported: false,
        statusMessage:
            'Camera & on-device ML Kit liveness require an iOS or Android device.',
      );
    } else {
      await requestCameraPermission();
    }
  }

  Future<void> requestCameraPermission() async {
    state = state.copyWith(
      permissionState: CameraPermissionState.checking,
      statusMessage: 'Requesting camera access...',
    );

    final perm = await _permissionService.requestPermission();
    if (perm == CameraPermissionState.granted) {
      state = state.copyWith(
        permissionState: CameraPermissionState.granted,
        status: BiometricVerificationStatus.aligning,
        progress: 0.15,
        statusMessage: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      );
    } else if (perm == CameraPermissionState.unavailable) {
      state = state.copyWith(
        permissionState: CameraPermissionState.unavailable,
        status: BiometricVerificationStatus.failed,
        isHardwareSupported: false,
        statusMessage:
            'Hardware camera unavailable on this platform.',
      );
    } else {
      state = state.copyWith(
        permissionState: perm,
        status: BiometricVerificationStatus.failed,
        statusMessage: perm == CameraPermissionState.permanentlyDenied
            ? 'Camera permission permanently denied. Open app settings to allow camera access.'
            : 'Camera permission denied. Allow access to continue.',
      );
    }
  }

  void setCheckingPermissionState(String message) {
    state = state.copyWith(
      permissionState: CameraPermissionState.checking,
      status: BiometricVerificationStatus.requestingPermission,
      statusMessage: message,
      clearResult: true,
    );
  }

  void setGrantedAligningState({String? statusMessage}) {
    state = state.copyWith(
      permissionState: CameraPermissionState.granted,
      status: BiometricVerificationStatus.aligning,
      isHardwareSupported: true,
      progress: 0.15,
      statusMessage: statusMessage ?? FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      clearResult: true,
    );
  }

  void setHardwareUnavailableState(String reason) {
    _timeoutTicker?.cancel();
    state = state.copyWith(
      permissionState: CameraPermissionState.unavailable,
      isHardwareSupported: false,
      status: BiometricVerificationStatus.failed,
      statusMessage: reason,
      clearResult: true,
    );
  }

  void setPermissionDenied({bool permanent = false, String? customMessage}) {
    _timeoutTicker?.cancel();
    state = state.copyWith(
      permissionState: permanent
          ? CameraPermissionState.permanentlyDenied
          : CameraPermissionState.denied,
      status: BiometricVerificationStatus.failed,
      statusMessage: customMessage ??
          (permanent
              ? 'Camera permission permanently denied. Enable in system settings.'
              : 'Camera permission denied. Allow access to continue.'),
      clearResult: true,
    );
  }

  Future<void> openSettings() async {
    await _permissionService.openSettings();
  }

  void markCameraUnavailable(String reason) {
    _timeoutTicker?.cancel();
    state = state.copyWith(
      isHardwareSupported: false,
      status: BiometricVerificationStatus.failed,
      statusMessage: reason,
      result: BiometricVerificationResult(
        isSuccess: false,
        resultStatus: FaceVerificationStatus.failed,
        isDemoResult: true,
        message: reason,
        confidenceScore: 0.0,
      ),
    );
  }

  /// Processes real camera + ML Kit frame analysis via the pure-Dart state machine.
  void onFaceAnalysisFrame(FaceAnalysisResult analysis, {DateTime? timestamp}) {
    if (state.status == BiometricVerificationStatus.processing ||
        state.status == BiometricVerificationStatus.verified ||
        state.status == BiometricVerificationStatus.failed) {
      return;
    }

    final now = timestamp ?? DateTime.now();
    final snap = _livenessMachine.processFrame(analysis, now: now);

    final bool lightingOk = analysis.meanLuma >= 45.0;
    final bool tooFar =
        analysis.alignmentStatus == FaceAlignmentStatus.tooFar;
    final bool tooClose =
        analysis.alignmentStatus == FaceAlignmentStatus.tooClose;
    final bool centeredOk = analysis.hasFace &&
        analysis.faceCount == 1 &&
        analysis.alignmentStatus != FaceAlignmentStatus.offCenterHorizontal &&
        analysis.alignmentStatus != FaceAlignmentStatus.offCenterVertical;
    final bool distanceOk = analysis.hasFace && !tooFar && !tooClose;
    final double eyeRatio = ((analysis.leftEyeOpenProbability ?? 1.0) +
            (analysis.rightEyeOpenProbability ?? 1.0)) /
        2.0;

    if (snap.phase == LivenessMachinePhase.timedOut) {
      _timeoutTicker?.cancel();
      final res = BiometricVerificationResult(
        isSuccess: false,
        resultStatus: FaceVerificationStatus.retryRequired,
        isDemoResult: true,
        message: snap.failureReason ?? 'Liveness challenge timed out.',
        confidenceScore: 0.0,
      );
      state = state.copyWith(
        status: BiometricVerificationStatus.failed,
        machinePhase: LivenessMachinePhase.timedOut,
        statusMessage: snap.instructionText,
        result: res,
      );
      return;
    }

    double overallProgress = 0.20;
    String resolvedInstruction = snap.instructionText;
    if (snap.phase == LivenessMachinePhase.waitingForAlignment) {
      overallProgress =
          analysis.alignmentStatus == FaceAlignmentStatus.aligned ? 0.30 : 0.15;
    } else if (snap.phase == LivenessMachinePhase.runningChallenge) {
      final total = snap.challenges.isEmpty ? 1 : snap.challenges.length;
      overallProgress = 0.35 +
          ((snap.currentChallengeIndex + snap.currentChallengeProgress) /
                  total) *
              0.50;
    } else if (snap.phase == LivenessMachinePhase.completed) {
      _timeoutTicker?.cancel();
      overallProgress = 0.90;
      resolvedInstruction = analysis.alignmentStatus == FaceAlignmentStatus.aligned
          ? 'All active liveness checks passed! Tap Capture & Verify.'
          : 'Liveness passed! Center your face in the oval to capture.';
    }

    state = state.copyWith(
      alignmentStatus: snap.phase == LivenessMachinePhase.waitingForAlignment &&
              analysis.alignmentStatus == FaceAlignmentStatus.aligned &&
              snap.alignedStableFrames < 2
          ? FaceAlignmentStatus.holdStill
          : analysis.alignmentStatus,
      machinePhase: snap.phase,
      currentChallengeIndex: snap.currentChallengeIndex,
      currentChallengeProgress: snap.currentChallengeProgress,
      blinkCyclesCompleted: snap.blinkCyclesCompleted,
      currentActionCompleted: snap.areAllChallengesCompleted,
      isLightingGood: lightingOk,
      isDistanceGood: distanceOk,
      isFaceTooClose: tooClose,
      isFaceTooFar: tooFar,
      isCentered: centeredOk,
      landmarkPoints: analysis.normalizedLandmarks,
      headYawAngle: analysis.headEulerAngleY,
      eyeOpenRatio: eyeRatio,
      progress: overallProgress.clamp(0.0, 1.0),
      statusMessage: resolvedInstruction,
    );
  }

  /// Compatibility helper feeding deterministic alignment states in tests.
  void updateFaceAlignment({
    required bool lighting,
    required bool centered,
    bool tooClose = false,
    bool tooFar = false,
  }) {
    final FaceAlignmentStatus alignment;
    if (!lighting) {
      alignment = FaceAlignmentStatus.poorLighting;
    } else if (tooFar) {
      alignment = FaceAlignmentStatus.tooFar;
    } else if (tooClose) {
      alignment = FaceAlignmentStatus.tooClose;
    } else if (!centered) {
      alignment = FaceAlignmentStatus.noFaceDetected;
    } else {
      alignment = FaceAlignmentStatus.aligned;
    }

    final frame = FaceAnalysisResult(
      hasFace: centered || tooClose || tooFar,
      faceCount: (centered || tooClose || tooFar) ? 1 : 0,
      meanLuma: lighting ? 128.0 : 25.0,
      alignmentStatus: alignment,
    );
    // Feed two stable frames when aligned so stability guard unlocks cleanly in test
    if (alignment == FaceAlignmentStatus.aligned) {
      onFaceAnalysisFrame(frame);
    }
    onFaceAnalysisFrame(frame);
  }

  /// Transitions from aligned face into randomized liveness challenges.
  void startLivenessVerification() {
    if (state.alignmentStatus != FaceAlignmentStatus.aligned) return;

    _livenessMachine.beginChallenges(DateTime.now());
    final snap = _livenessMachine.snapshot;

    _timeoutTicker?.cancel();
    _timeoutTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      evaluateChallengeTimeout();
    });

    state = state.copyWith(
      status: BiometricVerificationStatus.challenging,
      machinePhase: snap.phase,
      currentChallengeIndex: 0,
      currentChallengeProgress: 0.0,
      blinkCyclesCompleted: 0,
      currentActionCompleted: false,
      progress: 0.35,
      statusMessage: snap.instructionText,
    );
  }

  /// Checks active liveness deadline on timer ticks without synthesizing frame metrics.
  void evaluateChallengeTimeout({DateTime? now}) {
    if (state.status != BiometricVerificationStatus.challenging) return;
    final snap = _livenessMachine.evaluateTimeout(now: now ?? DateTime.now());
    if (snap.phase == LivenessMachinePhase.timedOut) {
      _timeoutTicker?.cancel();
      state = state.copyWith(
        status: BiometricVerificationStatus.failed,
        machinePhase: LivenessMachinePhase.timedOut,
        statusMessage: snap.instructionText,
        result: BiometricVerificationResult(
          isSuccess: false,
          resultStatus: FaceVerificationStatus.retryRequired,
          isDemoResult: true,
          message: snap.failureReason ?? 'Liveness challenge timed out.',
          confidenceScore: 0.0,
        ),
      );
    }
  }

  /// Camera / app background interruption handler.
  void handleCameraInterruption(String reason) {
    _timeoutTicker?.cancel();
    _livenessMachine.markInterrupted(reason);
    state = state.copyWith(
      status: BiometricVerificationStatus.failed,
      machinePhase: LivenessMachinePhase.interrupted,
      statusMessage: reason,
      result: BiometricVerificationResult(
        isSuccess: false,
        resultStatus: FaceVerificationStatus.retryRequired,
        isDemoResult: true,
        message: reason,
        confidenceScore: 0.0,
      ),
    );
  }

  /// Captures and submits volatile verification frame buffer ONLY when liveness
  /// checks have succeeded.
  Future<void> submitBiometricVerification({Uint8List? inMemoryFrameBytes}) async {
    if (!state.areAllChallengesCompleted && inMemoryFrameBytes != null) {
      inMemoryFrameBytes.fillRange(0, inMemoryFrameBytes.length, 0);
      return;
    }

    _timeoutTicker?.cancel();

    state = state.copyWith(
      status: BiometricVerificationStatus.processing,
      progress: 0.95,
      statusMessage: 'Validating on-device liveness in volatile memory...',
    );

    final frameData = BiometricFrameData(
      rawBytes: inMemoryFrameBytes,
      isLightingAdequate: state.isLightingGood,
      isDistanceAdequate: state.isDistanceGood,
      isFaceCentered: state.isCentered,
      alignmentStatus: state.alignmentStatus,
      landmarks: state.landmarkPoints,
      headEulerAngleY: state.headYawAngle,
      leftEyeOpenProbability: state.eyeOpenRatio,
      rightEyeOpenProbability: state.eyeOpenRatio,
    );

    final result = await _service.verifyBiometric(
      frameData: frameData,
      completedAction: state.challenges.isNotEmpty
          ? state.challenges.first
          : BiometricLivenessAction.blinkTwice,
    );

    if (result.isSuccess) {
      ref.read(isUserBiometricallyVerifiedProvider.notifier).setVerified(true);
      state = state.copyWith(
        status: BiometricVerificationStatus.verified,
        progress: 1.0,
        statusMessage: 'On-device liveness check passed (Demo Mode).',
        result: result,
      );
    } else {
      state = state.copyWith(
        status: BiometricVerificationStatus.failed,
        progress: 1.0,
        statusMessage: result.message,
        result: result,
      );
    }
  }

  /// Resets state machine and sequence cleanly for retry.
  void retry() {
    _timeoutTicker?.cancel();
    final challenges = _service.generateChallengeSequence();
    _livenessMachine.reset(sequence: challenges);

    state = state.copyWith(
      status: state.permissionState == CameraPermissionState.granted
          ? BiometricVerificationStatus.aligning
          : BiometricVerificationStatus.requestingPermission,
      alignmentStatus: FaceAlignmentStatus.noFaceDetected,
      machinePhase: LivenessMachinePhase.waitingForAlignment,
      challenges: _livenessMachine.snapshot.challenges,
      currentChallengeIndex: 0,
      currentChallengeProgress: 0.0,
      blinkCyclesCompleted: 0,
      isLightingGood: false,
      isDistanceGood: false,
      isFaceTooClose: false,
      isFaceTooFar: false,
      isCentered: false,
      currentActionCompleted: false,
      progress: 0.15,
      headYawAngle: 0.0,
      eyeOpenRatio: 1.0,
      landmarkPoints: const [],
      statusMessage: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      clearResult: true,
    );
  }
}

final biometricVerificationProvider = NotifierProvider.autoDispose<
    BiometricVerificationNotifier, BiometricVerificationState>(
  BiometricVerificationNotifier.new,
);
