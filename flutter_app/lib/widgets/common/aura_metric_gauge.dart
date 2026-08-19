import 'package:flutter/material.dart';
import '../../theme/theme.dart';

enum AuraMetricVariant {
  energy,
  protein,
  water,
  recovery,
  custom,
}

/// Fluid animated progress / macro gauge for AURA.
/// Smoothly animates value transitions with spring ease curves.
class AuraMetricGauge extends StatelessWidget {
  final String label;
  final num currentValue;
  final num targetValue;
  final String unit;
  final AuraMetricVariant variant;
  final Color? customColor;
  final IconData? icon;
  final bool showValuesRow;
  final double height;

  const AuraMetricGauge({
    super.key,
    required this.label,
    required this.currentValue,
    required this.targetValue,
    this.unit = '',
    this.variant = AuraMetricVariant.energy,
    this.customColor,
    this.icon,
    this.showValuesRow = true,
    this.height = 8.0,
  });

  Color _resolveColor(BuildContext context) {
    if (customColor != null) return customColor!;
    final auraTheme = context.auraTheme;

    switch (variant) {
      case AuraMetricVariant.energy:
        return auraTheme.energyAccent;
      case AuraMetricVariant.protein:
        return auraTheme.proteinAccent;
      case AuraMetricVariant.water:
        return auraTheme.waterAccent;
      case AuraMetricVariant.recovery:
        return AuraColors.recovery;
      case AuraMetricVariant.custom:
        return auraTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _resolveColor(context);
    final targetProgress = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showValuesRow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: activeColor),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: AuraTypography.bodyMedium.copyWith(
                      color: AuraColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  text: '$currentValue',
                  style: AuraTypography.labelBold.copyWith(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' / $targetValue $unit',
                      style: AuraTypography.bodySmall.copyWith(
                        color: AuraColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (showValuesRow) const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetProgress.toDouble()),
          duration: const Duration(milliseconds: 600),
          curve: AuraCurves.fluidEaseOut,
          builder: (context, animatedVal, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: Stack(
                children: [
                  Container(
                    height: height,
                    width: double.infinity,
                    color: activeColor.withValues(alpha: 0.12),
                  ),
                  FractionallySizedBox(
                    widthFactor: animatedVal.clamp(0.0, 1.0),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
