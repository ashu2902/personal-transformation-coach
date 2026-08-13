class FoodItemDefinition {
  final String id;
  final String name;
  final String category;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final int defaultServingG;
  final String servingUnit;

  const FoodItemDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.defaultServingG = 100,
    this.servingUnit = 'g',
  });

  /// Scales macro values based on selected weight in grams
  Map<String, int> calculateMacrosForWeight(int weightGrams) {
    final factor = weightGrams / 100.0;
    return {
      'calories': (caloriesPer100g * factor).round(),
      'proteinG': (proteinPer100g * factor).round(),
      'carbsG': (carbsPer100g * factor).round(),
      'fatG': (fatPer100g * factor).round(),
    };
  }
}

class FoodDatabase {
  static const List<FoodItemDefinition> items = [
    // --- PROTEINS ---
    FoodItemDefinition(id: 'f_chicken_breast', name: 'Grilled Chicken Breast', category: 'Protein', caloriesPer100g: 165, proteinPer100g: 31.0, carbsPer100g: 0.0, fatPer100g: 3.6, defaultServingG: 150),
    FoodItemDefinition(id: 'f_whey_isolate', name: 'Whey Protein Isolate Scoop', category: 'Protein', caloriesPer100g: 375, proteinPer100g: 80.0, carbsPer100g: 3.0, fatPer100g: 1.5, defaultServingG: 30, servingUnit: 'scoop (30g)'),
    FoodItemDefinition(id: 'f_salmon_fillet', name: 'Pan-Seared Salmon Fillet', category: 'Protein', caloriesPer100g: 206, proteinPer100g: 22.0, carbsPer100g: 0.0, fatPer100g: 12.0, defaultServingG: 150),
    FoodItemDefinition(id: 'f_whole_eggs', name: 'Whole Eggs (2 Large)', category: 'Protein', caloriesPer100g: 143, proteinPer100g: 12.6, carbsPer100g: 0.7, fatPer100g: 9.5, defaultServingG: 100, servingUnit: '2 eggs'),
    FoodItemDefinition(id: 'f_egg_whites', name: 'Liquid Egg Whites', category: 'Protein', caloriesPer100g: 52, proteinPer100g: 11.0, carbsPer100g: 0.7, fatPer100g: 0.2, defaultServingG: 150),
    FoodItemDefinition(id: 'f_greek_yogurt', name: '0% Non-Fat Greek Yogurt', category: 'Protein', caloriesPer100g: 59, proteinPer100g: 10.0, carbsPer100g: 3.6, fatPer100g: 0.4, defaultServingG: 200),
    FoodItemDefinition(id: 'f_lean_beef', name: '93/7 Ground Beef', category: 'Protein', caloriesPer100g: 172, proteinPer100g: 24.0, carbsPer100g: 0.0, fatPer100g: 8.0, defaultServingG: 150),

    // --- CARBS & GRAINS ---
    FoodItemDefinition(id: 'f_white_rice', name: 'Steamed Jasmine White Rice', category: 'Carbs', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.0, fatPer100g: 0.3, defaultServingG: 150),
    FoodItemDefinition(id: 'f_rolled_oats', name: 'Rolled Oats (Dry)', category: 'Carbs', caloriesPer100g: 389, proteinPer100g: 16.9, carbsPer100g: 66.0, fatPer100g: 6.9, defaultServingG: 60),
    FoodItemDefinition(id: 'f_sweet_potato', name: 'Baked Sweet Potato', category: 'Carbs', caloriesPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20.0, fatPer100g: 0.1, defaultServingG: 200),
    FoodItemDefinition(id: 'f_quinoa', name: 'Cooked Quinoa', category: 'Carbs', caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 21.0, fatPer100g: 1.9, defaultServingG: 150),
    FoodItemDefinition(id: 'f_banana', name: 'Fresh Yellow Banana', category: 'Carbs', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23.0, fatPer100g: 0.3, defaultServingG: 120, servingUnit: '1 medium'),
    FoodItemDefinition(id: 'f_blueberries', name: 'Fresh Blueberries', category: 'Carbs', caloriesPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14.0, fatPer100g: 0.3, defaultServingG: 100),

    // --- HEALTHY FATS ---
    FoodItemDefinition(id: 'f_avocado', name: 'Fresh Avocado', category: 'Fats', caloriesPer100g: 160, proteinPer100g: 2.0, carbsPer100g: 8.5, fatPer100g: 14.7, defaultServingG: 100, servingUnit: '1/2 avocado'),
    FoodItemDefinition(id: 'f_almonds', name: 'Raw Almonds', category: 'Fats', caloriesPer100g: 579, proteinPer100g: 21.0, carbsPer100g: 21.6, fatPer100g: 49.9, defaultServingG: 30, servingUnit: 'handful (30g)'),
    FoodItemDefinition(id: 'f_peanut_butter', name: 'Natural Peanut Butter', category: 'Fats', caloriesPer100g: 588, proteinPer100g: 25.0, carbsPer100g: 20.0, fatPer100g: 50.0, defaultServingG: 32, servingUnit: '2 tbsp'),
    FoodItemDefinition(id: 'f_olive_oil', name: 'Extra Virgin Olive Oil', category: 'Fats', caloriesPer100g: 884, proteinPer100g: 0.0, carbsPer100g: 0.0, fatPer100g: 100.0, defaultServingG: 14, servingUnit: '1 tbsp'),
  ];

  /// Searches food library by keyword query
  static List<FoodItemDefinition> search(String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((f) => f.name.toLowerCase().contains(q) || f.category.toLowerCase().contains(q)).toList();
  }
}
