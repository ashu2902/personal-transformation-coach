import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/curated_meal_plan.dart';
import '../../theme/theme.dart';
import '../../widgets/common/common.dart';

class CuratedMealCard extends StatefulWidget {
  final CuratedMeal meal;
  final VoidCallback? onLog;

  const CuratedMealCard({
    super.key,
    required this.meal,
    this.onLog,
  });

  @override
  State<CuratedMealCard> createState() => _CuratedMealCardState();
}

class _CuratedMealCardState extends State<CuratedMealCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final meal = widget.meal;
    final isLogged = meal.isLogged;

    return AuraCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundColor: isLogged
          ? auraTheme.surfaceCard.withValues(alpha: 0.6)
          : auraTheme.surfaceCard,
      borderColor: isLogged
          ? AuraColors.actionGreen.withValues(alpha: 0.3)
          : AuraColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Slot badge + Logged indicator or Calories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLogged
                      ? AuraColors.actionGreen.withValues(alpha: 0.15)
                      : auraTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLogged ? LucideIcons.checkCircle2 : LucideIcons.utensils,
                      size: 11,
                      color: isLogged ? AuraColors.actionGreen : auraTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.slotName.toUpperCase(),
                      style: AuraTypography.sectionHeader.copyWith(
                        fontSize: 10,
                        color: isLogged ? AuraColors.actionGreen : auraTheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (meal.prepTime != null && meal.prepTime!.isNotEmpty) ...[
                    const Icon(LucideIcons.clock, size: 11, color: AuraColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      meal.prepTime!,
                      style: AuraTypography.bodySmall.copyWith(
                        color: AuraColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AuraStatBadge(
                    label: '${meal.calories} kcal',
                    color: auraTheme.energyAccent,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Meal Name
          Text(
            meal.name,
            style: AuraTypography.titleMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isLogged
                  ? AuraColors.textPrimary.withValues(alpha: 0.8)
                  : AuraColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Macros Pills Row
          Row(
            children: [
              _buildMacroChip('${meal.proteinG}g P', auraTheme.proteinAccent),
              const SizedBox(width: 6),
              _buildMacroChip('${meal.carbsG}g C', AuraColors.carbs),
              const SizedBox(width: 6),
              _buildMacroChip('${meal.fatG}g F', AuraColors.fat),
              if (meal.tags.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: auraTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    meal.tags.first,
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Ingredients & portion details
          if (meal.description.isNotEmpty) ...[
            Text(
              meal.description,
              style: AuraTypography.bodySmall.copyWith(
                color: AuraColors.textSecondary,
                height: 1.4,
              ),
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ],

          // Expandable cooking instruction
          if (meal.instructions != null && meal.instructions!.isNotEmpty) ...[
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AuraColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.chefHat, size: 13, color: auraTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meal.instructions!,
                        style: AuraTypography.bodySmall.copyWith(
                          color: AuraColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Show less' : 'View ingredients & prep',
                    style: AuraTypography.bodySmall.copyWith(
                      color: auraTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 12,
                    color: auraTheme.primary,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // 1-Tap Log Action
          if (isLogged)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AuraColors.actionGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AuraColors.actionGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.check, size: 14, color: AuraColors.actionGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Logged to Today\'s Fuel',
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.actionGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            AuraButton(
              text: 'Log This Meal (+${meal.calories} kcal)',
              icon: LucideIcons.plus,
              width: double.infinity,
              height: 38,
              borderRadius: 10,
              variant: AuraButtonVariant.primary,
              onPressed: widget.onLog,
            ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
