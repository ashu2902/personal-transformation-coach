class CuratedMeal {
  final String id;
  final String name;
  final String slotName; // e.g. "Breakfast", "Post-Workout Lunch", "Evening Snack", "Dinner"
  final String description; // Ingredients, portions & notes
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final String? prepTime; // e.g. "15 mins"
  final String? instructions; // Quick cooking tip / prep advice
  final List<String> tags; // e.g. ['High Protein', 'Gluten-Free']
  final bool isLogged;

  const CuratedMeal({
    required this.id,
    required this.name,
    required this.slotName,
    required this.description,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.prepTime,
    this.instructions,
    this.tags = const [],
    this.isLogged = false,
  });

  factory CuratedMeal.fromJson(Map<String, dynamic> json) {
    return CuratedMeal(
      id: json['id']?.toString() ?? 'meal_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? 'Curated Meal',
      slotName: json['slotName']?.toString() ?? 'Meal',
      description: json['description']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
      fatG: (json['fatG'] as num?)?.toInt() ?? 0,
      prepTime: json['prepTime']?.toString(),
      instructions: json['instructions']?.toString(),
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      isLogged: json['isLogged'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slotName': slotName,
      'description': description,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      if (prepTime != null) 'prepTime': prepTime,
      if (instructions != null) 'instructions': instructions,
      'tags': tags,
      'isLogged': isLogged,
    };
  }

  CuratedMeal copyWith({
    String? id,
    String? name,
    String? slotName,
    String? description,
    int? calories,
    int? proteinG,
    int? carbsG,
    int? fatG,
    String? prepTime,
    String? instructions,
    List<String>? tags,
    bool? isLogged,
  }) {
    return CuratedMeal(
      id: id ?? this.id,
      name: name ?? this.name,
      slotName: slotName ?? this.slotName,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      prepTime: prepTime ?? this.prepTime,
      instructions: instructions ?? this.instructions,
      tags: tags ?? this.tags,
      isLogged: isLogged ?? this.isLogged,
    );
  }
}

class CuratedMealPlan {
  final String id;
  final String date; // YYYY-MM-DD
  final String title; // e.g. "Upper Body Strength Fueling Strategy"
  final String overview; // AI explanation connecting nutrition to today's workout
  final int totalCalories;
  final int totalProteinG;
  final int totalCarbsG;
  final int totalFatG;
  final List<CuratedMeal> meals; // Dynamic length: 2, 3, 4, 5, etc.
  final String? coachNotes;
  final String createdAt;

  const CuratedMealPlan({
    required this.id,
    required this.date,
    required this.title,
    required this.overview,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.meals,
    this.coachNotes,
    required this.createdAt,
  });

  factory CuratedMealPlan.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'] as List? ?? [];
    final parsedMeals = rawMeals
        .map((m) => CuratedMeal.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();

    return CuratedMealPlan(
      id: json['id']?.toString() ?? 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      date: json['date']?.toString() ?? '',
      title: json['title']?.toString() ?? "Today's Curated Meal Plan",
      overview: json['overview']?.toString() ?? '',
      totalCalories: (json['totalCalories'] as num?)?.toInt() ??
          parsedMeals.fold<int>(0, (sum, m) => sum + m.calories),
      totalProteinG: (json['totalProteinG'] as num?)?.toInt() ??
          parsedMeals.fold<int>(0, (sum, m) => sum + m.proteinG),
      totalCarbsG: (json['totalCarbsG'] as num?)?.toInt() ??
          parsedMeals.fold<int>(0, (sum, m) => sum + m.carbsG),
      totalFatG: (json['totalFatG'] as num?)?.toInt() ??
          parsedMeals.fold<int>(0, (sum, m) => sum + m.fatG),
      meals: parsedMeals,
      coachNotes: json['coachNotes']?.toString(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'overview': overview,
      'totalCalories': totalCalories,
      'totalProteinG': totalProteinG,
      'totalCarbsG': totalCarbsG,
      'totalFatG': totalFatG,
      'meals': meals.map((m) => m.toJson()).toList(),
      if (coachNotes != null) 'coachNotes': coachNotes,
      'createdAt': createdAt,
    };
  }

  CuratedMealPlan copyWith({
    String? id,
    String? date,
    String? title,
    String? overview,
    int? totalCalories,
    int? totalProteinG,
    int? totalCarbsG,
    int? totalFatG,
    List<CuratedMeal>? meals,
    String? coachNotes,
    String? createdAt,
  }) {
    return CuratedMealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteinG: totalProteinG ?? this.totalProteinG,
      totalCarbsG: totalCarbsG ?? this.totalCarbsG,
      totalFatG: totalFatG ?? this.totalFatG,
      meals: meals ?? this.meals,
      coachNotes: coachNotes ?? this.coachNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
