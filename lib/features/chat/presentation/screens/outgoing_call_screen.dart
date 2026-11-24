import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'video_call_screen.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String participantName;
  final String participantAvatar;
  final String channelId;

  const OutgoingCallScreen({
    super.key,
    required this.participantName,
    required this.participantAvatar,
    required this.channelId,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _connectTimer;
  bool _isMuted = false;
  bool _isSpeaker = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Auto-connect to WebRTC Video Call Screen after 2.5 seconds simulation
    _connectTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              matchId: widget.channelId,
              matchName: widget.participantName,
              matchAvatar: widget.participantAvatar,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _cancelCall() {
    _connectTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Status Badge
              Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock_rounded, color: AppColors.accent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'END-TO-END ENCRYPTED WEBRTC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Calling...',
                    style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.5),
                  ),
                ],
              ),

              // Avatar with calling pulses
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 170 + (_pulseController.value * 50),
                            height: 170 + (_pulseController.value * 50),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.electricViolet.withValues(
                                alpha: (1 - _pulseController.value) * 0.4,
                              ),
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.electricViolet, AppColors.blushPink],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(widget.participantAvatar),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.participantName,
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ringing & awaiting video feed...',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),

              // Controls & End Call Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mic toggle
                        IconButton(
                          iconSize: 32,
                          style: IconButton.styleFrom(
                            backgroundColor: _isMuted ? Colors.white : Colors.white24,
                            foregroundColor: _isMuted ? Colors.black : Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                          icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                          onPressed: () => setState(() => _isMuted = !_isMuted),
                        ),
                        const SizedBox(width: 24),

                        // Speaker toggle
                        IconButton(
                          iconSize: 32,
                          style: IconButton.styleFrom(
                            backgroundColor: _isSpeaker ? Colors.white : Colors.white24,
                            foregroundColor: _isSpeaker ? Colors.black : Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                          icon: Icon(_isSpeaker ? Icons.volume_up : Icons.volume_down),
                          onPressed: () => setState(() => _isSpeaker = !_isSpeaker),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Cancel Call
                    InkWell(
                      onTap: _cancelCall,
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'End Call',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
