import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/providers/transformation_state.dart';
import 'package:aura_transformation_engine/providers/analytics_provider.dart';
import 'package:aura_transformation_engine/services/analytics_service.dart';
import 'package:aura_transformation_engine/screens/widgets/curated_meal_card.dart';
import 'package:aura_transformation_engine/screens/today_screen.dart';
import 'package:aura_transformation_engine/theme/theme.dart';

class MockAnalyticsService implements IAnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> registerSuperProperties(Map<String, dynamic> properties) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    loggedEvents.add({
      'name': eventName,
      'properties': properties,
    });
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await logEvent(AuraAnalyticsEvents.screenViewed, properties: {'screen_name': screenName});
  }
}

void main() {
  group('CuratedMeal & CuratedMealPlan Model Tests', () {
    test('CuratedMeal parses from and serializes to JSON correctly', () {
      final json = {
        'id': 'meal_123',
        'name': 'Grilled Salmon with Quinoa & Asparagus',
        'slotName': 'Post-Workout Dinner',
        'description': '200g wild salmon, 1 cup cooked quinoa, 150g steamed asparagus',
        'calories': 620,
        'proteinG': 48,
        'carbsG': 52,
        'fatG': 22,
        'prepTime': '20 mins',
        'instructions': 'Pan-sear salmon in olive oil for 4 mins each side.',
        'tags': ['High Protein', 'Omega-3', 'Gluten-Free'],
        'isLogged': false,
      };

      final meal = CuratedMeal.fromJson(json);
      expect(meal.id, 'meal_123');
      expect(meal.name, 'Grilled Salmon with Quinoa & Asparagus');
      expect(meal.slotName, 'Post-Workout Dinner');
      expect(meal.calories, 620);
      expect(meal.proteinG, 48);
      expect(meal.carbsG, 52);
      expect(meal.fatG, 22);
      expect(meal.prepTime, '20 mins');
      expect(meal.tags.length, 3);
      expect(meal.isLogged, false);

      final serialized = meal.toJson();
      expect(serialized['id'], 'meal_123');
      expect(serialized['calories'], 620);
      expect(serialized['tags'], ['High Protein', 'Omega-3', 'Gluten-Free']);
    });

    test('CuratedMealPlan supports dynamic meal counts (e.g. 2 IF meals or 4 standard meals)', () {
      final meals = [
        const CuratedMeal(
          id: 'm1',
          name: 'Power Break-Fast Bowl',
          slotName: 'Meal 1 (12:00 PM)',
          description: '4 eggs, avocado, sourdough toast, and fruit',
          calories: 850,
          proteinG: 55,
          carbsG: 70,
          fatG: 38,
        ),
        const CuratedMeal(
          id: 'm2',
          name: 'Steak & Sweet Potato Feast',
          slotName: 'Meal 2 (7:00 PM)',
          description: '250g sirloin steak, baked sweet potato, large green salad',
          calories: 1150,
          proteinG: 95,
          carbsG: 80,
          fatG: 45,
        ),
      ];

      final plan = CuratedMealPlan(
        id: 'cmp_if_01',
        date: '2026-09-10',
        title: '16:8 Intermittent Fasting Strategy',
        overview: 'Two high-density meals timed around evening resistance training.',
        totalCalories: 2000,
        totalProteinG: 150,
        totalCarbsG: 150,
        totalFatG: 83,
        meals: meals,
        createdAt: '2026-09-10T12:00:00Z',
      );

      expect(plan.meals.length, 2);
      expect(plan.totalCalories, 2000);
      expect(plan.totalProteinG, 150);

      final json = plan.toJson();
      final revived = CuratedMealPlan.fromJson(json);
      expect(revived.meals.length, 2);
      expect(revived.meals.first.name, 'Power Break-Fast Bowl');
      expect(revived.meals.last.calories, 1150);
    });

    test('DailyNutrition serializes and deserializes CuratedMealPlan cleanly', () {
      const plan = CuratedMealPlan(
        id: 'cmp_today',
        date: '2026-09-10',
        title: 'High Protein Day',
        overview: 'Calibrated for upper body hypertrophy.',
        totalCalories: 2400,
        totalProteinG: 175,
        totalCarbsG: 220,
        totalFatG: 70,
        meals: [
          CuratedMeal(
            id: 'm1',
            name: 'Protein Oatmeal',
            slotName: 'Breakfast',
            description: 'Oats, whey, peanut butter',
            calories: 550,
            proteinG: 45,
            carbsG: 60,
            fatG: 14,
          ),
        ],
        createdAt: '2026-09-10T08:00:00Z',
      );

      const nutrition = DailyNutrition(
        date: '2026-09-10',
        targetCalories: 2400,
        targetProteinG: 175,
        targetCarbsG: 220,
        targetFatG: 70,
        targetWaterMl: 3000,
        waterMl: 1000,
        meals: [],
        curatedMealPlan: plan,
      );

      final json = nutrition.toJson();
      expect(json['curatedMealPlan'], isNotNull);

      final restored = DailyNutrition.fromJson(json);
      expect(restored.curatedMealPlan, isNotNull);
      expect(restored.curatedMealPlan!.title, 'High Protein Day');
      expect(restored.curatedMealPlan!.meals.length, 1);

      // Verify clearCuratedMealPlan in copyWith
      final cleared = restored.copyWith(clearCuratedMealPlan: true);
      expect(cleared.curatedMealPlan, isNull);
    });
  });

  group('CuratedMealCard Widget Tests', () {
    testWidgets('Renders meal details and triggers onLog', (tester) async {
      bool logClicked = false;
      const meal = CuratedMeal(
        id: 'm_test',
        name: 'Turkey Quinoa Skillet',
        slotName: 'Lunch',
        description: '200g ground turkey, 1 cup quinoa, peppers & onions',
        calories: 580,
        proteinG: 46,
        carbsG: 50,
        fatG: 18,
        prepTime: '15 mins',
        instructions: 'Cook turkey in non-stick pan, add pre-cooked quinoa and veg.',
        tags: ['High Protein'],
        isLogged: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: getAuraTheme(CoachSoul.supporter),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CuratedMealCard(
                meal: meal,
                onLog: () => logClicked = true,
              ),
            ),
          ),
        ),
      );

      // Verify UI elements
      expect(find.text('LUNCH'), findsOneWidget);
      expect(find.text('Turkey Quinoa Skillet'), findsOneWidget);
      expect(find.text('580 kcal'), findsOneWidget);
      expect(find.text('46g P'), findsOneWidget);
      expect(find.text('50g C'), findsOneWidget);
      expect(find.text('18g F'), findsOneWidget);
      expect(find.text('15 mins'), findsOneWidget);
      expect(find.text('High Protein'), findsOneWidget);

      // Verify expandable cooking instructions
      expect(find.text('View ingredients & prep'), findsOneWidget);
      await tester.tap(find.text('View ingredients & prep'));
      await tester.pumpAndSettle();
      expect(find.text('Cook turkey in non-stick pan, add pre-cooked quinoa and veg.'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);

      // Verify Log This Meal CTA
      expect(find.text('Log This Meal (+580 kcal)'), findsOneWidget);
      await tester.tap(find.text('Log This Meal (+580 kcal)'));
      expect(logClicked, isTrue);
    });

    testWidgets('Renders logged state when isLogged is true', (tester) async {
      const loggedMeal = CuratedMeal(
        id: 'm_logged',
        name: 'Whey Protein & Greek Yogurt',
        slotName: 'Post-Workout',
        description: '1 scoop whey with 200g non-fat Greek yogurt',
        calories: 260,
        proteinG: 45,
        carbsG: 12,
        fatG: 2,
        isLogged: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: getAuraTheme(CoachSoul.pro),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: CuratedMealCard(meal: loggedMeal),
            ),
          ),
        ),
      );

      expect(find.text('Logged to Today\'s Fuel'), findsOneWidget);
      expect(find.text('Log This Meal (+260 kcal)'), findsNothing);
    });
  });

  group('Transformation State & Nutrition Mutations Integration', () {
    test('logCuratedMeal adds MealItem, marks isLogged in CuratedMealPlan, and tracks event', () async {
      final mockAnalytics = MockAnalyticsService();
      final notifier = TransformationEngineNotifier(
        analytics: mockAnalytics,
      );

      const curatedPlan = CuratedMealPlan(
        id: 'plan_01',
        date: '2026-09-10',
        title: 'Daily Fuel Strategy',
        overview: 'Balanced meals for recovery',
        totalCalories: 1800,
        totalProteinG: 140,
        totalCarbsG: 180,
        totalFatG: 50,
        meals: [
          CuratedMeal(
            id: 'm_1',
            name: 'Protein Oatmeal',
            slotName: 'Breakfast',
            description: 'Oats and whey',
            calories: 450,
            proteinG: 35,
            carbsG: 55,
            fatG: 10,
            isLogged: false,
          ),
          CuratedMeal(
            id: 'm_2',
            name: 'Chicken Rice Bowl',
            slotName: 'Lunch',
            description: 'Grilled chicken breast with rice',
            calories: 650,
            proteinG: 55,
            carbsG: 65,
            fatG: 15,
            isLogged: false,
          ),
        ],
        createdAt: '2026-09-10T08:00:00Z',
      );

      // Set state with curated meal plan
      notifier.state = notifier.state.copyWith(
        nutrition: notifier.state.nutrition.copyWith(
          curatedMealPlan: curatedPlan,
        ),
      );

      expect(notifier.state.nutrition.meals.length, 0);
      expect(notifier.state.nutrition.curatedMealPlan!.meals[0].isLogged, false);

      // Log first meal
      final mealToLog = notifier.state.nutrition.curatedMealPlan!.meals[0];
      await notifier.logCuratedMeal(mealToLog);

      // Verify nutrition meals list has 1 item with correct macros
      expect(notifier.state.nutrition.meals.length, 1);
      final loggedItem = notifier.state.nutrition.meals.first;
      expect(loggedItem.name, 'Protein Oatmeal');
      expect(loggedItem.calories, 450);
      expect(loggedItem.proteinG, 35);

      // Verify curatedMealPlan meal is now marked isLogged = true
      expect(notifier.state.nutrition.curatedMealPlan!.meals[0].isLogged, true);
      expect(notifier.state.nutrition.curatedMealPlan!.meals[1].isLogged, false);

      // Verify Mixpanel event was tracked
      final curatedLoggedEvents = mockAnalytics.loggedEvents
          .where((e) => e['name'] == AuraAnalyticsEvents.curatedMealLogged)
          .toList();
      expect(curatedLoggedEvents.length, 1);
      final eventProps = curatedLoggedEvents.first['properties'] as Map<String, dynamic>;
      expect(eventProps['slot_name'], 'Breakfast');
      expect(eventProps['calories'], 450);
      expect(eventProps['protein_g'], 35);
    });
  });

  group('TodayScreen Curated Meal Integration Widget Tests', () {
    testWidgets('Shows Curate Today\'s Meal Plan callout when curatedMealPlan is null', (tester) async {
      final mockAnalytics = MockAnalyticsService();
      final notifier = TransformationEngineNotifier(analytics: mockAnalytics);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transformationEngineProvider.overrideWith((ref) => notifier),
            analyticsServiceProvider.overrideWithValue(mockAnalytics),
          ],
          child: MaterialApp(
            theme: getAuraTheme(CoachSoul.supporter),
            home: const Scaffold(body: TodayScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CURATED DAILY MEAL PLAN'), findsOneWidget);
      expect(find.text('Curate Today\'s Meal Plan'), findsOneWidget);
    });

    testWidgets('Shows Today\'s Curated Meals and Adjust Plan when plan exists', (tester) async {
      final mockAnalytics = MockAnalyticsService();
      final notifier = TransformationEngineNotifier(analytics: mockAnalytics);

      const curatedPlan = CuratedMealPlan(
        id: 'plan_today',
        date: '2026-09-10',
        title: 'High Protein Recovery Plan',
        overview: 'Fueled for intense session',
        totalCalories: 2200,
        totalProteinG: 160,
        totalCarbsG: 230,
        totalFatG: 65,
        meals: [
          CuratedMeal(
            id: 'm1',
            name: 'Greek Yogurt Parfait',
            slotName: 'Breakfast',
            description: 'Greek yogurt with blueberries and almonds',
            calories: 380,
            proteinG: 32,
            carbsG: 35,
            fatG: 12,
          ),
        ],
        createdAt: '2026-09-10T08:00:00Z',
      );

      notifier.state = notifier.state.copyWith(
        nutrition: notifier.state.nutrition.copyWith(
          curatedMealPlan: curatedPlan,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transformationEngineProvider.overrideWith((ref) => notifier),
            analyticsServiceProvider.overrideWithValue(mockAnalytics),
          ],
          child: MaterialApp(
            theme: getAuraTheme(CoachSoul.supporter),
            home: const Scaffold(body: TodayScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("TODAY'S CURATED MEALS"), findsOneWidget);
      expect(find.text('Adjust Plan'), findsOneWidget);
      expect(find.text('High Protein Recovery Plan'), findsOneWidget);
      expect(find.text('Greek Yogurt Parfait'), findsOneWidget);
    });
  });
}
