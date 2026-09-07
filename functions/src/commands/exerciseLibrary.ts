export interface ExerciseDef {
  id: string;
  name: string;
  targetMuscle: string;
  movementPattern: string;
  equipment: "bodyweight" | "dumbbells" | "barbell" | "cables" | "machine" | "free_weight";
  jointLoad: "low" | "medium" | "high";
  isKneeIntensive: boolean;
  isLowerBackIntensive: boolean;
  alternativeIds: string[];
}

export const EXERCISE_LIBRARY: ExerciseDef[] = [
  // --- QUAD DOMINANT / UNILATERAL ---
  {
    id: "ex_bulgarian_split_squat",
    name: "Bulgarian Split Squat",
    targetMuscle: "Quadriceps & Glutes",
    movementPattern: "quadDominant",
    equipment: "dumbbells",
    jointLoad: "high",
    isKneeIntensive: true,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_step_up", "ex_goblet_squat", "ex_db_rdl"],
  },
  {
    id: "ex_db_step_up",
    name: "Dumbbell Box Step-Up",
    targetMuscle: "Quadriceps & Glutes",
    movementPattern: "quadDominant",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bulgarian_split_squat", "ex_goblet_squat"],
  },
  {
    id: "ex_goblet_squat",
    name: "Dumbbell Goblet Squat",
    targetMuscle: "Quadriceps",
    movementPattern: "quadDominant",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bb_squat", "ex_bodyweight_squat"],
  },
  {
    id: "ex_bb_squat",
    name: "Barbell Back Squat",
    targetMuscle: "Quadriceps & Glutes",
    movementPattern: "quadDominant",
    equipment: "barbell",
    jointLoad: "high",
    isKneeIntensive: true,
    isLowerBackIntensive: true,
    alternativeIds: ["ex_goblet_squat", "ex_leg_press"],
  },
  {
    id: "ex_bodyweight_squat",
    name: "Bodyweight Squat",
    targetMuscle: "Quadriceps",
    movementPattern: "quadDominant",
    equipment: "bodyweight",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_goblet_squat"],
  },
  {
    id: "ex_leg_press",
    name: "Leg Press",
    targetMuscle: "Quadriceps",
    movementPattern: "quadDominant",
    equipment: "machine",
    jointLoad: "medium",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_goblet_squat", "ex_bb_squat"],
  },

  // --- HIP HINGE ---
  {
    id: "ex_bb_deadlift",
    name: "Barbell Conventional Deadlift",
    targetMuscle: "Posterior Chain & Hamstrings",
    movementPattern: "hipHinge",
    equipment: "barbell",
    jointLoad: "high",
    isKneeIntensive: false,
    isLowerBackIntensive: true,
    alternativeIds: ["ex_db_rdl", "ex_glute_bridge"],
  },
  {
    id: "ex_db_rdl",
    name: "Dumbbell Romanian Deadlift",
    targetMuscle: "Hamstrings & Glutes",
    movementPattern: "hipHinge",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bb_deadlift", "ex_glute_bridge"],
  },
  {
    id: "ex_glute_bridge",
    name: "Bodyweight Glute Bridge",
    targetMuscle: "Glutes & Hamstrings",
    movementPattern: "hipHinge",
    equipment: "bodyweight",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_rdl"],
  },

  // --- HORIZONTAL PUSH ---
  {
    id: "ex_db_bench",
    name: "Flat Dumbbell Press",
    targetMuscle: "Mid Chest",
    movementPattern: "horizontalPush",
    equipment: "dumbbells",
    jointLoad: "medium",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bb_bench", "ex_pushups"],
  },
  {
    id: "ex_bb_bench",
    name: "Flat Barbell Bench Press",
    targetMuscle: "Mid Chest",
    movementPattern: "horizontalPush",
    equipment: "barbell",
    jointLoad: "medium",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_bench", "ex_pushups"],
  },
  {
    id: "ex_pushups",
    name: "Bodyweight Push-Ups",
    targetMuscle: "Mid Chest & Triceps",
    movementPattern: "horizontalPush",
    equipment: "bodyweight",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_bench"],
  },

  // --- VERTICAL PUSH ---
  {
    id: "ex_db_shoulder_press",
    name: "Dumbbell Overhead Press",
    targetMuscle: "Shoulders & Triceps",
    movementPattern: "verticalPush",
    equipment: "dumbbells",
    jointLoad: "medium",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_pike_pushup"],
  },
  {
    id: "ex_pike_pushup",
    name: "Pike Push-Ups",
    targetMuscle: "Shoulders",
    movementPattern: "verticalPush",
    equipment: "bodyweight",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_shoulder_press"],
  },

  // --- HORIZONTAL PULL ---
  {
    id: "ex_db_row",
    name: "Single-Arm Dumbbell Row",
    targetMuscle: "Upper Back & Lats",
    movementPattern: "horizontalPull",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bb_row", "ex_cable_row"],
  },
  {
    id: "ex_bb_row",
    name: "Bent-Over Barbell Row",
    targetMuscle: "Upper Back & Lats",
    movementPattern: "horizontalPull",
    equipment: "barbell",
    jointLoad: "medium",
    isKneeIntensive: false,
    isLowerBackIntensive: true,
    alternativeIds: ["ex_db_row", "ex_cable_row"],
  },
  {
    id: "ex_cable_row",
    name: "Seated Cable Row",
    targetMuscle: "Mid Back & Lats",
    movementPattern: "horizontalPull",
    equipment: "cables",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_db_row", "ex_bb_row"],
  },

  // --- VERTICAL PULL ---
  {
    id: "ex_lat_pulldown",
    name: "Lat Pulldown",
    targetMuscle: "Lats & Upper Back",
    movementPattern: "verticalPull",
    equipment: "cables",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_pullups"],
  },
  {
    id: "ex_pullups",
    name: "Bodyweight Pull-Ups",
    targetMuscle: "Lats & Arms",
    movementPattern: "verticalPull",
    equipment: "bodyweight",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_lat_pulldown"],
  },

  // --- ARM ISOLATION ---
  {
    id: "ex_bicep_curl",
    name: "Dumbbell Bicep Curl",
    targetMuscle: "Biceps",
    movementPattern: "armIso",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_cable_curl"],
  },
  {
    id: "ex_cable_curl",
    name: "Cable Bicep Curl",
    targetMuscle: "Biceps",
    movementPattern: "armIso",
    equipment: "cables",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_bicep_curl"],
  },
  {
    id: "ex_tricep_pushdown",
    name: "Cable Tricep Pushdown",
    targetMuscle: "Triceps",
    movementPattern: "armIso",
    equipment: "cables",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_overhead_tricep"],
  },
  {
    id: "ex_overhead_tricep",
    name: "Dumbbell Overhead Tricep Extension",
    targetMuscle: "Triceps Long Head",
    movementPattern: "armIso",
    equipment: "dumbbells",
    jointLoad: "low",
    isKneeIntensive: false,
    isLowerBackIntensive: false,
    alternativeIds: ["ex_tricep_pushdown"],
  },
];

