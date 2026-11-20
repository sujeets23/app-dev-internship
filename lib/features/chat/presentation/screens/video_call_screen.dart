import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/call_session.dart';
import '../providers/video_call_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String matchName;
  final String matchAvatar;

  const VideoCallScreen({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.matchAvatar,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _hasUserConsented = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMutualConsentDialog();
    });
  }

  void _showMutualConsentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.neonLime),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mutual Call Consent',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date² strictly enforces mutual consent before connecting live video audio feeds with ${widget.matchName}.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.electricViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_moon, color: AppColors.neonLime, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Continuous 2-second on-device TFLite safety scans protect this stream.',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Exit call screen
              },
              child: const Text('Decline', style: TextStyle(color: AppColors.textMutedDark)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => _hasUserConsented = true);
                Navigator.pop(ctx);
                ref.read(videoCallProvider.notifier).initiateCall(
                      matchId: widget.matchId,
                      matchName: widget.matchName,
                      matchAvatar: widget.matchAvatar,
                    );
              },
              child: const Text('Accept & Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(videoCallProvider);

    if (!_hasUserConsented || callState == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.electricViolet),
        ),
      );
    }

    if (callState.status == CallStatus.terminatedByModeration) {
      return _buildTerminatedByModerationScreen(callState);
    }

    if (callState.status == CallStatus.requestingConsent ||
        callState.status == CallStatus.ringing) {
      return _buildRingingScreen(callState);
    }

    return _buildConnectedCallScreen(callState);
  }

  Widget _buildRingingScreen(CallSession call) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 65,
              backgroundImage: NetworkImage(widget.matchAvatar),
            ),
            const SizedBox(height: 24),
            Text(
              widget.matchName,
              style: AppTypography.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              call.status == CallStatus.requestingConsent
                  ? 'Requesting Mutual Video Consent...'
                  : 'Ringing (Establishing secure WebRTC)...',
              style: const TextStyle(color: AppColors.neonLime, fontSize: 14),
            ),
            const Spacer(),
            FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: () {
                ref.read(videoCallProvider.notifier).endCall();
                Navigator.pop(context);
              },
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedCallScreen(CallSession call) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Remote WebRTC Video
          Positioned.fill(
            child: call.isVideoMuted
                ? Container(
                    color: AppColors.surfaceDark,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.matchAvatar),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.matchName} turned camera off',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.network(
                    widget.matchAvatar,
                    fit: BoxFit.cover,
                  ),
          ),

          // Dark gradient vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Top Header & Safety Shield HUD
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.matchName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _formatDuration(call.duration),
                      style: const TextStyle(color: AppColors.neonLime, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield, color: AppColors.neonLime, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'TFLite 2s Frame Scan',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Local Self PIP (Picture-In-Picture)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              width: 100,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.electricViolet, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xFF20202A),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white54, size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Call Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Testing helper button for NSFW violation demo
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.25),
                  ),
                  onPressed: () {
                    ref.read(videoCallProvider.notifier).triggerSafetyViolation(
                          reason: 'Explicit video content flagged by TFLite NSFW classifier',
                        );
                  },
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 16),
                  label: const Text(
                    'Simulate TFLite NSFW Violation (Terminates Call)',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCallActionBtn(
                      icon: call.isAudioMuted ? Icons.mic_off : Icons.mic,
                      active: !call.isAudioMuted,
                      onTap: () => ref.read(videoCallProvider.notifier).toggleAudio(),
                    ),
                    _buildCallActionBtn(
                      icon: call.isVideoMuted ? Icons.videocam_off : Icons.videocam,
                      active: !call.isVideoMuted,
                      onTap: () => ref.read(videoCallProvider.notifier).toggleVideo(),
                    ),
                    _buildCallActionBtn(
                      icon: Icons.flip_camera_ios,
                      active: true,
                      onTap: () => ref.read(videoCallProvider.notifier).switchCamera(),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        ref.read(videoCallProvider.notifier).endCall();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActionBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.25) : Colors.red.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTerminatedByModerationScreen(CallSession call) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: const Icon(
                  Icons.gpp_bad,
                  color: Colors.redAccent,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Call Terminated by AI Moderation',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  call.moderationWarning ??
                      'Inappropriate content detected. The connection was terminated immediately to maintain user safety.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ref.read(videoCallProvider.notifier).endCall();
                  Navigator.pop(context);
                },
                child: const Text('Return to Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
