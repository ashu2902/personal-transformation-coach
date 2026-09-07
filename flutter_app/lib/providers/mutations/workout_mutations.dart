import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout.dart';
import '../../models/exercise_definition.dart';
import '../transformation_state.dart';

/// Domain mutations for Workout prescriptions, sets, completions, and micro-deviations.
mixin WorkoutMutations on StateNotifier<TransformationEngineState> {
  void updateExerciseSet(String exerciseId, int setIndex, bool completed) {
    debugPrint('[AURA STATE] Updating exercise set: $exerciseId (Set #${setIndex + 1} completed: $completed)');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      final updatedSets = List<ExerciseSet>.from(ex.sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(completed: completed);
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final anyCompleted = updatedExercises.any((ex) => ex.sets.any((s) => s.completed));
    final allCompleted = updatedExercises.every((ex) => ex.sets.every((s) => s.completed));

    WorkoutStatus newStatus = state.workout.status;
    if (allCompleted) {
      newStatus = WorkoutStatus.completed;
      debugPrint('[AURA STATE] Workout completed! All sets marked done.');
    } else if (anyCompleted && state.workout.status == WorkoutStatus.skipped) {
      newStatus = WorkoutStatus.scheduled;
    }

    final updatedWorkout = state.workout.copyWith(
      exercises: updatedExercises,
      status: newStatus,
    );
    state = state.copyWith(workout: updatedWorkout);

    saveWorkoutToRemote(updatedWorkout);
  }

  /// Workout Micro-Deviations (PRD Phase 3):
  /// Allows instant manual adjustment of target reps and weight without AI invocation.
  void updateSetTarget(
    String exerciseId,
    int setIndex, {
    int? targetReps,
    double? targetWeightKg,
    int? newReps,
    double? newWeightKg,
  }) {
    final finalReps = targetReps ?? newReps;
    final finalWeight = targetWeightKg ?? newWeightKg;
    debugPrint('[AURA STATE] Micro-Deviation: $exerciseId Set #${setIndex + 1} -> Reps: $finalReps, Weight: $finalWeight kg');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      final updatedSets = List<ExerciseSet>.from(ex.sets);
      final current = updatedSets[setIndex];
      updatedSets[setIndex] = current.copyWith(
        targetReps: finalReps ?? current.targetReps,
        targetWeightKg: finalWeight ?? current.targetWeightKg,
      );
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final updatedWorkout = state.workout.copyWith(exercises: updatedExercises);
    state = state.copyWith(workout: updatedWorkout);
    updateWorkoutFieldsToRemote({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
    });
  }

  void markAllExercisesCompleted() {
    debugPrint('[AURA STATE] Marking all workout exercises & sets completed in bulk');
    final updatedExercises = state.workout.exercises.map((ex) {
      final updatedSets = ex.sets.map((s) => s.copyWith(completed: true)).toList();
      return ex.copyWith(sets: updatedSets);
    }).toList();

    final updatedWorkout = state.workout.copyWith(
      exercises: updatedExercises,
      status: WorkoutStatus.completed,
    );
    state = state.copyWith(workout: updatedWorkout);
    saveWorkoutToRemote(updatedWorkout);
  }

  void substituteExercise(String exerciseId, ExerciseDefinition newDefinition) {
    debugPrint('[AURA STATE] Substituting exercise $exerciseId -> ${newDefinition.name}');
    final updatedExercises = state.workout.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      return ex.copyWith(
        name: newDefinition.name,
        targetMuscle: newDefinition.targetMuscle,
        equipmentRequired: newDefinition.equipment.name,
        notes: 'Substituted for ${ex.name}',
      );
    }).toList();

    final updatedWorkout = state.workout.copyWith(exercises: updatedExercises);
    state = state.copyWith(workout: updatedWorkout);
    updateWorkoutFieldsToRemote({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
    });
  }

  void updateWorkoutStatus(WorkoutStatus status) {
    debugPrint('[AURA STATE] Updating workout status: ${status.name}');
    final updatedWorkout = state.workout.copyWith(status: status);
    state = state.copyWith(workout: updatedWorkout);
    updateWorkoutFieldsToRemote({
      'status': status.name,
    });
  }

  /// Hook for remote persistence
  void saveWorkoutToRemote(DailyWorkout workout);

  void updateWorkoutFieldsToRemote(Map<String, dynamic> fields);
}
