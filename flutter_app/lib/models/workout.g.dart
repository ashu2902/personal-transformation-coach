// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => _ExerciseSet(
      setNumber: (json['setNumber'] as num).toInt(),
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
      actualReps: (json['actualReps'] as num?)?.toInt(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
      actualWeightKg: (json['actualWeightKg'] as num?)?.toDouble(),
      targetDurationSeconds:
          (json['targetDurationSeconds'] as num?)?.toInt() ?? 0,
      actualDurationSeconds: (json['actualDurationSeconds'] as num?)?.toInt(),
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$ExerciseSetToJson(_ExerciseSet instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'targetReps': instance.targetReps,
      'actualReps': instance.actualReps,
      'targetWeightKg': instance.targetWeightKg,
      'actualWeightKg': instance.actualWeightKg,
      'targetDurationSeconds': instance.targetDurationSeconds,
      'actualDurationSeconds': instance.actualDurationSeconds,
      'completed': instance.completed,
    };

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      targetMuscle: json['targetMuscle'] as String,
      equipmentRequired: json['equipmentRequired'] as String,
      trackingType: $enumDecodeNullable(
              _$ExerciseTrackingTypeEnumMap, json['trackingType']) ??
          ExerciseTrackingType.reps,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      instructions: json['instructions'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetMuscle': instance.targetMuscle,
      'equipmentRequired': instance.equipmentRequired,
      'trackingType': _$ExerciseTrackingTypeEnumMap[instance.trackingType]!,
      'sets': instance.sets,
      'notes': instance.notes,
      'instructions': instance.instructions,
      'videoUrl': instance.videoUrl,
    };

const _$ExerciseTrackingTypeEnumMap = {
  ExerciseTrackingType.reps: 'reps',
  ExerciseTrackingType.duration: 'duration',
  ExerciseTrackingType.completion: 'completion',
};

_DailyWorkout _$DailyWorkoutFromJson(Map<String, dynamic> json) =>
    _DailyWorkout(
      id: json['id'] as String,
      date: json['date'] as String,
      title: json['title'] as String,
      focusArea: json['focusArea'] as String,
      estimatedDurationMin: (json['estimatedDurationMin'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
          WorkoutStatus.scheduled,
      adaptationNote: json['adaptationNote'] as String?,
    );

Map<String, dynamic> _$DailyWorkoutToJson(_DailyWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'title': instance.title,
      'focusArea': instance.focusArea,
      'estimatedDurationMin': instance.estimatedDurationMin,
      'exercises': instance.exercises,
      'status': _$WorkoutStatusEnumMap[instance.status]!,
      'adaptationNote': instance.adaptationNote,
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.scheduled: 'scheduled',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.skipped: 'skipped',
  WorkoutStatus.adapted: 'adapted',
};
