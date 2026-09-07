import * as admin from "firebase-admin";
import { ContextEnvelope, ResolutionContext, TargetExerciseResolution } from "../commands/types";

function normalizeString(str: string): string {
  return (str || "").toLowerCase().replace(/[^a-z0-9]/g, "");
}

/**
 * Builds the ResolutionContext with deterministic target resolution.
 */
export function buildResolutionContext(
  uid: string,
  todayStr: string,
  userState: {
    profile: any;
    workout: any;
    nutrition: any;
    recovery: any;
  },
  envelope: ContextEnvelope | undefined,
  db: admin.firestore.Firestore
): ResolutionContext {
  const workoutExercises: any[] = Array.isArray(userState.workout?.exercises)
    ? userState.workout.exercises
    : [];

  const resolveExerciseTarget = (targetNameOrPronoun?: string): TargetExerciseResolution | null => {
    const rawTarget = (targetNameOrPronoun || "").trim().toLowerCase();
    const isImplicit =
      !rawTarget ||
      rawTarget === "this" ||
      rawTarget === "it" ||
      rawTarget === "this exercise" ||
      rawTarget === "that" ||
      rawTarget === "that one" ||
      rawTarget === "current" ||
      rawTarget === "current exercise";

    // 1. If implicit pronoun ("this", "it", etc.), use Context Envelope first
    if (isImplicit) {
      if (envelope?.focusedExerciseId) {
        const idx = workoutExercises.findIndex(
          (ex: any) => ex.id && ex.id.toLowerCase() === envelope.focusedExerciseId!.toLowerCase()
        );
        if (idx !== -1) {
          return { exercise: workoutExercises[idx], index: idx };
        }
      }
      if (envelope?.focusedExerciseName) {
        const normFocused = normalizeString(envelope.focusedExerciseName);
        const idx = workoutExercises.findIndex(
          (ex: any) => normalizeString(ex.name) === normFocused ||
                      normalizeString(ex.name).includes(normFocused) ||
                      normFocused.includes(normalizeString(ex.name))
        );
        if (idx !== -1) {
          return { exercise: workoutExercises[idx], index: idx };
        }
      }
      // If only one exercise in the workout, resolve to it
      if (workoutExercises.length === 1) {
        return { exercise: workoutExercises[0], index: 0 };
      }
      // If currentSetIndex is given, try the first exercise or fallback to 0
      if (workoutExercises.length > 0) {
        return { exercise: workoutExercises[0], index: 0 };
      }
      return null;
    }

    // 2. Check for ordinal phrases ("first", "second", "the 2nd one", "last exercise")
    if (workoutExercises.length > 0) {
      if (rawTarget.includes("first") || rawTarget.includes("1st")) {
        return { exercise: workoutExercises[0], index: 0 };
      }
      if (rawTarget.includes("second") || rawTarget.includes("2nd")) {
        if (workoutExercises.length > 1) return { exercise: workoutExercises[1], index: 1 };
      }
      if (rawTarget.includes("third") || rawTarget.includes("3rd")) {
        if (workoutExercises.length > 2) return { exercise: workoutExercises[2], index: 2 };
      }
      if (rawTarget.includes("fourth") || rawTarget.includes("4th")) {
        if (workoutExercises.length > 3) return { exercise: workoutExercises[3], index: 3 };
      }
      if (rawTarget.includes("last")) {
        const lastIdx = workoutExercises.length - 1;
        return { exercise: workoutExercises[lastIdx], index: lastIdx };
      }
    }

    // 3. Exact or partial name matching against today's workout exercises
    const normTarget = normalizeString(rawTarget);
    for (let i = 0; i < workoutExercises.length; i++) {
      const ex = workoutExercises[i];
      const exName = normalizeString(ex.name || "");
      if (exName === normTarget || exName.includes(normTarget) || normTarget.includes(exName)) {
        return { exercise: ex, index: i };
      }
    }

    // 4. Try matching exercise ID
    for (let i = 0; i < workoutExercises.length; i++) {
      const ex = workoutExercises[i];
      if (ex.id && ex.id.toLowerCase() === rawTarget) {
        return { exercise: ex, index: i };
      }
    }

    // 5. Fallback: if user is looking at an exercise in the envelope, match that
    if (envelope?.focusedExerciseName && normalizeString(envelope.focusedExerciseName).includes(normTarget)) {
      const idx = workoutExercises.findIndex((ex: any) =>
        normalizeString(ex.name) === normalizeString(envelope.focusedExerciseName!)
      );
      if (idx !== -1) return { exercise: workoutExercises[idx], index: idx };
    }

    return null;
  };

  const resolveWorkoutTarget = (targetDateOrDescriptor?: string): string => {
    if (!targetDateOrDescriptor) {
      return envelope?.activeWorkoutDate || todayStr;
    }
    const lower = targetDateOrDescriptor.trim().toLowerCase();
    if (lower === "today" || lower === "today's workout" || lower === "this workout") {
      return todayStr;
    }
    if (lower === "tomorrow" || lower === "tomorrow's workout") {
      const d = new Date();
      d.setDate(d.getDate() + 1);
      return d.toISOString().split("T")[0];
    }
    if (lower === "yesterday") {
      const d = new Date();
      d.setDate(d.getDate() - 1);
      return d.toISOString().split("T")[0];
    }
    if (/^\d{4}-\d{2}-\d{2}$/.test(targetDateOrDescriptor.trim())) {
      return targetDateOrDescriptor.trim();
    }
    return envelope?.activeWorkoutDate || todayStr;
  };

  const resolveSetTarget = (
    setIndexOrDescriptor?: string | number,
    exerciseIndex: number = 0
  ): number | null => {
    const ex = workoutExercises[exerciseIndex];
    const sets = Array.isArray(ex?.sets) ? ex.sets : [];
    if (sets.length === 0) return null;

    if (typeof setIndexOrDescriptor === "number") {
      // Allow 0-indexed or 1-indexed
      if (setIndexOrDescriptor >= 0 && setIndexOrDescriptor < sets.length) {
        return setIndexOrDescriptor;
      }
      if (setIndexOrDescriptor >= 1 && setIndexOrDescriptor <= sets.length) {
        return setIndexOrDescriptor - 1;
      }
    }

    const desc = String(setIndexOrDescriptor || "").toLowerCase().trim();
    if (!desc || desc === "current" || desc === "this set") {
      if (envelope?.currentSetIndex !== undefined) {
        const idx = envelope.currentSetIndex;
        return idx < sets.length ? idx : sets.length - 1;
      }
      return 0;
    }

    if (desc.includes("last")) return sets.length - 1;
    if (desc.includes("first") || desc.includes("1st")) return 0;
    if (desc.includes("second") || desc.includes("2nd")) return Math.min(1, sets.length - 1);
    if (desc.includes("third") || desc.includes("3rd")) return Math.min(2, sets.length - 1);

    const match = desc.match(/set\s*(\d+)/i);
    if (match) {
      const num = parseInt(match[1], 10);
      if (num >= 1 && num <= sets.length) return num - 1;
    }

    return null;
  };

  return {
    uid,
    todayStr,
    userState,
    envelope,
    db,
    resolveExerciseTarget,
    resolveWorkoutTarget,
    resolveSetTarget,
  };
}

