import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';

enum OrbState { idle, pulsing, thinking, rippling, swirling, adapting, completed }

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
      duration: _durationForState(widget.state),
    )..repeat();
  }

  Duration _durationForState(OrbState state) {
    switch (state) {
      case OrbState.idle:
      case OrbState.pulsing:
        return const Duration(seconds: 4);
      case OrbState.thinking:
      case OrbState.swirling:
        return const Duration(milliseconds: 1800);
      case OrbState.rippling:
        return const Duration(milliseconds: 1400);
      case OrbState.adapting:
        return const Duration(milliseconds: 2200);
      case OrbState.completed:
        return const Duration(milliseconds: 1600);
    }
  }

  @override
  void didUpdateWidget(AuraOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _controller.duration = _durationForState(widget.state);
      _controller.reset();
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getOrbColors() {
    final baseColors = AuraColors.getSoulColors(widget.soul);
    if (widget.state == OrbState.adapting) {
      // Shift toward Action Green during plan adaptation
      final green = AuraColors.actionGreen;
      return [
        Color.lerp(baseColors.primary, green, 0.7)!,
        Color.lerp(baseColors.secondary, green.withOpacity(0.8), 0.7)!,
      ];
    } else if (widget.state == OrbState.completed) {
      return [
        AuraColors.actionGreen,
        AuraColors.actionGreen.withOpacity(0.5),
      ];
    }
    return [baseColors.primary, baseColors.secondary];
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

    if (orbState == OrbState.idle || orbState == OrbState.pulsing) {
      // Gentle calm breathing pulse
      pulseScale = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.08);
    } else if (orbState == OrbState.thinking || orbState == OrbState.swirling) {
      rotationAngle = animationValue * 2 * math.pi;
      pulseScale = 1.0 + (math.sin(animationValue * 4 * math.pi) * 0.05);
    } else if (orbState == OrbState.adapting) {
      rotationAngle = animationValue * math.pi;
      pulseScale = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.12);
    } else if (orbState == OrbState.completed) {
      pulseScale = 1.0 + (math.sin(animationValue * math.pi) * 0.15);
    }

    final activeRadius = baseRadius * pulseScale;

    // Draw the glow background: restrained soft-tech blur
    final glowOpacity = (orbState == OrbState.adapting || orbState == OrbState.completed) ? 0.55 : 0.35;
    final glowPaint = Paint()
      ..color = colors[1].withOpacity(glowOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, activeRadius * 0.9);
    canvas.drawCircle(center, activeRadius * 1.5, glowPaint);

    // Also draw a radiating secondary ring in pulsing/adapting state
    if (orbState == OrbState.pulsing || orbState == OrbState.idle || orbState == OrbState.adapting) {
      final pulseProgress = animationValue;
      final waveRadius = baseRadius * (1.1 + (pulseProgress * 0.45));
      final waveOpacity = (1.0 - pulseProgress) * 0.22;
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
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
