import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/services/firebase_service.dart';
import 'package:aura_transformation_engine/services/transformation_repository.dart';

void main() {
  group('WeeklyPlan Parsing & Synchronization Tests', () {
    final firestoreService = FirebaseFirestoreService();

    test('weeklyPlanFromMap derives missing day dates from startDate', () {
      final rawMap = {
        'weekId': 'w_1787622052557',
        'startDate': '2026-08-25',
        'endDate': '2026-08-31',
        'overview': '7-day adaptive body recomposition program.',
        'coachNote': 'Keep pushing!',
        'days': [
          {
            'dayName': 'Monday',
            'date': '',
            'title': 'Water Fasting & Complete Rest',
            'focusArea': 'Fasting & Recovery',
            'isRestDay': true,
            'exerciseNames': ['Light Walking', 'Gentle Stretching'],
          },
          {
            'dayName': 'Tuesday',
            'date': '',
            'title': 'Full Body Recomposition A',
            'focusArea': 'Chest, Back, Legs & Core',
            'isRestDay': false,
            'exerciseNames': ['Dumbbell Goblet Squats', 'Dumbbell Floor Press'],
          },
          {
            'dayName': 'Wednesday',
            'date': '2026-08-27',
            'title': 'Active Recovery',
            'focusArea': 'Mobility',
            'isRestDay': true,
            'exerciseNames': ['Cat-Cow'],
          },
        ],
      };

      final plan = firestoreService.weeklyPlanFromMap(rawMap);

      expect(plan.weekId, 'w_1787622052557');
      expect(plan.days.length, 3);
      // Day 0: derived from 2026-08-25 + 0 days
      expect(plan.days[0].date, '2026-08-25');
      // Day 1: derived from 2026-08-25 + 1 day
      expect(plan.days[1].date, '2026-08-26');
      // Day 2: explicitly was 2026-08-27
      expect(plan.days[2].date, '2026-08-27');
    });

    test('weeklyPlanToMap and weeklyPlanFromMap round-trip preserves all fields', () {
      final rawMap = {
        'weekId': '2026-W35',
        'startDate': '2026-08-24',
        'endDate': '2026-08-30',
        'overview': 'Overview test',
        'coachNote': 'Coach note test',
        'createdAt': '2026-08-25T10:00:00Z',
        'days': [
          {
            'dayName': 'Monday',
            'date': '2026-08-24',
            'title': 'Leg Day',
            'focusArea': 'Quads & Glutes',
            'isRestDay': false,
            'exerciseNames': ['Squats'],
            'nutritionFocus': 'High Protein',
          }
        ],
      };

      final plan = firestoreService.weeklyPlanFromMap(rawMap);
      final serialized = firestoreService.weeklyPlanToMap(plan);

      expect(serialized['weekId'], '2026-W35');
      expect(serialized['startDate'], '2026-08-24');
      expect(serialized['days'][0]['dayName'], 'Monday');
      expect(serialized['days'][0]['date'], '2026-08-24');
    });

    test('weeklyDayPlan update preserves other days and mutates target day', () {
      const monday = WeeklyDayPlan(
        dayName: 'Monday',
        date: '2026-08-24',
        title: 'Rest',
        focusArea: 'Recovery',
        isRestDay: true,
      );
      const wednesday = WeeklyDayPlan(
        dayName: 'Wednesday',
        date: '2026-08-26',
        title: 'Rest',
        focusArea: 'Recovery',
        isRestDay: true,
      );

      const plan = WeeklyPlan(
        weekId: '2026-W35',
        startDate: '2026-08-24',
        endDate: '2026-08-30',
        overview: 'Test overview',
        createdAt: '2026-08-24T00:00:00Z',
        days: [monday, wednesday],
      );

      final updatedWednesday = wednesday.copyWith(
        title: 'Active Recovery & Mobility',
        focusArea: 'Mobility & Core',
        isRestDay: true,
        exerciseNames: ['Cat-Cow Stretch', 'Bird-Dog'],
      );

      final updatedPlan = plan.copyWith(
        days: plan.days.map((d) => d.dayName == 'Wednesday' ? updatedWednesday : d).toList(),
      );

      expect(updatedPlan.days[1].title, 'Active Recovery & Mobility');
      expect(updatedPlan.days[1].exerciseNames, contains('Cat-Cow Stretch'));
      expect(updatedPlan.days[0].title, 'Rest');
    });

    test('LocalTransformationRepository saves and loads WeeklyPlan correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LocalTransformationRepository();
      const samplePlan = WeeklyPlan(
        weekId: 'w_test_123',
        startDate: '2026-09-01',
        endDate: '2026-09-07',
        overview: 'Test overview recomp plan',
        coachNote: 'Stay focused',
        createdAt: '2026-09-01T00:00:00Z',
        days: [
          WeeklyDayPlan(
            dayName: 'Wednesday',
            date: '2026-09-02',
            title: 'Active Recovery & Mobility',
            focusArea: 'Core, Mobility, Flexibility',
            isRestDay: true,
            exerciseNames: ['Cat-Cow Stretch', 'Plank Hold'],
            nutritionFocus: 'Hit 2000 kcal and 150g protein',
          ),
        ],
      );

      await repo.saveWeeklyPlan(samplePlan);
      final loaded = await repo.loadWeeklyPlan();

      expect(loaded, isNotNull);
      expect(loaded!.weekId, 'w_test_123');
      expect(loaded.days.length, 1);
      expect(loaded.days.first.exerciseNames, contains('Cat-Cow Stretch'));
    });

    test('plannedExercises serialization and deserialization preserves trackingType and duration', () {
      final rawMap = {
        'weekId': 'w_structured_types',
        'startDate': '2026-09-01',
        'endDate': '2026-09-07',
        'overview': 'Structured exercise tracking test',
        'createdAt': '2026-09-01T00:00:00Z',
        'days': [
          {
            'dayName': 'Wednesday',
            'date': '2026-09-03',
            'title': 'Active Recovery & Core',
            'focusArea': 'Core & Mobility',
            'isRestDay': true,
            'exerciseNames': ['Light Walking', 'Plank Hold', 'Dynamic Stretching'],
            'plannedExercises': [
              {
                'name': 'Light Walking',
                'trackingType': 'duration',
                'targetSets': 1,
                'targetDurationSeconds': 1800,
                'targetReps': 0,
                'notes': 'Steady pace',
              },
              {
                'name': 'Plank Hold',
                'trackingType': 'duration',
                'targetSets': 3,
                'targetDurationSeconds': 60,
                'targetReps': 0,
                'notes': 'Keep glutes squeezed',
              },
              {
                'name': 'Dynamic Stretching',
                'trackingType': 'completion',
                'targetSets': 1,
                'targetDurationSeconds': 600,
                'targetReps': 0,
                'notes': 'Full body mobility flow',
              },
            ],
          }
        ],
      };

      final plan = firestoreService.weeklyPlanFromMap(rawMap);
      expect(plan.days.first.plannedExercises.length, 3);

      final walking = plan.days.first.plannedExercises[0];
      expect(walking.name, 'Light Walking');
      expect(walking.trackingType, ExerciseTrackingType.duration);
      expect(walking.targetSets, 1);
      expect(walking.targetDurationSeconds, 1800);

      final plank = plan.days.first.plannedExercises[1];
      expect(plank.name, 'Plank Hold');
      expect(plank.trackingType, ExerciseTrackingType.duration);
      expect(plank.targetSets, 3);
      expect(plank.targetDurationSeconds, 60);

      final stretching = plan.days.first.plannedExercises[2];
      expect(stretching.name, 'Dynamic Stretching');
      expect(stretching.trackingType, ExerciseTrackingType.completion);
      expect(stretching.targetSets, 1);
      expect(stretching.targetDurationSeconds, 600);

      // Verify round-trip serialization
      final serialized = firestoreService.weeklyPlanToMap(plan);
      expect(serialized['days'][0]['plannedExercises'], isNotEmpty);
      final rawPlanned = (serialized['days'][0]['plannedExercises'] as List);
      expect(rawPlanned.length, 3);
      expect(rawPlanned[0]['trackingType'], 'duration');
      expect(rawPlanned[0]['targetDurationSeconds'], 1800);
      expect(rawPlanned[2]['trackingType'], 'completion');
    });

    test('weeklyPlanFromMap falls back cleanly when plannedExercises is missing', () {
      final rawMap = {
        'weekId': 'w_legacy',
        'startDate': '2026-09-01',
        'endDate': '2026-09-07',
        'days': [
          {
            'dayName': 'Monday',
            'date': '2026-09-01',
            'title': 'Legacy Day',
            'isRestDay': false,
            'exerciseNames': ['Squats', 'Pushups'],
          }
        ],
      };

      final plan = firestoreService.weeklyPlanFromMap(rawMap);
      expect(plan.days.first.plannedExercises, isEmpty);
      expect(plan.days.first.exerciseNames, ['Squats', 'Pushups']);
    });
  });
}
