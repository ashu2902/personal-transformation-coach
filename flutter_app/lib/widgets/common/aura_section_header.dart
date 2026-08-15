import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Standardized section title with optional action button for AURA.
class AuraSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final EdgeInsetsGeometry margin;

  const AuraSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;

    return Padding(
      padding: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: AuraTypography.sectionHeader.copyWith(
              color: auraTheme.primary,
            ),
          ),
          if (actionText != null || actionIcon != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                children: [
                  if (actionText != null)
                    Text(
                      actionText!,
                      style: AuraTypography.bodySmall.copyWith(
                        color: auraTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (actionIcon != null) ...[
                    const SizedBox(width: 4),
                    Icon(actionIcon, size: 14, color: auraTheme.primary),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
