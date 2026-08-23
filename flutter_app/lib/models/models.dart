import 'dart:typed_data';

enum Gender { male, female, other }

enum GoalType { fatLoss, muscleGain, recomp }

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.recomp:
        return 'Lose Fat & Build Muscle';
      case GoalType.fatLoss:
        return 'Burn Fat & Get Lean';
      case GoalType.muscleGain:
        return 'Build Muscle & Size';
    }
  }
}

enum EquipmentType { bodyweight, dumbbells, barbell, cables, machines }

class EquipmentItem {
  final String name;
  final String category; // 'free_weight', 'bodyweight', 'bands', 'machine', 'cables', 'other'
  final double? weightKg;
  final String? notes;

  const EquipmentItem({
    required this.name,
    this.category = 'free_weight',
    this.weightKg,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    if (weightKg != null) 'weightKg': weightKg,
    if (notes != null) 'notes': notes,
  };

  factory EquipmentItem.fromMap(Map<String, dynamic> map) => EquipmentItem(
    name: map['name']?.toString() ?? 'Equipment',
    category: map['category']?.toString() ?? 'free_weight',
    weightKg: (map['weightKg'] as num?)?.toDouble(),
    notes: map['notes']?.toString(),
  );

  factory EquipmentItem.fromString(String name, {double? weightKg, String? notes}) {
    final lower = name.toLowerCase();
    String cat = 'free_weight';
    if (lower.contains('bodyweight') || lower.contains('calisthenic') || lower.contains('pull-up') || lower.contains('push-up')) {
      cat = 'bodyweight';
    } else if (lower.contains('band')) {
      cat = 'bands';
    } else if (lower.contains('cable')) {
      cat = 'cables';
    } else if (lower.contains('machine')) {
      cat = 'machine';
    }
    double? detectedWeight = weightKg;
    if (detectedWeight == null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|lbs|kilos)', caseSensitive: false).firstMatch(name);
      if (match != null) {
        detectedWeight = double.tryParse(match.group(1)!);
      }
    }
    return EquipmentItem(name: name, category: cat, weightKg: detectedWeight, notes: notes);
  }

  EquipmentItem copyWith({
    String? name,
    String? category,
    double? weightKg,
    String? notes,
  }) {
    return EquipmentItem(
      name: name ?? this.name,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    final wStr = weightKg != null ? ' (${weightKg!.toStringAsFixed(weightKg! % 1 == 0 ? 0 : 1)}kg)' : '';
    return '$name$wStr';
  }
}

class ExerciseSet {
  final int setNumber;
  final int targetReps;
  final int? actualReps;
  final double targetWeightKg;
  final double? actualWeightKg;
  final bool completed;

  ExerciseSet({
    required this.setNumber,
    required this.targetReps,
    this.actualReps,
    required this.targetWeightKg,
    this.actualWeightKg,
    this.completed = false,
  });

  ExerciseSet copyWith({
    int? setNumber,
    int? targetReps,
    int? actualReps,
    double? targetWeightKg,
    double? actualWeightKg,
    bool? completed,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      completed: completed ?? this.completed,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final String equipmentRequired;
  final List<ExerciseSet> sets;
  final String? notes;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.equipmentRequired,
    required this.sets,
    this.notes,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? targetMuscle,
    String? equipmentRequired,
    List<ExerciseSet>? sets,
    String? notes,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      equipmentRequired: equipmentRequired ?? this.equipmentRequired,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }
}

enum WorkoutStatus { scheduled, completed, skipped, adapted }

class DailyWorkout {
  final String id;
  final String date;
  final String title;
  final String focusArea;
  final int estimatedDurationMin;
  final List<Exercise> exercises;
  final WorkoutStatus status;
  final String? adaptationNote;

  DailyWorkout({
    required this.id,
    required this.date,
    required this.title,
    required this.focusArea,
    required this.estimatedDurationMin,
    required this.exercises,
    this.status = WorkoutStatus.scheduled,
    this.adaptationNote,
  });

  DailyWorkout copyWith({
    String? id,
    String? date,
    String? title,
    String? focusArea,
    int? estimatedDurationMin,
    List<Exercise>? exercises,
    WorkoutStatus? status,
    String? adaptationNote,
  }) {
    return DailyWorkout(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      focusArea: focusArea ?? this.focusArea,
      estimatedDurationMin: estimatedDurationMin ?? this.estimatedDurationMin,
      exercises: exercises ?? this.exercises,
      status: status ?? this.status,
      adaptationNote: adaptationNote ?? this.adaptationNote,
    );
  }
}

class MealItem {
  final String name;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  MealItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
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

  DailyNutrition({
    required this.date,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    this.waterMl = 0,
    this.targetWaterMl = 3200,
    this.meals = const [],
  });

