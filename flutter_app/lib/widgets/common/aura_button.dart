import 'package:flutter/material.dart';
import '../../theme/theme.dart';

enum AuraButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

/// Standardized action button for AURA.
class AuraButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case AuraButtonVariant.primary:
        bg = backgroundColor ?? auraTheme.primary;
        fg = textColor ?? Colors.black;
        break;
      case AuraButtonVariant.secondary:
        bg = backgroundColor ?? auraTheme.surfaceLight;
        fg = textColor ?? AuraColors.textPrimary;
        break;
      case AuraButtonVariant.outline:
        bg = backgroundColor ?? Colors.transparent;
        fg = textColor ?? auraTheme.primary;
        side = BorderSide(color: auraTheme.primary.withOpacity(0.4), width: 1);
        break;
      case AuraButtonVariant.ghost:
        bg = backgroundColor ?? Colors.transparent;
        fg = textColor ?? AuraColors.textSecondary;
        break;
    }

    if (!isEnabled && variant == AuraButtonVariant.primary) {
      bg = bg.withOpacity(0.4);
      fg = fg.withOpacity(0.6);
    }

    final childWidget = isLoading
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
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AuraTypography.buttonText.copyWith(color: fg),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: side,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: childWidget,
      ),
    );
  }
}
