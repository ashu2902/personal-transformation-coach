import '../models/models.dart';

class TodayFocus {
  final String primaryActionTitle;
  final String primaryActionDescription;
  final String category; // 'TRAIN', 'EAT', 'RECOVER', 'ADAPT'
  final bool isDeloadAdvised;

  TodayFocus({
    required this.primaryActionTitle,
    required this.primaryActionDescription,
    required this.category,
    this.isDeloadAdvised = false,
  });
}

class TransformationOrchestrator {
  /// Answers: "Given everything I know about you and what happened recently, what should you do today?"
  static TodayFocus synthesizeTodayFocus({
    required UserProfile profile,
    required DailyWorkout workout,
    required DailyNutrition nutrition,
    required RecoveryCheckIn recovery,
    required List<ProgressEntry> history,
  }) {
    final isWorkoutDone = workout.status == WorkoutStatus.completed;
    final totalProt = nutrition.meals.fold<num>(0, (sum, m) => sum + m.proteinG);
    final remainingProt = (nutrition.targetProteinG - totalProt).clamp(0, 999);

    if (recovery.recoveryScore < 50) {
      return TodayFocus(
        primaryActionTitle: 'Focus on Systemic Recovery & Deload',
        primaryActionDescription: 'Readiness is low (${recovery.recoveryScore}%). Execute today\'s scaled Deload session or take an active recovery walk.',
        category: 'RECOVER',
        isDeloadAdvised: true,
      );
    }

    if (!isWorkoutDone) {
      return TodayFocus(
        primaryActionTitle: 'Execute ${workout.title}',
        primaryActionDescription: 'Complete your ${workout.estimatedDurationMin}-minute session targeting ${workout.focusArea}. Aim for ${nutrition.targetProteinG}g protein.',
        category: 'TRAIN',
      );
    }

    if (remainingProt > 20) {
      return TodayFocus(
        primaryActionTitle: 'Hit Remaining ${remainingProt}g Protein Target',
        primaryActionDescription: 'Workout completed! Fuel muscle recovery by hitting your remaining protein target before sleep.',
        category: 'EAT',
      );
    }

    return TodayFocus(
      primaryActionTitle: 'Targets Complete! Optimize Nighttime Recovery',
      primaryActionDescription: 'Workout & nutrition targets hit for today. Hydrate with 500ml water and aim for 8 hours of sleep.',
      category: 'RECOVER',
    );
  }
}
