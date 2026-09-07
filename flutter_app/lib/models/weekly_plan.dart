import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_plan.freezed.dart';
part 'weekly_plan.g.dart';

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