  DailyNutrition copyWith({
    String? date,
    int? targetCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? waterMl,
    int? targetWaterMl,
    List<MealItem>? meals,
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
    );
  }
}

class RecoveryCheckIn {
  final String date;
  final double sleepHours;
  final int sleepQuality;
  final int muscleSoreness;
  final int energyLevel;
  final int stressLevel;
  final int recoveryScore;
  final String status;

  RecoveryCheckIn({
    required this.date,
    required this.sleepHours,
    required this.sleepQuality,
    required this.muscleSoreness,
    required this.energyLevel,
    required this.stressLevel,
    required this.recoveryScore,
    required this.status,
  });

  RecoveryCheckIn copyWith({
    String? date,
    double? sleepHours,
    int? sleepQuality,
    int? muscleSoreness,
    int? energyLevel,
    int? stressLevel,
    int? recoveryScore,
    String? status,
  }) {
    return RecoveryCheckIn(
      date: date ?? this.date,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      muscleSoreness: muscleSoreness ?? this.muscleSoreness,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      recoveryScore: recoveryScore ?? this.recoveryScore,
      status: status ?? this.status,
    );
  }
}

class ProgressEntry {
  final String date;
  final double weightKg;
  final double? bodyFatPercent;
  final double? waistCm;
  final String? notes;
  final WorkoutStatus? workoutStatus;

  ProgressEntry({
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
    this.waistCm,
    this.notes,
    this.workoutStatus,
  });
}

enum ExperienceLevel { beginner, intermediate, advanced }

enum CoachSoul { supporter, pro, teacher }

extension CoachSoulExtension on CoachSoul {
  String get displayName {
    switch (this) {
      case CoachSoul.supporter:
        return 'The Supporter';
      case CoachSoul.pro:
        return 'The Pro';
      case CoachSoul.teacher:
        return 'The Teacher';
    }
  }
}

class UserProfile {
  final String name;
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final GoalType goal;
  final int daysPerWeek;
  final String targetPhysique;
  final List<EquipmentItem> equipmentList;
  final ExperienceLevel experienceLevel;
  final double? benchPress1RMKg;
  final double? squat1RMKg;
  final double? deadlift1RMKg;
  final List<String> activeInjuries;
  final List<String> dislikedExercises;
  final List<String> personalNotes;
  final CoachSoul coachSoul;
  final String dietaryPreference; // 'nonVeg', 'vegetarian', 'vegan', 'pescatarian', 'eggetarian'
  final String? createdAtDateStr;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    required this.goal,
    required this.daysPerWeek,
    required this.targetPhysique,
    List<EquipmentItem>? equipmentList,
    List<EquipmentType>? availableEquipment,
    this.experienceLevel = ExperienceLevel.intermediate,
    this.benchPress1RMKg,
    this.squat1RMKg,
    this.deadlift1RMKg,
    this.activeInjuries = const [],
    this.dislikedExercises = const [],
    this.personalNotes = const [],
    this.coachSoul = CoachSoul.supporter,
    this.dietaryPreference = 'nonVeg',
    this.createdAtDateStr,
  }) : equipmentList = equipmentList ??
            (availableEquipment != null
                ? availableEquipment.map((e) => EquipmentItem.fromString(e.name)).toList()
                : [const EquipmentItem(name: 'Bodyweight', category: 'bodyweight')]);

  List<EquipmentType> get availableEquipment {
    final List<EquipmentType> result = [];
    for (var item in equipmentList) {
      final s = item.name.toLowerCase();
      if (s.contains('dumbbell') || s.contains('bag') || s.contains('weight') || item.category == 'free_weight') {
        if (!result.contains(EquipmentType.dumbbells)) result.add(EquipmentType.dumbbells);
      }
      if (s.contains('bodyweight') || item.category == 'bodyweight') {
        if (!result.contains(EquipmentType.bodyweight)) result.add(EquipmentType.bodyweight);
      }
      if (s.contains('barbell')) {
        if (!result.contains(EquipmentType.barbell)) result.add(EquipmentType.barbell);
      }
      if (s.contains('cable') || item.category == 'cables') {
        if (!result.contains(EquipmentType.cables)) result.add(EquipmentType.cables);
      }
      if (s.contains('machine') || item.category == 'machine') {
        if (!result.contains(EquipmentType.machines)) result.add(EquipmentType.machines);
      }
    }
    if (result.isEmpty) result.add(EquipmentType.bodyweight);
    return result;
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    GoalType? goal,
    int? daysPerWeek,
    String? targetPhysique,
    List<EquipmentItem>? equipmentList,
    List<EquipmentType>? availableEquipment,
    ExperienceLevel? experienceLevel,
    double? benchPress1RMKg,
    double? squat1RMKg,
    double? deadlift1RMKg,
    List<String>? activeInjuries,
    List<String>? dislikedExercises,
    List<String>? personalNotes,
    CoachSoul? coachSoul,
    String? dietaryPreference,
    String? createdAtDateStr,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      targetPhysique: targetPhysique ?? this.targetPhysique,
      equipmentList: equipmentList ?? this.equipmentList,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      benchPress1RMKg: benchPress1RMKg ?? this.benchPress1RMKg,
      squat1RMKg: squat1RMKg ?? this.squat1RMKg,
      deadlift1RMKg: deadlift1RMKg ?? this.deadlift1RMKg,
      activeInjuries: activeInjuries ?? this.activeInjuries,
      dislikedExercises: dislikedExercises ?? this.dislikedExercises,
      personalNotes: personalNotes ?? this.personalNotes,
      coachSoul: coachSoul ?? this.coachSoul,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      createdAtDateStr: createdAtDateStr ?? this.createdAtDateStr,
    );
  }
}

