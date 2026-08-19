import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Fluid, theme-aware interactive card component for AURA.
/// Features tactile spring press feedback, hover elevations, and responsive padding.
class AuraCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool enableHoverEffect;

  const AuraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.onTap,
    this.showBorder = true,
    this.enableHoverEffect = true,
  });

  @override
  State<AuraCard> createState() => _AuraCardState();
}

class _AuraCardState extends State<AuraCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final isInteractive = widget.onTap != null;
    final bg = widget.backgroundColor ?? auraTheme.surfaceCard;

    Color effectiveBorderColor = widget.borderColor ?? AuraColors.borderSubtle;
    if (_isHovered && isInteractive) {
      effectiveBorderColor = auraTheme.primary.withValues(alpha: 0.5);
    }

    final border = widget.showBorder
        ? Border.all(
            color: effectiveBorderColor,
            width: _isHovered && isInteractive ? 1.5 : 1.0,
          )
        : null;

    final baseGlow = widget.glowColor ?? (_isHovered && isInteractive ? auraTheme.primary : null);
    final glowOpacity = _isHovered ? 0.22 : 0.12;

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: border,
      boxShadow: baseGlow != null
          ? [
              BoxShadow(
                color: baseGlow.withValues(alpha: glowOpacity),
                blurRadius: _isHovered ? 24 : 16,
                spreadRadius: _isHovered ? 1 : 0,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ]
          : null,
    );

    double currentScale = 1.0;
    if (isInteractive) {
      if (_isPressed) {
        currentScale = 0.985;
      } else if (_isHovered && widget.enableHoverEffect) {
        currentScale = 1.012;
      }
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: AuraCurves.fluidEaseOut,
      padding: widget.padding,
      margin: widget.margin,
      decoration: decoration,
      child: widget.child,
    );

    if (isInteractive) {
      return MouseRegion(
        onEnter: (_) {
          if (widget.enableHoverEffect) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (widget.enableHoverEffect) setState(() => _isHovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: currentScale,
            duration: const Duration(milliseconds: 160),
            curve: AuraCurves.fluidSpring,
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
