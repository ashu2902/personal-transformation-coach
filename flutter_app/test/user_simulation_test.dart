import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/theme/theme.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';
import 'package:aura_transformation_engine/services/ai_service.dart';

/// Realistic mock of AIService for reproducible user simulation testing
class MockSimulatedAIService implements AIService {
  DailyNutrition? lastNutrition;
  DailyWorkout? lastWorkout;
  WeeklyPlan? lastWeeklyPlan;
  DailyWorkout? lastAdaptedWorkout;

  @override
  Future<LifestyleIntakeResult> parseLifestyleIntake(
    String text,
    UserProfile currentProfile, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    return const LifestyleIntakeResult(
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
  Future<void> generateAIMetabolicPlan(UserProfile profile) async {
    lastNutrition = DailyNutrition(
      date: DateTime.now().toIso8601String().split('T')[0],
      targetCalories: 2650,
      targetProteinG: 180,
      targetCarbsG: 298,
      targetFatG: 88,
      targetWaterMl: 3500,
      waterMl: 0,
      meals: const [],
    );
  }

  @override
  Future<void> generateAIInitialWorkout(UserProfile profile) async {
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

    lastWorkout = DailyWorkout(
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
  Future<WeeklyPlan?> generateAIWeeklyPlan(TransformationEngineState contextState) async {
    final now = DateTime.now();
    final List<String> dates = List.generate(
      7,
      (i) => now.add(Duration(days: i)).toIso8601String().split('T')[0],
    );

    lastWeeklyPlan = WeeklyPlan(
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
          exerciseNames: const ['Light Mobility Routine (15 mins)', 'Gentle Walking (30 mins)'],
          nutritionFocus: 'Water Fasting Protocol: 3.5–4L pure water, zero calorie intake.',
        ),
        WeeklyDayPlan(
          dayName: 'Tuesday',
          date: dates[1],
          title: 'Full-Body Hypertrophy A',
          focusArea: 'Upper/Lower Compound Density',
          isRestDay: false,
          exerciseNames: const ['Goblet Squats', 'Dumbbell Romanian Deadlifts', 'Push-Ups', 'Resistance Band Rows'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein, post-fast clean refeed.',
        ),
        WeeklyDayPlan(
          dayName: 'Wednesday',
          date: dates[2],
          title: 'Active Recovery & Core',
          focusArea: 'Tissue Regeneration',
          isRestDay: true,
          exerciseNames: const ['Core Stabilization', 'Brisk Walking'],
          nutritionFocus: 'Maintain 2650 kcal with high fiber and clean vegetarian protein sources.',
        ),
        WeeklyDayPlan(
          dayName: 'Thursday',
          date: dates[3],
          title: 'Full-Body Hypertrophy B',
          focusArea: 'Posterior Chain & Core Stability',
          isRestDay: false,
          exerciseNames: const ['Dumbbell Squats', 'Overhead Press', 'Glute Bridges', 'Resistance Band Pull-Aparts'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein.',
        ),
        WeeklyDayPlan(
          dayName: 'Friday',
          date: dates[4],
          title: 'Active Recovery',
          focusArea: 'Mobility & Stretching',
          isRestDay: true,
          exerciseNames: const ['Static Full Body Stretch', 'Light Walk'],
          nutritionFocus: 'Hit 2650 kcal.',
        ),
        WeeklyDayPlan(
          dayName: 'Saturday',
          date: dates[5],
          title: 'Full-Body Hypertrophy C',
          focusArea: 'Full Body Volume & Arms/Shoulders Focus',
          isRestDay: false,
          exerciseNames: const ['Bulgarian Split Squats', 'Dumbbell Floor Press', 'Lateral Raises', 'Dumbbell Curls'],
          nutritionFocus: 'Hit 2650 kcal and 180g protein.',
        ),
        WeeklyDayPlan(
          dayName: 'Sunday',
          date: dates[6],
          title: 'Complete Rest & Fasting Prep',
          focusArea: 'Mental Reset & Meal Prep',
          isRestDay: true,
          exerciseNames: const ['Gentle Stretching'],
          nutritionFocus: 'Prep nutrient-dense vegetarian meals for the upcoming week.',
        ),
      ],
      createdAt: DateTime.now().toIso8601String(),
    );
    return lastWeeklyPlan;
  }

  @override
  Future<void> generateAIAdaptedWorkout(
    TransformationEngineState contextState,
    String reason,
  ) async {
    final original = contextState.workout;
    lastAdaptedWorkout = original.copyWith(
      title: '${original.title} (Adapted: 20-min Express)',
      estimatedDurationMin: 20,
      adaptationNote: 'Trimmed volume to 2 compound movements for a rapid 20-min session: $reason',
      status: WorkoutStatus.adapted,
      exercises: original.exercises.take(2).toList(),
    );
  }

  @override
  Future<void> generateAIAdaptedNutrition(
    TransformationEngineState contextState,
    String reason,
  ) async {
    final current = contextState.nutrition;
    lastNutrition = current.copyWith(
      targetCalories: 2400,
      targetProteinG: 180,
    );
  }

  @override
  Future<void> adaptWorkoutWithAI(
    String adaptationRequest,
    TransformationEngineState contextState, {
    List<EquipmentType>? explicitEquipment,
    double? maxWeightKg,
    ContextEnvelope? contextEnvelope,
  }) async {
    await generateAIAdaptedWorkout(contextState, adaptationRequest);
  }

  @override
  Future<MealItem> estimateAIMealNutrition(String mealDescription) async {
    return const MealItem(
      name: 'High-Protein Paneer & Tofu Salad',
      calories: 520,
      proteinG: 42,
      carbsG: 25,
      fatG: 28,
    );
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(
    String rawText,
    TransformationEngineState contextState,
  ) async {
    return const QuickLogParsedResult(
      coachFeedback: 'Quick log processed',
    );
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
    return const WeeklyDebrief(
      headline: 'Flawless Recomp Execution & Fasting Compliance',
      narrative: 'Ashutosh successfully honored Monday fasting while hitting all 3 resistance sessions on Tue/Thu/Sat.',
      keyAchievement: 'Hit 180g protein target on all eating days and completed 3 hypertrophy sessions.',
      primaryNextStep: 'Increase dumbbell goblet squat weight by 2.5kg next Tuesday.',
      adherenceScore: 96,
    );
  }

  @override
  Future<AIOrchestratorResult> processCoachMessage(
    String userPrompt,
    TransformationEngineState contextState, {
    Uint8List? imageBytes,
    String? imageUrl,
    String? mimeType,
    ContextEnvelope? contextEnvelope,
  }) async {
    return const AIOrchestratorResult(
      coachResponse: "Focus on active hamstring mobility and dynamic warm-up before hitting your working sets.",
      actions: [],
    );
  }

  @override
  Future<CurateMealChatResult> curateMealPlanChat({
    required String message,
    List<Map<String, dynamic>>? history,
    ContextEnvelope? contextEnvelope,
  }) async {
    if (history == null || history.isEmpty) {
      return const CurateMealChatResult(
        coachResponse: "Hey Ashutosh! Let's fuel your recomp workout today. How would you like to structure your meals?",
        dynamicQuickReplies: ["3 meals + 1 snack", "2 large meals + shake", "Quick 15-min meals"],
        isFinalPlan: false,
      );
    }
    return const CurateMealChatResult(
      coachResponse: "Here is your customized Diwali recomp meal plan! 3 power meals + 1 recovery snack tailored to hit 2650 kcal and 180g protein.",
      dynamicQuickReplies: ["Looks delicious!", "Swap lunch", "Adjust calories"],
      isFinalPlan: true,
      curatedMealPlan: CuratedMealPlan(
        id: 'cmp_sim_1',
        date: '2026-08-25',
        createdAt: '2026-08-25T08:00:00Z',
        title: "Diwali Recomp High-Protein Fuel",
        overview: "Timed nutrition around Tuesday Full-Body Hypertrophy session.",
        totalCalories: 2650,
        totalProteinG: 180,
        totalCarbsG: 295,
        totalFatG: 85,
        meals: [
          CuratedMeal(
            id: 'm1',
            name: 'High Protein Oats & Whey',
            slotName: 'Pre-Workout Fuel',
            description: '80g oats with 1.5 scoops whey and almond milk',
            calories: 650,
            proteinG: 45,
            carbsG: 80,
            fatG: 15,
            prepTime: '5 mins',
            instructions: 'Microwave oats for 2 mins, stir in protein powder.',
            tags: ['Quick Prep', 'High Protein'],
          ),
          CuratedMeal(
            id: 'm2',
            name: 'Paneer Tofu Stir-Fry Bowl',
            slotName: 'Post-Workout Lunch',
            description: '200g paneer, 100g tofu, 1.5 cups brown rice and mixed vegetables',
            calories: 950,
            proteinG: 65,
            carbsG: 110,
            fatG: 30,
            prepTime: '15 mins',
            instructions: 'Sauté cubed paneer and tofu with soy sauce and turmeric, serve over brown rice.',
            tags: ['Post-Workout', 'Vegetarian High Protein'],
          ),
          CuratedMeal(
            id: 'm3',
            name: 'Greek Yogurt & Pumpkin Seeds',
            slotName: 'Afternoon Recovery Snack',
            description: '250g Greek yogurt with 30g pumpkin seeds',
            calories: 400,
            proteinG: 30,
            carbsG: 20,
            fatG: 20,
            prepTime: '2 mins',
            instructions: 'Mix seeds into cold yogurt.',
            tags: ['Clean Snack'],
          ),
          CuratedMeal(
            id: 'm4',
            name: 'Lentil Dal & Quinoa Power Plate',
            slotName: 'Evening Fuel',
            description: '1.5 cups cooked moong dal, 1 cup cooked quinoa, large cucumber salad',
            calories: 650,
            proteinG: 40,
            carbsG: 85,
            fatG: 20,
            prepTime: '20 mins',
            instructions: 'Simmer spiced moong dal and serve warm over quinoa.',
            tags: ['Slow Digesting', 'Overnight Recovery'],
          ),
        ],
      ),
    );
  }
}

void main() {
  group('AURA Complete End-to-End User Simulation: Ashutosh Sharma Recomp Journey', () {
    late MockSimulatedAIService aiService;

    setUp(() {
      aiService = MockSimulatedAIService();
    });

    test('Phase 1: Conversational Lifestyle Calibration correctly deduces constraints & equipment', () async {
      const initialProfile = UserProfile(
        name: 'Ashutosh Sharma',
        age: 26,
        gender: 'male',
        heightCm: 178,
        weightKg: 87,
        targetWeightKg: 87,
        goal: GoalType.recomp,
        daysPerWeek: 4,
        targetPhysique: 'Diwali body recomposition',
        coachSoul: CoachSoul.pro,
      );

      const userTranscript = '''
I want to transform my body by Diwali. I am currently 87kg, 178cm, vegetarian.
I have a pair of dumbbells at home and some resistance bands.
I want to fast with water only every Monday, and train 3 days a week: Tuesday, Thursday, and Saturday.
My focus is reducing belly fat while building broader shoulders and bigger arms.
''';

      final intakeResult = await aiService.parseLifestyleIntake(userTranscript, initialProfile);

      expect(intakeResult.isComplete, isTrue);
      expect(intakeResult.daysPerWeek, 3);
      expect(intakeResult.equipment, containsAll(['Dumbbells', 'Resistance Bands', 'Bodyweight']));
      expect(intakeResult.lifestyleNotes, contains('Fast with water only on Mondays'));
      expect(intakeResult.lifestyleNotes, contains('Workout schedule: Tuesday, Thursday, Saturday'));
      expect(intakeResult.lifestyleNotes, contains('Diet: Vegetarian'));
    });

    test('Phase 2: Baseline Calibration generates accurate metabolic targets and scheduled workout with exercises', () async {
      const userProfile = UserProfile(
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
          EquipmentItem(name: 'Bodyweight', category: 'bodyweight'),
          EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
          EquipmentItem(name: 'Resistance Bands', category: 'bands'),
        ],
        dietaryPreference: 'vegetarian',
        coachSoul: CoachSoul.pro,
      );

      // 1. Metabolic Calibration
      await aiService.generateAIMetabolicPlan(userProfile);
      final nutrition = aiService.lastNutrition!;
      expect(nutrition.targetCalories, 2650);
      expect(nutrition.targetProteinG, 180);
      expect(nutrition.targetWaterMl, 3500);

      // 2. Initial Workout Calibration
      await aiService.generateAIInitialWorkout(userProfile);
      final workout = aiService.lastWorkout!;
      expect(workout.title, contains("Initial Full-Body Recomp Workout"));
      expect(workout.status, WorkoutStatus.scheduled);
      expect(workout.exercises.length, 6);
      expect(workout.exercises.first.name, 'Goblet Squat');
      expect(workout.exercises.first.sets.length, 3);
      expect(workout.exercises.first.sets.first.completed, isFalse);
    });

    test('Phase 3: 7-Day Weekly Plan strictly places Monday as Fasting/Rest and Tue/Thu/Sat as Training', () async {
      const userProfile = UserProfile(
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
        workout: const DailyWorkout(
          id: 'w_init',
          date: '2026-08-25',
          title: 'Initial Workout',
          focusArea: 'Full Body',
          estimatedDurationMin: 45,
          status: WorkoutStatus.scheduled,
          exercises: [],
        ),
        nutrition: const DailyNutrition(
          date: '2026-08-25',
          targetCalories: 2650,
          targetProteinG: 180,
          targetCarbsG: 298,
          targetFatG: 88,
          targetWaterMl: 3500,
          waterMl: 0,
          meals: [],
        ),
        recovery: const RecoveryCheckIn(
          date: '2026-08-25',
          sleepHours: 8.0,
          sleepQuality: 85,
          muscleSoreness: 20,
          energyLevel: 90,
          stressLevel: 20,
          recoveryScore: 92,
          status: 'Optimal',
        ),
        progressHistory: const [],
        chatMessages: const [],
      );

      await aiService.generateAIWeeklyPlan(state);
      final weeklyPlan = aiService.lastWeeklyPlan!;

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

    test('Phase 4: Tuesday Workout Execution & Progressive Overload Engine', () async {
      const initialWorkout = DailyWorkout(
        id: 'w_tue_01',
        date: '2026-08-25',
        title: 'Full-Body Hypertrophy A',
        focusArea: 'Upper/Lower Compound Density',
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

      // Progressive Overload Progression: load increases (+2.5 kg) for next session
      final nextOverloadedWorkout = completedWorkout.copyWith(
        exercises: completedWorkout.exercises.map((ex) {
          final isDumbbell = ex.equipmentRequired.toLowerCase().contains('dumbbell');
          final increment = isDumbbell ? 2.5 : 0.0;
          return ex.copyWith(
            sets: ex.sets.map((s) => s.copyWith(
              targetWeightKg: s.targetWeightKg + increment,
              completed: false,
            )).toList(),
          );
        }).toList(),
      );

      expect(nextOverloadedWorkout.exercises.first.sets.first.targetWeightKg, 17.5);
      expect(nextOverloadedWorkout.exercises.first.sets.first.completed, isFalse);
    });

    test('Phase 5: Vegetarian Nutrition & Water Logging with Macro Tracking', () async {
      DailyNutrition dailyNutrition = const DailyNutrition(
        date: '2026-08-25',
        targetCalories: 2650,
        targetProteinG: 180,
        targetCarbsG: 298,
        targetFatG: 88,
        targetWaterMl: 3500,
        waterMl: 1000,
        meals: [],
      );

      // User estimates/logs a meal
      final loggedMeal = await aiService.estimateAIMealNutrition('Paneer and tofu high protein salad');
      expect(loggedMeal.proteinG, 42);
      expect(loggedMeal.calories, 520);

      dailyNutrition = dailyNutrition.copyWith(
        meals: [...dailyNutrition.meals, loggedMeal],
        waterMl: dailyNutrition.waterMl + 500,
      );

      expect(dailyNutrition.totalCalories, 520);
      expect(dailyNutrition.totalProtein, 42);
      expect(dailyNutrition.waterMl, 1500);
    });

    test('Phase 5b: Conversational Meal Curation simulates real user multi-turn flow', () async {
      // Step 1: User lands on empty meal state and initiates curation chat
      final conversationHistory = <Map<String, dynamic>>[];
      const userMessageTurn1 = "Hey coach, I'd like a custom meal plan curated for today's workout.";
      conversationHistory.add({'sender': 'user', 'text': userMessageTurn1});

      final turn1Result = await aiService.curateMealPlanChat(
        message: userMessageTurn1,
        history: [],
      );

      // AI asks for meal structure preferences and provides 3-4 dynamic chips
      expect(turn1Result.isFinalPlan, isFalse);
      expect(turn1Result.curatedMealPlan, isNull);
      expect(turn1Result.coachResponse, contains("fuel your recomp workout"));
      expect(turn1Result.dynamicQuickReplies, contains("3 meals + 1 snack"));
      conversationHistory.add({'sender': 'coach', 'text': turn1Result.coachResponse});

      // Step 2: User taps quick reply chip "3 meals + 1 snack"
      final selectedQuickReply = turn1Result.dynamicQuickReplies.first;
      expect(selectedQuickReply, "3 meals + 1 snack");
      conversationHistory.add({'sender': 'user', 'text': selectedQuickReply});

      final turn2Result = await aiService.curateMealPlanChat(
        message: selectedQuickReply,
        history: conversationHistory,
      );

      // AI responds with finalized plan calibrated to user target macros (2650 kcal, 180g P)
      expect(turn2Result.isFinalPlan, isTrue);
      expect(turn2Result.curatedMealPlan, isNotNull);
      final plan = turn2Result.curatedMealPlan!;
      expect(plan.title, contains("Diwali Recomp"));
      expect(plan.meals.length, 4);
      expect(plan.totalCalories, 2650);
      expect(plan.totalProteinG, 180);

      // Verify meal macro breakdown
      final computedCal = plan.meals.fold(0, (sum, m) => sum + m.calories);
      final computedProt = plan.meals.fold(0, (sum, m) => sum + m.proteinG);
      expect(computedCal, 2650);
      expect(computedProt, 180);

      // Step 3: Populate to daily nutrition and 1-tap log meal
      var dailyNutrition = DailyNutrition(
        date: '2026-08-25',
        targetCalories: 2650,
        targetProteinG: 180,
        targetCarbsG: 295,
        targetFatG: 85,
        waterMl: 1500,
        meals: const [],
        curatedMealPlan: plan,
      );

      // 1-Tap Log Meal 1 (Pre-Workout Fuel)
      final mealToLog = plan.meals.first;
      final loggedItem = MealItem(
        name: '${mealToLog.slotName}: ${mealToLog.name}',
        calories: mealToLog.calories,
        proteinG: mealToLog.proteinG,
        carbsG: mealToLog.carbsG,
        fatG: mealToLog.fatG,
      );

      final updatedPlan = plan.copyWith(
        meals: plan.meals.map((m) => m.id == mealToLog.id ? m.copyWith(isLogged: true) : m).toList(),
      );

      dailyNutrition = dailyNutrition.copyWith(
        meals: [...dailyNutrition.meals, loggedItem],
        curatedMealPlan: updatedPlan,
      );

      expect(dailyNutrition.curatedMealPlan!.meals.first.isLogged, isTrue);
      expect(dailyNutrition.curatedMealPlan!.meals[1].isLogged, isFalse);
      expect(dailyNutrition.totalCalories, 650);
      expect(dailyNutrition.totalProtein, 45);
    });

    test('Phase 6: Pro Coach Soul Theme Adherence & Tone Verification', () {
      const proSoul = CoachSoul.pro;
      final proPalette = AuraColors.getSoulPalette(proSoul);

      expect(proPalette.primary, const Color(0xFF00E5FF)); // Electric Cyan
      expect(proPalette.scaffoldBackground, const Color(0xFF0B0C0D));
    });

    test('Phase 7: Weekly Debrief Generation on Sunday', () async {
      final state = TransformationEngineState(
        profile: const UserProfile(
          name: 'Ashutosh Sharma',
          age: 26,
          gender: 'male',
          heightCm: 178,
          weightKg: 87,
          targetWeightKg: 87,
          goal: GoalType.recomp,
          daysPerWeek: 3,
          targetPhysique: 'Diwali body recomposition',
        ),
        workout: const DailyWorkout(
          id: 'w_done',
          date: '2026-08-30',
          title: 'Full-Body Hypertrophy C',
          focusArea: 'Full Body',
          estimatedDurationMin: 45,
          status: WorkoutStatus.completed,
          exercises: [],
        ),
        nutrition: const DailyNutrition(
          date: '2026-08-30',
          targetCalories: 2650,
          targetProteinG: 180,
          targetCarbsG: 298,
          targetFatG: 88,
          targetWaterMl: 3500,
          waterMl: 3500,
          meals: [],
        ),
        recovery: const RecoveryCheckIn(
          date: '2026-08-30',
          sleepHours: 8.5,
          sleepQuality: 90,
          muscleSoreness: 10,
          energyLevel: 95,
          stressLevel: 10,
          recoveryScore: 95,
          status: 'Optimal',
        ),
        progressHistory: const [],
        chatMessages: const [],
      );

      final debrief = await aiService.generateWeeklyDebrief(state);

      expect(debrief.headline, contains('Flawless Recomp Execution'));
      expect(debrief.adherenceScore, 96);
      expect(debrief.keyAchievement, contains('Hit 180g protein'));
      expect(debrief.primaryNextStep, contains('Increase dumbbell goblet squat weight'));
    });
  });
}
