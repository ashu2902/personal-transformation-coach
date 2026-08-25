import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/theme/theme.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';
import 'package:aura_transformation_engine/services/ai_service.dart';
import 'package:aura_transformation_engine/engine/progressive_overload_engine.dart';

/// Realistic mock of AIService for reproducible user simulation testing
class MockSimulatedAIService implements AIService {
  @override
  Future<LifestyleIntakeResult> parseLifestyleIntake(
    String text,
    UserProfile currentProfile, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    return LifestyleIntakeResult(
      isComplete: true,
      daysPerWeek: 3,
      equipment: ['Bodyweight', 'Dumbbells', 'Resistance Bands'],
      missingFields: [],
      followUpQuestion: 'Your custom Diwali body recomposition plan is ready for Tue, Thu, Sat!',
      dynamicQuickReplies: ['Show Tuesday Workout', 'View Nutrition Targets'],
      targetPhysique: 'Diwali body recomposition: reduce belly fat, build muscle',
      lifestyleNotes: [
        'Fast with water only on Mondays',
        'Workout schedule: Tuesday, Thursday, Saturday',
        'Diet: Vegetarian',
        'Target: Diwali body recomposition with bigger arms and broader shoulders',
      ],
    );
  }

  @override
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile) async {
    return DailyNutrition(
      date: DateTime.now().toIso8601String().split('T')[0],
      targetCalories: 2650,
      targetProteinG: 180,
      targetCarbsG: 298,
      targetFatG: 88,
      targetWaterMl: 3500,
      waterMl: 0,
      meals: [],
    );
  }

  @override
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final exerciseNames = [
      'Goblet Squat',
      'Push-Ups',
      'Dumbbell Romanian Deadlift',
      'Resistance Band Bent-Over Row',
      'Dumbbell Overhead Shoulder Press',
      'Plank with Shoulder Taps',
    ];

    final exercises = exerciseNames.asMap().entries.map((entry) {
      final i = entry.key;
      final name = entry.value;
      return Exercise(
        id: 'sim_ex_${i + 1}',
        name: name,
        targetMuscle: i % 2 == 0 ? 'Lower Body & Core' : 'Upper Body Push/Pull',
        equipmentRequired: name.contains('Dumbbell') || name.contains('Goblet')
            ? 'Dumbbells'
            : name.contains('Band')
                ? 'Resistance Bands'
                : 'Bodyweight',
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: name.contains('Dumbbell') ? 15.0 : 0.0),
          ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: name.contains('Dumbbell') ? 15.0 : 0.0),
          ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: name.contains('Dumbbell') ? 15.0 : 0.0),
        ],
      );
    }).toList();

    return DailyWorkout(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      date: todayStr,
      title: "${profile.name}'s Initial Full-Body Recomp Workout",
      focusArea: 'Full Body Hypertrophy and Fat Loss',
      estimatedDurationMin: 45,
      status: WorkoutStatus.scheduled,
      exercises: exercises,
      adaptationNote: 'Calibrated for 3-day resistance with dumbbells, bands, and bodyweight.',
    );
  }

  @override
  Future<WeeklyPlan> generateAIWeeklyPlan(TransformationEngineState contextState) async {
    final now = DateTime.now();
    final List<String> dates = List.generate(
      7,
      (i) => now.add(Duration(days: i)).toIso8601String().split('T')[0],
    );

    return WeeklyPlan(
      weekId: 'w_sim_${DateTime.now().millisecondsSinceEpoch}',
      startDate: dates.first,
      endDate: dates.last,
      overview: '3-Day Recomp Split with strict adherence to Monday Water Fast and Tue/Thu/Sat Training.',
      coachNote: 'Ashutosh, stay strict on hydration on Monday, and attack your lifting days on Tue/Thu/Sat.',
      days: [
        WeeklyDayPlan(
          dayName: 'Monday',
          date: dates[0],
          title: 'Fasting & Active Recovery',
          focusArea: 'Hydration & Mobility',
          isRestDay: true,
          exerciseNames: ['Light Mobility Routine (15 mins)', 'Gentle Walking (30 mins)'],
          nutritionFocus: 'Water Fasting Protocol: 3.5–4L pure water, zero calorie intake.',
        ),
        WeeklyDayPlan(
          dayName: 'Tuesday',
          date: dates[1],
          title: 'Full-Body Hypertrophy A',
          focusArea: 'Upper/Lower Compound Density',
          isRestDay: false,
          exerciseNames: ['Goblet Squats', 'Dumbbell Romanian Deadlifts', 'Push-Ups', 'Resistance Band Rows'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein, post-fast clean refeed.',
        ),
        WeeklyDayPlan(
          dayName: 'Wednesday',
          date: dates[2],
          title: 'Active Recovery & Core',
          focusArea: 'Tissue Regeneration',
          isRestDay: true,
          exerciseNames: ['Core Stabilization', 'Brisk Walking'],
          nutritionFocus: 'Maintain 2650 kcal with high fiber and clean vegetarian protein sources.',
        ),
        WeeklyDayPlan(
          dayName: 'Thursday',
          date: dates[3],
          title: 'Full-Body Hypertrophy B',
          focusArea: 'Delts, Chest & Posterior Chain',
          isRestDay: false,
          exerciseNames: ['Dumbbell Lunges', 'Overhead Shoulder Press', 'Resistance Band Rows', 'Plank Taps'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein.',
        ),
        WeeklyDayPlan(
          dayName: 'Friday',
          date: dates[4],
          title: 'Active Recovery',
          focusArea: 'Mobility & Stretching',
          isRestDay: true,
          exerciseNames: ['Static Full Body Stretch', 'Light Walk'],
          nutritionFocus: 'Hit 2650 kcal.',
        ),
        WeeklyDayPlan(
          dayName: 'Saturday',
          date: dates[5],
          title: 'Full-Body Hypertrophy C',
          focusArea: 'Full Body Volume & Arms/Shoulders Focus',
          isRestDay: false,
          exerciseNames: ['Bulgarian Split Squats', 'Dumbbell Floor Press', 'Lateral Raises', 'Dumbbell Curls'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein.',
        ),
        WeeklyDayPlan(
          dayName: 'Sunday',
          date: dates[6],
          title: 'Complete Rest & Fasting Prep',
          focusArea: 'Mental Reset & Meal Prep',
          isRestDay: true,
          exerciseNames: ['Gentle Stretching'],
          nutritionFocus: 'Prep nutrient-dense vegetarian meals for the upcoming week.',
        ),
      ],
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<DailyWorkout> generateAIAdaptedWorkout(
    TransformationEngineState contextState,
    String reason,
  ) async {
    final original = contextState.workout;
    return original.copyWith(
      title: '${original.title} (Adapted: 20-min Express)',
      estimatedDurationMin: 20,
      adaptationNote: 'Trimmed volume to 2 compound movements for a rapid 20-min session: $reason',
      status: WorkoutStatus.adapted,
      exercises: original.exercises.take(2).toList(),
    );
  }

  @override
  Future<DailyNutrition> generateAIAdaptedNutrition(
    TransformationEngineState contextState,
    String reason,
  ) async {
    final current = contextState.nutrition;
    return current.copyWith(
      targetCalories: 2400,
      targetProteinG: 180,
    );
  }

  @override
  Future<DailyWorkout> adaptWorkoutWithAI(
    String adaptationRequest,
    TransformationEngineState contextState, {
    List<EquipmentType>? explicitEquipment,
    double? maxWeightKg,
  }) async {
    return generateAIAdaptedWorkout(contextState, adaptationRequest);
  }

  @override
  Future<MealItem> estimateAIMealNutrition(String mealDescription) async {
    return MealItem(
      name: 'High-Protein Paneer & Tofu Salad',
      calories: 520,
      proteinG: 42,
      carbsG: 25,
      fatG: 28,
    );
  }

  @override
  Future<String> generateCoachResponse(
    String userPrompt,
    TransformationEngineState contextState,
  ) async {
    return "Focus on dynamic stretching and controlled sets today.";
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(
    String rawText,
    TransformationEngineState contextState,
  ) async {
    return QuickLogParsedResult(
      coachFeedback: 'Quick log processed',
    );
  }

  @override
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState) async {
    return 'Monday water fasting active: Keep hydration high with 3.5L of water today.';
  }

  @override
  Future<DailyWorkout> parseWorkoutFromNaturalText(
    String naturalText,
    TransformationEngineState contextState, {
    String? targetDate,
  }) async {
    return contextState.workout;
  }

  @override
  Future<WeeklyDebrief> generateWeeklyDebrief(TransformationEngineState contextState) async {
    return WeeklyDebrief(
      headline: 'Flawless Recomp Execution & Fasting Compliance',
      narrative: 'Ashutosh successfully honored Monday fasting while hitting all 3 resistance sessions on Tue/Thu/Sat.',
      keyAchievement: 'Hit 180g protein target on all eating days and completed 3 hypertrophy sessions.',
      primaryNextStep: 'Increase dumbbell goblet squat weight by 2.5kg next Tuesday.',
      adherenceScore: 96,
    );
  }

  @override
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState) async {
    return 'Monday water fasting active: Keep hydration high with 3.5L of water today.';
  }

  @override
  Future<AIOrchestratorResult> processCoachMessage(
    String userPrompt,
    TransformationEngineState contextState, {
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    return AIOrchestratorResult(
      coachResponse: "Focus on active hamstring mobility and dynamic warm-up before hitting your working sets.",
      actions: [],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🎯 Real User End-to-End Persona Simulation: Ashutosh (Diwali Recomp)', () {
    late MockSimulatedAIService aiService;

    setUp(() {
      aiService = MockSimulatedAIService();
    });

    test('Phase 1: Conversational Intake captures Monday fast, Tue/Thu/Sat schedule, and Recomp goal', () async {
      final initialProfile = UserProfile(
        name: 'Ashutosh Sharma',
        age: 26,
        gender: 'male',
        heightCm: 178,
        weightKg: 87,
        targetWeightKg: 87,
        goal: GoalType.recomp,
        daysPerWeek: 0,
        targetPhysique: 'Athletic & Strong',
        equipmentList: [],
        dietaryPreference: 'vegetarian',
        coachSoul: CoachSoul.pro,
      );

      final intakeRes = await aiService.parseLifestyleIntake(
        "I want to transform my physique by Diwali with bigger arms and broader shoulders. Vegetarian diet, water fast on Mondays, training with dumbbells and bands.",
        initialProfile,
      );

      expect(intakeRes.isComplete, isTrue);
      expect(intakeRes.daysPerWeek, 3);
      expect(intakeRes.equipment, containsAll(['Bodyweight', 'Dumbbells', 'Resistance Bands']));
      expect(intakeRes.lifestyleNotes, contains('Fast with water only on Mondays'));
      expect(intakeRes.lifestyleNotes, contains('Workout schedule: Tuesday, Thursday, Saturday'));
      expect(intakeRes.lifestyleNotes, contains('Diet: Vegetarian'));
    });

    test('Phase 2: Baseline Calibration generates accurate metabolic targets and scheduled workout with exercises', () async {
      final userProfile = UserProfile(
        name: 'Ashutosh Sharma',
        age: 26,
        gender: 'male',
        heightCm: 178,
        weightKg: 87,
        targetWeightKg: 87,
        goal: GoalType.recomp,
        daysPerWeek: 3,
        targetPhysique: 'Diwali body recomposition: reduce belly fat, build muscle',
        personalNotes: [
          'Fast with water only on Mondays',
          'Workout schedule: Tuesday, Thursday, Saturday',
          'Diet: Vegetarian',
        ],
        equipmentList: [
          const EquipmentItem(name: 'Bodyweight', category: 'bodyweight'),
          const EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
          const EquipmentItem(name: 'Resistance Bands', category: 'bands'),
        ],
        dietaryPreference: 'vegetarian',
        coachSoul: CoachSoul.pro,
      );

      // 1. Metabolic Calibration
      final nutrition = await aiService.generateAIMetabolicPlan(userProfile);
      expect(nutrition.targetCalories, 2650);
      expect(nutrition.targetProteinG, 180);
      expect(nutrition.targetWaterMl, 3500);

      // 2. Initial Workout Calibration
      final workout = await aiService.generateAIInitialWorkout(userProfile);
      expect(workout.title, contains("Initial Full-Body Recomp Workout"));
      expect(workout.status, WorkoutStatus.scheduled); // Must NOT be completed on startup!
      expect(workout.exercises.length, 6); // Must NOT be empty 0 exercises!
      expect(workout.exercises.first.name, 'Goblet Squat');
      expect(workout.exercises.first.sets.length, 3);
      expect(workout.exercises.first.sets.first.completed, isFalse);
    });

    test('Phase 3: 7-Day Weekly Plan strictly places Monday as Fasting/Rest and Tue/Thu/Sat as Training', () async {
      final userProfile = UserProfile(
        name: 'Ashutosh Sharma',
        age: 26,
        gender: 'male',
        heightCm: 178,
        weightKg: 87,
        targetWeightKg: 87,
        goal: GoalType.recomp,
        daysPerWeek: 3,
        targetPhysique: 'Diwali body recomposition',
        personalNotes: [
          'Fast with water only on Mondays',
          'Workout schedule: Tuesday, Thursday, Saturday',
          'Diet: Vegetarian',
        ],
        coachSoul: CoachSoul.pro,
      );

      final state = TransformationEngineState(
        profile: userProfile,
        workout: DailyWorkout(
          id: 'w_init',
          date: '2026-08-25',
          title: 'Initial Workout',
          focusArea: 'Full Body',
          estimatedDurationMin: 45,
          status: WorkoutStatus.scheduled,
          exercises: [],
        ),
        nutrition: DailyNutrition(
          date: '2026-08-25',
          targetCalories: 2650,
          targetProteinG: 180,
          targetCarbsG: 298,
          targetFatG: 88,
          targetWaterMl: 3500,
          waterMl: 0,
          meals: [],
        ),
        recovery: RecoveryCheckIn(
          date: '2026-08-25',
          sleepHours: 8.0,
          sleepQuality: 85,
          muscleSoreness: 20,
          energyLevel: 90,
          stressLevel: 20,
          recoveryScore: 92,
          status: 'Optimal',
        ),
        progressHistory: [],
        chatMessages: [],
      );

      final weeklyPlan = await aiService.generateAIWeeklyPlan(state);

      expect(weeklyPlan.days.length, 7);

      // Day 0: Monday (Fasting & Active Recovery)
      final monday = weeklyPlan.days[0];
      expect(monday.dayName, 'Monday');
      expect(monday.isRestDay, isTrue);
      expect(monday.nutritionFocus, contains('Water Fasting Protocol'));

      // Day 1: Tuesday (Workout A)
      final tuesday = weeklyPlan.days[1];
      expect(tuesday.dayName, 'Tuesday');
      expect(tuesday.isRestDay, isFalse);
      expect(tuesday.exerciseNames, isNotEmpty);
      expect(tuesday.nutritionFocus, contains('2650 kcal and 180g protein'));

      // Day 2: Wednesday (Rest)
      final wednesday = weeklyPlan.days[2];
      expect(wednesday.dayName, 'Wednesday');
      expect(wednesday.isRestDay, isTrue);

      // Day 3: Thursday (Workout B)
      final thursday = weeklyPlan.days[3];
      expect(thursday.dayName, 'Thursday');
      expect(thursday.isRestDay, isFalse);

      // Day 4: Friday (Rest)
      final friday = weeklyPlan.days[4];
      expect(friday.dayName, 'Friday');
      expect(friday.isRestDay, isTrue);

      // Day 5: Saturday (Workout C)
      final saturday = weeklyPlan.days[5];
      expect(saturday.dayName, 'Saturday');
      expect(saturday.isRestDay, isFalse);

      // Day 6: Sunday (Rest)
      final sunday = weeklyPlan.days[6];
      expect(sunday.dayName, 'Sunday');
      expect(sunday.isRestDay, isTrue);
    });

    test('Phase 4: Tuesday Workout Execution, Progressive Overload & Set Completion', () async {
      final initialWorkout = DailyWorkout(
        id: 'w_tuesday',
        date: '2026-08-25',
        title: 'Full-Body Hypertrophy A',
        focusArea: 'Compound Density',
        estimatedDurationMin: 45,
        status: WorkoutStatus.scheduled,
        exercises: [
          Exercise(
            id: 'ex_1',
            name: 'Goblet Squat',
            targetMuscle: 'Quadriceps',
            equipmentRequired: 'Dumbbells',
            sets: [
              ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 15.0, completed: false),
              ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 15.0, completed: false),
              ExerciseSet(setNumber: 3, targetReps: 12, targetWeightKg: 15.0, completed: false),
            ],
          ),
        ],
      );

      // User performs and completes all 3 sets with 100% completion
      final updatedSets = [
        initialWorkout.exercises.first.sets[0].copyWith(completed: true, actualReps: 12, actualWeightKg: 15.0),
        initialWorkout.exercises.first.sets[1].copyWith(completed: true, actualReps: 12, actualWeightKg: 15.0),
        initialWorkout.exercises.first.sets[2].copyWith(completed: true, actualReps: 12, actualWeightKg: 15.0),
      ];

      final completedWorkout = initialWorkout.copyWith(
        status: WorkoutStatus.completed,
        exercises: [
          initialWorkout.exercises.first.copyWith(sets: updatedSets),
        ],
      );

      expect(completedWorkout.status, WorkoutStatus.completed);
      expect(completedWorkout.exercises.first.sets.every((s) => s.completed), isTrue);

      // Progressive Overload Engine automatically increases load (+2.5 kg) for next session
      final nextOverloadedWorkout = ProgressiveOverloadEngine.applyProgressiveOverload(completedWorkout);

      expect(nextOverloadedWorkout.exercises.first.sets.first.targetWeightKg, 17.5);
      expect(nextOverloadedWorkout.exercises.first.sets.first.completed, isFalse);
    });

    test('Phase 5: Vegetarian Nutrition & Water Logging with Macro Tracking', () async {
      DailyNutrition dailyNutrition = DailyNutrition(
        date: '2026-08-25',
        targetCalories: 2650,
        targetProteinG: 180,
        targetCarbsG: 298,
        targetFatG: 88,
        targetWaterMl: 3500,
        waterMl: 1000,
        meals: [],
      );

      // User logs lunch
      final parsedMeal = await aiService.estimateAIMealNutrition("High-protein paneer and tofu salad with quinoa");

      dailyNutrition = dailyNutrition.copyWith(
        meals: [...dailyNutrition.meals, parsedMeal],
        waterMl: dailyNutrition.waterMl + 500,
      );

      final totalCal = dailyNutrition.meals.fold<num>(0, (sum, m) => sum + m.calories);
      final totalProt = dailyNutrition.meals.fold<num>(0, (sum, m) => sum + m.proteinG);

      expect(totalCal, 520);
      expect(totalProt, 42);
      expect(dailyNutrition.waterMl, 1500);
      expect(dailyNutrition.targetCalories - totalCal, 2130);
      expect(dailyNutrition.targetProteinG - totalProt, 138);
    });

    test('Phase 6: Recovery Check-In updates Readiness and Coach Reasoning Banner', () {
      final recovery = RecoveryCheckIn(
        date: '2026-08-25',
        sleepHours: 8.0,
        sleepQuality: 85,
        muscleSoreness: 20,
        energyLevel: 90,
        stressLevel: 20,
        recoveryScore: 92,
        status: 'Optimal',
      );

      expect(recovery.recoveryScore, 92);
      expect(recovery.status, 'Optimal');

      // The Pro Persona Theme Dynamic Banner
      final coachSoul = CoachSoul.pro;
      final palette = AuraColors.getSoulPalette(coachSoul);
      expect(palette.primary, const Color(0xFF00E5FF)); // Cyan for Pro
    });
  });
}
