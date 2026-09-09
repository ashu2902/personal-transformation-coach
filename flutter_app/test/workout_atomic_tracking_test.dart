import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';
import 'package:aura_transformation_engine/services/analytics_service.dart';
import 'package:aura_transformation_engine/services/transformation_repository.dart';

class MockAnalyticsService implements IAnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? properties}) async {
    loggedEvents.add({
      'name': name,
      'properties': properties ?? <String, dynamic>{},
    });
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> registerSuperProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> reset() async {}
}

class MockRepo implements ITransformationRepository {
  final List<ProgressEntry> savedProgress = [];

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
  Future<WeeklyPlan?> loadWeeklyPlan() async => null;
  @override
  Future<void> saveWeeklyPlan(WeeklyPlan plan) async {}
  @override
  Future<List<ProgressEntry>> loadProgressHistory() async => [];
  @override
  Future<void> saveProgressEntry(ProgressEntry entry) async {
    savedProgress.add(entry);
  }
  @override
  Future<void> clearAll() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Atomic Workout Tracking & Synchronization Tests', () {
    late MockAnalyticsService mockAnalytics;
    late MockRepo mockRepo;
    late TransformationEngineNotifier notifier;

    setUp(() {
      mockAnalytics = MockAnalyticsService();
      mockRepo = MockRepo();
      notifier = TransformationEngineNotifier(
        repository: mockRepo,
        analytics: mockAnalytics,
        autoInit: false,
      );

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final testWorkout = DailyWorkout(
        id: 'test_$todayStr',
        date: todayStr,
        title: "Today's Strength Session",
        focusArea: 'Chest & Arms',
        estimatedDurationMin: 45,
        status: WorkoutStatus.scheduled,
        exercises: [
          const Exercise(
            id: 'ex_1',
            name: 'Dumbbell Bench Press',
            targetMuscle: 'Chest',
            equipmentRequired: 'dumbbells',
            sets: [
              ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 20.0),
              ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 20.0),
            ],
          ),
          const Exercise(
            id: 'ex_2',
            name: 'Dumbbell Bicep Curls',
            targetMuscle: 'Biceps',
            equipmentRequired: 'dumbbells',
            sets: [
              ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 12.0),
            ],
          ),
        ],
      );
      notifier.state = notifier.state.copyWith(workout: testWorkout);
    });

    test('effectiveTodayWorkoutStatus returns scheduled for today before completion', () {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      expect(notifier.state.workout.date, todayStr);
      expect(notifier.state.workout.status, WorkoutStatus.scheduled);
      // For today, it must NOT evaluate to skipped
      expect(notifier.state.effectiveTodayWorkoutStatus, WorkoutStatus.scheduled);
    });

    test('isProgressTrackedForDate accurately distinguishes scheduled vs completed', () {
      final pastDate = '2026-09-01';

      // Scheduled workout in recentWorkouts that was never done
      final scheduledPastWorkout = DailyWorkout(
        id: 'past_scheduled',
        date: pastDate,
        title: 'Unexecuted Workout',
        focusArea: 'Core',
        estimatedDurationMin: 30,
        status: WorkoutStatus.scheduled,
        exercises: [],
      );

      notifier.state = notifier.state.copyWith(
        recentWorkouts: {pastDate: scheduledPastWorkout},
      );

      // Should NOT be tracked because it was only scheduled
      expect(notifier.state.isProgressTrackedForDate(pastDate), false);

      // Once marked completed, it should be tracked
      final completedPastWorkout = scheduledPastWorkout.copyWith(
        status: WorkoutStatus.completed,
      );
      notifier.state = notifier.state.copyWith(
        recentWorkouts: {pastDate: completedPastWorkout},
      );
      expect(notifier.state.isProgressTrackedForDate(pastDate), true);
    });

    test('completeWorkout() updates workout status, recentWorkouts, progress, and logs Mixpanel', () {
      final todayStr = notifier.state.workout.date;

      notifier.completeWorkout();

      // 1. Status is completed
      expect(notifier.state.workout.status, WorkoutStatus.completed);
      expect(notifier.state.effectiveTodayWorkoutStatus, WorkoutStatus.completed);

      // 2. All sets marked completed
      for (final ex in notifier.state.workout.exercises) {
        for (final s in ex.sets) {
          expect(s.completed, true);
        }
      }

      // 3. recentWorkouts is updated synchronously in-memory
      expect(notifier.state.recentWorkouts.containsKey(todayStr), true);
      expect(notifier.state.recentWorkouts[todayStr]!.status, WorkoutStatus.completed);

      // 4. Progress entry added
      expect(notifier.state.progressHistory.any((p) => p.date == todayStr), true);
      expect(mockRepo.savedProgress.any((p) => p.date == todayStr), true);

      // 5. Mixpanel event prescription_completed logged
      expect(mockAnalytics.loggedEvents.any((e) => e['name'] == AuraAnalyticsEvents.prescriptionCompleted), true);
      final event = mockAnalytics.loggedEvents.firstWhere((e) => e['name'] == AuraAnalyticsEvents.prescriptionCompleted);
      expect(event['properties']['workout_type'], notifier.state.workout.title);
      expect(event['properties']['focus_area'], notifier.state.workout.focusArea);
      expect(event['properties']['coach_soul'], notifier.state.profile.coachSoul.name);
    });

    test('Toggling all exercise sets to completed automatically triggers completeWorkout()', () {
      final todayStr = notifier.state.workout.date;
      final exercises = notifier.state.workout.exercises;

      // Complete all sets across all exercises
      for (final ex in exercises) {
        for (int i = 0; i < ex.sets.length; i++) {
          notifier.updateExerciseSet(ex.id, i, true);
        }
      }

      // Verified automatic completion
      expect(notifier.state.workout.status, WorkoutStatus.completed);
      expect(notifier.state.recentWorkouts[todayStr]!.status, WorkoutStatus.completed);
      expect(mockAnalytics.loggedEvents.any((e) => e['name'] == AuraAnalyticsEvents.prescriptionCompleted), true);
    });

    test('Micro-deviations and substitutions keep recentWorkouts synchronized in-memory', () {
      final todayStr = notifier.state.workout.date;
      final firstEx = notifier.state.workout.exercises.first;

      // 1. Update set target (micro-deviation)
      notifier.updateSetTarget(firstEx.id, 0, targetReps: 15, targetWeightKg: 20.0);
      expect(notifier.state.workout.exercises.first.sets.first.targetReps, 15);
      expect(notifier.state.workout.exercises.first.sets.first.targetWeightKg, 20.0);
      expect(notifier.state.recentWorkouts[todayStr]!.exercises.first.sets.first.targetReps, 15);

      // 2. Substitute exercise
      const newDef = ExerciseDefinition(
        id: 'new_def',
        name: 'Incline Dumbbell Press',
        targetMuscle: 'Upper Chest',
        movementPattern: MovementPattern.horizontalPush,
        equipment: EquipmentType.dumbbells,
        instructions: 'Push at 30 degree incline',
      );
      notifier.substituteExercise(firstEx.id, newDef);
      expect(notifier.state.workout.exercises.first.name, 'Incline Dumbbell Press');
      expect(notifier.state.recentWorkouts[todayStr]!.exercises.first.name, 'Incline Dumbbell Press');
    });

    test('updateSetTarget updates targetDurationSeconds and reflects in recentWorkouts', () {
      final todayStr = notifier.state.workout.date;
      final firstEx = notifier.state.workout.exercises.first;

      // Update target duration to 45s (e.g. plank hold)
      notifier.updateSetTarget(firstEx.id, 0, newDurationSeconds: 45);

      expect(notifier.state.workout.exercises.first.sets.first.targetDurationSeconds, 45);
      expect(notifier.state.recentWorkouts[todayStr]!.exercises.first.sets.first.targetDurationSeconds, 45);
    });

    test('autoDeriveTodayWorkout hydrates ExerciseTrackingType and targetDurationSeconds from weeklyPlan plannedExercises', () async {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];
      final dayIndex = now.weekday - 1;

      final targetDayPlan = WeeklyDayPlan(
        dayName: 'Today',
        date: todayStr,
        title: 'Active Recovery & Core',
        focusArea: 'Core & Mobility',
        isRestDay: true,
        plannedExercises: [
          const PlannedExercise(
            name: 'Light Walking or Stationary Cycling (30 mins)',
            trackingType: ExerciseTrackingType.duration,
            targetSets: 1,
            targetDurationSeconds: 1800,
            notes: 'Zone 2 steady state',
          ),
          const PlannedExercise(
            name: 'Plank Hold',
            trackingType: ExerciseTrackingType.duration,
            targetSets: 3,
            targetDurationSeconds: 45,
            notes: 'Hold flat core',
          ),
          const PlannedExercise(
            name: 'Full Body Dynamic Stretching',
            trackingType: ExerciseTrackingType.completion,
            targetSets: 1,
            targetDurationSeconds: 600,
            notes: 'Gentle mobility',
          ),
        ],
      );

      final days = List.generate(7, (i) {
        if (i == dayIndex) return targetDayPlan;
        return WeeklyDayPlan(
          dayName: 'Day $i',
          date: '2026-09-0$i',
          title: 'Other Day',
          focusArea: 'Rest',
          isRestDay: true,
        );
      });

      final weeklyPlan = WeeklyPlan(
        weekId: 'w_test_planned',
        startDate: todayStr,
        endDate: todayStr,
        overview: 'Test overview',
        createdAt: todayStr,
        days: days,
      );

      await notifier.autoDeriveTodayWorkoutIfMissing('user_123', todayStr, explicitPlan: weeklyPlan);

      final derived = notifier.state.workout;
      expect(derived.exercises.length, 3);

      // 1. Walking: duration with 1 set of 1800s
      final walkingEx = derived.exercises[0];
      expect(walkingEx.name, 'Light Walking or Stationary Cycling (30 mins)');
      expect(walkingEx.trackingType, ExerciseTrackingType.duration);
      expect(walkingEx.sets.length, 1);
      expect(walkingEx.sets.first.targetDurationSeconds, 1800);

      // 2. Plank: duration with 3 sets of 45s
      final plankEx = derived.exercises[1];
      expect(plankEx.name, 'Plank Hold');
      expect(plankEx.trackingType, ExerciseTrackingType.duration);
      expect(plankEx.sets.length, 3);
      expect(plankEx.sets[0].targetDurationSeconds, 45);
      expect(plankEx.sets[1].targetDurationSeconds, 45);
      expect(plankEx.sets[2].targetDurationSeconds, 45);

      // 3. Dynamic Stretching: completion with 1 set
      final stretchEx = derived.exercises[2];
      expect(stretchEx.name, 'Full Body Dynamic Stretching');
      expect(stretchEx.trackingType, ExerciseTrackingType.completion);
      expect(stretchEx.sets.length, 1);
      expect(stretchEx.sets.first.targetDurationSeconds, 600);
    });
  });
}
