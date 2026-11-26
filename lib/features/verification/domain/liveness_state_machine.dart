import 'dart:math';
import '../domain/models/biometric_verification_model.dart';
import '../data/face_liveness_detector.dart';

enum LivenessMachinePhase {
  waitingForAlignment,
  runningChallenge,
  completed,
  timedOut,
  interrupted,
  failed,
}

class LivenessMachineSnapshot {
  final LivenessMachinePhase phase;
  final List<BiometricLivenessAction> challenges;
  final int currentChallengeIndex;
  final double currentChallengeProgress; // 0.0 to 1.0
  final int blinkCyclesCompleted;
  final int alignedStableFrames;
  final String instructionText;
  final String? failureReason;

  const LivenessMachineSnapshot({
    required this.phase,
    required this.challenges,
    required this.currentChallengeIndex,
    required this.currentChallengeProgress,
    required this.blinkCyclesCompleted,
    required this.alignedStableFrames,
    required this.instructionText,
    this.failureReason,
  });

  BiometricLivenessAction? get currentChallenge {
    if (currentChallengeIndex < challenges.length) {
      return challenges[currentChallengeIndex];
    }
    return null;
  }

  bool get areAllChallengesCompleted =>
      phase == LivenessMachinePhase.completed ||
      currentChallengeIndex >= challenges.length;

  LivenessMachineSnapshot copyWith({
    LivenessMachinePhase? phase,
    List<BiometricLivenessAction>? challenges,
    int? currentChallengeIndex,
    double? currentChallengeProgress,
    int? blinkCyclesCompleted,
    int? alignedStableFrames,
    String? instructionText,
    String? failureReason,
    bool clearFailure = false,
  }) {
    return LivenessMachineSnapshot(
      phase: phase ?? this.phase,
      challenges: challenges ?? this.challenges,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      currentChallengeProgress:
          currentChallengeProgress ?? this.currentChallengeProgress,
      blinkCyclesCompleted: blinkCyclesCompleted ?? this.blinkCyclesCompleted,
      alignedStableFrames: alignedStableFrames ?? this.alignedStableFrames,
      instructionText: instructionText ?? this.instructionText,
      failureReason:
          clearFailure ? null : (failureReason ?? this.failureReason),
    );
  }
}

/// Pure-Dart Active Liveness State Machine strictly decoupled from Flutter UI.
/// Tracks real blink cycles and ~15° head yaw turns with timeout and
/// interruption recovery.
class ActiveLivenessStateMachine {
  final Duration challengeTimeout;
  final bool invertYawAxisForFrontMirror;

  late LivenessMachineSnapshot _snapshot;
  DateTime? _challengeStartedAt;
  bool _sawEyesClosedInCycle = false;
  int _alignedHoldFrames = 0;

  ActiveLivenessStateMachine({
    List<BiometricLivenessAction>? initialSequence,
    this.challengeTimeout = const Duration(seconds: 20),
    this.invertYawAxisForFrontMirror = false,
  }) {
    final sequence = initialSequence ?? _generateRandomizedSequence();
    _snapshot = LivenessMachineSnapshot(
      phase: LivenessMachinePhase.waitingForAlignment,
      challenges: sequence,
      currentChallengeIndex: 0,
      currentChallengeProgress: 0.0,
      blinkCyclesCompleted: 0,
      alignedStableFrames: 0,
      instructionText: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
    );
  }

  LivenessMachineSnapshot get snapshot => _snapshot;

  static List<BiometricLivenessAction> _generateRandomizedSequence([
    Random? random,
  ]) {
    final list = List<BiometricLivenessAction>.from(
      BiometricLivenessAction.values,
    );
    list.shuffle(random ?? Random());
    return list;
  }

  void reset({List<BiometricLivenessAction>? sequence}) {
    _challengeStartedAt = null;
    _sawEyesClosedInCycle = false;
    _alignedHoldFrames = 0;
    final nextSeq = sequence ?? _generateRandomizedSequence();
    _snapshot = LivenessMachineSnapshot(
      phase: LivenessMachinePhase.waitingForAlignment,
      challenges: nextSeq,
      currentChallengeIndex: 0,
      currentChallengeProgress: 0.0,
      blinkCyclesCompleted: 0,
      alignedStableFrames: 0,
      instructionText: FaceAlignmentStatus.noFaceDetected.guidanceMessage,
    );
  }

