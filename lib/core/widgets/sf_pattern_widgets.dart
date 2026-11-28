import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive & Visual Pattern Components matching the SF Pro & playful sticker design system
/// 1. SfWelcomeBadgesPattern: Floating speech bubbles & playful badges surrounding welcome screen
/// 2. SfBirthdayCandlesPattern: Playful chunky birthday candle digits (donut frosting & sprinkles)
/// 3. SfCandyTokensPattern: Overlapping chunky candy tokens with heart cutouts & privacy shield
/// 4. SfDateOfBirthBoxes: 3 distinct rounded white box cards for Day, Month, Year

// =============================================================================
// 1. WELCOME SPEECH BUBBLES & PLAYFUL BADGES PATTERN
// =============================================================================
class SfWelcomeBadgesPattern extends StatelessWidget {
  final bool showRussianText;

  const SfWelcomeBadgesPattern({
    super.key,
    this.showRussianText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Floating Row: Purple/Pink Pill + Yellow Heart Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pill 1: Safety is our priority
            Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD6B8FF), Color(0xFFFF94CE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6B8FF).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  showRussianText
                      ? 'безопасность – наш приоритет'
                      : 'safety is our top priority',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),

            // Badge 1: Yellow Heart Coin
            Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.sfYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFC7445),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 2: Pink Search Icon Badge + Cobalt Blue Compatibility Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge 2: Pink Magnifying Glass Coin
            Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE0F0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFFFF4D94),
                    size: 24,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Pill 2: Cobalt Blue Compatibility Pill
            Expanded(
              child: Transform.rotate(
                angle: 0.03,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.sfBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sfBlue.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    showRussianText
                        ? 'подбирайте пару по совместимости'
                        : 'find a match by compatibility',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SfWelcomeBottomBadgesPattern extends StatelessWidget {
  final bool showRussianText;

  const SfWelcomeBottomBadgesPattern({
    super.key,
    this.showRussianText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 3: Warm Coral Comfort Pill + Orange Puzzle Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pill 3: Warm Coral Comfort Pill
            Transform.rotate(
              angle: -0.03,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sfCoral,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sfCoral.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  showRussianText
                      ? 'общайтесь с комфортом'
                      : 'connect with genuine comfort',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Badge 3: Orange Puzzle Coin
            Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD9B3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.extension_rounded,
                    color: Color(0xFFFC7445),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 4: Cobalt Blue Link Badge + Candy Pink Discovery Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge 4: Cobalt Blue Link Coin
            Transform.rotate(
              angle: -0.06,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.sfBlue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Pill 4: Candy Pink Discovery Pill
            Expanded(
              child: Transform.rotate(
                angle: 0.02,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD3EC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    showRussianText
                        ? 'и находите новые знакомства'
                        : 'and make inspiring new connections',
                    style: const TextStyle(
                      color: Color(0xFFD61A70),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// 2. BIRTHDAY CANDLES & CELEBRATION PATTERN (Screen 3 of Reference)
// =============================================================================
class SfBirthdayCandlesPattern extends StatelessWidget {
  final int age;

  const SfBirthdayCandlesPattern({
    super.key,
    this.age = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F7),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background organic wave curves
            Positioned.fill(
              child: CustomPaint(
                painter: _SoftPastelWavesPainter(),
              ),
            ),

            // Chunky Candle Numbers (Digits '1' and '8' or dynamic age)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: 280,
                height: 180,
                child: CustomPaint(
                  painter: _BirthdayCandleDigitsPainter(
                    digits: age.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftPastelWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = const Color(0xFFFFD4EB).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.65,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BirthdayCandleDigitsPainter extends CustomPainter {
  final String digits;

  _BirthdayCandleDigitsPainter({required this.digits});

  @override
  void paint(Canvas canvas, Size size) {
    // Left digit (e.g. '1' or '2')
    _drawCandleDigit(
      canvas,
      Offset(size.width * 0.26, size.height * 0.55),
      digits.isNotEmpty ? digits[0] : '1',
      const Color(0xFFFC7445), // Coral donut base
      const Color(0xFFFFD6ED), // Pink frosting
    );

    // Right digit (e.g. '8' or '4')
    _drawCandleDigit(
      canvas,
      Offset(size.width * 0.72, size.height * 0.55),
      digits.length > 1 ? digits[1] : '8',
      const Color(0xFFFAC938), // Golden donut base
      const Color(0xFFFF94CE), // Bubblegum frosting
    );
  }

  void _drawCandleDigit(
    Canvas canvas,
    Offset center,
    String char,
    Color baseColor,
    Color frostingColor,
  ) {
    // 1. Draw flame on top
    final flameCenter = Offset(center.dx, center.dy - 65);
    final flameOuter = Paint()..color = const Color(0xFFFF6243);
    final flameInner = Paint()..color = const Color(0xFFFFE033);

    // Outer flame teardrop
    final flamePath = Path()
      ..moveTo(flameCenter.dx, flameCenter.dy - 22)
      ..cubicTo(
        flameCenter.dx + 14,
        flameCenter.dy - 6,
        flameCenter.dx + 14,
        flameCenter.dy + 14,
        flameCenter.dx,
        flameCenter.dy + 14,
      )
      ..cubicTo(
        flameCenter.dx - 14,
        flameCenter.dy + 14,
        flameCenter.dx - 14,
        flameCenter.dy - 6,
        flameCenter.dx,
        flameCenter.dy - 22,
      );
    canvas.drawPath(flamePath, flameOuter);

    // Inner flame
    final innerFlamePath = Path()
      ..moveTo(flameCenter.dx, flameCenter.dy - 12)
      ..cubicTo(
        flameCenter.dx + 7,
        flameCenter.dy - 2,
        flameCenter.dx + 7,
        flameCenter.dy + 9,
        flameCenter.dx,
        flameCenter.dy + 9,
      )
      ..cubicTo(
        flameCenter.dx - 7,
        flameCenter.dy + 9,
        flameCenter.dx - 7,
        flameCenter.dy - 2,
        flameCenter.dx,
        flameCenter.dy - 12,
      );
    canvas.drawPath(innerFlamePath, flameInner);

    // Wick
    final wickPaint = Paint()
      ..color = const Color(0xFF212322)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(flameCenter.dx, flameCenter.dy + 14),
      Offset(flameCenter.dx, flameCenter.dy + 22),
      wickPaint,
    );

    // 2. Chunky digit body
    final digitRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 88, height: 110),
      const Radius.circular(30),
    );

    // White outline border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(digitRect, borderPaint);

    // Base fill
    final basePaint = Paint()..color = baseColor;
    canvas.drawRRect(digitRect, basePaint);

    // Frosting waves
    final frostPaint = Paint()..color = frostingColor;
    final frostPath = Path()
      ..moveTo(center.dx - 40, center.dy - 20)
      ..quadraticBezierTo(center.dx - 20, center.dy - 35, center.dx, center.dy - 20)
      ..quadraticBezierTo(center.dx + 20, center.dy - 5, center.dx + 40, center.dy - 20)
      ..lineTo(center.dx + 40, center.dy + 50)
      ..lineTo(center.dx - 40, center.dy + 50)
      ..close();
    canvas.drawPath(frostPath, frostPaint);

    // Draw digit text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 62,
          fontWeight: FontWeight.w900,
          fontFamily: 'SF Pro',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );

    // Colorful Sprinkles on top
    final sprinkleColors = [
      Colors.white,
      const Color(0xFF1A5EDB),
      const Color(0xFFFF94CE),
      const Color(0xFFFAC938),
    ];
    final random = math.Random(char.codeUnitAt(0));

    for (int i = 0; i < 7; i++) {
      final sx = center.dx - 30 + random.nextDouble() * 60;
      final sy = center.dy - 35 + random.nextDouble() * 70;
      final sPaint = Paint()
        ..color = sprinkleColors[i % sprinkleColors.length]
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final angle = random.nextDouble() * math.pi;
      const length = 6.0;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + math.cos(angle) * length, sy + math.sin(angle) * length),
        sPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 3. CANDY TOKENS & PRIVACY SHIELD PATTERN (Screen 4 of Reference)
// =============================================================================
class SfCandyTokensPattern extends StatelessWidget {
  const SfCandyTokensPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Overlapping candy tokens illustration
        SizedBox(
          height: 150,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Lilac Donut Ring (Left background)
              Positioned(
                left: 20,
                bottom: 10,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6B8FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Coral Disc with Heart (Left middle)
              Positioned(
                left: 55,
                bottom: -5,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.sfCoral,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF94CE),
                      size: 40,
                    ),
                  ),
                ),
              ),

              // 3. Bubblegum Pink Disc (Right background)
              Positioned(
                right: 35,
                bottom: 25,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: AppColors.sfPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),

              // 4. Large Golden Yellow Disc with Coral Heart (Right center)
              Positioned(
                right: 15,
                bottom: -15,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.sfYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFC7445),
                      size: 52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Privacy Lock Subtitle Note
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Color(0xFF8E8E93),
            ),
            SizedBox(width: 5),
            Text(
              'This information is hidden from other users',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// 4. 3-BOX DATE OF BIRTH INPUT CARDS (Screen 3 of Reference)
// =============================================================================
class SfDateOfBirthBoxes extends StatelessWidget {
  final DateTime? dateOfBirth;
  final VoidCallback onTap;

  const SfDateOfBirthBoxes({
    super.key,
    required this.dateOfBirth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final effective = dateOfBirth ?? DateTime(now.year - 24, 1, 1);

    final dayStr = effective.day.toString().padLeft(2, '0');
    final monthStr = effective.month.toString().padLeft(2, '0');
    final yearStr = effective.year.toString();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day Card
          _buildBoxCard('Day', dayStr, width: 78),
          const SizedBox(width: 14),

          // Month Card
          _buildBoxCard('Month', monthStr, width: 78),
          const SizedBox(width: 14),

          // Year Card
          _buildBoxCard('Year', yearStr, width: 104),
        ],
      ),
    );
  }

  Widget _buildBoxCard(String label, String value, {required double width}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.sfCharcoal,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
