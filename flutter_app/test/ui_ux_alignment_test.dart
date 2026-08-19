import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/theme/theme.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AURA UI/UX Design Direction Alignment Tests', () {
    test('Canonical color tokens are strictly defined', () {
      expect(AuraColors.background, const Color(0xFF0B0C0D));
      expect(AuraColors.surface1, const Color(0xFF121416));
      expect(AuraColors.surface2, const Color(0xFF191C1F));
      expect(AuraColors.actionGreen, const Color(0xFF39E6A3));
      expect(AuraColors.auraPurple, const Color(0xFFA779FF));
      expect(AuraColors.textPrimary, const Color(0xFFF5F6F4));
      expect(AuraColors.textSecondary, const Color(0xFF929797));
    });

    test('All CoachSoul palettes provide distinct primary and secondary colors', () {
      final supporter = AuraColors.getSoulPalette(CoachSoul.supporter);
      final pro = AuraColors.getSoulPalette(CoachSoul.pro);
      final teacher = AuraColors.getSoulPalette(CoachSoul.teacher);

      expect(supporter.primary, const Color(0xFFA779FF));
      expect(pro.primary, const Color(0xFF00E5FF));
      expect(teacher.primary, const Color(0xFF00BFA5));

      expect(supporter.scaffoldBackground, const Color(0xFF0B0C0D));
      expect(pro.scaffoldBackground, const Color(0xFF0B0C0D));
      expect(teacher.scaffoldBackground, const Color(0xFF0B0C0D));
    });

    test('AuraThemeExtension from CoachSoul correctly embeds palette tokens', () {
      final ext = AuraThemeExtension.fromSoul(CoachSoul.supporter);

      expect(ext.soul, CoachSoul.supporter);
      expect(ext.primary, const Color(0xFFA779FF));
      expect(ext.scaffoldBackground, const Color(0xFF0B0C0D));
    });
  });

  group('Workout History & Tracking State Tests', () {
    test('Differentiates completed workout vs skipped workout and resolves day status', () {
      final state = TransformationEngineState(
        profile: UserProfile(
          name: 'Ashutosh',
          age: 26,
          gender: 'male',
          heightCm: 175,
          weightKg: 72,
          targetWeightKg: 70,
          goal: GoalType.recomp,
          targetPhysique: 'Athletic',
          daysPerWeek: 5,
          experienceLevel: ExperienceLevel.intermediate,
          coachSoul: CoachSoul.pro,
          dietaryPreference: 'vegetarian',
        ),
        workout: DailyWorkout(
          id: 'w_today',
          date: '2026-08-20',
          title: 'Today Workout',
          focusArea: 'Full Body',
          estimatedDurationMin: 45,
          status: WorkoutStatus.scheduled,
          exercises: [],
        ),
        nutrition: DailyNutrition(
          date: '2026-08-20',
          targetCalories: 2000,
          targetProteinG: 150,
          targetCarbsG: 200,
          targetFatG: 60,
          waterMl: 1000,
          targetWaterMl: 3000,
          meals: [],
        ),
        recovery: RecoveryCheckIn(
          date: '2026-08-20',
          sleepHours: 7.5,
          sleepQuality: 80,
          muscleSoreness: 20,
          energyLevel: 85,
          stressLevel: 25,
          recoveryScore: 88,
          status: 'Optimal',
        ),
        chatMessages: [],
        progressHistory: [
          // Mon: Skipped
          ProgressEntry(
            date: '2026-08-17',
            weightKg: 72,
            notes: 'Marked skipped',
            workoutStatus: WorkoutStatus.skipped,
          ),
          // Tue: Skipped (Legacy notes fallback)
          ProgressEntry(
            date: '2026-08-18',
            weightKg: 72,
            notes: 'Marked skipped',
          ),
          // Wed: Completed Workout
          ProgressEntry(
            date: '2026-08-19',
            weightKg: 72,
            notes: 'Workout: Full Body Recomp Strength Session (5 exercises)',
            workoutStatus: WorkoutStatus.completed,
          ),
        ],
        recentWorkouts: {
          '2026-08-19': DailyWorkout(
            id: 'w_wed',
            date: '2026-08-19',
            title: 'Full Body Recomp Strength Session',
            focusArea: 'Full Body',
            estimatedDurationMin: 45,
            status: WorkoutStatus.completed,
            exercises: [
              Exercise(
                id: 'ex_1',
                name: 'Barbell Back Squat',
                targetMuscle: 'Legs',
                equipmentRequired: 'barbell',
                sets: [
                  ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 25.0, completed: true),
                  ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 30.0, completed: true),
                ],
              ),
            ],
          ),
        },
      );

      // Mon (2026-08-17): Skipped session
      expect(state.isProgressTrackedForDate('2026-08-17'), isTrue);
      expect(state.isWorkoutCompletedForDate('2026-08-17'), isFalse);
      expect(state.isWorkoutSkippedForDate('2026-08-17'), isTrue);

      // Tue (2026-08-18): Skipped session via fallback
      expect(state.isProgressTrackedForDate('2026-08-18'), isTrue);
      expect(state.isWorkoutCompletedForDate('2026-08-18'), isFalse);
      expect(state.isWorkoutSkippedForDate('2026-08-18'), isTrue);

      // Wed (2026-08-19): Completed workout session
      expect(state.isProgressTrackedForDate('2026-08-19'), isTrue);
      expect(state.isWorkoutCompletedForDate('2026-08-19'), isTrue);
      expect(state.isWorkoutSkippedForDate('2026-08-19'), isFalse);

      final wedWorkout = state.getWorkoutForDate('2026-08-19');
      expect(wedWorkout, isNotNull);
      expect(wedWorkout!.title, 'Full Body Recomp Strength Session');
      expect(wedWorkout.exercises.first.name, 'Barbell Back Squat');
      expect(wedWorkout.exercises.first.sets.length, 2);
    });

    test('Goal Recalibration updates profile, calories, and protein targets appropriately', () {
      final baseProfile = UserProfile(
        name: 'Test Athlete',
        age: 26,
        gender: 'male',
        heightCm: 178,
        weightKg: 74,
        targetWeightKg: 70,
        goal: GoalType.recomp,
        targetPhysique: 'Athletic V-Taper',
        daysPerWeek: 4,
        dietaryPreference: 'nonVeg',
        coachSoul: CoachSoul.supporter,
      );

      final fatLossProfile = baseProfile.copyWith(
        goal: GoalType.fatLoss,
        targetPhysique: 'Lean & Defined',
        targetWeightKg: 68.0,
        daysPerWeek: 4,
      );

      expect(fatLossProfile.goal, GoalType.fatLoss);
      expect(fatLossProfile.goal.displayName, 'Burn Fat & Get Lean');
      expect(fatLossProfile.targetPhysique, 'Lean & Defined');
      expect(fatLossProfile.targetWeightKg, 68.0);

      final muscleGainProfile = baseProfile.copyWith(
        goal: GoalType.muscleGain,
        targetPhysique: 'Maximum Mass',
        targetWeightKg: 80.0,
        daysPerWeek: 5,
      );

      expect(muscleGainProfile.goal, GoalType.muscleGain);
      expect(muscleGainProfile.goal.displayName, 'Build Muscle & Size');
      expect(muscleGainProfile.targetPhysique, 'Maximum Mass');
      expect(muscleGainProfile.daysPerWeek, 5);
    });
  });
}
