import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

@freezed
abstract class ExerciseSet with _$ExerciseSet {
  const ExerciseSet._();

  const factory ExerciseSet({
    required int setNumber,
    required int targetReps,
    int? actualReps,
    required double targetWeightKg,
    double? actualWeightKg,
    @Default(false) bool completed,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);
}

@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    required String targetMuscle,
    required String equipmentRequired,
    required List<ExerciseSet> sets,
    String? notes,
    String? instructions,
    String? videoUrl,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}

enum WorkoutStatus {
  @JsonValue('scheduled') scheduled,
  @JsonValue('completed') completed,
  @JsonValue('skipped') skipped,
  @JsonValue('adapted') adapted,
}

@freezed
abstract class DailyWorkout with _$DailyWorkout {
  const DailyWorkout._();

  const factory DailyWorkout({
    required String id,
    required String date,
    required String title,
    required String focusArea,
    required int estimatedDurationMin,
    required List<Exercise> exercises,
    @Default(WorkoutStatus.scheduled) WorkoutStatus status,
    String? adaptationNote,
  }) = _DailyWorkout;

  factory DailyWorkout.fromJson(Map<String, dynamic> json) => _$DailyWorkoutFromJson(json);
}
