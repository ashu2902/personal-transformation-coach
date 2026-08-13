import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'workout_screen.dart';
import 'nutrition_screen.dart';

class PlanLogScreen extends StatefulWidget {
  final int initialSubIndex;
  const PlanLogScreen({super.key, this.initialSubIndex = 0});

  @override
  State<PlanLogScreen> createState() => _PlanLogScreenState();
}

class _PlanLogScreenState extends State<PlanLogScreen> {
  late int _selectedSegment;

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSubIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Segmented Switcher
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF141923),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2638)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSegment = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSegment == 0 ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          size: 16,
                          color: _selectedSegment == 0 ? Colors.black : const Color(0xFFA1A1AA),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Train Session',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedSegment == 0 ? Colors.black : const Color(0xFFA1A1AA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSegment = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSegment == 1 ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.apple,
                          size: 16,
                          color: _selectedSegment == 1 ? Colors.black : const Color(0xFFA1A1AA),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nutrition & Fuel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedSegment == 1 ? Colors.black : const Color(0xFFA1A1AA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedSegment),
              child: _selectedSegment == 0 ? const WorkoutScreen() : const NutritionScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
