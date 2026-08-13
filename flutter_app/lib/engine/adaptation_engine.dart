import '../models/models.dart';

class AdaptationResult {
  final DailyNutrition nutrition;
  final DailyWorkout workout;
  final String? adaptationNotice;

  AdaptationResult({
    required this.nutrition,
    required this.workout,
    this.adaptationNotice,
  });
}

class AdaptationEngine {
  /// Evaluates recovery check-in and weight trends to apply deterministic adaptations
  static AdaptationResult evaluateAdaptation({
    required UserProfile profile,
    required DailyNutrition nutrition,
    required DailyWorkout workout,
    required RecoveryCheckIn recovery,
    required List<ProgressEntry> history,
  }) {
    DailyWorkout adaptedWorkout = workout;
    DailyNutrition adaptedNutrition = nutrition;
    String? notice;

    // 1. FATIGUE DELOAD ADAPTATION
    if (recovery.recoveryScore < 50 && workout.status != WorkoutStatus.adapted && workout.status != WorkoutStatus.completed) {
      final scaledExercises = workout.exercises.map((ex) {
        // Reduce set count by 33% (minimum 2 sets)
        final targetSetCount = (ex.sets.length * 0.67).ceil().clamp(2, ex.sets.length);
        final reducedSets = ex.sets.take(targetSetCount).map((s) {
          final reducedWeight = (s.targetWeightKg * 0.85).roundToDouble(); // 15% load reduction
          return s.copyWith(targetWeightKg: reducedWeight);
        }).toList();

        return ex.copyWith(
          sets: reducedSets,
          notes: 'Deload: 15% load & 33% volume reduction for systemic recovery',
        );
      }).toList();

      adaptedWorkout = workout.copyWith(
        title: '${workout.title} (Deload)',
        status: WorkoutStatus.adapted,
        adaptationNote: 'High systemic fatigue detected (Score: ${recovery.recoveryScore}%). Workout auto-scaled for active recovery.',
        exercises: scaledExercises,
      );
      notice = 'High fatigue detected (${recovery.recoveryScore}%). Workout auto-scaled to an active recovery deload.';
    }

    // 2. WEIGHT STALL NUTRITION ADAPTATION (14-day check)
    if (profile.goal == GoalType.fatLoss && history.length >= 14) {
      final recent14 = history.sublist(history.length - 14);
      final firstWeight = recent14.first.weightKg;
      final lastWeight = recent14.last.weightKg;
      final delta = (lastWeight - firstWeight).abs();

      if (delta < 0.2 && nutrition.targetCalories > 1500) {
        final newCalories = (nutrition.targetCalories - 150).clamp(1400, 4000);
        final newProtein = (profile.weightKg * 2.0).round();
        final newFat = ((newCalories * 0.25) / 9).round();
        final newCarbs = ((newCalories - (newProtein * 4) - (newFat * 9)) / 4).round();

        adaptedNutrition = nutrition.copyWith(
          targetCalories: newCalories,
          targetProteinG: newProtein,
          targetCarbsG: newCarbs,
          targetFatG: newFat,
        );

        notice = (notice != null)
            ? '$notice | Weight stalled over 14 days (-0.0 kg). Daily calories auto-adjusted by -150 kcal.'
            : 'Weight progress stalled over past 14 days. Daily target calories auto-adjusted by -150 kcal.';
      }
    }

    return AdaptationResult(
      nutrition: adaptedNutrition,
      workout: adaptedWorkout,
      adaptationNotice: notice,
    );
  }
}
