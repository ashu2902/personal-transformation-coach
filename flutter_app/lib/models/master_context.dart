import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_context.freezed.dart';
part 'master_context.g.dart';

@freezed
abstract class DeducedKnowledge with _$DeducedKnowledge {
  const DeducedKnowledge._();

  const factory DeducedKnowledge({
    String? activityLevel,
    int? sessionDurationMin,
    @Default([]) List<String> preferredTrainingDays,
    String? preferredTrainingStyle,
    String? cardioPreference,
    @Default([]) List<String> activeInjuries,
    @Default([]) List<String> foodAllergies,
    @Default([]) List<String> dislikedExercises,
    @Default([]) List<String> preferredProteinSources,
    double? sleepPatternAvg,
    int? stressBaseline,
    @Default([]) List<String> personalNotes,
    String? lastUpdated,
  }) = _DeducedKnowledge;

  factory DeducedKnowledge.fromJson(Map<String, dynamic> json) => _$DeducedKnowledgeFromJson(json);
}

@freezed
abstract class RollingSummary with _$RollingSummary {
  const RollingSummary._();

  const factory RollingSummary({
    @Default(7) int periodDays,
    @Default(0.0) double workoutComplianceRate,
    @Default(0) int workoutsCompleted,
    @Default(0) int workoutsSkipped,
    double? avgSessionDurationMin,
    @Default([]) List<Map<String, dynamic>> recentWorkouts,
    @Default({}) Map<String, dynamic> nutritionAvg,
    @Default({}) Map<String, dynamic> recoveryAvg,
    @Default([]) List<Map<String, dynamic>> weightTrend,
    String? lastUpdated,
  }) = _RollingSummary;

  factory RollingSummary.fromJson(Map<String, dynamic> json) => _$RollingSummaryFromJson(json);
}

@freezed
abstract class MasterContext with _$MasterContext {
  const MasterContext._();

  const factory MasterContext({
    @Default(DeducedKnowledge()) DeducedKnowledge deduced,
    @Default(RollingSummary()) RollingSummary rollingSummary,
  }) = _MasterContext;

  factory MasterContext.fromJson(Map<String, dynamic> json) => _$MasterContextFromJson(json);
}
