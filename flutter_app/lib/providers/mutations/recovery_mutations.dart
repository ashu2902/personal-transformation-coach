import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../transformation_state.dart';

/// Domain mutations for Recovery checks, sleep, soreness, and fatigue deload checks.
mixin RecoveryMutations on StateNotifier<TransformationEngineState> {
  void updateRecoveryCheckIn({
    required double sleepHours,
    required int sleepQuality,
    required int muscleSoreness,
    required int energyLevel,
    required int stressLevel,
  }) {
    final sleepScore = ((sleepHours / 8.0).clamp(0.0, 1.2)) * 10 * (sleepQuality / 10.0);
    final score = ((sleepScore * 3.5) + (energyLevel * 3.5) + ((10 - muscleSoreness) * 2.0) + ((10 - stressLevel) * 1.0)).round().clamp(20, 100);

    String statusText = 'Optimal Adaptation';
    if (score < 50) {
      statusText = 'High Fatigue (Deload Advised)';
    } else if (score < 70) {
      statusText = 'Moderate Readiness';
    }

    debugPrint('[AURA STATE] Recovery Check-in updated: Score $score% ($statusText)');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final updatedRecovery = RecoveryCheckIn(
      date: todayStr,
      sleepHours: sleepHours,
      sleepQuality: sleepQuality,
      muscleSoreness: muscleSoreness,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
      recoveryScore: score,
      status: statusText,
    );

    state = state.copyWith(recovery: updatedRecovery);
    saveRecoveryToRemote(todayStr, updatedRecovery);

    // If high fatigue, trigger automatic deload adaptation
    if (score < 50) {
      handleFatigueDeload(score);
    }
  }

  void updateSleep(double sleepHours) {
    updateRecoveryCheckIn(
      sleepHours: sleepHours,
      sleepQuality: state.recovery.sleepQuality,
      muscleSoreness: state.recovery.muscleSoreness,
      energyLevel: state.recovery.energyLevel,
      stressLevel: state.recovery.stressLevel,
    );
  }

  void updateSoreness(int soreness) {
    updateRecoveryCheckIn(
      sleepHours: state.recovery.sleepHours,
      sleepQuality: state.recovery.sleepQuality,
      muscleSoreness: soreness,
      energyLevel: state.recovery.energyLevel,
      stressLevel: state.recovery.stressLevel,
    );
  }

  /// Hook for remote persistence
  void saveRecoveryToRemote(String date, RecoveryCheckIn recovery);
  void handleFatigueDeload(int score);
}
