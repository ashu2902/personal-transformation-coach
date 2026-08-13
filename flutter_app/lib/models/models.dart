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
  final EquipmentType equipmentRequired;
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
    EquipmentType? equipmentRequired,
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

  ProgressEntry({
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
    this.waistCm,
    this.notes,
  });
}

enum ExperienceLevel { beginner, intermediate, advanced }

class UserProfile {
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final GoalType goal;
  final int daysPerWeek;
  final String targetPhysique;
  final List<EquipmentType> availableEquipment;
  final ExperienceLevel experienceLevel;
  final double? benchPress1RMKg;
  final double? squat1RMKg;
  final double? deadlift1RMKg;
  final List<String> activeInjuries;

  UserProfile({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    required this.goal,
    required this.daysPerWeek,
    required this.targetPhysique,
    required this.availableEquipment,
    this.experienceLevel = ExperienceLevel.intermediate,
    this.benchPress1RMKg,
    this.squat1RMKg,
    this.deadlift1RMKg,
    this.activeInjuries = const [],
  });

  UserProfile copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    GoalType? goal,
    int? daysPerWeek,
    String? targetPhysique,
    List<EquipmentType>? availableEquipment,
    ExperienceLevel? experienceLevel,
    double? benchPress1RMKg,
    double? squat1RMKg,
    double? deadlift1RMKg,
    List<String>? activeInjuries,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      targetPhysique: targetPhysique ?? this.targetPhysique,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      benchPress1RMKg: benchPress1RMKg ?? this.benchPress1RMKg,
      squat1RMKg: squat1RMKg ?? this.squat1RMKg,
      deadlift1RMKg: deadlift1RMKg ?? this.deadlift1RMKg,
      activeInjuries: activeInjuries ?? this.activeInjuries,
    );
  }
}

class ChatMessage {
  final String id;
  final String sender; // 'user' or 'ai'
  final String text;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });
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

