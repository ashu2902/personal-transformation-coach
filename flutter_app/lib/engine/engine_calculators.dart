import '../models/models.dart';

class EngineCalculators {
  /// Mifflin-St Jeor Equation for BMR calculation
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    bool isMale = true,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears);
    return isMale ? base + 5 : base - 161;
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) based on activity for everyday active adults
  static double calculateTDEE({
    required double bmr,
    required int daysPerWeek,
  }) {
    double activityMultiplier = 1.2; // Desk job / low non-exercise activity
    if (daysPerWeek >= 5) {
      activityMultiplier = 1.38; // 5+ workout days
    } else if (daysPerWeek >= 3) {
      activityMultiplier = 1.30; // 3-4 workout days
    } else if (daysPerWeek >= 1) {
      activityMultiplier = 1.25; // 1-2 workout days
    }
    return bmr * activityMultiplier;
  }

  /// Generates initial macro targets based on goal and baseline stats
  static DailyNutrition calculateInitialNutrition({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required GoalType goal,
    required int daysPerWeek,
    double? targetWeightKg,
  }) {
    final bmr = calculateBMR(weightKg: weightKg, heightCm: heightCm, ageYears: ageYears);
    final tdee = calculateTDEE(bmr: bmr, daysPerWeek: daysPerWeek);

    int targetCalories = tdee.round();
    if (goal == GoalType.fatLoss || goal == GoalType.recomp) {
      targetCalories = (tdee * 0.80).round(); // ~20% healthy fat loss deficit
    } else if (goal == GoalType.muscleGain) {
      targetCalories = (tdee * 1.08).round(); // ~8% lean surplus
    }

    // Realistic everyday human protein: ~1.5g-1.6g per kg of target weight (or body weight)
    double refWeight = (goal == GoalType.fatLoss && targetWeightKg != null && targetWeightKg > 0)
        ? targetWeightKg
        : weightKg;
    double proteinMultiplier = (goal == GoalType.muscleGain) ? 1.7 : 1.5;
    final targetProteinG = (refWeight * proteinMultiplier).round().clamp(80, 160);

    // Fat: ~25% of calories (9 kcal/g)
    final targetFatG = ((targetCalories * 0.25) / 9).round();
    // Carbs: Remaining calories (4 kcal/g)
    final proteinCal = targetProteinG * 4;
    final fatCal = targetFatG * 9;
    final remainingCal = (targetCalories - proteinCal - fatCal).clamp(0, 5000);
    final targetCarbsG = (remainingCal / 4).round();

    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    return DailyNutrition(
      date: todayStr,
      targetCalories: targetCalories,
      targetProteinG: targetProteinG,
      targetCarbsG: targetCarbsG,
      targetFatG: targetFatG,
      waterMl: 0,
      targetWaterMl: (weightKg * 35).round().clamp(2500, 4500),
      meals: [],
    );
  }

  /// Generates initial workout based on user equipment and split preference
  static DailyWorkout generateWorkoutForSplit({
    required GoalType goal,
    required List<EquipmentType> availableEquipment,
    required int daysPerWeek,
  }) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final hasBarbell = availableEquipment.contains(EquipmentType.barbell);
    final hasDumbbells = availableEquipment.contains(EquipmentType.dumbbells);
    final hasCables = availableEquipment.contains(EquipmentType.cables);

    List<Exercise> exercises = [];

    if (hasDumbbells || hasBarbell) {
      exercises.add(Exercise(
        id: 'ex_push_1',
        name: hasDumbbells ? 'Incline Dumbbell Press' : 'Incline Barbell Press',
        targetMuscle: 'Upper Chest',
        equipmentRequired: hasDumbbells ? EquipmentType.dumbbells : EquipmentType.barbell,
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 24),
          ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 24),
          ExerciseSet(setNumber: 3, targetReps: 8, targetWeightKg: 26),
        ],
      ));

      exercises.add(Exercise(
        id: 'ex_push_2',
        name: hasBarbell ? 'Barbell Bench Press' : 'Dumbbell Flat Press',
        targetMuscle: 'Mid Chest',
        equipmentRequired: hasBarbell ? EquipmentType.barbell : EquipmentType.dumbbells,
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 8, targetWeightKg: 60),
          ExerciseSet(setNumber: 2, targetReps: 8, targetWeightKg: 60),
          ExerciseSet(setNumber: 3, targetReps: 6, targetWeightKg: 65),
        ],
      ));
    }

    if (hasCables || hasDumbbells) {
      exercises.add(Exercise(
        id: 'ex_push_3',
        name: hasCables ? 'Cable Tricep Pushdown' : 'Dumbbell Overhead Extension',
        targetMuscle: 'Triceps',
        equipmentRequired: hasCables ? EquipmentType.cables : EquipmentType.dumbbells,
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 20),
          ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 20),
          ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 22.5),
        ],
      ));
    } else {
      exercises.add(Exercise(
        id: 'ex_push_body',
        name: 'Bodyweight Push-Ups',
        targetMuscle: 'Chest & Triceps',
        equipmentRequired: EquipmentType.bodyweight,
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 15, targetWeightKg: 0),
          ExerciseSet(setNumber: 2, targetReps: 15, targetWeightKg: 0),
          ExerciseSet(setNumber: 3, targetReps: 12, targetWeightKg: 0),
        ],
      ));
    }

    return DailyWorkout(
      id: 'w_init_${DateTime.now().millisecondsSinceEpoch}',
      date: todayStr,
      title: 'Hypertrophy: Upper Push & Arms',
      focusArea: 'Chest, Shoulders & Triceps',
      estimatedDurationMin: 45,
      status: WorkoutStatus.scheduled,
      exercises: exercises,
    );
  }
}
