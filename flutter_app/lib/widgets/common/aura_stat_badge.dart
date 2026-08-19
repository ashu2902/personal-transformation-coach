import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Compact, fluid badge / tag for displaying metrics, categories, or status.
class AuraStatBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final bool isFilled;

  const AuraStatBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final accentColor = color ?? auraTheme.primary;
    final bg = backgroundColor ?? (isFilled ? accentColor : accentColor.withValues(alpha: 0.14));
    final fg = isFilled ? Colors.black : accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: !isFilled ? Border.all(color: accentColor.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AuraTypography.bodySmall.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
