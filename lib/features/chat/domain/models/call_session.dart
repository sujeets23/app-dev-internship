enum CallStatus {
  idle,
  requestingConsent,
  consentDeclined,
  ringing,
  connected,
  ended,
  terminatedByModeration,
}

class CallSession {
  final String callId;
  final String matchId;
  final String matchName;
  final String matchAvatar;
  final CallStatus status;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final bool isFrontCamera;
  final Duration duration;
  final String? moderationWarning;

  const CallSession({
    required this.callId,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
    this.status = CallStatus.idle,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.isFrontCamera = true,
    this.duration = Duration.zero,
    this.moderationWarning,
  });

  CallSession copyWith({
    String? callId,
    String? matchId,
    String? matchName,
    String? matchAvatar,
    CallStatus? status,
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isFrontCamera,
    Duration? duration,
    String? moderationWarning,
  }) {
    return CallSession(
      callId: callId ?? this.callId,
      matchId: matchId ?? this.matchId,
      matchName: matchName ?? this.matchName,
      matchAvatar: matchAvatar ?? this.matchAvatar,
      status: status ?? this.status,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      duration: duration ?? this.duration,
      moderationWarning: moderationWarning ?? this.moderationWarning,
    );
  }
}
