import 'curated_meal_plan.dart';

class MealItem {
  final String name;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  const MealItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
      fatG: (json['fatG'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };

  MealItem copyWith({
    String? name,
    int? calories,
    int? proteinG,
    int? carbsG,
    int? fatG,
  }) {
    return MealItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          calories == other.calories &&
          proteinG == other.proteinG &&
          carbsG == other.carbsG &&
          fatG == other.fatG;

  @override
  int get hashCode => Object.hash(name, calories, proteinG, carbsG, fatG);

  @override
  String toString() =>
      'MealItem(name: $name, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG)';
}

class DailyNutrition {
  final String date;
  final int targetCalories;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final int waterMl;
  final int targetWaterMl;
  final List<MealItem> meals;
  final CuratedMealPlan? curatedMealPlan;

  const DailyNutrition({
    required this.date,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    this.waterMl = 0,
    this.targetWaterMl = 3200,
    this.meals = const [],
    this.curatedMealPlan,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      date: json['date'] as String? ?? '',
      targetCalories: (json['targetCalories'] as num?)?.toInt() ?? 2000,
      targetProteinG: (json['targetProteinG'] as num?)?.toInt() ?? 150,
      targetCarbsG: (json['targetCarbsG'] as num?)?.toInt() ?? 200,
      targetFatG: (json['targetFatG'] as num?)?.toInt() ?? 60,
      waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
      targetWaterMl: (json['targetWaterMl'] as num?)?.toInt() ?? 3200,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      curatedMealPlan: json['curatedMealPlan'] != null
          ? CuratedMealPlan.fromJson(
              Map<String, dynamic>.from(json['curatedMealPlan'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'targetCalories': targetCalories,
        'targetProteinG': targetProteinG,
        'targetCarbsG': targetCarbsG,
        'targetFatG': targetFatG,
        'waterMl': waterMl,
        'targetWaterMl': targetWaterMl,
        'meals': meals.map((m) => m.toJson()).toList(),
        if (curatedMealPlan != null) 'curatedMealPlan': curatedMealPlan!.toJson(),
      };

  DailyNutrition copyWith({
    String? date,
    int? targetCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? waterMl,
    int? targetWaterMl,
    List<MealItem>? meals,
    CuratedMealPlan? curatedMealPlan,
    bool clearCuratedMealPlan = false,
  }) {
    return DailyNutrition(
      date: date ?? this.date,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      waterMl: waterMl ?? this.waterMl,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      meals: meals ?? this.meals,
      curatedMealPlan: clearCuratedMealPlan ? null : (curatedMealPlan ?? this.curatedMealPlan),
    );
  }

  int get totalCalories => meals.fold<int>(0, (sum, m) => sum + m.calories);
  int get totalProtein => meals.fold<int>(0, (sum, m) => sum + m.proteinG);
  int get totalCarbs => meals.fold<int>(0, (sum, m) => sum + m.carbsG);
  int get totalFat => meals.fold<int>(0, (sum, m) => sum + m.fatG);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyNutrition &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          targetCalories == other.targetCalories &&
          targetProteinG == other.targetProteinG &&
          targetCarbsG == other.targetCarbsG &&
          targetFatG == other.targetFatG &&
          waterMl == other.waterMl &&
          targetWaterMl == other.targetWaterMl &&
          curatedMealPlan == other.curatedMealPlan;

  @override
  int get hashCode => Object.hash(
        date,
        targetCalories,
        targetProteinG,
        targetCarbsG,
        targetFatG,
        waterMl,
        targetWaterMl,
        curatedMealPlan,
      );
}
