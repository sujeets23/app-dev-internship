import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/biometric_verification_service.dart';
import '../../domain/models/biometric_verification_model.dart';

class BiometricVerificationState {
  final BiometricVerificationStatus status;
  final CameraPermissionState permissionState;
  final FaceAlignmentStatus alignmentStatus;
  final List<BiometricLivenessAction> challenges;
  final int currentChallengeIndex;
  final bool isLightingGood;
  final bool isDistanceGood;
  final bool isFaceTooClose;
  final bool isFaceTooFar;
  final bool isCentered;
  final bool currentActionCompleted;
  final double progress;
  final String statusMessage;
  final BiometricVerificationResult? result;
  final List<FaceLandmarkPoint> landmarkPoints;
  final double headYawAngle; // in degrees (-15° to +15°)
  final double eyeOpenRatio; // 0.0 (closed) to 1.0 (open)

  const BiometricVerificationState({
    required this.status,
    required this.permissionState,
    required this.alignmentStatus,
    required this.challenges,
    required this.currentChallengeIndex,
    required this.isLightingGood,
    required this.isDistanceGood,
    required this.isFaceTooClose,
    required this.isFaceTooFar,
    required this.isCentered,
    required this.currentActionCompleted,
    required this.progress,
    required this.statusMessage,
    this.result,
    required this.landmarkPoints,
    this.headYawAngle = 0.0,
    this.eyeOpenRatio = 1.0,
  });

  BiometricLivenessAction? get currentChallenge {
    if (currentChallengeIndex < challenges.length) {
      return challenges[currentChallengeIndex];
    }
    return null;
  }

  bool get areAllChallengesCompleted =>
      currentChallengeIndex >= challenges.length;

  bool get isReadyToCapture =>
      alignmentStatus == FaceAlignmentStatus.aligned &&
      permissionState == CameraPermissionState.granted &&
      areAllChallengesCompleted &&
      status == BiometricVerificationStatus.challenging;

