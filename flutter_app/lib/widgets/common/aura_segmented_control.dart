import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AuraSegmentItem {
  final String label;
  final IconData? icon;

  const AuraSegmentItem({
    required this.label,
    this.icon,
  });
}

/// A fluid, tactile segmented tab control for AURA.
class AuraSegmentedControl extends StatelessWidget {
  final List<AuraSegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final EdgeInsetsGeometry margin;

  const AuraSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: auraTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AuraColors.borderSubtle),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final item = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: AuraCurves.fluidEaseOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? auraTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: auraTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 16,
                        color: isSelected ? Colors.black : AuraColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AuraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
