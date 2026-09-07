import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout.dart';

part 'recovery.freezed.dart';
part 'recovery.g.dart';

@freezed
abstract class RecoveryCheckIn with _$RecoveryCheckIn {
  const RecoveryCheckIn._();

  const factory RecoveryCheckIn({
    required String date,
    required double sleepHours,
    required int sleepQuality,
    required int muscleSoreness,
    required int energyLevel,
    required int stressLevel,
    required int recoveryScore,
    required String status,
  }) = _RecoveryCheckIn;

  factory RecoveryCheckIn.fromJson(Map<String, dynamic> json) => _$RecoveryCheckInFromJson(json);
}

@freezed
abstract class ProgressEntry with _$ProgressEntry {
  const ProgressEntry._();

  const factory ProgressEntry({
    required String date,
    required double weightKg,
    double? bodyFatPercent,
    double? waistCm,
    String? notes,
    WorkoutStatus? workoutStatus,
  }) = _ProgressEntry;

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => _$ProgressEntryFromJson(json);
}
