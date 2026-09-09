// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeducedKnowledge _$DeducedKnowledgeFromJson(Map<String, dynamic> json) =>
    _DeducedKnowledge(
      activityLevel: json['activityLevel'] as String?,
      sessionDurationMin: (json['sessionDurationMin'] as num?)?.toInt(),
      preferredTrainingDays: (json['preferredTrainingDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredTrainingStyle: json['preferredTrainingStyle'] as String?,
      cardioPreference: json['cardioPreference'] as String?,
      activeInjuries: (json['activeInjuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      foodAllergies: (json['foodAllergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedExercises: (json['dislikedExercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredProteinSources:
          (json['preferredProteinSources'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      sleepPatternAvg: (json['sleepPatternAvg'] as num?)?.toDouble(),
      stressBaseline: (json['stressBaseline'] as num?)?.toInt(),
      personalNotes: (json['personalNotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastUpdated: json['lastUpdated'] as String?,
    );

Map<String, dynamic> _$DeducedKnowledgeToJson(_DeducedKnowledge instance) =>
    <String, dynamic>{
      'activityLevel': instance.activityLevel,
      'sessionDurationMin': instance.sessionDurationMin,
      'preferredTrainingDays': instance.preferredTrainingDays,
      'preferredTrainingStyle': instance.preferredTrainingStyle,
      'cardioPreference': instance.cardioPreference,
      'activeInjuries': instance.activeInjuries,
      'foodAllergies': instance.foodAllergies,
      'dislikedExercises': instance.dislikedExercises,
      'preferredProteinSources': instance.preferredProteinSources,
      'sleepPatternAvg': instance.sleepPatternAvg,
      'stressBaseline': instance.stressBaseline,
      'personalNotes': instance.personalNotes,
      'lastUpdated': instance.lastUpdated,
    };

_RollingSummary _$RollingSummaryFromJson(Map<String, dynamic> json) =>
    _RollingSummary(
      periodDays: (json['periodDays'] as num?)?.toInt() ?? 7,
      workoutComplianceRate:
          (json['workoutComplianceRate'] as num?)?.toDouble() ?? 0.0,
      workoutsCompleted: (json['workoutsCompleted'] as num?)?.toInt() ?? 0,
      workoutsSkipped: (json['workoutsSkipped'] as num?)?.toInt() ?? 0,
      avgSessionDurationMin:
          (json['avgSessionDurationMin'] as num?)?.toDouble(),
      recentWorkouts: (json['recentWorkouts'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      nutritionAvg: json['nutritionAvg'] as Map<String, dynamic>? ?? const {},
      recoveryAvg: json['recoveryAvg'] as Map<String, dynamic>? ?? const {},
      weightTrend: (json['weightTrend'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      lastUpdated: json['lastUpdated'] as String?,
    );

Map<String, dynamic> _$RollingSummaryToJson(_RollingSummary instance) =>
    <String, dynamic>{
      'periodDays': instance.periodDays,
      'workoutComplianceRate': instance.workoutComplianceRate,
      'workoutsCompleted': instance.workoutsCompleted,
      'workoutsSkipped': instance.workoutsSkipped,
      'avgSessionDurationMin': instance.avgSessionDurationMin,
      'recentWorkouts': instance.recentWorkouts,
      'nutritionAvg': instance.nutritionAvg,
      'recoveryAvg': instance.recoveryAvg,
      'weightTrend': instance.weightTrend,
      'lastUpdated': instance.lastUpdated,
    };

_MasterContext _$MasterContextFromJson(Map<String, dynamic> json) =>
    _MasterContext(
      deduced: json['deduced'] == null
          ? const DeducedKnowledge()
          : DeducedKnowledge.fromJson(json['deduced'] as Map<String, dynamic>),
      rollingSummary: json['rollingSummary'] == null
          ? const RollingSummary()
          : RollingSummary.fromJson(
              json['rollingSummary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MasterContextToJson(_MasterContext instance) =>
    <String, dynamic>{
      'deduced': instance.deduced,
      'rollingSummary': instance.rollingSummary,
    };