class ChatMessage {
  final String id;
  final String sender; // 'user' or 'ai'
  final String text;
  final String timestamp;
  final DateTime createdAt;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    String? timestamp,
    DateTime? createdAt,
    this.imageBytes,
  })  : createdAt = createdAt ??
            (timestamp != null && timestamp != 'Just now'
                ? DateTime.tryParse(timestamp) ?? DateTime.now()
                : DateTime.now()),
        timestamp = (timestamp != null && timestamp != 'Just now')
            ? timestamp
            : (createdAt ?? DateTime.now()).toIso8601String();

  String get formattedTime {
    final now = DateTime.now();
    final date = createdAt;
    final diff = now.difference(date);

    if (diff.inSeconds < 45 && diff.inSeconds >= -5) {
      return 'Just now';
    } else if (diff.inMinutes < 60 && diff.inMinutes >= 0 && date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${diff.inMinutes}m ago';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return 'Yesterday $hour:$minute $period';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[date.month - 1];
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$monthStr ${date.day}, $hour:$minute $period';
    }
  }
}

class QuickLogParsedResult {
  final WorkoutStatus? workoutStatus;
  final String? workoutReason;
  final List<MealItem> mealsToAdd;
  final List<String> skippedMeals;
  final double? sleepHours;
  final double? weightKg;
  final int? energyLevel;
  final String coachFeedback;

  QuickLogParsedResult({
    this.workoutStatus,
    this.workoutReason,
    this.mealsToAdd = const [],
    this.skippedMeals = const [],
    this.sleepHours,
    this.weightKg,
    this.energyLevel,
    required this.coachFeedback,
  });
}

class AIActionCall {
  final String functionName;
  final Map<String, dynamic> arguments;

  AIActionCall({
    required this.functionName,
    required this.arguments,
  });
}

class AIOrchestratorResult {
  final List<AIActionCall> actions;
  final String coachResponse;

  AIOrchestratorResult({
    this.actions = const [],
    required this.coachResponse,
  });
}

// ─── Weekly Plan Models ───

class WeeklyDayPlan {
  final String dayName;
  final String date;
  final String title;
  final String focusArea;
  final bool isRestDay;
  final List<String> exerciseNames;
  final String? nutritionFocus;

  WeeklyDayPlan({
    required this.dayName,
    required this.date,
    required this.title,
    required this.focusArea,
    this.isRestDay = false,
    this.exerciseNames = const [],
    this.nutritionFocus,
  });

  WeeklyDayPlan copyWith({
    String? dayName,
    String? date,
    String? title,
    String? focusArea,
    bool? isRestDay,
    List<String>? exerciseNames,
    String? nutritionFocus,
  }) {
    return WeeklyDayPlan(
      dayName: dayName ?? this.dayName,
      date: date ?? this.date,
      title: title ?? this.title,
      focusArea: focusArea ?? this.focusArea,
      isRestDay: isRestDay ?? this.isRestDay,
      exerciseNames: exerciseNames ?? this.exerciseNames,
      nutritionFocus: nutritionFocus ?? this.nutritionFocus,
    );
  }
}

class WeeklyPlan {
  final String weekId;
  final String startDate;
  final String endDate;
  final String overview;
  final String? coachNote;
  final List<WeeklyDayPlan> days;
  final String createdAt;

  WeeklyPlan({
    required this.weekId,
    required this.startDate,
    required this.endDate,
    required this.overview,
    this.coachNote,
    required this.days,
    required this.createdAt,
  });