  BiometricVerificationState copyWith({
    BiometricVerificationStatus? status,
    CameraPermissionState? permissionState,
    FaceAlignmentStatus? alignmentStatus,
    List<BiometricLivenessAction>? challenges,
    int? currentChallengeIndex,
    bool? isLightingGood,
    bool? isDistanceGood,
    bool? isFaceTooClose,
    bool? isFaceTooFar,
    bool? isCentered,
    bool? currentActionCompleted,
    double? progress,
    String? statusMessage,
    BiometricVerificationResult? result,
    List<FaceLandmarkPoint>? landmarkPoints,
    double? headYawAngle,
    double? eyeOpenRatio,
  }) {
    return BiometricVerificationState(
      status: status ?? this.status,
      permissionState: permissionState ?? this.permissionState,
      alignmentStatus: alignmentStatus ?? this.alignmentStatus,
      challenges: challenges ?? this.challenges,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      isLightingGood: isLightingGood ?? this.isLightingGood,
      isDistanceGood: isDistanceGood ?? this.isDistanceGood,
      isFaceTooClose: isFaceTooClose ?? this.isFaceTooClose,
      isFaceTooFar: isFaceTooFar ?? this.isFaceTooFar,
      isCentered: isCentered ?? this.isCentered,
      currentActionCompleted:
          currentActionCompleted ?? this.currentActionCompleted,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      result: result ?? this.result,
      landmarkPoints: landmarkPoints ?? this.landmarkPoints,
      headYawAngle: headYawAngle ?? this.headYawAngle,
      eyeOpenRatio: eyeOpenRatio ?? this.eyeOpenRatio,
    );
  }
}

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
  Timer? _livenessTimer;
  IBiometricVerificationService get _service =>
      ref.read(biometricServiceProvider);

  @override
  BiometricVerificationState build() {
    ref.onDispose(() {
      _livenessTimer?.cancel();
    });

    final challenges = _service.generateChallengeSequence();

    return BiometricVerificationState(
      status: BiometricVerificationStatus.aligning,
      permissionState: CameraPermissionState.granted,
      alignmentStatus: FaceAlignmentStatus.aligned,
      challenges: challenges,
      currentChallengeIndex: 0,
      isLightingGood: true,
      isDistanceGood: true,
      isFaceTooClose: false,
      isFaceTooFar: false,
      isCentered: true,
      currentActionCompleted: false,
      progress: 0.20,
      statusMessage: 'Position your face inside the oval',
      landmarkPoints: _generateLandmarks(0.0),
    );
  }

  static List<FaceLandmarkPoint> _generateLandmarks(double yaw) {
    final shift = (yaw / 30.0) * 0.08;
    return [
      FaceLandmarkPoint(0.35 + shift, 0.38, 'left_eye'),
      FaceLandmarkPoint(0.65 + shift, 0.38, 'right_eye'),
      FaceLandmarkPoint(0.50 + shift, 0.52, 'nose_tip'),
      FaceLandmarkPoint(0.38 + shift, 0.68, 'mouth_left'),
      FaceLandmarkPoint(0.62 + shift, 0.68, 'mouth_right'),
      FaceLandmarkPoint(0.50 + shift, 0.73, 'chin'),
    ];
  }

  /// Request camera permission explicitly
  Future<void> requestCameraPermission() async {
    state = state.copyWith(
      permissionState: CameraPermissionState.checking,
      statusMessage: 'Requesting camera access...',
    );
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      permissionState: CameraPermissionState.granted,
      status: BiometricVerificationStatus.aligning,
      statusMessage: 'Position your face inside the oval',
    );
  }

  /// Deny permission for testing error flows
  void setPermissionDenied() {
    state = state.copyWith(
      permissionState: CameraPermissionState.denied,
      status: BiometricVerificationStatus.failed,
      statusMessage: 'Camera permission denied. Please allow access in settings.',
    );
  }

  /// Update face alignment state based on sensor / landmark analysis
  void updateFaceAlignment({
    required bool lighting,
    required bool centered,
    bool tooClose = false,
    bool tooFar = false,
  }) {
    FaceAlignmentStatus status;
    String message;

    if (!lighting) {
      status = FaceAlignmentStatus.poorLighting;
      message = 'Improve lighting';
    } else if (tooFar) {
      status = FaceAlignmentStatus.tooFar;
      message = 'Move closer';
    } else if (tooClose) {
      status = FaceAlignmentStatus.tooClose;
      message = 'Move slightly back';
    } else if (!centered) {
      status = FaceAlignmentStatus.noFaceDetected;
      message = 'Position your face inside the oval';
    } else {
      status = FaceAlignmentStatus.aligned;
      message = state.status == BiometricVerificationStatus.challenging &&
              state.currentChallenge != null
          ? state.currentChallenge!.instruction
          : 'Face detected & aligned';
    }

    state = state.copyWith(
      isLightingGood: lighting,
      isCentered: centered,
      isFaceTooClose: tooClose,
      isFaceTooFar: tooFar,
      isDistanceGood: !tooClose && !tooFar,
      alignmentStatus: status,
      statusMessage: message,
    );
  }

  /// Start the randomized active liveness challenge step
  void startLivenessVerification() {
    if (state.alignmentStatus != FaceAlignmentStatus.aligned) return;

    state = state.copyWith(
      status: BiometricVerificationStatus.challenging,
      currentChallengeIndex: 0,
      currentActionCompleted: false,
      progress: 0.35,
      statusMessage: state.challenges.isNotEmpty
          ? state.challenges.first.instruction
          : 'Blink your eyes twice',
    );

    _runChallengeStep();
  }

  void _runChallengeStep() {
    _livenessTimer?.cancel();
    final action = state.currentChallenge;
    if (action == null) return;

    // Simulate real-time on-device landmark detection loop
    _livenessTimer = Timer(const Duration(milliseconds: 2200), () {
      completeCurrentAction();
    });
  }

  /// Mark the current active liveness action as successfully detected
  void completeCurrentAction() {
    if (state.status != BiometricVerificationStatus.challenging) return;
    final currentIdx = state.currentChallengeIndex;
    final totalChallenges = state.challenges.length;

    // Simulate head / eye movement for detected action
    final currentAction = state.challenges[currentIdx];
    double targetYaw = 0.0;
    double targetEye = 1.0;

    if (currentAction == BiometricLivenessAction.turnLeft) {
      targetYaw = -15.0;
    } else if (currentAction == BiometricLivenessAction.turnRight) {
      targetYaw = 15.0;
    } else if (currentAction == BiometricLivenessAction.blinkTwice) {
      targetEye = 0.1;
    }

    state = state.copyWith(
      currentActionCompleted: true,
      headYawAngle: targetYaw,
      eyeOpenRatio: targetEye,
      landmarkPoints: _generateLandmarks(targetYaw),
      statusMessage: 'Action confirmed! ✓',
    );

    Timer(const Duration(milliseconds: 600), () {
      final nextIdx = currentIdx + 1;
      final newProgress = 0.35 + ((nextIdx / totalChallenges) * 0.50);

      if (nextIdx < totalChallenges) {
        state = state.copyWith(
          currentChallengeIndex: nextIdx,
          currentActionCompleted: false,
          progress: newProgress,
          headYawAngle: 0.0,
          eyeOpenRatio: 1.0,
          landmarkPoints: _generateLandmarks(0.0),
          statusMessage: state.challenges[nextIdx].instruction,
        );
        _runChallengeStep();
      } else {
        // All challenges successfully satisfied
        state = state.copyWith(
          currentChallengeIndex: totalChallenges,
          currentActionCompleted: true,
          progress: 0.88,
          headYawAngle: 0.0,
          eyeOpenRatio: 1.0,
          landmarkPoints: _generateLandmarks(0.0),
          statusMessage: 'All liveness checks passed. Ready to capture.',
        );
        // Automatically submit cryptographic verification
        submitBiometricVerification();
      }
    });
  }

  /// Submit verification payload targeting POST /v1/auth/biometric-verify
  Future<void> submitBiometricVerification() async {
    _livenessTimer?.cancel();

    state = state.copyWith(
      status: BiometricVerificationStatus.processing,
      progress: 0.95,
      statusMessage: 'Cryptographically validating biometric proof...',
    );

    final frameData = BiometricFrameData(
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
        statusMessage: 'Identity verified successfully!',
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

  /// Retry verification with fresh randomized sequence
  void retry() {
    _livenessTimer?.cancel();
    final challenges = _service.generateChallengeSequence();
    state = state.copyWith(
      status: BiometricVerificationStatus.aligning,
      permissionState: CameraPermissionState.granted,
      alignmentStatus: FaceAlignmentStatus.aligned,
      challenges: challenges,
      currentChallengeIndex: 0,
      currentActionCompleted: false,
      progress: 0.20,
      headYawAngle: 0.0,
      eyeOpenRatio: 1.0,
      landmarkPoints: _generateLandmarks(0.0),
      statusMessage: 'Position your face inside the oval',
      result: null,
    );
  }
}

final biometricVerificationProvider = NotifierProvider.autoDispose<
    BiometricVerificationNotifier, BiometricVerificationState>(
  BiometricVerificationNotifier.new,
);
