// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealItem _$MealItemFromJson(Map<String, dynamic> json) => _MealItem(
      name: json['name'] as String,
      calories: (json['calories'] as num).toInt(),
      proteinG: (json['proteinG'] as num).toInt(),
      carbsG: (json['carbsG'] as num).toInt(),
      fatG: (json['fatG'] as num).toInt(),
    );

Map<String, dynamic> _$MealItemToJson(_MealItem instance) => <String, dynamic>{
      'name': instance.name,
      'calories': instance.calories,
      'proteinG': instance.proteinG,
      'carbsG': instance.carbsG,
      'fatG': instance.fatG,
    };

_DailyNutrition _$DailyNutritionFromJson(Map<String, dynamic> json) =>
    _DailyNutrition(
      date: json['date'] as String,
      targetCalories: (json['targetCalories'] as num).toInt(),
      targetProteinG: (json['targetProteinG'] as num).toInt(),
      targetCarbsG: (json['targetCarbsG'] as num).toInt(),
      targetFatG: (json['targetFatG'] as num).toInt(),
      waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
      targetWaterMl: (json['targetWaterMl'] as num?)?.toInt() ?? 3200,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DailyNutritionToJson(_DailyNutrition instance) =>
    <String, dynamic>{
      'date': instance.date,
      'targetCalories': instance.targetCalories,
      'targetProteinG': instance.targetProteinG,
      'targetCarbsG': instance.targetCarbsG,
      'targetFatG': instance.targetFatG,
      'waterMl': instance.waterMl,
      'targetWaterMl': instance.targetWaterMl,
      'meals': instance.meals,
    };
