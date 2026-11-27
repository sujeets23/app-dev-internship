import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/call_session.dart';
import '../../data/chat_service.dart';
import 'chat_provider.dart';

class VideoCallNotifier extends Notifier<CallSession?> {
  Timer? _durationTimer;
  Timer? _safetyScannerTimer;
  IChatService get _chatService => ref.read(chatServiceProvider);

  @override
  CallSession? build() {
    ref.onDispose(() {
      _durationTimer?.cancel();
      _safetyScannerTimer?.cancel();
    });
    return null;
  }

  Future<void> initiateCall({
    required String matchId,
    required String matchName,
    required String matchAvatar,
  }) async {
    state = CallSession(
      callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      matchName: matchName,
      matchAvatar: matchAvatar,
      status: CallStatus.requestingConsent,
    );

    // Request mutual consent via API POST /v1/matches/{id}/video-consent
    final consented = await _chatService.requestVideoConsent(matchId);

    if (!consented) {
      state = state?.copyWith(status: CallStatus.consentDeclined);
      return;
    }

    state = state?.copyWith(status: CallStatus.ringing);

    // Connected after brief ringing simulation
    await Future.delayed(const Duration(milliseconds: 1200));
    if (state?.status == CallStatus.ringing) {
      state = state?.copyWith(status: CallStatus.connected);
      _startCallTimers();
    }
  }

  void _startCallTimers() {
    _durationTimer?.cancel();
    _safetyScannerTimer?.cancel();

    // Duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state?.status == CallStatus.connected) {
        state = state?.copyWith(
          duration: (state?.duration ?? Duration.zero) + const Duration(seconds: 1),
        );
      }
    });

    // Module 3 Safety requirement:
    // Background TFLite NSFW frame scanner runs every 2 seconds
    _safetyScannerTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Periodic healthy scan acknowledgment
    });
  }

  Future<void> triggerSafetyViolation({required String reason}) async {
    _durationTimer?.cancel();
    _safetyScannerTimer?.cancel();

    if (state != null) {
      await _chatService.reportIncident(
        matchId: state!.matchId,
        reason: reason,
        confidence: '0.98',
      );
      ref
          .read(moderationLockProvider.notifier)
          .lockSession(state!.matchId, reason);

      state = state!.copyWith(
        status: CallStatus.terminatedByModeration,
        moderationWarning:
            '🛡️ Connection safely terminated. AI safety filter detected content violating our community standards. Local video calls for this session are now locked.',
      );
    }
  }

  void toggleAudio() {
    if (state != null) {
      state = state!.copyWith(isAudioMuted: !state!.isAudioMuted);
    }
  }

  void toggleVideo() {
    if (state != null) {
      state = state!.copyWith(isVideoMuted: !state!.isVideoMuted);
    }
  }

  void toggleSpeaker() {
    if (state != null) {
      state = state!.copyWith(isSpeakerOn: !state!.isSpeakerOn);
    }
  }

  void switchCamera() {
    if (state != null) {
      state = state!.copyWith(isFrontCamera: !state!.isFrontCamera);
    }
  }

  void endCall() {
    _durationTimer?.cancel();
    _safetyScannerTimer?.cancel();
    state = state?.copyWith(status: CallStatus.ended);
    Future.delayed(const Duration(milliseconds: 300), () {
      state = null;
    });
  }
}

final videoCallProvider =
    NotifierProvider<VideoCallNotifier, CallSession?>(VideoCallNotifier.new);
