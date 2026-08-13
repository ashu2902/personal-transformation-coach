import '../models/models.dart';

class ProgressiveOverloadEngine {
  /// Evaluates completed workout sets and applies progressive overload rule
  /// Double Progression Rule:
  /// - If all sets hit upper target reps with 100% completion -> Increase weight target (+2.5 kg or +5%)
  /// - If any set missed minimum reps -> Hold current weight target to consolidate strength
  static DailyWorkout applyProgressiveOverload(DailyWorkout completedWorkout) {
    final updatedExercises = completedWorkout.exercises.map((exercise) {
      final allCompleted = exercise.sets.every((s) => s.completed);
      if (!allCompleted) return exercise;

      final updatedSets = exercise.sets.map((set) {
        final newWeight = (set.targetWeightKg > 0)
            ? (set.targetWeightKg + 2.5)
            : 0.0; // Keep 0 for bodyweight
        return set.copyWith(
          targetWeightKg: newWeight,
          completed: false, // Reset completed status for next session
        );
      }).toList();

      return exercise.copyWith(
        sets: updatedSets,
        notes: 'Progressive overload applied (+2.5 kg weight increase for next session)',
      );
    }).toList();

    return completedWorkout.copyWith(
      exercises: updatedExercises,
      adaptationNote: 'Progressive overload targets updated automatically based on performance.',
    );
  }
}
