// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklyDayPlan _$WeeklyDayPlanFromJson(Map<String, dynamic> json) =>
    _WeeklyDayPlan(
      dayName: json['dayName'] as String,
      date: json['date'] as String,
      title: json['title'] as String,
      focusArea: json['focusArea'] as String,
      isRestDay: json['isRestDay'] as bool? ?? false,
      exerciseNames: (json['exerciseNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      plannedExercises: (json['plannedExercises'] as List<dynamic>?)
              ?.map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nutritionFocus: json['nutritionFocus'] as String?,
    );

Map<String, dynamic> _$WeeklyDayPlanToJson(_WeeklyDayPlan instance) =>
    <String, dynamic>{
      'dayName': instance.dayName,
      'date': instance.date,
      'title': instance.title,
      'focusArea': instance.focusArea,
      'isRestDay': instance.isRestDay,
      'exerciseNames': instance.exerciseNames,
      'plannedExercises': instance.plannedExercises,
      'nutritionFocus': instance.nutritionFocus,
    };

_WeeklyPlan _$WeeklyPlanFromJson(Map<String, dynamic> json) => _WeeklyPlan(
      weekId: json['weekId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      overview: json['overview'] as String,
      coachNote: json['coachNote'] as String?,
      days: (json['days'] as List<dynamic>)
          .map((e) => WeeklyDayPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$WeeklyPlanToJson(_WeeklyPlan instance) =>
    <String, dynamic>{
      'weekId': instance.weekId,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'overview': instance.overview,
      'coachNote': instance.coachNote,
      'days': instance.days,
      'createdAt': instance.createdAt,
    };
