import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition.freezed.dart';
part 'nutrition.g.dart';

@freezed
abstract class MealItem with _$MealItem {
  const MealItem._();

  const factory MealItem({
    required String name,
    required int calories,
    required int proteinG,
    required int carbsG,
    required int fatG,
  }) = _MealItem;

  factory MealItem.fromJson(Map<String, dynamic> json) => _$MealItemFromJson(json);
}

@freezed
abstract class DailyNutrition with _$DailyNutrition {
  const DailyNutrition._();

  const factory DailyNutrition({
    required String date,
    required int targetCalories,
    required int targetProteinG,
    required int targetCarbsG,
    required int targetFatG,
    @Default(0) int waterMl,
    @Default(3200) int targetWaterMl,
    @Default([]) List<MealItem> meals,
  }) = _DailyNutrition;

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => _$DailyNutritionFromJson(json);

  int get totalCalories => meals.fold<int>(0, (sum, m) => sum + m.calories);
  int get totalProtein => meals.fold<int>(0, (sum, m) => sum + m.proteinG);
  int get totalCarbs => meals.fold<int>(0, (sum, m) => sum + m.carbsG);
  int get totalFat => meals.fold<int>(0, (sum, m) => sum + m.fatG);
}
