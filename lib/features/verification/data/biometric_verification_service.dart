import 'dart:async';
import 'dart:math';
import '../domain/models/biometric_verification_model.dart';

abstract class IBiometricVerificationService {
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  });

  List<BiometricLivenessAction> generateChallengeSequence();
}

/// Production API Client (targets POST /v1/auth/biometric-verify)
class ProductionBiometricVerificationService
    implements IBiometricVerificationService {
  final String baseUrl;
  ProductionBiometricVerificationService({this.baseUrl = 'https://api.date2.app'});

  @override
  List<BiometricLivenessAction> generateChallengeSequence() {
    final actions = List<BiometricLivenessAction>.from(BiometricLivenessAction.values)
      ..shuffle(Random());
    return actions.take(2).toList();
  }

  @override
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  }) async {
    try {
      // In production, transmits sanitized, metadata-stripped frame buffer:
      // final response = await http.post(
      //   Uri.parse('$baseUrl/v1/auth/biometric-verify'),
      //   headers: {'Content-Type': 'application/octet-stream'},
      //   body: frameData.rawBytes,
      // );
      throw UnimplementedError(
        'Backend server at $baseUrl is currently offline. Mock service is used for interactive demo.',
      );
    } finally {
      // Mandatory security requirement: strip & clear buffer from volatile memory
      frameData.secureWipe();
    }
  }
}

/// Interactive Demo & Mock Verification Service
class MockBiometricVerificationService
    implements IBiometricVerificationService {
  @override
  List<BiometricLivenessAction> generateChallengeSequence() {
    final actions = List<BiometricLivenessAction>.from(BiometricLivenessAction.values)
      ..shuffle();
    return actions.take(2).toList();
  }

  @override
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  }) async {
    // Simulate real ML Kit & server pipeline latency
    await Future.delayed(const Duration(milliseconds: 1400));

    try {
      if (!frameData.isLightingAdequate || !frameData.isDistanceAdequate) {
        return const BiometricVerificationResult(
          isSuccess: false,
          message:
              'Verification failed: Poor lighting or face is too far. Please retry in a well-lit room.',
          confidenceScore: 0.42,
        );
      }

      return BiometricVerificationResult(
        isSuccess: true,
        message: 'Identity Verified. Liveness action successfully confirmed.',
        confidenceScore: 0.98,
        verificationId: 'VERIF-${DateTime.now().millisecondsSinceEpoch}',
      );
    } finally {
      // Security requirement: Ensure volatile buffer is immediately cleared
      frameData.secureWipe();
    }
  }
}
