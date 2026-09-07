// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EquipmentItem _$EquipmentItemFromJson(Map<String, dynamic> json) =>
    _EquipmentItem(
      name: json['name'] as String,
      category: json['category'] as String? ?? 'free_weight',
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$EquipmentItemToJson(_EquipmentItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'weightKg': instance.weightKg,
      'notes': instance.notes,
    };

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
      goal: $enumDecode(_$GoalTypeEnumMap, json['goal']),
      daysPerWeek: (json['daysPerWeek'] as num).toInt(),
      targetPhysique: json['targetPhysique'] as String,
      equipmentList: (json['equipmentList'] as List<dynamic>?)
              ?.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [EquipmentItem(name: 'Bodyweight', category: 'bodyweight')],
      experienceLevel: $enumDecodeNullable(
              _$ExperienceLevelEnumMap, json['experienceLevel']) ??
          ExperienceLevel.intermediate,
      benchPress1RMKg: (json['benchPress1RMKg'] as num?)?.toDouble(),
      squat1RMKg: (json['squat1RMKg'] as num?)?.toDouble(),
      deadlift1RMKg: (json['deadlift1RMKg'] as num?)?.toDouble(),
      activeInjuries: (json['activeInjuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedExercises: (json['dislikedExercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      personalNotes: (json['personalNotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      coachSoul: $enumDecodeNullable(_$CoachSoulEnumMap, json['coachSoul']) ??
          CoachSoul.supporter,
      dietaryPreference: json['dietaryPreference'] as String? ?? 'nonVeg',
      createdAtDateStr: json['createdAtDateStr'] as String?,
    );

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'targetWeightKg': instance.targetWeightKg,
      'goal': _$GoalTypeEnumMap[instance.goal]!,
      'daysPerWeek': instance.daysPerWeek,
      'targetPhysique': instance.targetPhysique,
      'equipmentList': instance.equipmentList.map((e) => e.toJson()).toList(),
      'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
      'benchPress1RMKg': instance.benchPress1RMKg,
      'squat1RMKg': instance.squat1RMKg,
      'deadlift1RMKg': instance.deadlift1RMKg,
      'activeInjuries': instance.activeInjuries,
      'dislikedExercises': instance.dislikedExercises,
      'personalNotes': instance.personalNotes,
      'coachSoul': _$CoachSoulEnumMap[instance.coachSoul]!,
      'dietaryPreference': instance.dietaryPreference,
      'createdAtDateStr': instance.createdAtDateStr,
    };

const _$GoalTypeEnumMap = {
  GoalType.fatLoss: 'fatLoss',
  GoalType.muscleGain: 'muscleGain',
  GoalType.recomp: 'recomp',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

const _$CoachSoulEnumMap = {
  CoachSoul.supporter: 'supporter',
  CoachSoul.pro: 'pro',
  CoachSoul.teacher: 'teacher',
};
