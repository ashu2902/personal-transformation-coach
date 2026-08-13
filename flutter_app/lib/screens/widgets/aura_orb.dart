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
      // Breathing pulse: range from 0.96 to 1.04
      pulseScale = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.04);
    } else if (orbState == OrbState.swirling) {
      // Swirling rotation
      rotationAngle = animationValue * 2 * math.pi;
      pulseScale = 1.0 + (math.sin(animationValue * 4 * math.pi) * 0.02);
    }

    final activeRadius = baseRadius * pulseScale;

    // Draw the glow background
    final glowPaint = Paint()
      ..color = colors[1].withOpacity(0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, activeRadius * 0.8);
    canvas.drawCircle(center, activeRadius * 1.3, glowPaint);

    // 3. Main Orb Gradient with rotation if swirling
    final gradient = RadialGradient(
      center: Alignment(
        math.cos(rotationAngle) * 0.25,
        math.sin(rotationAngle) * 0.25,
      ),
      radius: 0.85,
      colors: [
        colors[0].withOpacity(0.95),
        colors[1].withOpacity(0.55),
        colors[1].withOpacity(0.0),
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: activeRadius));
    canvas.drawCircle(center, activeRadius, paint);

    // Inner bright core
    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          colors[0].withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: activeRadius * 0.45));

    canvas.drawCircle(center, activeRadius * 0.45, corePaint);
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.orbState != orbState ||
        oldDelegate.colors != colors;
  }
}
