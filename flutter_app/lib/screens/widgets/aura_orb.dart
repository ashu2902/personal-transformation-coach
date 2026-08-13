import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/models.dart';

enum OrbState { pulsing, rippling, swirling }

class AuraOrb extends StatefulWidget {
  final CoachSoul soul;
  final OrbState state;
  final double size;

  const AuraOrb({
    super.key,
    required this.soul,
    required this.state,
    this.size = 200,
  });

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<AuraOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(AuraOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _controller.stop();
      switch (widget.state) {
        case OrbState.pulsing:
          _controller.duration = const Duration(seconds: 4);
          _controller.repeat();
          break;
        case OrbState.rippling:
          _controller.duration = const Duration(milliseconds: 1500);
          _controller.repeat();
          break;
        case OrbState.swirling:
          _controller.duration = const Duration(seconds: 2);
          _controller.repeat();
          break;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getOrbColors() {
    switch (widget.soul) {
      case CoachSoul.supporter:
        return [
          const Color(0xFF8EA885), // Sage
          const Color(0xFF9A7EB8), // Lavender
        ];
      case CoachSoul.pro:
        return [
          const Color(0xFF00B2FF), // Electric Blue
          const Color(0xFFFF007A), // Neon Magenta
        ];
      case CoachSoul.teacher:
        return [
          const Color(0xFF00BFA5), // Teal
          const Color(0xFFB0BEC5), // Silver
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getOrbColors();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: OrbPainter(
            colors: colors,
            animationValue: _controller.value,
            orbState: widget.state,
          ),
        );
      },
    );
  }
}

class OrbPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;
  final OrbState orbState;

  OrbPainter({
    required this.colors,
    required this.animationValue,
    required this.orbState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2.8;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    // 1. Ripple Effect (outer wave)
    if (orbState == OrbState.rippling) {
      final rippleProgress = animationValue;
      final rippleOpacity = 1.0 - rippleProgress;
      final rippleRadius = baseRadius + (rippleProgress * (size.width / 2 - baseRadius));
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = colors[0].withOpacity(rippleOpacity * 0.4);

      canvas.drawCircle(center, rippleRadius, ripplePaint);

      final secondProgress = (animationValue + 0.5) % 1.0;
      final secondOpacity = 1.0 - secondProgress;
      final secondRadius = baseRadius + (secondProgress * (size.width / 2 - baseRadius));
      final secondPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..color = colors[1].withOpacity(secondOpacity * 0.3);

      canvas.drawCircle(center, secondRadius, secondPaint);
    }

    // 2. Pulse / swirl calculations
    double pulseScale = 1.0;
    double rotationAngle = 0.0;

    if (orbState == OrbState.pulsing) {
      // Breathing pulse: expand scale multiplier to 0.12 for prominent visual feedback
      pulseScale = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.12);
    } else if (orbState == OrbState.swirling) {
      rotationAngle = animationValue * 2 * math.pi;
      pulseScale = 1.0 + (math.sin(animationValue * 4 * math.pi) * 0.03);
    }

    final activeRadius = baseRadius * pulseScale;

    // Draw the glow background: make opacity 0.45 and size multiplier 1.6 for rich depth
    final glowPaint = Paint()
      ..color = colors[1].withOpacity(0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, activeRadius * 1.0);
    canvas.drawCircle(center, activeRadius * 1.6, glowPaint);

    // Also draw a radiating secondary ring in pulsing state to enhance the aura effect
    if (orbState == OrbState.pulsing) {
      final pulseProgress = animationValue;
      final waveRadius = baseRadius * (1.1 + (pulseProgress * 0.5));
      final waveOpacity = (1.0 - pulseProgress) * 0.25;
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..color = colors[0].withOpacity(waveOpacity);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    // 3. Main Orb Gradient with rotation if swirling
    final gradient = RadialGradient(
      center: Alignment(
        math.cos(rotationAngle) * 0.25,
        math.sin(rotationAngle) * 0.25,
      ),
      radius: 0.85,
      colors: [
        colors[0].withOpacity(0.95),
        colors[1].withOpacity(0.65),
        colors[1].withOpacity(0.0),
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: activeRadius));
    canvas.drawCircle(center, activeRadius, paint);

    // Inner bright core: make it larger and brighter
    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95),
          colors[0].withOpacity(0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: activeRadius * 0.55));

    canvas.drawCircle(center, activeRadius * 0.55, corePaint);
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.orbState != orbState ||
        oldDelegate.colors != colors;
  }
}
