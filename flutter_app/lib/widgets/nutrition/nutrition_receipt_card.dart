import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/nutrition.dart';

class NutritionReceiptCard extends StatelessWidget {
  final List<MealItem> meals;
  final int? totalWaterMl;
  final VoidCallback? onEditPressed;

  const NutritionReceiptCard({
    super.key,
    required this.meals,
    this.totalWaterMl,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold<int>(0, (sum, m) => sum + m.calories);
    final totalProtein = meals.fold<int>(0, (sum, m) => sum + m.proteinG);
    final totalCarbs = meals.fold<int>(0, (sum, m) => sum + m.carbsG);
    final totalFat = meals.fold<int>(0, (sum, m) => sum + m.fatG);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFA3).withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.receipt, color: Color(0xFF00FFA3), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NUTRITION RECEIPT',
                    style: GoogleFonts.syne(
                      color: const Color(0xFF00FFA3),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (onEditPressed != null)
                GestureDetector(
                  onTap: onEditPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.edit3, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Meal items list
          ...meals.map((meal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meal.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal • ${meal.proteinG}g P',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (totalWaterMl != null && totalWaterMl! > 0) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.droplets, color: Color(0xFF60A5FA), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Hydration Logged',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF60A5FA), fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '+${totalWaterMl}ml',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // Total Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Logged',
                style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                children: [
                  _buildMacroTag('$totalCalories kcal', const Color(0xFF00FFA3)),
                  const SizedBox(width: 6),
                  _buildMacroTag('${totalProtein}g P', const Color(0xFF60A5FA)),
                  const SizedBox(width: 6),
                  _buildMacroTag('${totalCarbs}g C', const Color(0xFFFBBF24)),
                  const SizedBox(width: 6),
                  _buildMacroTag('${totalFat}g F', const Color(0xFFF87171)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