/**
 * Normalizes an exercise name for fuzzy comparison.
 */
function normalizeName(name: string): string {
  return (name || "").toLowerCase().replace(/[^a-z0-9]/g, "");
}

/**
 * Find definition from library by name or ID.
 */
export function findExerciseInLibrary(nameOrId: string): ExerciseDef | null {
  if (!nameOrId) return null;
  const lower = nameOrId.toLowerCase().trim();
  const normalized = normalizeName(nameOrId);

  // Exact ID match
  const byId = EXERCISE_LIBRARY.find((e) => e.id.toLowerCase() === lower);
  if (byId) return byId;

  // Exact name match
  const byName = EXERCISE_LIBRARY.find((e) => e.name.toLowerCase() === lower);
  if (byName) return byName;

  // Substring or normalized match
  const byNorm = EXERCISE_LIBRARY.find(
    (e) => normalizeName(e.name) === normalized ||
           normalizeName(e.name).includes(normalized) ||
           normalized.includes(normalizeName(e.name))
  );
  if (byNorm) return byNorm;

  return null;
}

/**
 * Find biomechanically sound exercise substitution based on user equipment and limitations.
 */
export function findSubstitutions(
  currentDef: ExerciseDef | { name: string; targetMuscle?: string; equipmentRequired?: string },
  availableEquipmentNames: string[] = ["bodyweight", "dumbbells"],
  reason?: string
): ExerciseDef[] {
  const normReason = (reason || "").toLowerCase();
  const isKneeIssue = normReason.includes("knee") || normReason.includes("joint");
  const isBackIssue = normReason.includes("back") || normReason.includes("spine");

  // Normalize available equipment
  const eqSet = new Set<string>(
    availableEquipmentNames.map((e) => {
      const l = e.toLowerCase();
      if (l.includes("dumbbell")) return "dumbbells";
      if (l.includes("barbell")) return "barbell";
      if (l.includes("cable")) return "cables";
      if (l.includes("machine")) return "machine";
      if (l.includes("kettlebell")) return "dumbbells";
      return "bodyweight";
    })
  );
  eqSet.add("bodyweight"); // bodyweight is always available

  // If full def known
  const libDef = findExerciseInLibrary(currentDef.name) || (("id" in currentDef && currentDef.id) ? findExerciseInLibrary(currentDef.id) : null);

  // Filter candidates
  const candidates = EXERCISE_LIBRARY.filter((candidate) => {
    // Cannot substitute with itself
    if (libDef && candidate.id === libDef.id) return false;
    if (normalizeName(candidate.name) === normalizeName(currentDef.name)) return false;

    // Check equipment compatibility
    const equipmentMatches = eqSet.has(candidate.equipment as string) || candidate.equipment === "bodyweight" || candidate.equipment === "free_weight";
    if (!equipmentMatches) return false;

    // Check injury / joint compatibility
    if (isKneeIssue && candidate.isKneeIntensive) return false;
    if (isBackIssue && candidate.isLowerBackIntensive) return false;

    // Movement pattern or muscle match
    if (libDef) {
      if (candidate.movementPattern === libDef.movementPattern) return true;
      if (candidate.targetMuscle.toLowerCase() === libDef.targetMuscle.toLowerCase()) return true;
    } else {
      if (currentDef.targetMuscle && candidate.targetMuscle.toLowerCase().includes(currentDef.targetMuscle.toLowerCase())) {
        return true;
      }
    }

    return false;
  });

  // Prioritize curated alternatives
  if (libDef && Array.isArray(libDef.alternativeIds) && libDef.alternativeIds.length > 0) {
    candidates.sort((a, b) => {
      const aIsDirect = libDef.alternativeIds.includes(a.id) ? 1 : 0;
      const bIsDirect = libDef.alternativeIds.includes(b.id) ? 1 : 0;
      return bIsDirect - aIsDirect;
    });
  }

  return candidates;
}