  void markInterrupted(String reason) {
    _challengeStartedAt = null;
    _snapshot = _snapshot.copyWith(
      phase: LivenessMachinePhase.interrupted,
      instructionText: reason,
      failureReason: reason,
    );
  }

  void beginChallenges(DateTime now) {
    if (_alignedHoldFrames < 2) {
      return;
    }
    _challengeStartedAt = now;
    _sawEyesClosedInCycle = false;
    _snapshot = _snapshot.copyWith(
      phase: LivenessMachinePhase.runningChallenge,
      currentChallengeIndex: 0,
      currentChallengeProgress: 0.0,
      blinkCyclesCompleted: 0,
      instructionText: _snapshot.challenges.first.instruction,
      clearFailure: true,
    );
  }

  /// Processes a real frame analysis result at [now].
  LivenessMachineSnapshot processFrame(
    FaceAnalysisResult analysis, {
    required DateTime now,
  }) {
    if (_snapshot.phase == LivenessMachinePhase.completed ||
        _snapshot.phase == LivenessMachinePhase.timedOut ||
        _snapshot.phase == LivenessMachinePhase.failed ||
        _snapshot.phase == LivenessMachinePhase.interrupted) {
      return _snapshot;
    }

    if (_snapshot.phase == LivenessMachinePhase.waitingForAlignment) {
      if (analysis.alignmentStatus == FaceAlignmentStatus.aligned) {
        _alignedHoldFrames++;
        final msg = _alignedHoldFrames < 2
            ? FaceAlignmentStatus.holdStill.guidanceMessage
            : FaceAlignmentStatus.aligned.guidanceMessage;
        _snapshot = _snapshot.copyWith(
          alignedStableFrames: _alignedHoldFrames,
          instructionText: msg,
        );
      } else {
        _alignedHoldFrames = 0;
        _snapshot = _snapshot.copyWith(
          alignedStableFrames: 0,
          instructionText: analysis.alignmentStatus.guidanceMessage,
        );
      }
      return _snapshot;
    }

    // Running challenge phase
    if (!analysis.hasFace || analysis.faceCount > 1) {
      _snapshot = _snapshot.copyWith(
        instructionText: analysis.faceCount > 1
            ? FaceAlignmentStatus.multipleFaces.guidanceMessage
            : FaceAlignmentStatus.noFaceDetected.guidanceMessage,
      );
      return _checkTimeout(now);
    }

    if (analysis.meanLuma < 40.0) {
      _snapshot = _snapshot.copyWith(
        instructionText: FaceAlignmentStatus.poorLighting.guidanceMessage,
      );
      return _checkTimeout(now);
    }

    final challenge = _snapshot.currentChallenge;
    if (challenge == null) {
      _snapshot = _snapshot.copyWith(
        phase: LivenessMachinePhase.completed,
        currentChallengeProgress: 1.0,
        instructionText: 'All liveness checks completed.',
      );
      return _snapshot;
    }

    final timeoutSnapshot = _checkTimeout(now);
    if (timeoutSnapshot.phase == LivenessMachinePhase.timedOut) {
      return timeoutSnapshot;
    }

    switch (challenge) {
      case BiometricLivenessAction.blinkTwice:
        _handleBlinkFrame(analysis, now);
        break;
      case BiometricLivenessAction.turnLeft:
        _handleHeadTurnFrame(analysis, turnLeft: true, now: now);
        break;
      case BiometricLivenessAction.turnRight:
        _handleHeadTurnFrame(analysis, turnLeft: false, now: now);
        break;
    }

    return _snapshot;
  }

  /// Evaluates timeout purely by wall clock without feeding synthetic eye/yaw readings.
  LivenessMachineSnapshot evaluateTimeout({required DateTime now}) {
    if (_snapshot.phase != LivenessMachinePhase.runningChallenge) {
      return _snapshot;
    }
    return _checkTimeout(now);
  }

