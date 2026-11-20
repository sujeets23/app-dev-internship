import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/biometric_verification_service.dart';
import '../../domain/models/biometric_verification_model.dart';

class BiometricVerificationState {
  final BiometricVerificationStatus status;
  final List<BiometricLivenessAction> challenges;
  final int currentChallengeIndex;
  final bool isLightingGood;
  final bool isDistanceGood;
  final bool isCentered;
  final double progress;
  final String statusMessage;
  final BiometricVerificationResult? result;
  final List<FaceLandmarkPoint> landmarkPoints;

  const BiometricVerificationState({
    required this.status,
    required this.challenges,
    required this.currentChallengeIndex,
    required this.isLightingGood,
    required this.isDistanceGood,
    required this.isCentered,
    required this.progress,
    required this.statusMessage,
    this.result,
    required this.landmarkPoints,
  });

  BiometricLivenessAction? get currentChallenge {
    if (currentChallengeIndex < challenges.length) {
      return challenges[currentChallengeIndex];
    }
    return null;
  }

  bool get isReadyToCapture =>
      isLightingGood && isDistanceGood && isCentered && status == BiometricVerificationStatus.scanning;

  BiometricVerificationState copyWith({
    BiometricVerificationStatus? status,
    List<BiometricLivenessAction>? challenges,
    int? currentChallengeIndex,
    bool? isLightingGood,
    bool? isDistanceGood,
    bool? isCentered,
    double? progress,
    String? statusMessage,
    BiometricVerificationResult? result,
    List<FaceLandmarkPoint>? landmarkPoints,
  }) {
    return BiometricVerificationState(
      status: status ?? this.status,
      challenges: challenges ?? this.challenges,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      isLightingGood: isLightingGood ?? this.isLightingGood,
      isDistanceGood: isDistanceGood ?? this.isDistanceGood,
      isCentered: isCentered ?? this.isCentered,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      result: result ?? this.result,
      landmarkPoints: landmarkPoints ?? this.landmarkPoints,
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
    NotifierProvider<BiometricVerifiedNotifier, bool>(BiometricVerifiedNotifier.new);

final isProfileVerifiedProvider = isUserBiometricallyVerifiedProvider;

class BiometricVerificationNotifier
    extends Notifier<BiometricVerificationState> {
  Timer? _livenessTimer;
  IBiometricVerificationService get _service => ref.read(biometricServiceProvider);

  @override
  BiometricVerificationState build() {
    ref.onDispose(() {
      _livenessTimer?.cancel();
    });

    final challenges = _service.generateChallengeSequence();

    Future.microtask(() {
      _startLivenessLoop();
    });

    return BiometricVerificationState(
      status: BiometricVerificationStatus.scanning,
      challenges: challenges,
      currentChallengeIndex: 0,
      isLightingGood: true,
      isDistanceGood: true,
      isCentered: true,
      progress: 0.15,
      statusMessage: challenges.isNotEmpty
          ? challenges[0].instruction
          : 'Center your face in the oval',
      landmarkPoints: _generateSimulatedLandmarks(),
    );
  }

  static List<FaceLandmarkPoint> _generateSimulatedLandmarks() {
    return const [
      FaceLandmarkPoint(0.35, 0.38),
      FaceLandmarkPoint(0.65, 0.38),
      FaceLandmarkPoint(0.50, 0.52),
      FaceLandmarkPoint(0.38, 0.68),
      FaceLandmarkPoint(0.62, 0.68),
      FaceLandmarkPoint(0.50, 0.72),
    ];
  }

  void _startLivenessLoop() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (state.status != BiometricVerificationStatus.scanning) return;

      if (state.currentChallengeIndex + 1 < state.challenges.length) {
        state = state.copyWith(
          currentChallengeIndex: state.currentChallengeIndex + 1,
          progress: 0.60,
          statusMessage: state.challenges[state.currentChallengeIndex + 1].instruction,
        );
      } else {
        timer.cancel();
        submitBiometricVerification();
      }
    });
  }

  Future<void> submitBiometricVerification() async {
    _livenessTimer?.cancel();
    state = state.copyWith(
      status: BiometricVerificationStatus.processing,
      progress: 0.90,
      statusMessage: 'Cryptographically validating biometric proof...',
    );

    final frameData = BiometricFrameData(
      isLightingAdequate: state.isLightingGood,
      isDistanceAdequate: state.isDistanceGood,
      isFaceCentered: state.isCentered,
      landmarks: state.landmarkPoints,
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

  void toggleLighting(bool isGood) {
    state = state.copyWith(isLightingGood: isGood);
  }

  void toggleDistance(bool isGood) {
    state = state.copyWith(isDistanceGood: isGood);
  }

  void retry() {
    _livenessTimer?.cancel();
    final challenges = _service.generateChallengeSequence();
    state = state.copyWith(
      status: BiometricVerificationStatus.scanning,
      challenges: challenges,
      currentChallengeIndex: 0,
      progress: 0.15,
      statusMessage: challenges.isNotEmpty ? challenges[0].instruction : 'Center your face',
    );
    _startLivenessLoop();
  }
}

final biometricVerificationProvider =
    NotifierProvider.autoDispose<BiometricVerificationNotifier, BiometricVerificationState>(
  BiometricVerificationNotifier.new,
);
