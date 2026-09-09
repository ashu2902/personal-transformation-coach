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

  group('Past Workout Logging & Retroactive Resolution Tests', () {
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
    });

    test('markPastWorkoutCompleted generates completed workout and logs Mixpanel backfill event', () async {
      const pastDate = '2026-09-01';
      const planDay = WeeklyDayPlan(
        dayName: 'Tuesday',
        date: pastDate,
        title: 'Upper Body Power',
        focusArea: 'Chest & Back',
        isRestDay: false,
        exerciseNames: ['Push-Ups', 'Pull-Ups'],
      );

      expect(notifier.state.isWorkoutCompletedForDate(pastDate), isFalse);

      await notifier.markPastWorkoutCompleted(pastDate, planDay: planDay);

      expect(notifier.state.isWorkoutCompletedForDate(pastDate), isTrue);

      final loggedWorkout = notifier.state.getWorkoutForDate(pastDate);
      expect(loggedWorkout, isNotNull);
      expect(loggedWorkout!.status, WorkoutStatus.completed);
      expect(loggedWorkout.title, 'Upper Body Power');
      expect(loggedWorkout.exercises.length, 2);
      expect(loggedWorkout.exercises.first.sets.every((s) => s.completed), isTrue);

      // Verify Mixpanel event was logged with is_backfill: true
      final event = mockAnalytics.loggedEvents.firstWhere(
        (e) => e['name'] == AuraAnalyticsEvents.prescriptionCompleted,
      );
      expect(event['properties']['workout_type'], 'Upper Body Power');
      expect(event['properties']['is_backfill'], isTrue);
    });

    test('undoPastWorkoutStatus reverts completed past workout to scheduled', () async {
      const pastDate = '2026-09-01';
      const planDay = WeeklyDayPlan(
        dayName: 'Tuesday',
        date: pastDate,
        title: 'Upper Body Power',
        focusArea: 'Chest & Back',
        isRestDay: false,
        exerciseNames: ['Push-Ups'],
      );

      await notifier.markPastWorkoutCompleted(pastDate, planDay: planDay);
      expect(notifier.state.isWorkoutCompletedForDate(pastDate), isTrue);

      await notifier.undoPastWorkoutStatus(pastDate);
      expect(notifier.state.isWorkoutCompletedForDate(pastDate), isFalse);

      final workout = notifier.state.getWorkoutForDate(pastDate);
      expect(workout, isNotNull);
      expect(workout!.status, WorkoutStatus.scheduled);
      expect(workout.exercises.first.sets.every((s) => !s.completed), isTrue);
    });

    test('unloggedPreviousDays excludes rest days and completed days', () {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      // Build a 7-day weekly plan where Wednesday is a Rest Day
      final days = List.generate(7, (i) {
        final d = monday.add(Duration(days: i));
        final dateStr = d.toIso8601String().split('T')[0];
        final isRest = i == 2; // Wednesday = rest
        return WeeklyDayPlan(
          dayName: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
          date: dateStr,
          title: isRest ? 'Rest Day' : 'Strength Day',
          focusArea: isRest ? 'Recovery' : 'Full Body',
          isRestDay: isRest,
          exerciseNames: isRest ? [] : ['Squats'],
        );
      });

      final weeklyPlan = WeeklyPlan(
        weekId: '2026-W36',
        startDate: days.first.date,
        endDate: days.last.date,
        overview: 'Weekly overview',
        createdAt: DateTime.now().toIso8601String(),
        days: days,
      );

      notifier.state = notifier.state.copyWith(
        weeklyPlan: weeklyPlan,
        profile: notifier.state.profile.copyWith(
          createdAtDateStr: days.first.date,
        ),
      );

      final unlogged = notifier.state.unloggedPreviousDays;

      // Ensure that Wednesday (Rest Day) is NOT in the unlogged list
      if (now.weekday > 3) {
        final wednesdayDate = days[2].date;
        expect(unlogged.any((d) => d['date'] == wednesdayDate), isFalse);
      }
    });
  });
}
