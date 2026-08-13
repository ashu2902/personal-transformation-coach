import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

abstract class ITransformationRepository {
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<DailyWorkout?> loadTodayWorkout(String dateStr);
  Future<void> saveTodayWorkout(DailyWorkout workout);

  Future<DailyNutrition?> loadTodayNutrition(String dateStr);
  Future<void> saveTodayNutrition(DailyNutrition nutrition);

  Future<RecoveryCheckIn?> loadTodayRecovery(String dateStr);
  Future<void> saveTodayRecovery(RecoveryCheckIn recovery);

  Future<List<ProgressEntry>> loadProgressHistory();
  Future<void> saveProgressEntry(ProgressEntry entry);

  Future<String?> loadApiKey();
  Future<void> saveApiKey(String key);
}

class LocalTransformationRepository implements ITransformationRepository {
  static const String _keyProfile = 'aura_user_profile';
  static const String _keyWorkout = 'aura_daily_workout_';
  static const String _keyNutrition = 'aura_daily_nutrition_';
  static const String _keyRecovery = 'aura_daily_recovery_';
  static const String _keyProgress = 'aura_progress_history';
  static const String _keyApiKey = 'aura_gemini_api_key';

  @override
  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey);
  }

  @override
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }

  @override
  Future<UserProfile?> loadProfile() async {
    debugPrint('[AURA REPOSITORY] Loading user profile from localStorage...');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      debugPrint('[AURA REPOSITORY] No profile found in localStorage (New session)');
      return null;
    }
    try {
      final map = jsonDecode(jsonStr);
      final profile = UserProfile(
        name: map['name'] ?? '',
        age: map['age'] ?? 25,
        heightCm: (map['heightCm'] as num).toDouble(),
        weightKg: (map['weightKg'] as num).toDouble(),
        targetWeightKg: (map['targetWeightKg'] as num).toDouble(),
        goal: GoalType.values.firstWhere((g) => g.name == map['goal'], orElse: () => GoalType.recomp),
        daysPerWeek: map['daysPerWeek'] ?? 4,
        targetPhysique: map['targetPhysique'] ?? 'Athletic Physique',
        availableEquipment: (map['availableEquipment'] as List? ?? [])
            .map((e) => EquipmentType.values.firstWhere((eq) => eq.name == e, orElse: () => EquipmentType.dumbbells))
            .toList(),
        experienceLevel: ExperienceLevel.values.firstWhere((exp) => exp.name == map['experienceLevel'], orElse: () => ExperienceLevel.intermediate),
        benchPress1RMKg: (map['benchPress1RMKg'] as num?)?.toDouble(),
        squat1RMKg: (map['squat1RMKg'] as num?)?.toDouble(),
        deadlift1RMKg: (map['deadlift1RMKg'] as num?)?.toDouble(),
        activeInjuries: (map['activeInjuries'] as List? ?? []).map((e) => e.toString()).toList(),
      );
      debugPrint('[AURA REPOSITORY] Loaded profile for: ${profile.name} (${profile.goal.name})');
      return profile;
    } catch (e) {
      debugPrint('[AURA REPOSITORY] Error loading profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    debugPrint('[AURA REPOSITORY] Saving profile: ${profile.name} (${profile.goal.name})');
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'name': profile.name,
      'age': profile.age,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'targetWeightKg': profile.targetWeightKg,
      'goal': profile.goal.name,
      'daysPerWeek': profile.daysPerWeek,
      'targetPhysique': profile.targetPhysique,
      'availableEquipment': profile.availableEquipment.map((e) => e.name).toList(),
      'experienceLevel': profile.experienceLevel.name,
      'benchPress1RMKg': profile.benchPress1RMKg,
      'squat1RMKg': profile.squat1RMKg,
      'deadlift1RMKg': profile.deadlift1RMKg,
      'activeInjuries': profile.activeInjuries,
    };
    await prefs.setString(_keyProfile, jsonEncode(map));
    debugPrint('[AURA REPOSITORY] Profile saved to localStorage successfully');
  }

  @override
  Future<DailyWorkout?> loadTodayWorkout(String dateStr) async {
    debugPrint('[AURA REPOSITORY] Loading workout for date: $dateStr');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_keyWorkout$dateStr');
    if (jsonStr == null || jsonStr.isEmpty) {
      debugPrint('[AURA REPOSITORY] No workout entry found for $dateStr');
      return null;
    }
    try {
      final map = jsonDecode(jsonStr);
      final workout = DailyWorkout(
        id: map['id'],
        date: map['date'],
        title: map['title'],
        focusArea: map['focusArea'],
        estimatedDurationMin: map['estimatedDurationMin'],
        status: WorkoutStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => WorkoutStatus.scheduled),
        exercises: (map['exercises'] as List? ?? []).map((e) {
          return Exercise(
            id: e['id'],
            name: e['name'],
            targetMuscle: e['targetMuscle'],
            equipmentRequired: EquipmentType.values.firstWhere((eq) => eq.name == e['equipmentRequired'], orElse: () => EquipmentType.dumbbells),
            sets: (e['sets'] as List? ?? []).map((s) {
              return ExerciseSet(
                setNumber: s['setNumber'],
                targetReps: s['targetReps'],
                targetWeightKg: (s['targetWeightKg'] as num).toDouble(),
                completed: s['completed'] ?? false,
              );
            }).toList(),
          );
        }).toList(),
      );
      debugPrint('[AURA REPOSITORY] Loaded workout: ${workout.title} (${workout.exercises.length} exercises)');
      return workout;
    } catch (e) {
      debugPrint('[AURA REPOSITORY] Error loading workout: $e');
      return null;
    }
  }

  @override
  Future<void> saveTodayWorkout(DailyWorkout workout) async {
    debugPrint('[AURA REPOSITORY] Saving workout: ${workout.title} (${workout.status.name})');
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'id': workout.id,
      'date': workout.date,
      'title': workout.title,
      'focusArea': workout.focusArea,
      'estimatedDurationMin': workout.estimatedDurationMin,
      'status': workout.status.name,
      'exercises': workout.exercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'targetMuscle': e.targetMuscle,
        'equipmentRequired': e.equipmentRequired.name,
        'sets': e.sets.map((s) => {
          'setNumber': s.setNumber,
          'targetReps': s.targetReps,
          'targetWeightKg': s.targetWeightKg,
          'completed': s.completed,
        }).toList(),
      }).toList(),
    };
    await prefs.setString('$_keyWorkout${workout.date}', jsonEncode(map));
  }

  @override
  Future<DailyNutrition?> loadTodayNutrition(String dateStr) async {
    debugPrint('[AURA REPOSITORY] Loading nutrition for date: $dateStr');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_keyNutrition$dateStr');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      return DailyNutrition(
        date: map['date'],
        targetCalories: map['targetCalories'],
        targetProteinG: map['targetProteinG'],
        targetCarbsG: map['targetCarbsG'],
        targetFatG: map['targetFatG'],
        waterMl: map['waterMl'] ?? 0,
        targetWaterMl: map['targetWaterMl'] ?? 3200,
        meals: (map['meals'] as List? ?? []).map((m) {
          return MealItem(
            name: m['name'],
            calories: m['calories'],
            proteinG: m['proteinG'],
            carbsG: m['carbsG'],
            fatG: m['fatG'],
          );
        }).toList(),
      );
    } catch (e) {
      debugPrint('[AURA REPOSITORY] Error loading nutrition: $e');
      return null;
    }
  }

  @override
  Future<void> saveTodayNutrition(DailyNutrition nutrition) async {
    debugPrint('[AURA REPOSITORY] Saving nutrition: ${nutrition.targetCalories} kcal target');
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'date': nutrition.date,
      'targetCalories': nutrition.targetCalories,
      'targetProteinG': nutrition.targetProteinG,
      'targetCarbsG': nutrition.targetCarbsG,
      'targetFatG': nutrition.targetFatG,
      'waterMl': nutrition.waterMl,
      'targetWaterMl': nutrition.targetWaterMl,
      'meals': nutrition.meals.map((m) => {
        'name': m.name,
        'calories': m.calories,
        'proteinG': m.proteinG,
        'carbsG': m.carbsG,
        'fatG': m.fatG,
      }).toList(),
    };
    await prefs.setString('$_keyNutrition${nutrition.date}', jsonEncode(map));
  }

  @override
  Future<RecoveryCheckIn?> loadTodayRecovery(String dateStr) async {
    debugPrint('[AURA REPOSITORY] Loading recovery check-in for date: $dateStr');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_keyRecovery$dateStr');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      return RecoveryCheckIn(
        date: map['date'],
        sleepHours: (map['sleepHours'] as num).toDouble(),
        sleepQuality: map['sleepQuality'],
        muscleSoreness: map['muscleSoreness'],
        energyLevel: map['energyLevel'],
        stressLevel: map['stressLevel'],
        recoveryScore: map['recoveryScore'],
        status: map['status'],
      );
    } catch (e) {
      debugPrint('[AURA REPOSITORY] Error loading recovery: $e');
      return null;
    }
  }

  @override
  Future<void> saveTodayRecovery(RecoveryCheckIn recovery) async {
    debugPrint('[AURA REPOSITORY] Saving recovery: Score ${recovery.recoveryScore}% (${recovery.status})');
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'date': recovery.date,
      'sleepHours': recovery.sleepHours,
      'sleepQuality': recovery.sleepQuality,
      'muscleSoreness': recovery.muscleSoreness,
      'energyLevel': recovery.energyLevel,
      'stressLevel': recovery.stressLevel,
      'recoveryScore': recovery.recoveryScore,
      'status': recovery.status,
    };
    await prefs.setString('$_keyRecovery${recovery.date}', jsonEncode(map));
  }

  @override
  Future<List<ProgressEntry>> loadProgressHistory() async {
    debugPrint('[AURA REPOSITORY] Loading progress entry history...');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProgress);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((p) => ProgressEntry(
        date: p['date'],
        weightKg: (p['weightKg'] as num).toDouble(),
        bodyFatPercent: p['bodyFatPercent'] != null ? (p['bodyFatPercent'] as num).toDouble() : null,
        notes: p['notes'],
      )).toList();
    } catch (e) {
      debugPrint('[AURA REPOSITORY] Error loading progress history: $e');
      return [];
    }
  }

  @override
  Future<void> saveProgressEntry(ProgressEntry entry) async {
    debugPrint('[AURA REPOSITORY] Saving progress entry: Weight ${entry.weightKg} kg on ${entry.date}');
    final prefs = await SharedPreferences.getInstance();
    final current = await loadProgressHistory();
    current.removeWhere((p) => p.date == entry.date);
    current.add(entry);
    final mapList = current.map((p) => {
      'date': p.date,
      'weightKg': p.weightKg,
      'bodyFatPercent': p.bodyFatPercent,
      'notes': p.notes,
    }).toList();
    await prefs.setString(_keyProgress, jsonEncode(mapList));
  }
}