  LivenessMachineSnapshot _checkTimeout(DateTime now) {
    if (_challengeStartedAt != null &&
        now.difference(_challengeStartedAt!) > challengeTimeout) {
      _snapshot = _snapshot.copyWith(
        phase: LivenessMachinePhase.timedOut,
        instructionText: 'Challenge timed out. Please retry in good lighting.',
        failureReason: 'Liveness prompt timed out before completion.',
      );
    }
    return _snapshot;
  }

  void _handleBlinkFrame(FaceAnalysisResult analysis, DateTime now) {
    final left = analysis.leftEyeOpenProbability;
    final right = analysis.rightEyeOpenProbability;

    if (left == null || right == null) {
      _snapshot = _snapshot.copyWith(
        instructionText: 'Keep both eyes clearly visible and blink twice',
      );
      return;
    }

    final avgOpen = (left + right) / 2.0;

    if (!_sawEyesClosedInCycle && avgOpen <= 0.30) {
      _sawEyesClosedInCycle = true;
    } else if (_sawEyesClosedInCycle && avgOpen >= 0.60) {
      _sawEyesClosedInCycle = false;
      final completedBlinks = _snapshot.blinkCyclesCompleted + 1;
      if (completedBlinks >= 2) {
        _advanceToNextChallenge(now);
      } else {
        _snapshot = _snapshot.copyWith(
          blinkCyclesCompleted: completedBlinks,
          currentChallengeProgress: 0.5,
          instructionText: 'Great! Blink once more ($completedBlinks/2)',
        );
      }
    }
  }

  void _handleHeadTurnFrame(
    FaceAnalysisResult analysis, {
    required bool turnLeft,
    required DateTime now,
  }) {
    final rawYaw = analysis.headEulerAngleY;
    final yaw = invertYawAxisForFrontMirror ? -rawYaw : rawYaw;

    // On ML Kit Android/iOS, rotating ~15° reaches magnitude >= 12.0° reliably.
    const double thresholdDeg = 12.0;

    if (turnLeft) {
      // Positive yaw in ML Kit unmirrored sensor space corresponds to subject
      // turning to their own left (camera's right). Let's accept directional
      // movement >= +12.0 (or inverted -12.0 when invertYawAxisForFrontMirror is true).
      final progress = (yaw / 15.0).clamp(0.0, 1.0);
      if (yaw >= thresholdDeg) {
        _advanceToNextChallenge(now);
      } else {
        _snapshot = _snapshot.copyWith(
          currentChallengeProgress: progress,
          instructionText:
              '${BiometricLivenessAction.turnLeft.instruction} (${yaw.toStringAsFixed(0)}°)',
        );
      }
    } else {
      final progress = ((-yaw) / 15.0).clamp(0.0, 1.0);
      if (yaw <= -thresholdDeg) {
        _advanceToNextChallenge(now);
      } else {
        _snapshot = _snapshot.copyWith(
          currentChallengeProgress: progress,
          instructionText:
              '${BiometricLivenessAction.turnRight.instruction} (${(-yaw).toStringAsFixed(0)}°)',
        );
      }
    }
  }

  void _advanceToNextChallenge(DateTime now) {
    final nextIdx = _snapshot.currentChallengeIndex + 1;
    _sawEyesClosedInCycle = false;

    if (nextIdx >= _snapshot.challenges.length) {
      _challengeStartedAt = null;
      _snapshot = _snapshot.copyWith(
        phase: LivenessMachinePhase.completed,
        currentChallengeIndex: nextIdx,
        currentChallengeProgress: 1.0,
        instructionText: 'All active liveness checks passed!',
      );
    } else {
      _challengeStartedAt = now;
      _snapshot = _snapshot.copyWith(
        phase: LivenessMachinePhase.runningChallenge,
        currentChallengeIndex: nextIdx,
        currentChallengeProgress: 0.0,
        blinkCyclesCompleted: 0,
        instructionText: _snapshot.challenges[nextIdx].instruction,
      );
    }
  }
}
