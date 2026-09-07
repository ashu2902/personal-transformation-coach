import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum Gender {
  @JsonValue('male') male,
  @JsonValue('female') female,
  @JsonValue('other') other,
}

enum GoalType {
  @JsonValue('fatLoss') fatLoss,
  @JsonValue('muscleGain') muscleGain,
  @JsonValue('recomp') recomp,
}

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

enum EquipmentType {
  @JsonValue('bodyweight') bodyweight,
  @JsonValue('dumbbells') dumbbells,
  @JsonValue('barbell') barbell,
  @JsonValue('cables') cables,
  @JsonValue('machines') machines,
}

@freezed
abstract class EquipmentItem with _$EquipmentItem {
  const EquipmentItem._();

  const factory EquipmentItem({
    required String name,
    @Default('free_weight') String category,
    double? weightKg,
    String? notes,
  }) = _EquipmentItem;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) => _$EquipmentItemFromJson(json);

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

  @override
  String toString() {
    final wStr = weightKg != null ? ' (${weightKg!.toStringAsFixed(weightKg! % 1 == 0 ? 0 : 1)}kg)' : '';
    return '$name$wStr';
  }
}

enum ExperienceLevel {
  @JsonValue('beginner') beginner,
  @JsonValue('intermediate') intermediate,
  @JsonValue('advanced') advanced,
}

enum CoachSoul {
  @JsonValue('supporter') supporter,
  @JsonValue('pro') pro,
  @JsonValue('teacher') teacher,
}

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

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required double targetWeightKg,
    required GoalType goal,
    required int daysPerWeek,
    required String targetPhysique,
    @Default([EquipmentItem(name: 'Bodyweight', category: 'bodyweight')]) List<EquipmentItem> equipmentList,
    @Default(ExperienceLevel.intermediate) ExperienceLevel experienceLevel,
    double? benchPress1RMKg,
    double? squat1RMKg,
    double? deadlift1RMKg,
    @Default([]) List<String> activeInjuries,
    @Default([]) List<String> dislikedExercises,
    @Default([]) List<String> personalNotes,
    @Default(CoachSoul.supporter) CoachSoul coachSoul,
    @Default('nonVeg') String dietaryPreference,
    String? createdAtDateStr,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  factory UserProfile.create({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required double targetWeightKg,
    required GoalType goal,
    required int daysPerWeek,
    required String targetPhysique,
    List<EquipmentItem>? equipmentList,
    List<EquipmentType>? availableEquipment,
    ExperienceLevel experienceLevel = ExperienceLevel.intermediate,
    double? benchPress1RMKg,
    double? squat1RMKg,
    double? deadlift1RMKg,
    List<String> activeInjuries = const [],
    List<String> dislikedExercises = const [],
    List<String> personalNotes = const [],
    CoachSoul coachSoul = CoachSoul.supporter,
    String dietaryPreference = 'nonVeg',
    String? createdAtDateStr,
  }) {
    final effectiveEquipmentList = equipmentList ??
        (availableEquipment != null
            ? availableEquipment.map((e) => EquipmentItem.fromString(e.name)).toList()
            : const [EquipmentItem(name: 'Bodyweight', category: 'bodyweight')]);

    return UserProfile(
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      targetWeightKg: targetWeightKg,
      goal: goal,
      daysPerWeek: daysPerWeek,
      targetPhysique: targetPhysique,
      equipmentList: effectiveEquipmentList,
      experienceLevel: experienceLevel,
      benchPress1RMKg: benchPress1RMKg,
      squat1RMKg: squat1RMKg,
      deadlift1RMKg: deadlift1RMKg,
      activeInjuries: activeInjuries,
      dislikedExercises: dislikedExercises,
      personalNotes: personalNotes,
      coachSoul: coachSoul,
      dietaryPreference: dietaryPreference,
      createdAtDateStr: createdAtDateStr,
    );
  }

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
}
