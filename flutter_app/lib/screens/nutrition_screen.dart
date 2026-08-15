import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final notifier = ref.read(transformationEngineProvider.notifier);
        final nutrition = state.nutrition;
        final auraTheme = context.auraTheme;

        final totalCal = nutrition.meals.fold(0, (total, m) => total + m.calories);
        final totalProt = nutrition.meals.fold(0, (total, m) => total + m.proteinG);
        final totalCarbs = nutrition.meals.fold(0, (total, m) => total + m.carbsG);
        final totalFat = nutrition.meals.fold(0, (total, m) => total + m.fatG);

        final targetCal = nutrition.targetCalories > 0 ? nutrition.targetCalories : 2000;
        final targetProt = nutrition.targetProteinG > 0 ? nutrition.targetProteinG : 150;
        final targetCarbs = nutrition.targetCarbsG > 0 ? nutrition.targetCarbsG : 200;
        final targetFat = nutrition.targetFatG > 0 ? nutrition.targetFatG : 60;

        final calPercent = (totalCal / targetCal).clamp(0.0, 1.0);
        final protPercent = (totalProt / targetProt).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Macro Summary Card
              AuraCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ENERGY INTAKE',
                              style: AuraTypography.sectionHeader.copyWith(
                                color: AuraColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCal / $targetCal kcal',
                              style: AuraTypography.statNumber,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'PROTEIN TARGET',
                              style: AuraTypography.sectionHeader.copyWith(
                                color: auraTheme.proteinAccent,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalProt / ${targetProt}g',
                              style: AuraTypography.statNumber.copyWith(
                                color: auraTheme.proteinAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: calPercent,
                        minHeight: 10,
                        backgroundColor: auraTheme.energyAccent.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(auraTheme.energyAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroPill(
                          'Protein',
                          '${totalProt}g / ${targetProt}g',
                          auraTheme.proteinAccent,
                        ),
                        _buildMacroPill(
                          'Carbs',
                          '${totalCarbs}g / ${targetCarbs}g',
                          AuraColors.carbs,
                        ),
                        _buildMacroPill(
                          'Fats',
                          '${totalFat}g / ${targetFat}g',
                          AuraColors.fat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hydration Card
              AuraCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: auraTheme.waterAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(LucideIcons.droplets, color: auraTheme.waterAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HYDRATION',
                              style: AuraTypography.sectionHeader.copyWith(
                                color: AuraColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${nutrition.waterMl} / ${nutrition.targetWaterMl > 0 ? nutrition.targetWaterMl : 3000} ml',
                              style: AuraTypography.titleMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AuraButton(
                          text: '+250 ml',
                          variant: AuraButtonVariant.outline,
                          height: 34,
                          borderRadius: 10,
                          onPressed: () => notifier.addWater(250),
                        ),
                        const SizedBox(width: 6),
                        AuraButton(
                          text: '+500 ml',
                          variant: AuraButtonVariant.outline,
                          height: 34,
                          borderRadius: 10,
                          onPressed: () => notifier.addWater(500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Meal History & Quick Log Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOGGED MEALS',
                    style: AuraTypography.sectionHeader.copyWith(
                      color: auraTheme.primary,
                    ),
                  ),
                  AuraButton(
                    text: 'Log Meal with AI',
                    icon: LucideIcons.sparkles,
                    height: 36,
                    borderRadius: 18,
                    onPressed: () => _showAddAIMealDialog(context, notifier),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (nutrition.meals.isEmpty)
                AuraCard(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.utensils, color: AuraColors.textDisabled, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'No meals logged today yet',
                          style: AuraTypography.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "+ Log Meal with AI" to describe what you ate in natural language.',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...nutrition.meals.map((meal) {
                  return AuraCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: AuraTypography.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Protein: ${meal.proteinG}g  •  Carbs: ${meal.carbsG}g  •  Fat: ${meal.fatG}g',
                                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        AuraStatBadge(
                          label: '${meal.calories} kcal',
                          color: auraTheme.energyAccent,
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AuraTypography.sectionHeader.copyWith(color: color, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showAddAIMealDialog(BuildContext context, TransformationEngineNotifier notifier) {
    final auraTheme = context.auraTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: auraTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => AIMealLoggerModal(notifier: notifier),
    );
  }
}

class AIMealLoggerModal extends StatefulWidget {
  final TransformationEngineNotifier notifier;

  const AIMealLoggerModal({super.key, required this.notifier});

  @override
  State<AIMealLoggerModal> createState() => _AIMealLoggerModalState();
}

class _AIMealLoggerModalState extends State<AIMealLoggerModal> {
  final _inputCtrl = TextEditingController();
  bool _isEstimating = false;
  MealItem? _estimatedMeal;
  String? _errorMessage;

  final List<String> _quickSuggestions = [
    '3 Scrambled Eggs & Sourdough Toast',
    'Grilled Chicken Breast & Rice Bowl',
    'Double Scoop Whey Protein Shake & Oats',
    'Greek Yogurt with Berries & Almonds',
    'Paneer Tikka with 2 Roti & Salad',
    'Salmon with Quinoa and Avocado',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _runAIEstimate(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isEstimating = true;
      _errorMessage = null;
    });

    try {
      final meal = await widget.notifier.aiService.estimateAIMealNutrition(clean);
      if (mounted) {
        setState(() {
          _estimatedMeal = meal;
          _isEstimating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not calculate nutrition: $e';
          _isEstimating = false;
        });
      }
    }
  }

  void _commitMeal() {
    if (_estimatedMeal != null) {
      widget.notifier.addMeal(_estimatedMeal!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.sparkles, color: auraTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'AI Natural Meal Logger',
                        style: AuraTypography.titleLarge,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Describe what you ate or drank in plain language. AURA will calculate macros automatically.',
                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // Meal Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AuraColors.borderSubtle),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: 2,
                  style: AuraTypography.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. 2 fried eggs, 2 slices buttered toast, large coffee with milk',
                    hintStyle: AuraTypography.bodyMedium.copyWith(color: AuraColors.textTertiary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Action button to estimate
              AuraButton(
                text: 'Calculate with AI',
                icon: LucideIcons.calculator,
                isLoading: _isEstimating,
                width: double.infinity,
                onPressed: () => _runAIEstimate(_inputCtrl.text),
              ),
              const SizedBox(height: 14),

              // Quick suggestion chips
              Text(
                'QUICK EXAMPLES',
                style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textTertiary, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickSuggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      _inputCtrl.text = suggestion;
                      _runAIEstimate(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: auraTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AuraColors.borderSubtle),
                      ),
                      child: Text(
                        suggestion,
                        style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: AuraTypography.bodySmall.copyWith(color: AuraColors.error)),
              ],

              // Estimated Card Preview
              if (_estimatedMeal != null) ...[
                const SizedBox(height: 18),
                AuraCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: auraTheme.energyAccent.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _estimatedMeal!.name,
                              style: AuraTypography.titleMedium.copyWith(fontSize: 15),
                            ),
                          ),
                          AuraStatBadge(
                            label: '${_estimatedMeal!.calories} kcal',
                            color: auraTheme.energyAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniNutrient('Protein', '${_estimatedMeal!.proteinG}g', auraTheme.proteinAccent),
                          _buildMiniNutrient('Carbs', '${_estimatedMeal!.carbsG}g', AuraColors.carbs),
                          _buildMiniNutrient('Fats', '${_estimatedMeal!.fatG}g', AuraColors.fat),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AuraButton(
                        text: 'Log to Today\'s Nutrition',
                        width: double.infinity,
                        onPressed: _commitMeal,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniNutrient(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AuraTypography.sectionHeader.copyWith(color: color, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AuraTypography.labelBold.copyWith(fontSize: 13)),
      ],
    );
  }
}
