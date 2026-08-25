import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/services/ai_service.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';
import 'package:aura_transformation_engine/widgets/nutrition/nutrition_receipt_card.dart';

import 'package:aura_transformation_engine/services/transformation_repository.dart';

class MockTransformationRepository implements ITransformationRepository {
  @override
  Future<UserProfile?> loadProfile() async => null;
  @override
  Future<void> saveProfile(UserProfile profile) async {}
  @override
  Future<DailyWorkout?> loadTodayWorkout(String dateStr) async => null;
  @override
  Future<void> saveTodayWorkout(DailyWorkout workout) async {}
  @override
  Future<DailyNutrition?> loadTodayNutrition(String dateStr) async => null;
  @override
  Future<void> saveTodayNutrition(DailyNutrition nutrition) async {}
  @override
  Future<RecoveryCheckIn?> loadTodayRecovery(String dateStr) async => null;
  @override
  Future<void> saveTodayRecovery(RecoveryCheckIn recovery) async {}
  @override
  Future<List<ProgressEntry>> loadProgressHistory() async => [];
  @override
  Future<void> saveProgressEntry(ProgressEntry entry) async {}
  @override
  Future<void> clearAll() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('PRD MVP Core Models & Parsing Tests', () {
    test('WeeklyDebrief parses structured JSON correctly', () {
      final json = {
        'headline': 'Optimal Neural Recovery & Progressive Adaptation',
        'narrative': 'Your volume tolerance increased this week. Recovery scores averaged 85%. Keep prioritizing sleep.',
        'keyAchievement': 'Maintained 4/4 scheduled workout compliance',
        'primaryNextStep': 'Increase target dumbbell load by 2.5kg',
        'adherenceScore': 92,
      };

      final debrief = WeeklyDebrief.fromJson(json);

      expect(debrief.headline, 'Optimal Neural Recovery & Progressive Adaptation');
      expect(debrief.narrative, contains('volume tolerance increased'));
      expect(debrief.keyAchievement, 'Maintained 4/4 scheduled workout compliance');
      expect(debrief.primaryNextStep, 'Increase target dumbbell load by 2.5kg');
      expect(debrief.adherenceScore, 92);
    });

    test('LifestyleIntakeResult parses structured AI intake JSON correctly', () {
      final json = {
        'isComplete': true,
        'daysPerWeek': 4,
        'equipment': ['Dumbbells', 'Resistance Bands', 'Pull-up Bar'],
        'missingFields': <String>[],
        'followUpQuestion': 'All set! Ready to pick your coach persona.',
        'dynamicQuickReplies': ['Ready to choose my coach!', 'I prefer 45-min sessions'],
        'targetPhysique': 'V-Shape Physique & Bigger Arms',
        'lifestyleNotes': ['Water fast on Mondays', 'Prefers Tue, Thu, Sat training days'],
      };

      final result = LifestyleIntakeResult.fromJson(json);

      expect(result.isComplete, isTrue);
      expect(result.daysPerWeek, 4);
      expect(result.equipment, containsAll(['Dumbbells', 'Resistance Bands', 'Pull-up Bar']));
      expect(result.missingFields, isEmpty);
      expect(result.followUpQuestion, contains('All set'));
      expect(result.dynamicQuickReplies, contains('Ready to choose my coach!'));
      expect(result.targetPhysique, 'V-Shape Physique & Bigger Arms');
      expect(result.lifestyleNotes, containsAll(['Water fast on Mondays', 'Prefers Tue, Thu, Sat training days']));
    });

    test('EquipmentItem parses strings and formats correctly', () {
      final item = EquipmentItem.fromString('10kg Workout Bag');
      expect(item.name, '10kg Workout Bag');
      expect(item.category, 'free_weight');
      expect(item.weightKg, 10.0);
    });
  });

  group('Domain Mutations & Telemetry Tests', () {
    test('updateSetTarget applies micro-deviation to target reps and weight', () {
      final initialExercise = Exercise(
        id: 'ex_1',
        name: 'Dumbbell Press',
        targetMuscle: 'Chest',
        equipmentRequired: 'free_weight',
        sets: [
          ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 20.0),
          ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 20.0),
        ],
      );

      final initialWorkout = DailyWorkout(
        id: 'w_1',
        date: '2026-08-23',
        title: 'Upper Body Hypertrophy',
        focusArea: 'Chest & Shoulders',
        estimatedDurationMin: 45,
        status: WorkoutStatus.scheduled,
        exercises: [initialExercise],
      );

      final notifier = TransformationEngineNotifier(
        repository: MockTransformationRepository(),
        autoInit: false,
      );

      // Mutate workout state
      notifier.state = notifier.state.copyWith(workout: initialWorkout);

      // Apply micro-deviation
      notifier.updateSetTarget(
        'ex_1',
        0,
        newReps: 12,
        newWeightKg: 22.5,
      );

      final updatedWorkout = notifier.state.workout;
      final updatedSet = updatedWorkout.exercises.first.sets.first;

      expect(updatedSet.targetReps, 12);
      expect(updatedSet.targetWeightKg, 22.5);
    });
  });

  group('Glass Box Nutrition & FAB Widget Tests', () {
    testWidgets('NutritionReceiptCard renders items, macros, and handles edit tap', (tester) async {
      bool editTapped = false;
      final meals = [
        MealItem(name: 'Scrambled Eggs & Toast', calories: 420, proteinG: 28, carbsG: 34, fatG: 16),
        MealItem(name: 'Iced Protein Latte', calories: 180, proteinG: 20, carbsG: 8, fatG: 4),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionReceiptCard(
              meals: meals,
              totalWaterMl: 500,
              onEditPressed: () => editTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('NUTRITION RECEIPT'), findsOneWidget);
      expect(find.text('Scrambled Eggs & Toast'), findsOneWidget);
      expect(find.text('Iced Protein Latte'), findsOneWidget);
      expect(find.text('600 kcal'), findsOneWidget);
      expect(find.text('48g P'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(editTapped, isTrue);
    });

    test('NutritionMutations addMeal and addWater update state correctly', () {
      final notifier = TransformationEngineNotifier(
        repository: MockTransformationRepository(),
        autoInit: false,
      );

      notifier.addMeal(MealItem(
        name: 'Whey Protein Shake',
        calories: 140,
        proteinG: 25,
        carbsG: 3,
        fatG: 2,
      ));

      notifier.addWater(250);

      expect(notifier.state.nutrition.meals.length, 1);
      expect(notifier.state.nutrition.meals.first.name, 'Whey Protein Shake');
      expect(notifier.state.nutrition.waterMl, 250);
    });

    test('RecoveryMutations updateSleep and updateSoreness compute recovery score', () {
      final notifier = TransformationEngineNotifier(
        repository: MockTransformationRepository(),
        autoInit: false,
      );

      notifier.updateSleep(8.0);
      notifier.updateSoreness(2);

      expect(notifier.state.recovery.sleepHours, 8.0);
      expect(notifier.state.recovery.muscleSoreness, 2);
      expect(notifier.state.recovery.recoveryScore, greaterThan(0));
    });
  });
}
