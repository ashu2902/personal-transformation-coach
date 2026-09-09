import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout.dart';

part 'weekly_plan.freezed.dart';
part 'weekly_plan.g.dart';

class PlannedExercise {
  final String name;
  final ExerciseTrackingType trackingType;
  final int targetSets;
  final int targetReps;
  final double targetWeightKg;
  final int targetDurationSeconds;
  final String? notes;

  const PlannedExercise({
    required this.name,
    this.trackingType = ExerciseTrackingType.reps,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeightKg = 0.0,
    this.targetDurationSeconds = 0,
    this.notes,
  });

  factory PlannedExercise.fromJson(Map<String, dynamic> json) => PlannedExercise(
        name: json['name']?.toString() ?? 'Exercise',
        trackingType: ExerciseTrackingType.values.firstWhere(
          (e) => e.name == json['trackingType'],
          orElse: () => ExerciseTrackingType.reps,
        ),
        targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
        targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
        targetDurationSeconds: (json['targetDurationSeconds'] as num?)?.toInt() ?? 0,
        notes: json['notes']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'trackingType': trackingType.name,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'targetWeightKg': targetWeightKg,
        'targetDurationSeconds': targetDurationSeconds,
        if (notes != null) 'notes': notes,
      };
}

@freezed
abstract class WeeklyDayPlan with _$WeeklyDayPlan {
  const WeeklyDayPlan._();

  const factory WeeklyDayPlan({
    required String dayName,
    required String date,
    required String title,
    required String focusArea,
    @Default(false) bool isRestDay,
    @Default([]) List<String> exerciseNames,
    @Default([]) List<PlannedExercise> plannedExercises,
    String? nutritionFocus,
  }) = _WeeklyDayPlan;

  factory WeeklyDayPlan.fromJson(Map<String, dynamic> json) => _$WeeklyDayPlanFromJson(json);
}

@freezed
abstract class WeeklyPlan with _$WeeklyPlan {
  const WeeklyPlan._();

  const factory WeeklyPlan({
    required String weekId,
    required String startDate,
    required String endDate,
    required String overview,
    String? coachNote,
    required List<WeeklyDayPlan> days,
    required String createdAt,
  }) = _WeeklyPlan;

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) => _$WeeklyPlanFromJson(json);
}
