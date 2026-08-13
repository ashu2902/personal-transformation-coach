import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../engine/food_database.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final notifier = ref.read(transformationEngineProvider.notifier);
        final nutrition = state.nutrition;

        final totalCal = nutrition.meals.fold(0, (sum, m) => sum + m.calories);
        final totalProt = nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
        final totalCarbs = nutrition.meals.fold(0, (sum, m) => sum + m.carbsG);
        final totalFat = nutrition.meals.fold(0, (sum, m) => sum + m.fatG);

        final calPercent =
            (totalCal / nutrition.targetCalories).clamp(0.0, 1.0);
        final protPercent =
            (totalProt / nutrition.targetProteinG).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Macro Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2638)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ENERGY INTAKE',
                                style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text('$totalCal / ${nutrition.targetCalories} kcal',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('PROTEIN TARGET',
                                style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text('$totalProt / ${nutrition.targetProteinG} g',
                                style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
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
                        backgroundColor: const Color(0xFF1E2638),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF10B981)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroPill(
                            'Protein',
                            '${totalProt}g / ${nutrition.targetProteinG}g',
                            protPercent,
                            const Color(0xFF10B981)),
                        _buildMacroPill(
                            'Carbs',
                            '${totalCarbs}g / ${nutrition.targetCarbsG}g',
                            (totalCarbs / nutrition.targetCarbsG)
                                .clamp(0.0, 1.0),
                            const Color(0xFF3B82F6)),
                        _buildMacroPill(
                            'Fats',
                            '${totalFat}g / ${nutrition.targetFatG}g',
                            (totalFat / nutrition.targetFatG).clamp(0.0, 1.0),
                            const Color(0xFFF59E0B)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hydration Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2638)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0x2006B6D4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.droplets,
                              color: Color(0xFF06B6D4), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('HYDRATION',
                                style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text(
                                '${nutrition.waterMl} / ${nutrition.targetWaterMl} ml',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF06B6D4),
                            side: const BorderSide(color: Color(0x6006B6D4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          onPressed: () => notifier.addWater(250),
                          child: const Text('+250 ml',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF06B6D4),
                            side: const BorderSide(color: Color(0x6006B6D4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          onPressed: () => notifier.addWater(500),
                          child: const Text('+500 ml',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Meal History & Quick Log Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('LOGGED MEALS',
                      style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  TextButton.icon(
                    onPressed: () => _showAddMealDialog(context, notifier),
                    icon: const Icon(LucideIcons.plusCircle,
                        size: 14, color: Color(0xFF10B981)),
                    label: const Text('Add Meal',
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...nutrition.meals.map((meal) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141923),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E2638)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'P: ${meal.proteinG}g  •  C: ${meal.carbsG}g  •  F: ${meal.fatG}g',
                            style: const TextStyle(
                                color: Color(0xFFA1A1AA), fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2638),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
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

  Widget _buildMacroPill(
      String label, String value, double percent, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  void _showAddMealDialog(
      BuildContext context, TransformationEngineNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141923),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const FoodSearchLoggerModal(),
    ).then((selectedMeal) {
      if (selectedMeal != null && selectedMeal is MealItem) {
        notifier.addMeal(selectedMeal);
      }
    });
  }
}

class FoodSearchLoggerModal extends StatefulWidget {
  const FoodSearchLoggerModal({super.key});

  @override
  State<FoodSearchLoggerModal> createState() => _FoodSearchLoggerModalState();
}

class _FoodSearchLoggerModalState extends State<FoodSearchLoggerModal> {
  final _searchCtrl = TextEditingController();
  final _portionCtrl = TextEditingController();
  FoodItemDefinition? _selectedFood;

  @override
  Widget build(BuildContext context) {
    final searchResults = FoodDatabase.search(_searchCtrl.text);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Food Library & Search',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                IconButton(
                  icon: const Icon(LucideIcons.x,
                      color: Color(0xFFA1A1AA), size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search chicken, oats, rice, eggs, salmon...',
                hintStyle:
                    const TextStyle(color: Color(0xFF71717A), fontSize: 12),
                prefixIcon: const Icon(LucideIcons.search,
                    color: Color(0xFF10B981), size: 16),
                filled: true,
                fillColor: const Color(0xFF0B0F17),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E2638))),
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: _selectedFood != null
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Portion Scaler Panel
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0F17),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_selectedFood!.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    IconButton(
                                      icon: const Icon(LucideIcons.rotateCcw,
                                          size: 14, color: Color(0xFFA1A1AA)),
                                      onPressed: () =>
                                          setState(() => _selectedFood = null),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _portionCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    labelText: 'Portion Weight (grams)',
                                    labelStyle: TextStyle(
                                        color: Color(0xFFA1A1AA), fontSize: 11),
                                    suffixText: 'g',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (_) {
                                    final grams =
                                        int.tryParse(_portionCtrl.text) ?? 100;
                                    final macros = _selectedFood!
                                        .calculateMacrosForWeight(grams);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text('${macros['calories']} kcal',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        Text('P: ${macros['proteinG']}g',
                                            style: const TextStyle(
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        Text('C: ${macros['carbsG']}g',
                                            style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        Text('F: ${macros['fatG']}g',
                                            style: const TextStyle(
                                                color: Color(0xFFF59E0B),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final grams =
                                    int.tryParse(_portionCtrl.text) ?? 100;
                                final macros = _selectedFood!
                                    .calculateMacrosForWeight(grams);
                                final meal = MealItem(
                                  name: '${_selectedFood!.name} (${grams}g)',
                                  calories: macros['calories']!,
                                  proteinG: macros['proteinG']!,
                                  carbsG: macros['carbsG']!,
                                  fatG: macros['fatG']!,
                                );
                                Navigator.pop(context, meal);
                              },
                              child: const Text('Log Meal to Fuel Targets',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (ctx, idx) {
                        final food = searchResults[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0F17),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E2638)),
                          ),
                          child: ListTile(
                            title: Text(food.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            subtitle: Text(
                                '${food.category} • ${food.caloriesPer100g} kcal / 100g (${food.proteinPer100g}g protein)',
                                style: const TextStyle(
                                    color: Color(0xFFA1A1AA), fontSize: 11)),
                            trailing: const Icon(LucideIcons.chevronRight,
                                size: 16, color: Color(0xFF10B981)),
                            onTap: () {
                              setState(() {
                                _selectedFood = food;
                                _portionCtrl.text =
                                    food.defaultServingG.toString();
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
