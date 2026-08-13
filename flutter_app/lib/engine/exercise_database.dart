import '../models/models.dart';

enum MovementPattern {
  horizontalPush,
  verticalPush,
  horizontalPull,
  verticalPull,
  quadDominant,
  hipHinge,
  armIso,
  core,
}

class ExerciseDefinition {
  final String id;
  final String name;
  final String targetMuscle;
  final MovementPattern movementPattern;
  final EquipmentType equipment;
  final List<String> alternativeIds;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.movementPattern,
    required this.equipment,
    this.alternativeIds = const [],
  });
}

class ExerciseDatabase {
  static const List<ExerciseDefinition> library = [
    // --- HORIZONTAL PUSH ---
    ExerciseDefinition(
      id: 'ex_db_bench',
      name: 'Flat Dumbbell Press',
      targetMuscle: 'Mid Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_bench', 'ex_mach_chest'],
    ),
    ExerciseDefinition(
      id: 'ex_bb_bench',
      name: 'Flat Barbell Bench Press',
      targetMuscle: 'Mid Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_bench', 'ex_mach_chest'],
    ),
    ExerciseDefinition(
      id: 'ex_inc_db_bench',
      name: 'Incline Dumbbell Press',
      targetMuscle: 'Upper Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_inc_bb_bench'],
    ),
    ExerciseDefinition(
      id: 'ex_inc_bb_bench',
      name: 'Incline Barbell Bench Press',
      targetMuscle: 'Upper Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_inc_db_bench'],
    ),
    ExerciseDefinition(
      id: 'ex_pushups',
      name: 'Bodyweight Push-Ups',
      targetMuscle: 'Chest & Core',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.bodyweight,
      alternativeIds: ['ex_db_bench'],
    ),

    // --- VERTICAL PUSH ---
    ExerciseDefinition(
      id: 'ex_db_ohp',
      name: 'Seated Dumbbell Shoulder Press',
      targetMuscle: 'Front Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_ohp'],
    ),
    ExerciseDefinition(
      id: 'ex_bb_ohp',
      name: 'Standing Barbell Overhead Press',
      targetMuscle: 'Front & Side Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_ohp'],
    ),

    // --- HORIZONTAL PULL ---
    ExerciseDefinition(
      id: 'ex_db_row',
      name: 'Single-Arm Dumbbell Row',
      targetMuscle: 'Lats & Rhomboids',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_row', 'ex_cable_row'],
    ),
    ExerciseDefinition(
      id: 'ex_bb_row',
      name: 'Bent-Over Barbell Row',
      targetMuscle: 'Upper Back & Lats',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_row', 'ex_cable_row'],
    ),
    ExerciseDefinition(
      id: 'ex_cable_row',
      name: 'Seated Cable Row',
      targetMuscle: 'Mid Back & Lats',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_db_row', 'ex_bb_row'],
    ),

    // --- VERTICAL PULL ---
    ExerciseDefinition(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      targetMuscle: 'Lats & Upper Back',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_pullups'],
    ),
    ExerciseDefinition(
      id: 'ex_pullups',
      name: 'Bodyweight Pull-Ups',
      targetMuscle: 'Lats & Arms',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.bodyweight,
      alternativeIds: ['ex_lat_pulldown'],
    ),

    // --- QUAD DOMINANT ---
    ExerciseDefinition(
      id: 'ex_bb_squat',
      name: 'Barbell Back Squat',
      targetMuscle: 'Quadriceps & Glutes',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_goblet_squat', 'ex_leg_press'],
    ),
    ExerciseDefinition(
      id: 'ex_goblet_squat',
      name: 'Dumbbell Goblet Squat',
      targetMuscle: 'Quadriceps',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_squat'],
    ),

    // --- HIP HINGE ---
    ExerciseDefinition(
      id: 'ex_bb_deadlift',
      name: 'Barbell Conventional Deadlift',
      targetMuscle: 'Posterior Chain & Hamstrings',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_rdl'],
    ),
    ExerciseDefinition(
      id: 'ex_db_rdl',
      name: 'Dumbbell Romanian Deadlift',
      targetMuscle: 'Hamstrings & Glutes',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_deadlift'],
    ),

    // --- ARM ISOLATION ---
    ExerciseDefinition(
      id: 'ex_bicep_curl',
      name: 'Dumbbell Bicep Curl',
      targetMuscle: 'Biceps',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_cable_curl'],
    ),
    ExerciseDefinition(
      id: 'ex_tricep_pushdown',
      name: 'Cable Tricep Pushdown',
      targetMuscle: 'Triceps',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_overhead_tricep'],
    ),
    ExerciseDefinition(
      id: 'ex_overhead_tricep',
      name: 'Dumbbell Overhead Tricep Extension',
      targetMuscle: 'Triceps Long Head',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_tricep_pushdown'],
    ),
  ];

  /// Finds biomechanically equivalent exercise substitutions matching user equipment constraints
  static List<ExerciseDefinition> getSubstitutions({
    required String currentExerciseName,
    required List<EquipmentType> availableEquipment,
  }) {
    // Find current definition or match by name
    final current = library.firstWhere(
      (e) => e.name.toLowerCase() == currentExerciseName.toLowerCase(),
      orElse: () => library.first,
    );

    return library.where((e) {
      if (e.name == current.name) return false;
      final matchesPattern = e.movementPattern == current.movementPattern;
      final matchesEquipment = availableEquipment.contains(e.equipment) || e.equipment == EquipmentType.bodyweight;
      return matchesPattern && matchesEquipment;
    }).toList();
  }
}
