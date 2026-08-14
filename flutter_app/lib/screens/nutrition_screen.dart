import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final notifier = ref.read(transformationEngineProvider.notifier);
        final nutrition = state.nutrition;

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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141217),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
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
                              style: GoogleFonts.syne(
                                color: const Color(0xFFA1A1AA),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCal / $targetCal kcal',
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'PROTEIN TARGET',
                              style: GoogleFonts.syne(
                                color: const Color(0xFF00FFA3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalProt / ${targetProt}g',
                              style: GoogleFonts.syne(
                                color: const Color(0xFF00FFA3),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                        backgroundColor: Colors.white.withOpacity(0.06),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00FFA3)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroPill(
                          'Protein',
                          '${totalProt}g / ${targetProt}g',
                          protPercent,
                          const Color(0xFF00FFA3),
                        ),
                        _buildMacroPill(
                          'Carbs',
                          '${totalCarbs}g / ${targetCarbs}g',
                          (totalCarbs / targetCarbs).clamp(0.0, 1.0),
                          const Color(0xFF38BDF8),
                        ),
                        _buildMacroPill(
                          'Fats',
                          '${totalFat}g / ${targetFat}g',
                          (totalFat / targetFat).clamp(0.0, 1.0),
                          const Color(0xFFFBBF24),
                        ),
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
                  color: const Color(0xFF141217),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.droplets, color: Color(0xFF38BDF8), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HYDRATION',
                              style: GoogleFonts.syne(
                                color: const Color(0xFFA1A1AA),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${nutrition.waterMl} / ${nutrition.targetWaterMl > 0 ? nutrition.targetWaterMl : 3000} ml',
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            side: BorderSide(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onPressed: () => notifier.addWater(250),
                          child: const Text('+250 ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            side: BorderSide(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onPressed: () => notifier.addWater(500),
                          child: const Text('+500 ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                    style: GoogleFonts.syne(
                      color: const Color(0xFF00FFA3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFA3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    onPressed: () => _showAddAIMealDialog(context, notifier),
                    icon: const Icon(LucideIcons.sparkles, size: 14, color: Colors.black),
                    label: Text(
                      'Log Meal with AI',
                      style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (nutrition.meals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141217),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      Icon(LucideIcons.utensils, color: Colors.white.withOpacity(0.2), size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'No meals logged today yet',
                        style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "+ Log Meal with AI" to describe what you ate in natural language.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...nutrition.meals.map((meal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141217),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: GoogleFonts.syne(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Protein: ${meal.proteinG}g  •  Carbs: ${meal.carbsG}g  •  Fat: ${meal.fatG}g',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFA1A1AA),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FFA3).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00FFA3).withOpacity(0.2)),
                          ),
                          child: Text(
                            '${meal.calories} kcal',
                            style: GoogleFonts.syne(
                              color: const Color(0xFF00FFA3),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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

  Widget _buildMacroPill(String label, String value, double percent, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.syne(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  void _showAddAIMealDialog(BuildContext context, TransformationEngineNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E0E12),
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
                      const Icon(LucideIcons.sparkles, color: Color(0xFF00FFA3), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'AI Natural Meal Logger',
                        style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Color(0xFFA1A1AA), size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Describe what you ate or drank in plain language. AURA will calculate macros automatically.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
              ),
              const SizedBox(height: 14),

              // Meal Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141217),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 2 fried eggs, 2 slices buttered toast, large coffee with milk',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Action button to estimate
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFA3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isEstimating ? null : () => _runAIEstimate(_inputCtrl.text),
                  icon: _isEstimating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(LucideIcons.calculator, size: 16),
                  label: Text(
                    _isEstimating ? 'Analyzing with AI...' : 'Calculate with AI',
                    style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick suggestion chips
              Text(
                'QUICK EXAMPLES',
                style: GoogleFonts.syne(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
                        color: const Color(0xFF141217),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Text(
                        suggestion,
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 11),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],

              // Estimated Card Preview
              if (_estimatedMeal != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141217),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00FFA3).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _estimatedMeal!.name,
                              style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFA3).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_estimatedMeal!.calories} kcal',
                              style: GoogleFonts.syne(color: const Color(0xFF00FFA3), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniNutrient('Protein', '${_estimatedMeal!.proteinG}g', const Color(0xFF00FFA3)),
                          _buildMiniNutrient('Carbs', '${_estimatedMeal!.carbsG}g', const Color(0xFF38BDF8)),
                          _buildMiniNutrient('Fats', '${_estimatedMeal!.fatG}g', const Color(0xFFFBBF24)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FFA3),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _commitMeal,
                          child: Text(
                            'Log to Today\'s Nutrition',
                            style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
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
        Text(label, style: GoogleFonts.syne(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
