import 'user_profile.dart';
import 'workout.dart';

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

/// The Glanceable 3-Cue Triad for high-speed in-workout review
class ExerciseCues {
  final String feelItIn;
  final String setupCue;
  final String avoidMistake;

  const ExerciseCues({
    required this.feelItIn,
    required this.setupCue,
    required this.avoidMistake,
  });
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
  final ExerciseCues? cues;
  final Map<String, String>? coachTips;
  final List<String> aliases;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.movementPattern,
    required this.equipment,
    this.alternativeIds = const [],
    this.instructions,
    this.videoUrl,
    this.cues,
    this.coachTips,
    this.aliases = const [],
  });
}

class ExerciseDatabase {
  static const List<ExerciseDefinition> library = [
    // ─── 1. HORIZONTAL PUSH ──────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_db_bench',
      name: 'Flat Dumbbell Press',
      targetMuscle: 'Mid Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_bench', 'ex_mach_chest'],
      aliases: ['dumbbell bench press', 'flat db press', 'db chest press', 'dumbbell press'],
      cues: ExerciseCues(
        feelItIn: 'Mid pec fibers; deep stretch at bottom, strong squeeze at top.',
        setupCue: 'Pinch shoulder blades together; plant feet firmly; keep wrists directly over elbows.',
        avoidMistake: 'Do not clank dumbbells at top or flare elbows past 75 degrees.',
      ),
      coachTips: {
        'pro': 'Control the descent for 3 full seconds. Drive up with explosive intent without locking elbows hard.',
        'teacher': 'The converging dumbbell arc follows the natural sternal pec line, providing greater active range than a fixed barbell.',
        'supporter': 'Find a comfortable elbow angle that feels completely natural on your shoulders. You are in control of every rep.',
      },
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
      aliases: ['barbell bench press', 'flat bench press', 'bb bench press', 'bench press'],
      cues: ExerciseCues(
        feelItIn: 'Entire chest plate and triceps during the press.',
        setupCue: 'Eyes directly under bar; grip slightly wider than shoulders; drive upper back into bench.',
        avoidMistake: 'Do not bounce the bar off your sternum or lift hips off the bench.',
      ),
      coachTips: {
        'pro': 'Create total body tension. Squeeze the bar like you are trying to bend it in half.',
        'teacher': 'Maintain a slight tuck in the elbows (around 45–60°) to align the line of force with the sternocostal fibers.',
        'supporter': 'Focus on a smooth, controlled rhythm. If the weight feels heavy, prioritize clean bar path over adding plates.',
      },
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
      alternativeIds: ['ex_inc_bb_bench', 'ex_db_bench'],
      aliases: ['incline db press', 'incline dumbbell bench press', 'incline chest press db'],
      cues: ExerciseCues(
        feelItIn: 'Upper clavicular pectorals (just beneath collarbone).',
        setupCue: 'Set bench to 30 degrees (avoid steep 45°+ angles to protect deltoids).',
        avoidMistake: 'Do not flare elbows perpendicular to torso or arch lower back excessively.',
      ),
      coachTips: {
        'pro': 'Think about driving your inner biceps towards your collarbone at the peak.',
        'teacher': 'A 30-degree incline maximizes upper pec recruitment while keeping front deltoid dominance below 20%.',
        'supporter': 'Take your time getting the dumbbells set. Smooth descent, confident press.',
      },
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
      aliases: ['incline barbell press', 'incline bench press', 'incline bench barbell', 'incline barbell'],
      cues: ExerciseCues(
        feelItIn: 'Upper pecs near the clavicles and anterior shoulders.',
        setupCue: 'Bench angle at 30°; bar touches just below the collarbone on lowering.',
        avoidMistake: 'Never bounce the bar off your clavicle; pause for a split second before pressing.',
      ),
      coachTips: {
        'pro': 'Drive your feet into the floor and press the bar back over your eyes at the top.',
        'teacher': 'Touch point is higher on the chest than flat bench to align with the clavicular fiber orientation.',
        'supporter': 'Lower the bar with quiet control. You have full command over this bar.',
      },
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
      id: 'ex_mach_chest',
      name: 'Flat Chest Press Machine',
      targetMuscle: 'Mid Chest',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_db_bench', 'ex_bb_bench'],
      aliases: [
        'chest press machine',
        'machine chest press',
        'seated chest press machine',
        'seated chest press',
        'machine bench press',
      ],
      cues: ExerciseCues(
        feelItIn: 'Direct mid-chest squeeze without needing to balance free weights.',
        setupCue: 'Adjust seat height so handles align directly across mid-nipple level.',
        avoidMistake: 'Do not let shoulders roll forward off the pad at the end of the press.',
      ),
      coachTips: {
        'pro': 'Since balance is eliminated, train close to mechanical failure with strict 3-second negatives.',
        'teacher': 'The fixed machine axis allows isolated pectoralis major tension with minimal rotator cuff stabilizer fatigue.',
        'supporter': 'Great safe choice! Keep your head and spine rested comfortably against the back pad.',
      },
      instructions: """### Setup & Position
- Adjust seat height so the handles are aligned horizontally with the center of your chest.
- Rest head, upper back, and hips firmly against the back pad.

### Movement Execution
1. Grip handles firmly and press outward until arms are almost fully extended (soft elbow lockout).
2. Squeeze pecs hard for 1 second at full extension.
3. Lower slowly until handles return to chest level, feeling a deep pec stretch.

### Safety Tip
- Keep shoulder blades pinched against the pad throughout.""",
      videoUrl: 'https://www.youtube.com/watch?v=xUm0BiZCWlQ',
    ),
    ExerciseDefinition(
      id: 'ex_pushups',
      name: 'Bodyweight Push-Ups',
      targetMuscle: 'Chest & Core',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.bodyweight,
      alternativeIds: ['ex_db_bench'],
      aliases: ['push-ups', 'pushups', 'push ups', 'floor pushups'],
      cues: ExerciseCues(
        feelItIn: 'Chest, front delts, and rigid abdominal wall.',
        setupCue: 'Hands slightly wider than shoulders; body in a rigid straight plank from head to heels.',
        avoidMistake: 'Do not let hips sag towards the floor or pike into the air.',
      ),
      coachTips: {
        'pro': 'Squeeze glutes and quads like a moving plank. Zero body sag.',
        'teacher': 'Push-ups allow natural scapular protraction at the top, promoting healthy serratus anterior function.',
        'supporter': 'Every single rep counts! If you need to drop to knees on the final sets, keep that clean form.',
      },
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
    ExerciseDefinition(
      id: 'ex_db_fly',
      name: 'Pec Deck / Chest Flye Machine',
      targetMuscle: 'Pectoralis Major',
      movementPattern: MovementPattern.horizontalPush,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_db_bench', 'ex_mach_chest'],
      aliases: ['pec deck machine', 'machine chest fly', 'pec fly', 'butterfly machine', 'cable chest fly'],
      cues: ExerciseCues(
        feelItIn: 'Extreme stretch on the outer pecs and intense peak contraction across the sternum.',
        setupCue: 'Seat adjusted so elbows are level with mid-chest; slight bend maintained in elbows.',
        avoidMistake: 'Do not let elbows drop or rotate backwards past your comfort range.',
      ),
      coachTips: {
        'pro': 'Pause for 1 second in the fully contracted position with elbows touching imaginary center.',
        'teacher': 'Adduction of the humerus across the midline maximizes tension at shortened muscle lengths.',
        'supporter': 'Feel the gentle stretch and breathe out as the pads come together.',
      },
      instructions: """### Setup & Position
- Adjust seat so handles or arm pads align with your chest.
- Keep back flat on the support pad.

### Movement Execution
1. Bring arms together across your chest in a hugging motion.
2. Hold the peak contraction for 1 second.
3. Return slowly to feel a comfortable stretch in the chest.

### Safety Cue
- Do not let the weights hyperextend your shoulders at the back.""",
      videoUrl: 'https://www.youtube.com/watch?v=O-5k7h8F60I',
    ),

    // ─── 2. VERTICAL PUSH ────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_db_ohp',
      name: 'Seated Dumbbell Shoulder Press',
      targetMuscle: 'Front Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_ohp', 'ex_mach_shoulder_press'],
      aliases: ['seated dumbbell press', 'db shoulder press', 'seated db overhead press', 'dumbbell overhead press'],
      cues: ExerciseCues(
        feelItIn: 'Anterior and lateral heads of the deltoids.',
        setupCue: 'Bench angle at 75–80 degrees; dumbbells at ear level with elbows slightly angled forward.',
        avoidMistake: 'Do not flare elbows out 90 degrees or arch lower back excessively away from bench.',
      ),
      coachTips: {
        'pro': 'Drive vertically in an arc over your head. Keep your core glued to the back pad.',
        'teacher': 'Pressing in the scapular plane (~30° forward) eliminates impingement of the supraspinatus tendon.',
        'supporter': 'Stay tall, breathe smoothly, and press with steady, balanced confidence.',
      },
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
      alternativeIds: ['ex_db_ohp', 'ex_mach_shoulder_press'],
      aliases: ['overhead press', 'military press', 'standing barbell press', 'bb ohp'],
      cues: ExerciseCues(
        feelItIn: 'Shoulders, upper chest, and full-body core stabilizer chain.',
        setupCue: 'Feet shoulder-width; grip bar just outside delts; pull head back slightly to clear bar path.',
        avoidMistake: 'Do not lean back into an excessive spinal arch to heave the weight up.',
      ),
      coachTips: {
        'pro': 'Squeeze glutes and lock your core as if bracing for a punch before each rep.',
        'teacher': 'Once the bar passes forehead, push your head through the window to lock out directly over midfoot.',
        'supporter': 'Start lighter than you think. Overhead strength builds beautifully with patient, pristine form.',
      },
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
    ExerciseDefinition(
      id: 'ex_mach_shoulder_press',
      name: 'Shoulder Press Machine',
      targetMuscle: 'Front & Lateral Deltoids',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_db_ohp', 'ex_bb_ohp'],
      aliases: [
        'machine shoulder press',
        'seated shoulder press machine',
        'overhead press machine',
        'machine overhead press',
        'plate loaded shoulder press',
      ],
      cues: ExerciseCues(
        feelItIn: 'Front and middle deltoid caps without balance interference.',
        setupCue: 'Adjust seat so neutral/forward handles start level with your ears or chin.',
        avoidMistake: 'Do not let your lower back peel forward off the lumbar support.',
      ),
      coachTips: {
        'pro': 'Keep tension constant. Don\'t let the weight stack touch down between reps.',
        'teacher': 'Machine press provides a fixed convergent path that isolates deltoid contraction safely.',
        'supporter': 'Relax your neck and jaw. Drive straight up through the handles with smooth rhythm.',
      },
      instructions: """### Setup & Position
- Adjust seat height so handles are level with your shoulders or ears.
- Sit with back and head pressed flush against the pad.

### Movement Execution
1. Grip handles firmly and press vertically until arms are fully extended overhead.
2. Pause briefly at peak without hyperextending elbows.
3. Lower smoothly for 2-3 seconds until handles return to ear height.

### Safety Cue
- Keep core tight to prevent arching away from the back pad.""",
      videoUrl: 'https://www.youtube.com/watch?v=M2rwvNhTOu0',
    ),
    ExerciseDefinition(
      id: 'ex_db_lateral_raise',
      name: 'Dumbbell Lateral Raise',
      targetMuscle: 'Lateral Deltoids (Side Shoulders)',
      movementPattern: MovementPattern.verticalPush,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_db_ohp'],
      aliases: [
        'lateral raise',
        'dumbbell side raise',
        'db lateral raise',
        'side lateral raise',
        'side raise',
        'dumbbell side lateral raise',
      ],
      cues: ExerciseCues(
        feelItIn: 'Side deltoid caps (building shoulder width and V-taper).',
        setupCue: 'Lean torso forward 5–10°; raise arms in scapular plane (slightly in front of body).',
        avoidMistake: 'Do not shrug your traps or swing your torso to initiate the lift.',
      ),
      coachTips: {
        'pro': 'Think about pushing the dumbbells OUT towards the walls, not just lifting them up.',
        'teacher': 'Stopping at parallel (shoulder height) maintains lateral delt isolation without neck trap takeover.',
        'supporter': 'Light weights create magic on lateral raises. Strict form is 10x more effective than heavy swinging.',
      },
      instructions: """### Setup & Position
- Stand tall with dumbbells at sides, feet shoulder-width.
- Maintain a subtle 5-10 degree forward hinge at hips with soft knees.

### Movement Execution
1. Raise dumbbells out to the sides leading with your elbows.
2. Stop when arms are parallel to the floor (shoulder height).
3. Lower under strict 2-second control.

### Form Cues
- Keep thumbs slightly higher than pinkies or neutral to protect rotator cuff.""",
      videoUrl: 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
    ),
    ExerciseDefinition(
      id: 'ex_face_pull',
      name: 'Cable Face Pull',
      targetMuscle: 'Rear Deltoids & Rotator Cuff',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_db_lateral_raise'],
      aliases: ['face pull', 'cable face pulls', 'rope face pull', 'rear delt face pull'],
      cues: ExerciseCues(
        feelItIn: 'Rear shoulder caps, rhomboids, and upper back postural stabilizers.',
        setupCue: 'Set rope attachment at eye level; grip rope with thumbs pointing back towards you.',
        avoidMistake: 'Do not let your head jut forward to meet the rope; pull rope to your bridge of nose.',
      ),
      coachTips: {
        'pro': 'Rotate your hands back at the finish as if striking a double-bicep pose.',
        'teacher': 'Crucial for shoulder longevity: combines horizontal abduction with external rotation to counter desk slouching.',
        'supporter': 'One of the best posture-repair movements. Squeeze and feel your shoulder blades sing.',
      },
      instructions: """### Setup & Position
- Attach rope to cable pulley set at eye height.
- Step back with knees slightly unlocked and core braced.

### Movement Execution
1. Pull rope towards bridge of nose while actively spreading handles apart.
2. Rotate wrists backwards at the finish so thumbs point behind you.
3. Hold peak contraction for 1 second before controlling the return.

### Key Cue
- Keep elbows elevated high in line with ears.""",
      videoUrl: 'https://www.youtube.com/watch?v=rep-qVOkqgk',
    ),

    // ─── 3. HORIZONTAL PULL ──────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_db_row',
      name: 'Single-Arm Dumbbell Row',
      targetMuscle: 'Lats & Rhomboids',
      movementPattern: MovementPattern.horizontalPull,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bb_row', 'ex_cable_row'],
      aliases: ['one-arm dumbbell row', 'single arm db row', 'dumbbell row', 'db row'],
      cues: ExerciseCues(
        feelItIn: 'Lats (outer mid-back) and rear shoulder.',
        setupCue: 'Knee and hand on bench; torso flat parallel to floor; arm hanging straight down.',
        avoidMistake: 'Do not rotate your chest or jerk your shoulder upward to hoist the dumbbell.',
      ),
      coachTips: {
        'pro': 'Think "pull elbow to hip pocket" rather than curling with the bicep.',
        'teacher': 'Pulling diagonally towards the hip aligns line of pull with the latissimus dorsi fibers.',
        'supporter': 'Keep your spine long and supported. Focus on the stretch at the bottom.',
      },
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
      aliases: ['barbell row', 'bent over row', 'bb row', 'pendlay row'],
      cues: ExerciseCues(
        feelItIn: 'Mid back, lats, and spinal erectors.',
        setupCue: 'Hinge hips back to 45 degrees; flat spine; overhand grip outside knees.',
        avoidMistake: 'Do not stand up or bounce knees to get the bar moving.',
      ),
      coachTips: {
        'pro': 'Pull with the elbows. Hold the bar against your belly button for a count of one.',
        'teacher': 'Torso angle determines target: 45° targets mid/upper back, flatter angles recruit more lat.',
        'supporter': 'Brace your belly and protect your lower back. Quality over quantity every set.',
      },
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
      aliases: ['cable row', 'seated row', 'low row machine', 'seated low cable row'],
      cues: ExerciseCues(
        feelItIn: 'Rhomboids pinching between shoulder blades and lower lats.',
        setupCue: 'Sit tall on bench; knees softly bent; pull shoulders back and down.',
        avoidMistake: 'Do not rock aggressively forward and back with your lower back.',
      ),
      coachTips: {
        'pro': 'Stretch forward from the shoulder blades at the reach, but keep the torso upright.',
        'teacher': 'Scapular retraction followed by arm extension ensures optimal back muscle recruitment.',
        'supporter': 'Feel your posture open up with each pull. Great for undoing desk posture.',
      },
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

    // ─── 4. VERTICAL PULL ────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      targetMuscle: 'Lats & Upper Back',
      movementPattern: MovementPattern.verticalPull,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_pullups'],
      aliases: ['cable lat pulldown', 'wide grip lat pulldown', 'lat pull down', 'lat pulldowns'],
      cues: ExerciseCues(
        feelItIn: 'Lats wrapping around sides of ribcage down to the waist.',
        setupCue: 'Thigh pads snug; wide overhand grip; slight 10–15° backward torso lean.',
        avoidMistake: 'Do not lean back 45 degrees turning the pulldown into a messy row.',
      ),
      coachTips: {
        'pro': 'Drive your elbows straight down into your back pockets.',
        'teacher': 'Vertical downward elbow path engages lat fibers with minimal bicep compensation.',
        'supporter': 'Controlled stretch at the top; feel your lats lengthen safely before pulling.',
      },
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
      aliases: ['pullups', 'pull-ups', 'chin-ups', 'chinups', 'pull ups'],
      cues: ExerciseCues(
        feelItIn: 'Upper body pulling power through lats and forearms.',
        setupCue: 'Dead hang on bar; shoulders pulled down away from ears before bending arms.',
        avoidMistake: 'Do not kip or swing your legs to kick yourself over the bar.',
      ),
      coachTips: {
        'pro': 'Chest to bar. Lower under strict 3-second tempo to dead hang on every single rep.',
        'teacher': 'Initial scapular depression engages lower traps and lats prior to humeral flexion.',
        'supporter': 'Every millimeter counts. If needed, use a resistance band to keep reps clean and confident.',
      },
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

    // ─── 5. QUAD DOMINANT ────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_bb_squat',
      name: 'Barbell Back Squat',
      targetMuscle: 'Quadriceps & Glutes',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_goblet_squat', 'ex_leg_press'],
      aliases: ['squat', 'back squat', 'barbell squat', 'bb squat'],
      cues: ExerciseCues(
        feelItIn: 'Thighs, glutes, and full-body core bracing.',
        setupCue: 'Feet shoulder-width, toes angled slightly out; big belly breath into core.',
        avoidMistake: 'Do not let knees cave inward (valgus) or heels lift off the floor.',
      ),
      coachTips: {
        'pro': 'Spread the floor with your feet on the ascent. Drive through midfoot.',
        'teacher': 'Hip crease descending below top of kneecap ensures full quadriceps length-tension development.',
        'supporter': 'Solid footing, proud chest. Trust your depth and stand up tall.',
      },
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
      alternativeIds: ['ex_bb_squat', 'ex_leg_press'],
      aliases: ['goblet squat', 'db goblet squat', 'dumbbell squat'],
      cues: ExerciseCues(
        feelItIn: 'Quadriceps and hip stabilizers.',
        setupCue: 'Hold dumbbell vertically against chest with both palms cupping top plate.',
        avoidMistake: 'Do not let the dumbbell drift away from your sternum.',
      ),
      coachTips: {
        'pro': 'Sink hips between your ankles. Keep upright torso throughout.',
        'teacher': 'Front-loaded weight naturally forces an upright torso, ideal for building squat mechanics.',
        'supporter': 'A fantastic, knee-friendly way to build pure leg strength and mobility.',
      },
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
    ExerciseDefinition(
      id: 'ex_leg_press',
      name: 'Leg Press Machine',
      targetMuscle: 'Quadriceps & Glutes',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_bb_squat', 'ex_goblet_squat'],
      aliases: ['leg press', '45 degree leg press', 'machine leg press'],
      cues: ExerciseCues(
        feelItIn: 'Front thighs and glutes with zero spinal compression.',
        setupCue: 'Back flush to seat; feet shoulder-width on platform; lower safety bars.',
        avoidMistake: 'Never lock your knees out completely at top or let your tailbone curl off the seat.',
      ),
      coachTips: {
        'pro': 'Do not bounce at the bottom. Take 3 full seconds to descend into deep knee flexion.',
        'teacher': 'Isolates leg extensors without compressive spinal load, ideal for high-volume hypertrophy.',
        'supporter': 'Keep your lower back glued to the pad. Smooth and steady rhythm.',
      },
      instructions: """### Setup & Position
- Sit on machine with lower back firmly against pad.
- Place feet shoulder-width in center of sled.

### Movement Execution
1. Disengage safety handles and lower platform until knees are at 90 degrees.
2. Press through heels and midfoot back to top.
3. Stop just short of locking knees out.

### Caution
- Never allow lower back to round off the seat at depth.""",
      videoUrl: 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
    ),
    ExerciseDefinition(
      id: 'ex_leg_ext',
      name: 'Leg Extension Machine',
      targetMuscle: 'Quadriceps (Rectus Femoris)',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_goblet_squat'],
      aliases: ['leg extension', 'quad extension', 'machine leg extension'],
      cues: ExerciseCues(
        feelItIn: 'Intense burn directly across the front of the thighs.',
        setupCue: 'Knee joint aligned with machine pivot axis; pad resting comfortably on lower shins.',
        avoidMistake: 'Do not kick or swing weights upward with momentum.',
      ),
      coachTips: {
        'pro': 'Hold the peak lockout for 1 full second with quads flexed hard.',
        'teacher': 'Provides peak mechanical tension at full extension, overloading the rectus femoris.',
        'supporter': 'Focus on the squeeze at the top. Smooth and controlled descent.',
      },
      instructions: """### Setup & Position
- Align knee joints with the machine's pivot point.
- Set shin pad just above ankles.

### Movement Execution
1. Extend legs fully, squeezing quadriceps at the top.
2. Hold peak contraction for 1 second.
3. Lower slowly under full muscular resistance.

### Safety Cue
- Keep hips down firmly against the seat.""",
      videoUrl: 'https://www.youtube.com/watch?v=YyvSfVjQeL0',
    ),
    ExerciseDefinition(
      id: 'ex_bulgarian_split_squat',
      name: 'Bulgarian Split Squat',
      targetMuscle: 'Quads & Glute Max',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_goblet_squat'],
      aliases: ['rear foot elevated split squat', 'split squat', 'bulgarian split squat db', 'db split squat'],
      cues: ExerciseCues(
        feelItIn: 'Front leg glute and quad burning; deep stretch on rear hip flexor.',
        setupCue: 'Rear foot laces down on bench; front foot stepped forward into stable lunge stance.',
        avoidMistake: 'Do not push through front toes; keep weight centered on front heel.',
      ),
      coachTips: {
        'pro': 'Sink the rear knee towards the floor under strict 3-second control. Build bulletproof single-leg strength.',
        'teacher': 'Eliminates bilateral deficits and recruits gluteus medius for pelvic stability.',
        'supporter': 'Tough movement! Take your time finding your balance before starting the set.',
      },
      instructions: """### Setup & Position
- Place top of rear foot on bench behind you.
- Step front foot forward about 2-3 feet.

### Movement Execution
1. Lower hips straight down until front thigh is parallel to ground.
2. Drive through front heel to stand back up.
3. Keep torso slightly pitched forward to load the glute.

### Balance Tip
- Pick a stationary spot on the floor to look at.""",
      videoUrl: 'https://www.youtube.com/watch?v=2C-uNgKwPLE',
    ),

    // ─── 6. HIP HINGE ────────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_bb_deadlift',
      name: 'Barbell Conventional Deadlift',
      targetMuscle: 'Posterior Chain & Hamstrings',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.barbell,
      alternativeIds: ['ex_db_rdl'],
      aliases: ['deadlift', 'barbell deadlift', 'conventional deadlift', 'bb deadlift'],
      cues: ExerciseCues(
        feelItIn: 'Glutes, hamstrings, and whole posterior chain pulling together.',
        setupCue: 'Bar over midfoot; shins touching bar; chest tall to take slack out of bar.',
        avoidMistake: 'Never allow lower back to round or jerk bar off the floor.',
      ),
      coachTips: {
        'pro': 'Push the floor away through your heels. Keep bar glued to your shins.',
        'teacher': 'Hip hinge pattern transfers force through hip extensors without spinal flexion.',
        'supporter': 'Own your setup before you pull. A patient setup guarantees a safe, powerful lift.',
      },
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
      alternativeIds: ['ex_bb_deadlift', 'ex_leg_curl'],
      aliases: ['romanian deadlift', 'dumbbell rdl', 'db rdl', 'rdl', 'stiff leg deadlift'],
      cues: ExerciseCues(
        feelItIn: 'Deep stretch across the back of the hamstrings and glutes.',
        setupCue: 'Soft knees (unlocked); push hips back towards wall behind you as weights slide down shins.',
        avoidMistake: 'Do not bend knees into a squat; this is a pure hip hinge.',
      ),
      coachTips: {
        'pro': 'Stop the descent the moment your hips stop traveling backward. Squeeze glutes to stand.',
        'teacher': 'Lengthening hamstrings under load triggers superior stretch-mediated hypertrophy.',
        'supporter': 'Keep the dumbbells skimming your legs. Feel that fantastic hamstring stretch.',
      },
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
    ExerciseDefinition(
      id: 'ex_leg_curl',
      name: 'Lying Leg Curl Machine',
      targetMuscle: 'Hamstrings',
      movementPattern: MovementPattern.hipHinge,
      equipment: EquipmentType.machines,
      alternativeIds: ['ex_db_rdl'],
      aliases: ['leg curl', 'lying leg curl', 'hamstring curl', 'machine leg curl', 'seated leg curl'],
      cues: ExerciseCues(
        feelItIn: 'Direct hamstring contraction pulling heels towards glutes.',
        setupCue: 'Lie flat with pad resting just below calves; knees aligned with pivot point.',
        avoidMistake: 'Do not arch lower back or lift hips off pad during the curl.',
      ),
      coachTips: {
        'pro': 'Point toes slightly towards shins (dorsiflexion) to maximize hamstring tension.',
        'teacher': 'Direct knee flexion isolation complements the hip hinge movement pattern for total hamstring health.',
        'supporter': 'Keep hips glued to the bench and curl with smooth, controlled rhythm.',
      },
      instructions: """### Setup & Position
- Lie face down on machine with leg pad against lower calves.
- Hold side handles to anchor hips to the bench.

### Movement Execution
1. Curl legs upward towards glutes as far as comfortably possible.
2. Hold contraction for 1 second.
3. Lower slowly under 3-second resistance.

### Form Cue
- Keep hips pressed into pad throughout the rep.""",
      videoUrl: 'https://www.youtube.com/watch?v=1Tq3QdYUuHs',
    ),

    // ─── 7. ARM ISOLATION ────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_bicep_curl',
      name: 'Dumbbell Bicep Curl',
      targetMuscle: 'Biceps Brachii',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_hammer_curl'],
      aliases: ['bicep curl', 'db bicep curl', 'dumbbell curl', 'standing bicep curl', 'arm curl'],
      cues: ExerciseCues(
        feelItIn: 'Front of the upper arm squeezing tight at top.',
        setupCue: 'Elbows pinned to sides; supinate wrists as dumbbells rise (turn palms up).',
        avoidMistake: 'Do not swing your torso or drive elbows forward to lift the weights.',
      ),
      coachTips: {
        'pro': 'Full range of motion: completely extend your elbow at the bottom before curling.',
        'teacher': 'Supinating the forearm activates both the long and short head of the biceps fully.',
        'supporter': 'Keep your shoulders relaxed and let your arms do the clean work.',
      },
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
      id: 'ex_hammer_curl',
      name: 'Dumbbell Hammer Curl',
      targetMuscle: 'Brachialis & Forearms',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_bicep_curl'],
      aliases: ['hammer curl', 'db hammer curl', 'neutral grip curl'],
      cues: ExerciseCues(
        feelItIn: 'Outer arm thickness (brachialis) and top of forearms.',
        setupCue: 'Palms facing each other (neutral grip) throughout the entire movement.',
        avoidMistake: 'Do not twist wrists or use body momentum.',
      ),
      coachTips: {
        'pro': 'Squeeze dumbbells hard at the top like hammering a nail.',
        'teacher': 'Neutral wrist position shifts mechanical advantage to the brachialis and brachioradialis.',
        'supporter': 'Great exercise for building arm density and wrist stability safely.',
      },
      instructions: """### Setup & Position
- Hold dumbbells with palms facing each other (neutral grip).
- Stand with knees slightly soft and core tight.

### Movement Execution
1. Curl dumbbells upward while keeping palms facing inward.
2. Squeeze at shoulder height.
3. Lower with control to full arm extension.

### Focus
- Keep elbows stationary by your sides.""",
      videoUrl: 'https://www.youtube.com/watch?v=zC3nLlEvin4',
    ),
    ExerciseDefinition(
      id: 'ex_tricep_pushdown',
      name: 'Cable Tricep Pushdown',
      targetMuscle: 'Triceps Lateral & Medial Heads',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_tricep_rope_pushdown', 'ex_overhead_tricep'],
      aliases: ['tricep pushdown', 'cable pushdown', 'bar pushdown', 'cable triceps extension'],
      cues: ExerciseCues(
        feelItIn: 'Back of the upper arms (triceps horseshoe).',
        setupCue: 'Straight or V-bar on high pulley; elbows pinned to ribcage; hinge slightly forward.',
        avoidMistake: 'Do not allow elbows to drift forward or shoulders to shrug up.',
      ),
      coachTips: {
        'pro': 'Lock out fully at the bottom with maximum triceps flex. Control the return.',
        'teacher': 'Fixing the upper arm isolates pure elbow extension, removing shoulder involvement.',
        'supporter': 'Keep your chest open and breathe out on the push.',
      },
      instructions: """### Setup & Position
- Attach straight bar or V-bar to high cable pulley.
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
      id: 'ex_tricep_rope_pushdown',
      name: 'Triceps Rope Pulldown',
      targetMuscle: 'Triceps Lateral & Long Heads',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.cables,
      alternativeIds: ['ex_tricep_pushdown', 'ex_overhead_tricep'],
      aliases: [
        'tricep rope pushdown',
        'triceps rope pulldown',
        'rope pushdown',
        'rope pulldown',
        'cable rope pushdown',
        'rope triceps extension',
        'rope tricep pushdown',
      ],
      cues: ExerciseCues(
        feelItIn: 'Triceps horseshoe; spread ropes apart at bottom for deep peak contraction.',
        setupCue: 'Rope on high cable; elbows glued to sides; flare rope ends outward at bottom lockout.',
        avoidMistake: 'Do not let upper arms swing back and forth.',
      ),
      coachTips: {
        'pro': 'Separate the rope handles as hard as possible at the bottom to hit the lateral head.',
        'teacher': 'Rope allows natural internal rotation and increased active range of motion at lockout.',
        'supporter': 'Stay balanced, hinge forward slightly, and enjoy that crisp triceps squeeze.',
      },
      instructions: """### Setup & Position
- Attach rope attachment to high cable pulley.
- Stand with a slight forward torso angle, elbows pinned to sides.

### Movement Execution
1. Push rope downwards until arms are fully extended.
2. Spread the rope ends apart at the bottom to maximize peak triceps contraction.
3. Return slowly until forearms are slightly above 90 degrees.

### Form Cue
- Only the forearms move; upper arms remain completely stationary.""",
      videoUrl: 'https://www.youtube.com/watch?v=vB5OHsJ3EME',
    ),
    ExerciseDefinition(
      id: 'ex_overhead_tricep',
      name: 'Dumbbell Overhead Tricep Extension',
      targetMuscle: 'Triceps Long Head',
      movementPattern: MovementPattern.armIso,
      equipment: EquipmentType.dumbbells,
      alternativeIds: ['ex_tricep_pushdown', 'ex_tricep_rope_pushdown'],
      aliases: ['overhead tricep extension', 'dumbbell tricep extension', 'db overhead tricep'],
      cues: ExerciseCues(
        feelItIn: 'Triceps long head (inner back of arm along shoulder blade).',
        setupCue: 'Sit tall; dumbbell held vertically overhead with both hands cupping top plate.',
        avoidMistake: 'Do not flare elbows wide outwards or arch lower back.',
      ),
      coachTips: {
        'pro': 'Lower all the way behind head to feel a deep long-head stretch before pressing.',
        'teacher': 'Overhead shoulder position places the long head of the triceps on stretch for maximal muscle growth.',
        'supporter': 'Keep your elbows tucked and press with steady control.',
      },
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

    // ─── 8. CORE & CALVES ────────────────────────────────────────────
    ExerciseDefinition(
      id: 'ex_plank',
      name: 'Core Plank',
      targetMuscle: 'Transverse Abdominis & Core',
      movementPattern: MovementPattern.core,
      equipment: EquipmentType.bodyweight,
      alternativeIds: [],
      aliases: ['plank', 'forearm plank', 'abdominal plank'],
      cues: ExerciseCues(
        feelItIn: 'Deep abdominal wall, glutes, and shoulders holding rigid tension.',
        setupCue: 'Forearms on floor under shoulders; body in a rigid straight line from head to heels.',
        avoidMistake: 'Do not let hips sag towards floor or pike up high.',
      ),
      coachTips: {
        'pro': 'Pull elbows towards toes to create maximal isometric abdominal tension.',
        'teacher': 'Anti-extension stability trains the core to protect the lumbar spine under heavy loads.',
        'supporter': 'Breathe steadily. Keep that rock-solid line and hold strong!',
      },
      instructions: """### Setup & Position
- Rest on forearms and balls of feet.
- Forearms parallel, elbows directly below shoulders.

### Movement Execution
1. Squeeze glutes and draw navel towards spine.
2. Hold perfectly straight line without sagging.
3. Breathe in controlled diaphragm breaths throughout.

### Form Cue
- Treat the plank like an active full-body flex.""",
      videoUrl: 'https://www.youtube.com/watch?v=ASdvN_XEl_c',
    ),
    ExerciseDefinition(
      id: 'ex_calf_raise',
      name: 'Standing Calf Raise',
      targetMuscle: 'Gastrocnemius (Calves)',
      movementPattern: MovementPattern.quadDominant,
      equipment: EquipmentType.dumbbells,
      alternativeIds: [],
      aliases: ['calf raise', 'standing calf raises', 'db calf raise', 'machine calf raise'],
      cues: ExerciseCues(
        feelItIn: 'Upper calf muscle belly pushing onto balls of big toes.',
        setupCue: 'Stand on edge of step with balls of feet; heels hanging off for full stretch.',
        avoidMistake: 'Do not bounce at the bottom using Achilles tendon elasticity.',
      ),
      coachTips: {
        'pro': 'Pause 2 full seconds in the deep stretch at bottom, then explode onto toes.',
        'teacher': 'Pausing eliminates the stretch reflex, forcing the gastrocnemius fibers to perform 100% of the work.',
        'supporter': 'Full stretch and proud contraction at the top. Great for ankle resilience!',
      },
      instructions: """### Setup & Position
- Stand with balls of feet on edge of platform or step.
- Hold weight or wall for balance.

### Movement Execution
1. Lower heels below platform level for a full calf stretch.
2. Hold bottom stretch for 2 seconds.
3. Press up powerfully onto balls of big toes to peak contraction.

### Safety Cue
- No bouncing at the bottom.""",
      videoUrl: 'https://www.youtube.com/watch?v=ymmwvffcQ4E',
    ),
  ];

  /// Normalizes a string for matching: lowercase, alphanumeric and spaces only
  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extracts meaningful stem tokens, expanding common abbreviations
  static Set<String> _tokenize(String input) {
    final normalized = _normalize(input);
    final rawTokens = normalized.split(' ').where((t) => t.isNotEmpty);
    final Set<String> tokens = {};

    for (final t in rawTokens) {
      if (t == 'db') {
        tokens.add('dumbbell');
      } else if (t == 'bb') {
        tokens.add('barbell');
      } else if (t == 'mach' || t == 'machinery') {
        tokens.add('machine');
      } else if (t == 'tricep' || t == 'triceps') {
        tokens.add('tricep');
      } else if (t == 'bicep' || t == 'biceps') {
        tokens.add('bicep');
      } else if (t == 'delt' || t == 'delts' || t == 'deltoid' || t == 'deltoids') {
        tokens.add('shoulder');
      } else if (t == 'abs' || t == 'abdominals' || t == 'abdominal') {
        tokens.add('core');
      } else {
        tokens.add(t);
      }
    }
    return tokens;
  }

  /// Robust multi-stage lookup resolving exact, alias, substring, and token-overlap matches
  static ExerciseDefinition? findDefinition(String name) {
    final clean = _normalize(name);
    if (clean.isEmpty) return null;

    // Stage 1: Exact Name Match
    for (final e in library) {
      if (_normalize(e.name) == clean) return e;
    }

    // Stage 2: Exact Alias Match
    for (final e in library) {
      for (final alias in e.aliases) {
        if (_normalize(alias) == clean) return e;
      }
    }

    // Stage 3: Direct Substring Containment (multi-token or substantial match)
    for (final e in library) {
      final eNorm = _normalize(e.name);
      if (eNorm.contains(clean) || (clean.contains(eNorm) && eNorm.split(' ').length >= 2)) {
        return e;
      }
      for (final alias in e.aliases) {
        final aNorm = _normalize(alias);
        if (aNorm.contains(clean) || (clean.contains(aNorm) && aNorm.split(' ').length >= 2)) {
          return e;
        }
      }
    }

    // Stage 4: Stem & Token-Overlap Scoring
    final queryTokens = _tokenize(name);
    if (queryTokens.isEmpty) return null;

    ExerciseDefinition? bestMatch;
    double bestScore = 0.0;

    for (final e in library) {
      final candidates = [e.name, ...e.aliases];
      for (final candidate in candidates) {
        final candidateTokens = _tokenize(candidate);
        if (candidateTokens.isEmpty) continue;

        final intersection = queryTokens.intersection(candidateTokens);
        if (intersection.isEmpty) continue;

        final union = queryTokens.union(candidateTokens);
        final jaccard = intersection.length / union.length;
        final candidateCoverage = intersection.length / candidateTokens.length;
        final queryCoverage = intersection.length / queryTokens.length;

        // Ensure at least 40% of the query's concepts are covered
        if (queryCoverage < 0.40) continue;

        final score = (jaccard * 0.5) + (queryCoverage * 0.3) + (candidateCoverage * 0.2);

        if (score > bestScore && score >= 0.55) {
          bestScore = score;
          bestMatch = e;
        }
      }
    }

    return bestMatch;
  }

  /// Resolves glanceable 3-Cue Triad for any exercise
  static ExerciseCues resolveCues(Exercise ex) {
    final def = findDefinition(ex.name);
    if (def?.cues != null) return def!.cues!;

    final muscle = ex.targetMuscle.isNotEmpty ? ex.targetMuscle : 'target muscle';
    final eq = ex.equipmentRequired.isNotEmpty ? ex.equipmentRequired : 'equipment';

    return ExerciseCues(
      feelItIn: 'Deep muscular contraction and controlled stretch in the $muscle.',
      setupCue: 'Secure stable footing and brace core; align joint angle with the $eq resistance line.',
      avoidMistake: 'Do not use body momentum or swing. Control the eccentric phase for 2 seconds.',
    );
  }

  /// Resolves a verified tutorial video URL (or deterministic trusted channel search)
  static String resolveVideoUrl(Exercise ex) {
    if (ex.videoUrl != null && ex.videoUrl!.isNotEmpty) {
      return ex.videoUrl!;
    }
    final def = findDefinition(ex.name);
    if (def?.videoUrl != null && def!.videoUrl!.isNotEmpty) {
      return def.videoUrl!;
    }
    return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent('Renaissance Periodization ${ex.name} proper form')}';
  }

  /// Resolves actionable coaching tip matching the user's active Coach Soul
  static String resolveCoachTip(Exercise ex, CoachSoul soul) {
    final def = findDefinition(ex.name);
    final key = soul.name;
    if (def?.coachTips != null && def!.coachTips![key] != null) {
      return def.coachTips![key]!;
    }
    switch (soul) {
      case CoachSoul.pro:
        return 'Lock in strict 2-second negatives. Explode through the concentric phase with zero momentum.';
      case CoachSoul.teacher:
        return 'Focus on full range of motion. Mechanical tension in the stretched position triggers optimal hypertrophy.';
      case CoachSoul.supporter:
        return 'Listen to your joints today. Stay within a pain-free range of motion and celebrate every clean rep.';
    }
  }

  /// Resolves phase-by-phase detailed instructions
  static String resolveInstructions(Exercise ex) {
    if (ex.instructions != null && ex.instructions!.isNotEmpty) {
      return ex.instructions!;
    }
    final def = findDefinition(ex.name);
    if (def?.instructions != null && def!.instructions!.isNotEmpty) {
      return def.instructions!;
    }
    final cues = resolveCues(ex);
    return """### Setup & Position
- ${cues.setupCue}

### Movement Execution
1. Initiate movement strictly using ${ex.targetMuscle}.
2. Lower under full muscular control for 2 seconds.
3. Drive through to peak contraction.

### Safety & Focus
- ${cues.avoidMistake}""";
  }

  /// Finds biomechanically equivalent exercise substitutions matching user equipment constraints
  static List<ExerciseDefinition> getSubstitutions({
    required String currentExerciseName,
    required List<EquipmentType> availableEquipment,
  }) {
    final current = findDefinition(currentExerciseName);
    if (current == null) return [];

    return library.where((e) {
      if (e.id == current.id || e.name.toLowerCase() == current.name.toLowerCase()) return false;
      final matchesPattern = e.movementPattern == current.movementPattern;
      final matchesEquipment = availableEquipment.contains(e.equipment) || e.equipment == EquipmentType.bodyweight;
      return matchesPattern && matchesEquipment;
    }).toList();
  }
}
