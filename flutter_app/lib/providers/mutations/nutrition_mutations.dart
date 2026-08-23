import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../transformation_state.dart';

/// Domain mutations for Nutrition targets, logged meals, portion corrections, and water.
mixin NutritionMutations on StateNotifier<TransformationEngineState> {
  void addWater(int amountMl) {
    final newWater = state.nutrition.waterMl + amountMl;
    debugPrint('[AURA STATE] Added +${amountMl}ml water (Total: ${newWater}ml)');
    final updatedNutrition = state.nutrition.copyWith(waterMl: newWater);
    state = state.copyWith(nutrition: updatedNutrition);
    saveNutritionToRemote(state.nutrition.date, updatedNutrition);
  }

  void addMeal(MealItem meal) {
    debugPrint('[AURA STATE] Added meal: ${meal.name} (${meal.calories} kcal, ${meal.proteinG}g P)');
    final newMeals = List<MealItem>.from(state.nutrition.meals)..add(meal);
    final updatedNutrition = state.nutrition.copyWith(meals: newMeals);
    state = state.copyWith(nutrition: updatedNutrition);
    saveNutritionToRemote(state.nutrition.date, updatedNutrition);
  }

  void clearTodayNutrition() {
    debugPrint('[AURA STATE] Clearing today\'s logged nutrition entries...');
    final updatedNutrition = state.nutrition.copyWith(meals: []);
    state = state.copyWith(nutrition: updatedNutrition);
    saveNutritionToRemote(state.nutrition.date, updatedNutrition);
  }

  String resolveTargetDate(String? rawDate) {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    if (rawDate == null || rawDate.isEmpty || rawDate.toLowerCase() == 'today') {
      return todayStr;
    }
    if (rawDate.toLowerCase() == 'yesterday') {
      final yesterday = today.subtract(const Duration(days: 1));
      return yesterday.toIso8601String().split('T')[0];
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
      return rawDate;
    }
    return todayStr;
  }

  Future<void> logNutritionForDate({
    required List<MealItem> newMeals,
    int? waterMl,
    String? rawDate,
  }) async {
    final targetDate = resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    debugPrint('[AURA STATE] Logging nutrition for date: $targetDate (Today: $todayStr)');

    if (targetDate == todayStr) {
      final combined = List<MealItem>.from(state.nutrition.meals)..addAll(newMeals);
      var updated = state.nutrition.copyWith(meals: combined);
      if (waterMl != null && waterMl > 0) {
        updated = updated.copyWith(waterMl: updated.waterMl + waterMl);
      }
      state = state.copyWith(nutrition: updated);
      await saveNutritionToRemote(todayStr, updated);
    } else {
      final existing = await getRemoteNutrition(targetDate);
      final combined = List<MealItem>.from(existing.meals)..addAll(newMeals);
      var updated = existing.copyWith(date: targetDate, meals: combined);
      if (waterMl != null && waterMl > 0) {
        updated = updated.copyWith(waterMl: updated.waterMl + waterMl);
      }
      await saveNutritionToRemote(targetDate, updated);
    }
  }

  Future<void> removeMealFromDate({
    required String mealName,
    String? rawDate,
  }) async {
    final targetDate = resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final search = mealName.toLowerCase();

    debugPrint('[AURA STATE] Removing meal "$mealName" for date: $targetDate');

    if (targetDate == todayStr) {
      final updatedMeals = state.nutrition.meals.where((m) => !m.name.toLowerCase().contains(search)).toList();
      final updated = state.nutrition.copyWith(meals: updatedMeals);
      state = state.copyWith(nutrition: updated);
      await saveNutritionToRemote(todayStr, updated);
    } else {
      final existing = await getRemoteNutrition(targetDate);
      final updatedMeals = existing.meals.where((m) => !m.name.toLowerCase().contains(search)).toList();
      final updated = existing.copyWith(meals: updatedMeals);
      await saveNutritionToRemote(targetDate, updated);
    }
  }

  Future<void> updateMealPortionForDate({
    required String mealName,
    required num calories,
    required num proteinG,
    required num carbsG,
    required num fatG,
    String? rawDate,
  }) async {
    final targetDate = resolveTargetDate(rawDate);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final search = mealName.toLowerCase();

    debugPrint('[AURA STATE] Updating meal portion for "$mealName" on date: $targetDate');

    if (targetDate == todayStr) {
      final updatedMeals = state.nutrition.meals.map((m) {
        if (m.name.toLowerCase().contains(search) || search.contains(m.name.toLowerCase())) {
          return MealItem(
            name: m.name,
            calories: calories.toInt(),
            proteinG: proteinG.toInt(),
            carbsG: carbsG.toInt(),
            fatG: fatG.toInt(),
          );
        }
        return m;
      }).toList();
      final updated = state.nutrition.copyWith(meals: updatedMeals);
      state = state.copyWith(nutrition: updated);
      await saveNutritionToRemote(todayStr, updated);
    } else {
      final existing = await getRemoteNutrition(targetDate);
      final updatedMeals = existing.meals.map((m) {
        if (m.name.toLowerCase().contains(search) || search.contains(m.name.toLowerCase())) {
          return MealItem(
            name: m.name,
            calories: calories.toInt(),
            proteinG: proteinG.toInt(),
            carbsG: carbsG.toInt(),
            fatG: fatG.toInt(),
          );
        }
        return m;
      }).toList();
      final updated = existing.copyWith(meals: updatedMeals);
      await saveNutritionToRemote(targetDate, updated);
    }
  }

  /// Hook for remote persistence
  Future<void> saveNutritionToRemote(String date, DailyNutrition nutrition);
  Future<DailyNutrition> getRemoteNutrition(String date);
}
