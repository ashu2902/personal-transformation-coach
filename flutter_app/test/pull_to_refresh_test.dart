import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_transformation_engine/models/user_profile.dart';
import 'package:aura_transformation_engine/screens/today_screen.dart';
import 'package:aura_transformation_engine/screens/insights_screen.dart';
import 'package:aura_transformation_engine/screens/profile_screen.dart';
import 'package:aura_transformation_engine/screens/workout_screen.dart';
import 'package:aura_transformation_engine/screens/weekly_plan_screen.dart';
import 'package:aura_transformation_engine/screens/coach_screen.dart';
import 'package:aura_transformation_engine/screens/nutrition_screen.dart';
import 'package:aura_transformation_engine/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: getAuraTheme(CoachSoul.supporter),
        home: Scaffold(body: child),
      ),
    );
  }

  group('Pull to Refresh (Swipe Down to Reload) Tests', () {
    testWidgets('TodayScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TodayScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('InsightsScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const InsightsScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('ProfileScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('WorkoutScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const WorkoutScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('WeeklyPlanScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const WeeklyPlanScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('NutritionScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const NutritionScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('CoachScreen contains RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CoachScreen()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
