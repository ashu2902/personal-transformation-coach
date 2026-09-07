import 'user_profile.dart';

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
  final String? instructions;
  final String? videoUrl;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.movementPattern,
    required this.equipment,
    this.alternativeIds = const [],
    this.instructions,
    this.videoUrl,
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
      instructions: """### Setup & Position
- Lie flat on the bench with feet firmly planted on the floor.
- Retract your shoulder blades (pinch them together) and maintain a slight natural arch in your lower back.

### Movement Execution
1. **Lowering (Eccentric):** Lower dumbbells slowly at a 45-degree angle relative to your torso until you feel a deep stretch in the pecs.
2. **Pressing (Concentric):** Press up powerfully in a slight arc, focusing on driving through the chest without clanking dumbbells at the top.

### Form Cues
- Keep wrists neutral directly over elbows.
- Inhale on the way down, exhale as you drive up.""",
      videoUrl: 'https://www.youtube.com/watch?v=VmB1G1K7v94',
    ),
    ExerciseDefinition(
      id: 'ex_bb_bench',
      name: 'Flat Barbell Bench Press',
      targetMuscle: 'Mid Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_bench', 'ex_mach_chest'],
      instructions: """### Setup & Position
- Lie with eyes directly under the racked bar.
- Grip the bar slightly wider than shoulder-width. Drive upper back into the bench.

### Movement Execution
1. Unrack and stabilize bar over chest.
2. Lower bar in a controlled path to the lower sternum.
3. Drive feet into the floor and press bar back up in a slight diagonal trajectory.

### Key Cues
- Keep elbows tucked ~45-60 degrees from torso.
- Maintain full tension across glutes and upper back.""",
      videoUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
    ),
    ExerciseDefinition(
      id: 'ex_inc_db_bench',
      name: 'Incline Dumbbell Press',
      targetMuscle: 'Upper Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_inc_bb_bench'],
      instructions: """### Setup & Position
- Set bench angle to 30 degrees (avoid higher incline to prevent front deltoid takeover).
- Keep heels pinned to the ground.

### Movement Execution
1. Lower dumbbells until the weights align with upper chest level.
2. Press smoothly up and slightly inward over clavicles.
3. Squeeze upper pecs at peak contraction.

### Safety Tip
- Do not flare elbows out at 90 degrees to protect the rotator cuff.""",
      videoUrl: 'https://www.youtube.com/watch?v=8iPEnn-ltC8',
    ),
    ExerciseDefinition(
      id: 'ex_inc_bb_bench',
      name: 'Incline Barbell Bench Press',
      targetMuscle: 'Upper Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_inc_db_bench'],
      instructions: """### Setup & Position
- Bench set to 30-45 degrees.
- Grip barbell with overhand grip just outside shoulders.

### Movement Execution
1. Lower barbell with control to the clavicle / upper chest line.
2. Pause for 0.5s without bouncing off ribs.
3. Drive vertically back to lockout.

### Form Cues
- Engage core to prevent excessive lumbar arching.""",
      videoUrl: 'https://www.youtube.com/watch?v=DbFgXlT_bGY',
    ),
    ExerciseDefinition(
      id: 'ex_pushups',
      name: 'Bodyweight Push-Ups',
      targetMuscle: 'Chest & Core',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.bodyweight,
      alternativeIds: ['ex_db_bench'],
      instructions: """### Setup & Position
- Hands placed slightly wider than shoulder-width on the floor.
- Body forming a rigid straight plank from crown to heels.

### Movement Execution
1. Lower chest to floor while keeping elbows tracking backwards at 45 degrees.
2. Lower until chest grazes the ground (1-2 inches above).
3. Press through the palms to full arm extension.

### Core Cues
- Squeeze glutes and brace abs throughout. Do not let hips sag.""",
      videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
    ),

    // --- VERTICAL PUSH ---
    ExerciseDefinition(
      id: 'ex_db_ohp',
      name: 'Seated Dumbbell Shoulder Press',
      targetMuscle: 'Front Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_ohp'],
      instructions: """### Setup & Position
- Bench upright at 75-85 degrees.
- Dumbbells held at shoulder height with palms facing forward or slightly angled.

### Movement Execution
1. Press dumbbells straight overhead until arms are extended.
2. Do not let dumbbells bang together at the top.
3. Lower dumbbells under strict 2-second tempo back to ear level.

### Form Cues
- Keep ribs tucked down and core engaged.""",
      videoUrl: 'https://www.youtube.com/watch?v=qEwKCR5JCog',
    ),
    ExerciseDefinition(
      id: 'ex_bb_ohp',
      name: 'Standing Barbell Overhead Press',
      targetMuscle: 'Front & Side Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_ohp'],
      instructions: """### Setup & Position
- Stand with feet shoulder-width apart.
- Grip barbell just outside shoulders, resting bar on front deltoids.

### Movement Execution
1. Squeeze glutes and brace abdominal wall.
2. Move head slightly back to clear bar path, then press bar vertically overhead.
3. Push head forward into 'window' at full lockout.
4. Reverse path with control.

### Form Cues
- Keep body rigid; avoid leaning back backwards.""",
      videoUrl: 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
    ),

    // --- HORIZONTAL PULL ---
    ExerciseDefinition(
      id: 'ex_db_row',
      name: 'Single-Arm Dumbbell Row',
      targetMuscle: 'Lats & Rhomboids',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_row', 'ex_cable_row'],
      instructions: """### Setup & Position
- Place one knee and hand on flat bench.
- Keep back flat parallel to the floor, holding dumbbell in free hand.

### Movement Execution
1. Pull dumbbell towards hip, driving back through the elbow.
2. Squeeze lat firmly at top for 1 full second.
3. Lower dumbbell with full stretch without rotating torso.

### Cues
- Think 'elbow to hip pocket' rather than pulling with biceps.""",
      videoUrl: 'https://www.youtube.com/watch?v=roCP6wCXPqo',
    ),
    ExerciseDefinition(
      id: 'ex_bb_row',
      name: 'Bent-Over Barbell Row',
      targetMuscle: 'Upper Back & Lats',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_row', 'ex_cable_row'],
      instructions: """### Setup & Position
- Hinge at hips to a 45-degree angle with flat spine and soft knees.
- Grip barbell overhand shoulder-width.

### Movement Execution
1. Pull bar towards lower abdomen / belly button.
2. Squeeze shoulder blades together at top.
3. Lower bar smoothly under control.

### Caution
- Do not jerk with lower back. Keep torso locked stationary.""",
      videoUrl: 'https://www.youtube.com/watch?v=9efgc2WgPWM',
    ),
    ExerciseDefinition(
      id: 'ex_cable_row',
      name: 'Seated Cable Row',
      targetMuscle: 'Mid Back & Lats',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_db_row', 'ex_bb_row'],
      instructions: """### Setup & Position
- Sit upright with feet on footplates, knees slightly bent.
- Maintain tall chest and neutral spine.

### Movement Execution
1. Pull handle into lower abdomen while keeping shoulders down.
2. Pinch scapulae together and hold contraction.
3. Slowly return with controlled reach to stretch lats.

### Form Cues
- Avoid rocking excessively forward and backward.""",
      videoUrl: 'https://www.youtube.com/watch?v=GZbfZ033fbo',
    ),

    // --- VERTICAL PULL ---
    ExerciseDefinition(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      targetMuscle: 'Lats & Upper Back',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_pullups'],
      instructions: """### Setup & Position
- Secure thigh pads snugly over legs.
- Grip wide bar with overhand grip outside shoulder width.

### Movement Execution
1. Lean back slightly (~10-15 degrees) with chest lifted.
2. Pull bar down towards upper chest, leading with elbows.
3. Squeeze lats at bottom, then control the release all the way to full arm extension.

### Cues
- Pull elbows down and back, not wrists.""",
      videoUrl: 'https://www.youtube.com/watch?v=CAwf7n6Luuc',
    ),
    ExerciseDefinition(
      id: 'ex_pullups',
      name: 'Bodyweight Pull-Ups',
      targetMuscle: 'Lats & Arms',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.bodyweight,
      alternativeIds: ['ex_lat_pulldown'],
      instructions: """### Setup & Position
- Grip pull-up bar with overhand grip wider than shoulders.
- Hang in full dead-hang position to start.

### Movement Execution
1. Depress scapulae (pull shoulders down away from ears).
2. Pull yourself up until chin clears the bar.
3. Lower under strict 2-3 second control back to dead hang.

### Progression
- Use resistance band assistance if needed to hit target reps with pristine form.""",
      videoUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
    ),

    // --- QUAD DOMINANT ---
    ExerciseDefinition(
      id: 'ex_bb_squat',
      name: 'Barbell Back Squat',
      targetMuscle: 'Quadriceps & Glutes',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_goblet_squat'],
      instructions: """### Setup & Position
- Bar rested on upper traps (high-bar) or rear delts (low-bar).
- Feet shoulder-width apart, toes pointed slightly outward (15-30 degrees).

### Movement Execution
1. Take deep diaphragmatic breath and brace core.
2. Break at hips and knees simultaneously, descending until hip crease passes below knees.
3. Drive through midfoot and heels to stand back up.

### Key Cues
- Keep chest up and knees tracking in line with toes.""",
      videoUrl: 'https://www.youtube.com/watch?v=ultWZbUMPL8',
    ),
    ExerciseDefinition(
      id: 'ex_goblet_squat',
      name: 'Dumbbell Goblet Squat',
      targetMuscle: 'Quadriceps',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_squat'],
      instructions: """### Setup & Position
- Hold one dumbbell vertically against chest with both palms cupping the top plate.
- Stand with feet slightly wider than shoulder width.

### Movement Execution
1. Squat down between knees, keeping elbows inside thighs.
2. Reach full depth while keeping torso upright.
3. Drive through feet to return to starting position.

### Form Cue
- Perfect for building squat mobility and quad strength safely.""",
      videoUrl: 'https://www.youtube.com/watch?v=MeIiIdhvXT4',
    ),

    // --- HIP HINGE ---
    ExerciseDefinition(
      id: 'ex_bb_deadlift',
      name: 'Barbell Conventional Deadlift',
      targetMuscle: 'Posterior Chain & Hamstrings',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_rdl'],
      instructions: """### Setup & Position
- Feet hip-width apart under the bar; bar cutting midfoot in half.
- Grip bar just outside shins. Pull chest tall to engage lats and remove slack from bar.

### Movement Execution
1. Push the floor away through midfoot, keeping bar glued to shins and thighs.
2. Lock out hips and knees simultaneously at the top.
3. Hinge hips backwards to lower bar in a straight line back to floor.

### Safety Rule
- Never let lower spine round under load.""",
      videoUrl: 'https://www.youtube.com/watch?v=op9kVnSso6Q',
    ),
    ExerciseDefinition(
      id: 'ex_db_rdl',
      name: 'Dumbbell Romanian Deadlift',
      targetMuscle: 'Hamstrings & Glutes',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_deadlift'],
      instructions: """### Setup & Position
- Stand holding dumbbells in front of thighs with slight unlock in knees.
- Shoulders back and core braced.

### Movement Execution
1. Push hips backward towards the wall behind you, sliding dumbbells down along shins.
2. Stop when you feel maximum hamstring stretch (usually mid-shin level).
3. Drive hips forward to stand, squeezing glutes at the top.

### Form Cues
- Knees stay fixed at soft angle; movement comes entirely from hip hinge.""",
      videoUrl: 'https://www.youtube.com/watch?v=kYv_37E1LFE',
    ),

    // --- ARM ISOLATION ---
    ExerciseDefinition(
      id: 'ex_bicep_curl',
      name: 'Dumbbell Bicep Curl',
      targetMuscle: 'Biceps',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_cable_curl'],
      instructions: """### Setup & Position
- Stand tall with dumbbells at sides, palms facing inward (neutral grip).

### Movement Execution
1. Curl weights up while supinating wrists (palms face ceiling at peak).
2. Squeeze biceps hard at the top without swinging elbows forward.
3. Lower under 2-3 second eccentric tempo.

### Cue
- Pin elbows to sides of ribcage throughout.""",
      videoUrl: 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
    ),
    ExerciseDefinition(
      id: 'ex_tricep_pushdown',
      name: 'Cable Tricep Pushdown',
      targetMuscle: 'Triceps',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_overhead_tricep'],
      instructions: """### Setup & Position
- Attach straight bar or rope to high cable pulley.
- Stand with slight forward hinge, elbows tucked at sides.

### Movement Execution
1. Push attachment downwards until arms are completely locked out.
2. Squeeze triceps at bottom.
3. Allow forearms to rise back up to 90 degrees before next rep.

### Cue
- Only forearms move; upper arms stay locked stationary.""",
      videoUrl: 'https://www.youtube.com/watch?v=2-LAMcpzODU',
    ),
    ExerciseDefinition(
      id: 'ex_overhead_tricep',
      name: 'Dumbbell Overhead Tricep Extension',
      targetMuscle: 'Triceps Long Head',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_tricep_pushdown'],
      instructions: """### Setup & Position
- Sit on bench with dumbbell held vertically with both hands under top plate overhead.

### Movement Execution
1. Lower dumbbell behind head by bending elbows until forearms touch biceps.
2. Keep elbows pointing forward, not flared out wide.
3. Press weight back overhead to full triceps lockout.

### Benefit
- Directly targets the long head of the tricep for arm thickness.""",
      videoUrl: 'https://www.youtube.com/watch?v=-Vyt2QdsR7E',
    ),
  ];

  /// Finds biomechanically equivalent exercise substitutions matching user equipment constraints
  static List<ExerciseDefinition> getSubstitutions({
    required String currentExerciseName,
    required List<EquipmentType> availableEquipment,
  }) {
    final current = library.where(
      (e) => e.name.toLowerCase() == currentExerciseName.toLowerCase(),
    ).firstOrNull;

    if (current == null) return [];

    return library.where((e) {
      if (e.name == current.name) return false;
      final matchesPattern = e.movementPattern == current.movementPattern;
      final matchesEquipment = availableEquipment.contains(e.equipment) || e.equipment == EquipmentType.bodyweight;
      return matchesPattern && matchesEquipment;
    }).toList();
  }

  /// Helper to lookup an exercise definition by name
  static ExerciseDefinition? findDefinition(String name) {
    final clean = name.toLowerCase().trim();
    return library.where((e) => e.name.toLowerCase().trim() == clean || clean.contains(e.name.toLowerCase().trim())).firstOrNull;
  }
}