  WeeklyPlan copyWith({
    String? weekId,
    String? startDate,
    String? endDate,
    String? overview,
    String? coachNote,
    List<WeeklyDayPlan>? days,
    String? createdAt,
  }) {
    return WeeklyPlan(
      weekId: weekId ?? this.weekId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      overview: overview ?? this.overview,
      coachNote: coachNote ?? this.coachNote,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ─── Master Context Models ───

class DeducedKnowledge {
  final String? activityLevel;
  final int? sessionDurationMin;
  final List<String> preferredTrainingDays;
  final String? preferredTrainingStyle;
  final String? cardioPreference;
  final List<String> activeInjuries;
  final List<String> foodAllergies;
  final List<String> dislikedExercises;
  final List<String> preferredProteinSources;
  final double? sleepPatternAvg;
  final int? stressBaseline;
  final List<String> personalNotes;
  final String? lastUpdated;

  DeducedKnowledge({
    this.activityLevel,
    this.sessionDurationMin,
    this.preferredTrainingDays = const [],
    this.preferredTrainingStyle,
    this.cardioPreference,
    this.activeInjuries = const [],
    this.foodAllergies = const [],
    this.dislikedExercises = const [],
    this.preferredProteinSources = const [],
    this.sleepPatternAvg,
    this.stressBaseline,
    this.personalNotes = const [],
    this.lastUpdated,
  });

  DeducedKnowledge copyWith({
    String? activityLevel,
    int? sessionDurationMin,
    List<String>? preferredTrainingDays,
    String? preferredTrainingStyle,
    String? cardioPreference,
    List<String>? activeInjuries,
    List<String>? foodAllergies,
    List<String>? dislikedExercises,
    List<String>? preferredProteinSources,
    double? sleepPatternAvg,
    int? stressBaseline,
    List<String>? personalNotes,
    String? lastUpdated,
  }) {
    return DeducedKnowledge(
      activityLevel: activityLevel ?? this.activityLevel,
      sessionDurationMin: sessionDurationMin ?? this.sessionDurationMin,
      preferredTrainingDays: preferredTrainingDays ?? this.preferredTrainingDays,
      preferredTrainingStyle: preferredTrainingStyle ?? this.preferredTrainingStyle,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      activeInjuries: activeInjuries ?? this.activeInjuries,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      dislikedExercises: dislikedExercises ?? this.dislikedExercises,
      preferredProteinSources: preferredProteinSources ?? this.preferredProteinSources,
      sleepPatternAvg: sleepPatternAvg ?? this.sleepPatternAvg,
      stressBaseline: stressBaseline ?? this.stressBaseline,
      personalNotes: personalNotes ?? this.personalNotes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RollingSummary {
  final int periodDays;
  final double workoutComplianceRate;
  final int workoutsCompleted;
  final int workoutsSkipped;
  final double? avgSessionDurationMin;
  final List<Map<String, dynamic>> recentWorkouts;
  final Map<String, dynamic> nutritionAvg;
  final Map<String, dynamic> recoveryAvg;
  final List<Map<String, dynamic>> weightTrend;
  final String? lastUpdated;

  RollingSummary({
    this.periodDays = 7,
    this.workoutComplianceRate = 0.0,
    this.workoutsCompleted = 0,
    this.workoutsSkipped = 0,
    this.avgSessionDurationMin,
    this.recentWorkouts = const [],
    this.nutritionAvg = const {},
    this.recoveryAvg = const {},
    this.weightTrend = const [],
    this.lastUpdated,
  });

  RollingSummary copyWith({
    int? periodDays,
    double? workoutComplianceRate,
    int? workoutsCompleted,
    int? workoutsSkipped,
    double? avgSessionDurationMin,
    List<Map<String, dynamic>>? recentWorkouts,
    Map<String, dynamic>? nutritionAvg,
    Map<String, dynamic>? recoveryAvg,
    List<Map<String, dynamic>>? weightTrend,
    String? lastUpdated,
  }) {
    return RollingSummary(
      periodDays: periodDays ?? this.periodDays,
      workoutComplianceRate: workoutComplianceRate ?? this.workoutComplianceRate,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      workoutsSkipped: workoutsSkipped ?? this.workoutsSkipped,
      avgSessionDurationMin: avgSessionDurationMin ?? this.avgSessionDurationMin,
      recentWorkouts: recentWorkouts ?? this.recentWorkouts,
      nutritionAvg: nutritionAvg ?? this.nutritionAvg,
      recoveryAvg: recoveryAvg ?? this.recoveryAvg,
      weightTrend: weightTrend ?? this.weightTrend,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MasterContext {
  final DeducedKnowledge deduced;
  final RollingSummary rollingSummary;

  MasterContext({
    DeducedKnowledge? deduced,
    RollingSummary? rollingSummary,
  })  : deduced = deduced ?? DeducedKnowledge(),
        rollingSummary = rollingSummary ?? RollingSummary();

  MasterContext copyWith({
    DeducedKnowledge? deduced,
    RollingSummary? rollingSummary,
  }) {
    return MasterContext(
      deduced: deduced ?? this.deduced,
      rollingSummary: rollingSummary ?? this.rollingSummary,
    );
  }
}

