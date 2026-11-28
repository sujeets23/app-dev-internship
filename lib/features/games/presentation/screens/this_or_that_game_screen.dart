import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import 'package:inclusive_dating/features/chat/presentation/screens/chat_screen.dart';

/// Interactive "This or That" Breaking The Ice Experience
/// Faithfully reproduces the "Unmute - Breaking the Ice" Case Study UI:
/// 1. Question Card Screen: Choice between "Beach" (warm sunset & waves) and "Mountains" (lavender & snowpeaks).
/// 2. Interactive Selection: "Locked in" badge, checkmark, "tap to undo", and animated Continue button.
/// 3. Reveal Screen ("They answered."): Side-by-side tilted cards, radiating concentric rings, orange smiley face,
///    wavy partner connector line, witty outcome copy, and "See your opening ➔" leading straight into Chat.
class ThisOrThatGameScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  final String? matchName;
  final String? matchAvatar;
  final String? userAvatar;

  const ThisOrThatGameScreen({
    super.key,
    this.conversationId,
    this.matchName,
    this.matchAvatar,
    this.userAvatar,
  });

  @override
  ConsumerState<ThisOrThatGameScreen> createState() =>
      _ThisOrThatGameScreenState();
}

class _ThisOrThatGameScreenState extends ConsumerState<ThisOrThatGameScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOption; // 'Beach' or 'Mountains'
  bool _isRevealed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final String _matchChoice = 'Mountains'; // Match choice

  String get _matchName => widget.matchName ?? 'Marc';
  String get _matchAvatar =>
      widget.matchAvatar ??
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';
  String get _userAvatar =>
      widget.userAvatar ??
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onSelectOption(String option) {
    if (_isRevealed) return;
    setState(() {
      if (_selectedOption == option) {
        _selectedOption = null; // Toggle undo
      } else {
        _selectedOption = option;
      }
    });
  }

  void _onContinue() {
    if (_selectedOption == null) return;
    setState(() {
      _isRevealed = true;
    });
    _animController.forward(from: 0.0);
  }

  void _onSeeYourOpening() {
    final convId = widget.conversationId ?? 'conv_1';
    final isMatch = _selectedOption == _matchChoice;

    final icebreakerText = isMatch
        ? 'We both picked $_selectedOption! 🏔️ Apparently neither of us wants a beach holiday. What\'s your dream trek?'
        : 'Opposites attract! I picked $_selectedOption while you picked $_matchChoice. Ready to negotiate our dream vacation? 😉';

    // Post message to chat
    try {
      ref.read(chatServiceProvider).sendMessage(
            conversationId: convId,
            text: icebreakerText,
          );
      ref.invalidate(conversationsProvider);
    } catch (_) {}

    // Navigate to Chat
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: convId,
          participantName: _matchName,
          participantAvatar: _matchAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warm clean editorial canvas
    const bgColor = Color(0xFFF9F7F3);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isRevealed ? _buildRevealView() : _buildQuestionView(),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. QUESTION VIEW (Beach vs Mountains Dilemma)
  // ===========================================================================
  Widget _buildQuestionView() {
    final bool isBeachSelected = _selectedOption == 'Beach';
    final bool isMountainsSelected = _selectedOption == 'Mountains';
    final bool hasSelection = _selectedOption != null;

    return Column(
      key: const ValueKey('question_view'),
      children: [
        // Top Header Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close ✕
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 26, color: Color(0xFF161824)),
                onPressed: () => Navigator.of(context).maybePop(),
              ),

              // "• This or That" Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E4DC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5C38),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'This or That',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF161824),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Overlapping Avatar Thumbnails
              SizedBox(
                width: 48,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 12.5,
                          backgroundImage: NetworkImage(_userAvatar),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 12.5,
                          backgroundImage: NetworkImage(_matchAvatar),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow
                Row(
                  children: [
                    const Text('👾', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'We found something you two might disagree on.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF161824).withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Main Display Title
                const Text(
                  'Pick your escape.',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: Color(0xFF141416),
                  ),
                ),

                const SizedBox(height: 14),

                // Two Dilemma Cards with center emoji badge
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          // Card 1: Beach
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onSelectOption('Beach'),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isMountainsSelected ? 0.38 : 1.0,
                                child: _buildBeachCard(
                                    isSelected: isBeachSelected),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Card 2: Mountains
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onSelectOption('Mountains'),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isBeachSelected ? 0.38 : 1.0,
                                child: _buildMountainsCard(
                                    isSelected: isMountainsSelected),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Floating center curiosity emoji (when nothing is selected)
                      if (!hasSelection)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFECE6DC), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child:
                              const Text('🤨', style: TextStyle(fontSize: 22)),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Lock & Hidden status hint
                Center(
                  child: GestureDetector(
                    onTap: hasSelection
                        ? () => setState(() => _selectedOption = null)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: const Color(0xFF141416).withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hasSelection
                              ? 'Locked. They can\'t see it yet • tap to undo'
                              : 'Your answer stays hidden until both of you choose.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF141416)
                                .withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Bottom Action Button
                hasSelection
                    ? SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF141416),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5C38),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 54,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE5DC),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pick one to continue',
                              style: TextStyle(
                                color: const Color(0xFF141416)
                                    .withValues(alpha: 0.45),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: const Color(0xFF141416)
                                  .withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 1A. BEACH CARD (Custom Painted Sunset, Palm Trees & Waves)
  // ===========================================================================
  Widget _buildBeachCard({required bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Custom Painted Beach Illustration
            Positioned.fill(
              child: CustomPaint(
                painter: _BeachCardPainter(),
              ),
            ),

            // Card Title in Top-Left
            const Positioned(
              top: 18,
              left: 20,
              child: Text(
                'Beach',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF141416),
                  letterSpacing: -0.6,
                ),
              ),
            ),

            // "Locked in" Badge in Top-Right
            if (isSelected)
              Positioned(
                top: 16,
                right: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181A20).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Locked in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Big selection checkmark
            if (isSelected)
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1B. MOUNTAINS CARD (Custom Painted Lavender Sky, Moon & Snowpeaks)
  // ===========================================================================
  Widget _buildMountainsCard({required bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Custom Painted Mountains Illustration
            Positioned.fill(
              child: CustomPaint(
                painter: _MountainsCardPainter(),
              ),
            ),

            // Card Title in Top-Left
            const Positioned(
              top: 18,
              left: 20,
              child: Text(
                'Mountains',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF141416),
                  letterSpacing: -0.6,
                ),
              ),
            ),

            // "Locked in" Badge
            if (isSelected)
              Positioned(
                bottom: 16,
                right: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181A20).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Locked in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Big selection checkmark
            if (isSelected)
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. REVEAL / COMPARISON VIEW ("They answered.")
  // ===========================================================================
  Widget _buildRevealView() {
    final bool isBothMountains = _selectedOption == 'Mountains';

    return Padding(
      key: const ValueKey('reveal_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Pill Banner: [Avatar] They answered.
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFECE7DE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 9,
                    backgroundImage: NetworkImage(_matchAvatar),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'They answered.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141416),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Side-by-side tilted cards with radiating concentric rings & smiley face
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                height: 230,
                width: 290,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Concentric radiant background rings
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF7E58).withValues(alpha: 0.22),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6D3E).withValues(alpha: 0.88),
                      ),
                    ),

                    // Left Tilted Card ("YOU")
                    Positioned(
                      left: 10,
                      top: 14,
                      child: Transform.rotate(
                        angle: -0.12, // -7 degrees
                        child: _buildMiniChoiceCard(
                          title: _selectedOption ?? 'Mountains',
                          subtitle: 'YOU',
                          isDark: false,
                        ),
                      ),
                    ),

                    // Right Tilted Card ("THEM")
                    Positioned(
                      right: 10,
                      top: 14,
                      child: Transform.rotate(
                        angle: 0.12, // +7 degrees
                        child: _buildMiniChoiceCard(
                          title: _matchChoice,
                          subtitle: 'THEM',
                          isDark: true,
                        ),
                      ),
                    ),

                    // Center Radiant Orange Smiley Emoji Face 😃
                    Positioned(
                      bottom: 42,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5C38),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5C38).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '😃',
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                    ),

                    // Wavy Squiggle Line connecting You & Match avatars below
                    Positioned(
                      bottom: 0,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(_userAvatar),
                          ),
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 16),
                              painter: _WavyConnectorPainter(),
                            ),
                          ),
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(_matchAvatar),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Display Outcome Title
          Text(
            isBothMountains
                ? 'Okay... this got\neasier.'
                : 'Opposites\nattract!',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.9,
              color: Color(0xFF141416),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle Explanation
          Text(
            isBothMountains
                ? 'You both picked Mountains.\nApparently neither of you wants a beach holiday.'
                : 'You chose ${_selectedOption ?? 'Beach'}, while $_matchName picked $_matchChoice.\nTime to plan the ultimate coast-to-summit trip.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: const Color(0xFF141416).withValues(alpha: 0.72),
            ),
          ),

          const Spacer(),

          // Bottom Action: "See your opening ➔"
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onSeeYourOpening,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF141416),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'See your opening',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Mini Card helper for comparison
  Widget _buildMiniChoiceCard({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: 124,
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2236AA) : const Color(0xFFC7C5F7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? Colors.white70 : const Color(0xFF383858),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF141416),
            ),
          ),
          const Spacer(),
          // Little mountain graphic
          SizedBox(
            height: 50,
            width: double.infinity,
            child: CustomPaint(
              painter: _MiniMountainPainter(isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// VECTOR PAINTERS FOR BEACH & MOUNTAINS
// =============================================================================

class _BeachCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient Background (golden yellow to warm orange)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFFFA242)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Setting Sun
    final sunCenter = Offset(size.width * 0.72, size.height * 0.38);
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7246), Color(0xFFFF5232)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: sunCenter, radius: size.height * 0.5));
    canvas.drawCircle(sunCenter, size.height * 0.44, sunPaint);

    // 3. Palm Trees
    _drawPalmTree(canvas, Offset(size.width * 0.78, size.height * 0.62), scale: 0.95);
    _drawPalmTree(canvas, Offset(size.width * 0.90, size.height * 0.68), scale: 0.72);

    // 4. Layered Turquoise Ocean Waves
    final wave1Paint = Paint()..color = const Color(0xFF30D5C8);
    final wave1 = Path()
      ..moveTo(0, size.height * 0.68)
      ..cubicTo(size.width * 0.15, size.height * 0.63, size.width * 0.35, size.height * 0.74, size.width * 0.55, size.height * 0.67)
      ..cubicTo(size.width * 0.75, size.height * 0.60, size.width * 0.88, size.height * 0.72, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave1, wave1Paint);

    final wave2Paint = Paint()..color = const Color(0xFF14B8AA);
    final wave2 = Path()
      ..moveTo(0, size.height * 0.76)
      ..cubicTo(size.width * 0.2, size.height * 0.72, size.width * 0.45, size.height * 0.82, size.width * 0.65, size.height * 0.75)
      ..cubicTo(size.width * 0.85, size.height * 0.68, size.width * 0.95, size.height * 0.78, size.width, size.height * 0.73)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave2, wave2Paint);

    // Sandy Shore in bottom right
    final sandPaint = Paint()..color = const Color(0xFFFFCF68);
    final sand = Path()
      ..moveTo(size.width * 0.65, size.height)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.84, size.width, size.height * 0.86)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(sand, sandPaint);
  }

  void _drawPalmTree(Canvas canvas, Offset base, {required double scale}) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF9E5C28)
      ..strokeWidth = 3.5 * scale
      ..style = PaintingStyle.stroke;

    final trunk = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx - 8 * scale, base.dy - 35 * scale, base.dx - 4 * scale, base.dy - 65 * scale);
    canvas.drawPath(trunk, trunkPaint);

    final leafPaint = Paint()
      ..color = const Color(0xFF1B7A66)
      ..strokeWidth = 3.8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final top = Offset(base.dx - 4 * scale, base.dy - 65 * scale);
    // Draw 5 palm fronds
    canvas.drawLine(top, Offset(top.dx - 22 * scale, top.dy - 8 * scale), leafPaint);
    canvas.drawLine(top, Offset(top.dx - 18 * scale, top.dy + 12 * scale), leafPaint);
    canvas.drawLine(top, Offset(top.dx + 4 * scale, top.dy - 20 * scale), leafPaint);
    canvas.drawLine(top, Offset(top.dx + 22 * scale, top.dy - 10 * scale), leafPaint);
    canvas.drawLine(top, Offset(top.dx + 18 * scale, top.dy + 12 * scale), leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainsCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Lavender sky gradient background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFDDD9FA), Color(0xFFBEBAF7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Full moon
    final moonCenter = Offset(size.width * 0.78, size.height * 0.32);
    final moonPaint = Paint()..color = Colors.white;
    canvas.drawCircle(moonCenter, 13, moonPaint);

    // 3. Deep royal blue mountains
    // Peak 1: Front left & center
    final mtn1Paint = Paint()..color = const Color(0xFF2C3C9E);
    final mtn1 = Path()
      ..moveTo(-10, size.height)
      ..lineTo(size.width * 0.34, size.height * 0.42)
      ..lineTo(size.width * 0.70, size.height)
      ..close();
    canvas.drawPath(mtn1, mtn1Paint);

    // Snowcap for Peak 1
    final snow1Paint = Paint()..color = Colors.white;
    final snow1 = Path()
      ..moveTo(size.width * 0.34, size.height * 0.42)
      ..lineTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.32, size.height * 0.50)
      ..lineTo(size.width * 0.35, size.height * 0.53)
      ..lineTo(size.width * 0.40, size.height * 0.51)
      ..close();
    canvas.drawPath(snow1, snow1Paint);

    // Peak 2: Front right
    final mtn2Paint = Paint()..color = const Color(0xFF1E2A78);
    final mtn2 = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..lineTo(size.width * 0.68, size.height * 0.50)
      ..lineTo(size.width * 1.05, size.height)
      ..close();
    canvas.drawPath(mtn2, mtn2Paint);

    // Snowcap for Peak 2
    final snow2 = Path()
      ..moveTo(size.width * 0.68, size.height * 0.50)
      ..lineTo(size.width * 0.63, size.height * 0.58)
      ..lineTo(size.width * 0.67, size.height * 0.56)
      ..lineTo(size.width * 0.73, size.height * 0.57)
      ..close();
    canvas.drawPath(snow2, snow1Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniMountainPainter extends CustomPainter {
  final bool isDark;
  const _MiniMountainPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final mtnPaint = Paint()
      ..color = isDark ? const Color(0xFF141F68) : const Color(0xFF2C3C9E);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.42, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height)
      ..close();
    canvas.drawPath(path, mtnPaint);

    final snowPaint = Paint()..color = Colors.white;
    final snow = Path()
      ..moveTo(size.width * 0.42, size.height * 0.15)
      ..lineTo(size.width * 0.34, size.height * 0.38)
      ..lineTo(size.width * 0.40, size.height * 0.34)
      ..lineTo(size.width * 0.48, size.height * 0.36)
      ..close();
    canvas.drawPath(snow, snowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavyConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5C38)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(8, size.height * 0.5);

    double x = 8;
    const double waveLength = 12.0;
    const double amplitude = 4.0;
    bool up = true;

    while (x < size.width - 8) {
      final nextX = math.min(x + waveLength, size.width - 8);
      final midX = (x + nextX) / 2;
      final controlY = up ? (size.height * 0.5 - amplitude) : (size.height * 0.5 + amplitude);
      path.quadraticBezierTo(midX, controlY, nextX, size.height * 0.5);
      x = nextX;
      up = !up;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