/**
 * Semantic Compression: Translates raw JSON state and context envelope into dense working memory.
 */
export function compressSemanticState(state: any, envelope?: ContextEnvelope): string {
  if (!state) return "New client onboarding baseline.";

  const profile = state.profile || {};
  const workout = state.workout || {};
  const nutrition = state.nutrition || {};
  const recovery = state.recovery || {};

  const name = profile.name || "Client";
  const gender = profile.gender || "unspecified";
  const age = profile.age || 25;
  const weight = profile.weightKg || 70;
  const targetWeight = profile.targetWeightKg || weight;
  const goal = profile.goal || "recomp";
  const soul = profile.coachSoul || "supporter";

  // Equipment
  const equipment =
    Array.isArray(profile.equipmentList) && profile.equipmentList.length > 0
      ? profile.equipmentList
          .map((e: any) => (typeof e === "string" ? e : e.name || ""))
          .filter(Boolean)
          .join(", ")
      : "Bodyweight";

  // Recovery
  const sleepH = recovery.sleepHours ? `${recovery.sleepHours}h sleep` : "normal sleep";
  const sore = recovery.muscleSoreness ? `soreness ${recovery.muscleSoreness}/10` : "no soreness";
  const energy = recovery.energyLevel ? `energy ${recovery.energyLevel}/10` : "moderate energy";
  const recStatus = recovery.status || "Ready";

  // Nutrition
  const meals = Array.isArray(nutrition.meals) ? nutrition.meals : [];
  const totalCal = meals.reduce((sum: number, m: any) => sum + (Number(m.calories) || 0), 0);
  const totalProt = meals.reduce((sum: number, m: any) => sum + (Number(m.proteinG) || 0), 0);
  const targetCal = nutrition.targetCalories || 2000;
  const targetProt = nutrition.targetProteinG || 150;
  const remCal = Math.max(0, targetCal - totalCal);
  const remProt = Math.max(0, targetProt - totalProt);

  // Workout
  const workoutTitle = workout.title || "Daily Routine";
  const workoutStatus = workout.status || "scheduled";
  const focus = workout.focusArea || "General Fitness";
  const exNames = Array.isArray(workout.exercises) && workout.exercises.length > 0
    ? ` [Exercises: ${workout.exercises.map((e: any) => `${e.name} (${(e.sets || []).length}s)`).join(", ")}]`
    : "";

  // Constraints
  const injuries =
    Array.isArray(profile.activeInjuries) && profile.activeInjuries.length > 0
      ? profile.activeInjuries.join(", ")
      : "none";

  // Client Envelope Context
  let envContext = "";
  if (envelope) {
    const parts: string[] = [];
    if (envelope.activeScreen) parts.push(`Screen: ${envelope.activeScreen}`);
    if (envelope.focusedExerciseName) parts.push(`Focused Exercise: "${envelope.focusedExerciseName}"`);
    else if (envelope.focusedExerciseId) parts.push(`Focused Exercise ID: ${envelope.focusedExerciseId}`);
    if (envelope.currentSetIndex !== undefined) parts.push(`Current Set: #${envelope.currentSetIndex + 1}`);
    if (envelope.sessionElapsedSec !== undefined) parts.push(`Elapsed Time: ${Math.round(envelope.sessionElapsedSec / 60)}min`);
    if (parts.length > 0) {
      envContext = ` Active UI Context: [${parts.join("; ")}].`;
    }
  }

  return `Client ${name} (${gender}, ${age}y, ${weight}kg -> ${targetWeight}kg, goal: ${goal}, coach: ${soul}). Gear: ${equipment}. Joint safeguards: ${injuries}.${envContext} Recovery: ${sleepH}, ${sore}, ${energy} (${recStatus}). Fuel today: ${totalCal}/${targetCal} kcal (${remCal} left), ${totalProt}/${targetProt}g protein (${remProt}g left). Workout: ${workoutTitle} (${focus}, status: ${workoutStatus})${exNames}.`;
}
