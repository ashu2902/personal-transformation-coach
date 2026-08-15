import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Standardized theme-aware card component for AURA.
class AuraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;
  final bool showBorder;

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
  });

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final bg = backgroundColor ?? auraTheme.surfaceCard;
    final border = showBorder
        ? Border.all(
            color: borderColor ?? AuraColors.borderSubtle,
            width: 1,
          )
        : null;

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: glowColor != null
          ? [
              BoxShadow(
                color: glowColor!.withOpacity(0.12),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
