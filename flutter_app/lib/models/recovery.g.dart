// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecoveryCheckIn _$RecoveryCheckInFromJson(Map<String, dynamic> json) =>
    _RecoveryCheckIn(
      date: json['date'] as String,
      sleepHours: (json['sleepHours'] as num).toDouble(),
      sleepQuality: (json['sleepQuality'] as num).toInt(),
      muscleSoreness: (json['muscleSoreness'] as num).toInt(),
      energyLevel: (json['energyLevel'] as num).toInt(),
      stressLevel: (json['stressLevel'] as num).toInt(),
      recoveryScore: (json['recoveryScore'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$RecoveryCheckInToJson(_RecoveryCheckIn instance) =>
    <String, dynamic>{
      'date': instance.date,
      'sleepHours': instance.sleepHours,
      'sleepQuality': instance.sleepQuality,
      'muscleSoreness': instance.muscleSoreness,
      'energyLevel': instance.energyLevel,
      'stressLevel': instance.stressLevel,
      'recoveryScore': instance.recoveryScore,
      'status': instance.status,
    };

_ProgressEntry _$ProgressEntryFromJson(Map<String, dynamic> json) =>
    _ProgressEntry(
      date: json['date'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      workoutStatus:
          $enumDecodeNullable(_$WorkoutStatusEnumMap, json['workoutStatus']),
    );

Map<String, dynamic> _$ProgressEntryToJson(_ProgressEntry instance) =>
    <String, dynamic>{
      'date': instance.date,
      'weightKg': instance.weightKg,
      'bodyFatPercent': instance.bodyFatPercent,
      'waistCm': instance.waistCm,
      'notes': instance.notes,
      'workoutStatus': _$WorkoutStatusEnumMap[instance.workoutStatus],
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.scheduled: 'scheduled',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.skipped: 'skipped',
  WorkoutStatus.adapted: 'adapted',
};
