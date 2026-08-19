import 'package:flutter/material.dart';
import '../../theme/theme.dart';

enum AuraButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

/// Tactile, Fluid UI action button for AURA.
/// Features spring scale feedback, smooth hover states, and responsive layout scaling.
class AuraButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const AuraButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.borderRadius = 14.0,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<AuraButton> createState() => _AuraButtonState();
}

class _AuraButtonState extends State<AuraButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (widget.variant) {
      case AuraButtonVariant.primary:
        bg = widget.backgroundColor ?? auraTheme.primary;
        fg = widget.textColor ?? Colors.black;
        break;
      case AuraButtonVariant.secondary:
        bg = widget.backgroundColor ?? auraTheme.surfaceLight;
        fg = widget.textColor ?? AuraColors.textPrimary;
        break;
      case AuraButtonVariant.outline:
        bg = widget.backgroundColor ?? Colors.transparent;
        fg = widget.textColor ?? auraTheme.primary;
        side = BorderSide(color: auraTheme.primary.withValues(alpha: 0.4), width: 1);
        break;
      case AuraButtonVariant.ghost:
        bg = widget.backgroundColor ?? Colors.transparent;
        fg = widget.textColor ?? AuraColors.textSecondary;
        break;
    }

    if (!isEnabled && widget.variant == AuraButtonVariant.primary) {
      bg = bg.withValues(alpha: 0.4);
      fg = fg.withValues(alpha: 0.6);
    }

    final childWidget = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: AuraTypography.buttonText.copyWith(color: fg),
              ),
            ],
          );

    double scale = 1.0;
    if (isEnabled) {
      if (_isPressed) {
        scale = 0.96;
      } else if (_isHovered) {
        scale = 1.02;
      }
    }

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) setState(() => _isHovered = false);
      },
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) {
          if (isEnabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isEnabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (isEnabled) setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: AuraCurves.fluidSpring,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: ElevatedButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  side: side,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: childWidget,
            ),
          ),
        ),
      ),
    );
  }
}
