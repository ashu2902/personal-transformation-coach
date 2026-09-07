import * as admin from "firebase-admin";
import { z } from "zod";
import { CommandDefinition, CommandPreview, ExecutionContext, ResolutionContext } from "./types";
import { findExerciseInLibrary, findSubstitutions } from "./exerciseLibrary";

// ─── 1. workout.substituteExercise ───────────────────────────────────

const substituteInputSchema = z.object({
  targetExercise: z
    .string()
    .optional()
    .describe("Name, ordinal ('second exercise'), or pronoun ('this exercise') of the exercise to substitute"),
  reason: z
    .string()
    .optional()
    .describe("Reason for substitution, e.g. 'knee pain', 'equipment busy', 'too hard'"),
  replacementExercise: z
    .string()
    .optional()
    .describe("Specific exercise name requested as replacement, if any"),
});

interface ResolvedSubstitution {
  targetIndex: number;
  oldExercise: any;
  newExercise: any;
  workoutDate: string;
  reason?: string;
}

export const workoutSubstituteExerciseCommand: CommandDefinition<
  z.infer<typeof substituteInputSchema>,
  ResolvedSubstitution
> = {
  name: "workout.substituteExercise",
  category: "workout",
  summary: "Substitute an exercise with a biomechanically compatible alternative matching equipment",
  risk: "low",
  inputSchema: substituteInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedSubstitution> => {
    const workoutDate = ctx.resolveWorkoutTarget();
    let res = ctx.resolveExerciseTarget(input.targetExercise);

    // If workout has no exercises in state, create a placeholder so substitution can proceed
    const workout = ctx.userState.workout || {};
    let exercises: any[] = Array.isArray(workout.exercises) ? [...workout.exercises] : [];

    if (!res && exercises.length > 0) {
      res = { exercise: exercises[0], index: 0 };
    }

    if (!res) {
      // Fallback exercise if none existed in today's workout
      const defaultName = input.targetExercise || ctx.envelope?.focusedExerciseName || "Bulgarian Split Squat";
      const fallbackOld = {
        id: `ex_${Date.now()}`,
        name: defaultName,
        targetMuscle: "Quadriceps & Glutes",
        equipmentRequired: "dumbbells",
        sets: [
          { setNumber: 1, targetReps: 10, targetWeightKg: 0, completed: false },
          { setNumber: 2, targetReps: 10, targetWeightKg: 0, completed: false },
          { setNumber: 3, targetReps: 10, targetWeightKg: 0, completed: false },
        ],
      };
      exercises = [fallbackOld];
      res = { exercise: fallbackOld, index: 0 };
    }

    const oldEx = res.exercise;
    const targetIdx = res.index;

    // Available user equipment
    const profileEquipment = Array.isArray(ctx.userState.profile?.equipmentList)
      ? ctx.userState.profile.equipmentList.map((e: any) => (typeof e === "string" ? e : e.name || ""))
      : ["Bodyweight", "Dumbbells"];

    let replacementName = input.replacementExercise;
    let replacementDef: any = null;

    if (replacementName) {
      replacementDef = findExerciseInLibrary(replacementName);
    }

    if (!replacementDef) {
      const candidates = findSubstitutions(oldEx, profileEquipment, input.reason);
      if (candidates.length > 0) {
        replacementDef = candidates[0];
        replacementName = replacementDef.name;
      } else {
        // Fallback knee-friendly or dumbbell alternative
        if ((input.reason || "").toLowerCase().includes("knee")) {
          replacementDef = findExerciseInLibrary("Dumbbell Box Step-Up") || findExerciseInLibrary("Dumbbell Goblet Squat");
        } else {
          replacementDef = findExerciseInLibrary("Dumbbell Goblet Squat");
        }
        replacementName = replacementDef?.name || "Dumbbell Box Step-Up";
      }
    }

    // Preserve set and rep targets
    const oldSets = Array.isArray(oldEx.sets) && oldEx.sets.length > 0
      ? oldEx.sets
      : [
          { setNumber: 1, targetReps: 10, targetWeightKg: 0, completed: false },
          { setNumber: 2, targetReps: 10, targetWeightKg: 0, completed: false },
          { setNumber: 3, targetReps: 10, targetWeightKg: 0, completed: false },
        ];

    const newSets = oldSets.map((s: any, idx: number) => ({
      setNumber: idx + 1,
      targetReps: s.targetReps || 10,
      targetWeightKg: s.targetWeightKg || 0,
      completed: false,
    }));

    const newEx = {
      id: replacementDef?.id || `ex_sub_${Date.now()}`,
      name: replacementName || "Alternative Exercise",
      targetMuscle: replacementDef?.targetMuscle || oldEx.targetMuscle || "Legs",
      equipmentRequired: replacementDef?.equipment || "dumbbells",
      sets: newSets,
      notes: input.reason ? `Substituted for ${oldEx.name} due to: ${input.reason}` : `Substituted for ${oldEx.name}`,
    };

    return {
      targetIndex: targetIdx,
      oldExercise: oldEx,
      newExercise: newEx,
      workoutDate,
      reason: input.reason,
    };
  },

  preview: async (resolved: ResolvedSubstitution): Promise<CommandPreview> => {
    const oldSetsCount = resolved.oldExercise.sets?.length || 3;
    const oldReps = resolved.oldExercise.sets?.[0]?.targetReps || 10;
    const newSetsCount = resolved.newExercise.sets?.length || 3;
    const newReps = resolved.newExercise.sets?.[0]?.targetReps || 10;

    return {
      commandName: "workout.substituteExercise",
      category: "workout",
      risk: "low",
      summary: `Substituted ${resolved.oldExercise.name} with ${resolved.newExercise.name}`,
      changes: [
        {
          target: resolved.oldExercise.name,
          description: `Exercise replaced with ${resolved.newExercise.name}`,
          before: `${resolved.oldExercise.name} (${oldSetsCount} × ${oldReps})`,
          after: `${resolved.newExercise.name} (${newSetsCount} × ${newReps})`,
        },
      ],
      warnings: resolved.reason ? [`Adapted for: ${resolved.reason}`] : undefined,
    };
  },

  execute: async (resolved: ResolvedSubstitution, ctx: ExecutionContext) => {
    const userRef = ctx.db.collection("users").doc(ctx.uid);
    const workoutRef = userRef.collection("workouts").doc(resolved.workoutDate);
    const workoutDoc = await workoutRef.get();

    let exercises: any[] = [];
    let workoutData: any = {};
    if (workoutDoc.exists) {
      workoutData = workoutDoc.data() || {};
      exercises = Array.isArray(workoutData.exercises) ? [...workoutData.exercises] : [];
    }

    if (resolved.targetIndex >= 0 && resolved.targetIndex < exercises.length) {
      exercises[resolved.targetIndex] = resolved.newExercise;
    } else {
      exercises.push(resolved.newExercise);
    }

    const updatePayload = {
      ...workoutData,
      status: "adapted",
      adaptationNote: resolved.reason
        ? `Substituted ${resolved.oldExercise.name} with ${resolved.newExercise.name} (${resolved.reason})`
        : `Substituted ${resolved.oldExercise.name} with ${resolved.newExercise.name}`,
      exercises,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await workoutRef.set(updatePayload, { merge: true });
    return { success: true, result: updatePayload };
  },
};

// ─── 2. workout.adjustVolume ─────────────────────────────────────────

const adjustVolumeInputSchema = z.object({
  targetExercise: z
    .string()
    .optional()
    .describe("Name, ordinal, or pronoun ('it', 'this exercise') to adjust"),
  targetSetIndex: z
    .union([z.number(), z.string()])
    .optional()
    .describe("Specific set number (1-indexed or 'last set') or all sets if omitted"),
  deltaWeightKg: z
    .number()
    .optional()
    .describe("Weight difference in kg to add or subtract (e.g. 5 for +5kg, -5 for -5kg)"),
  deltaSets: z
    .number()
    .optional()
    .describe("Number of sets to add or subtract (e.g. -1 for 1 fewer set)"),
  deltaReps: z
    .number()
    .optional()
    .describe("Number of reps to add or subtract"),
  scaleFactor: z
    .number()
    .optional()
    .describe("Scaling factor for sets or weight (e.g. 0.8 for 20% reduction)"),
  reason: z.string().optional(),
});

interface ResolvedVolumeAdjustment {
  targetIndex: number;
  oldExercise: any;
  updatedExercise: any;
  changesSummary: string;
  workoutDate: string;
}

export const workoutAdjustVolumeCommand: CommandDefinition<
  z.infer<typeof adjustVolumeInputSchema>,
  ResolvedVolumeAdjustment
> = {
  name: "workout.adjustVolume",
  category: "workout",
  summary: "Deterministically adjust exercise weights, sets, or reps without arbitrary guessing",
  risk: "low",
  inputSchema: adjustVolumeInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedVolumeAdjustment> => {
    const workoutDate = ctx.resolveWorkoutTarget();
    let res = ctx.resolveExerciseTarget(input.targetExercise);

    const workout = ctx.userState.workout || {};
    let exercises: any[] = Array.isArray(workout.exercises) ? [...workout.exercises] : [];

    if (!res && exercises.length > 0) {
      res = { exercise: exercises[0], index: 0 };
    }

    if (!res) {
      const defaultName = input.targetExercise || ctx.envelope?.focusedExerciseName || "Current Exercise";
      const fallback = {
        id: `ex_${Date.now()}`,
        name: defaultName,
        targetMuscle: "Full Body",
        equipmentRequired: "free_weight",
        sets: [
          { setNumber: 1, targetReps: 10, targetWeightKg: 20, completed: false },
          { setNumber: 2, targetReps: 10, targetWeightKg: 20, completed: false },
          { setNumber: 3, targetReps: 10, targetWeightKg: 20, completed: false },
        ],
      };
      exercises = [fallback];
      res = { exercise: fallback, index: 0 };
    }

    const oldEx = res.exercise;
    const sets = Array.isArray(oldEx.sets) ? oldEx.sets.map((s: any) => ({ ...s })) : [];
    let setIdx: number | null = null;
    if (input.targetSetIndex !== undefined) {
      setIdx = ctx.resolveSetTarget(input.targetSetIndex, res.index);
    }

    const changeDescriptions: string[] = [];

    // 1. Weight Adjustment
    if (input.deltaWeightKg !== undefined && input.deltaWeightKg !== 0) {
      const sign = input.deltaWeightKg > 0 ? "+" : "";
      if (setIdx !== null && setIdx >= 0 && setIdx < sets.length) {
        const oldW = sets[setIdx].targetWeightKg || 0;
        const newW = Math.max(0, oldW + input.deltaWeightKg);
        sets[setIdx].targetWeightKg = newW;
        changeDescriptions.push(`Set #${setIdx + 1} weight: ${oldW}kg -> ${newW}kg (${sign}${input.deltaWeightKg}kg)`);
      } else {
        const oldW = sets[0]?.targetWeightKg || 0;
        const newW = Math.max(0, oldW + input.deltaWeightKg);
        for (const s of sets) {
          s.targetWeightKg = Math.max(0, (s.targetWeightKg || 0) + input.deltaWeightKg);
        }
        changeDescriptions.push(`Weight: ${oldW}kg -> ${newW}kg (${sign}${input.deltaWeightKg}kg across sets)`);
      }
    }

    // 2. Reps Adjustment
    if (input.deltaReps !== undefined && input.deltaReps !== 0) {
      const sign = input.deltaReps > 0 ? "+" : "";
      if (setIdx !== null && setIdx >= 0 && setIdx < sets.length) {
        const oldR = sets[setIdx].targetReps || 10;
        const newR = Math.max(1, oldR + input.deltaReps);
        sets[setIdx].targetReps = newR;
        changeDescriptions.push(`Set #${setIdx + 1} reps: ${oldR} -> ${newR} (${sign}${input.deltaReps})`);
      } else {
        const oldR = sets[0]?.targetReps || 10;
        const newR = Math.max(1, oldR + input.deltaReps);
        for (const s of sets) {
          s.targetReps = Math.max(1, (s.targetReps || 10) + input.deltaReps);
        }
        changeDescriptions.push(`Reps: ${oldR} -> ${newR} (${sign}${input.deltaReps})`);
      }
    }

    // 3. Set Count Adjustment
    if (input.deltaSets !== undefined && input.deltaSets !== 0) {
      if (input.deltaSets < 0) {
        const removeCount = Math.abs(input.deltaSets);
        const newLength = Math.max(1, sets.length - removeCount);
        sets.length = newLength;
        changeDescriptions.push(`Reduced volume from ${oldEx.sets.length} to ${newLength} sets`);
      } else if (input.deltaSets > 0) {
        const lastSet = sets[sets.length - 1] || { targetReps: 10, targetWeightKg: 0 };
        for (let i = 0; i < input.deltaSets; i++) {
          sets.push({
            setNumber: sets.length + 1,
            targetReps: lastSet.targetReps || 10,
            targetWeightKg: lastSet.targetWeightKg || 0,
            completed: false,
          });
        }
        changeDescriptions.push(`Added ${input.deltaSets} set(s) (Total: ${sets.length} sets)`);
      }
    }

    // 4. Scale Factor (e.g. 0.8 for deload)
    if (input.scaleFactor !== undefined && input.scaleFactor > 0 && input.scaleFactor !== 1) {
      const pct = Math.round((1 - input.scaleFactor) * 100);
      if (input.scaleFactor < 1) {
        for (const s of sets) {
          s.targetWeightKg = Math.round((s.targetWeightKg || 0) * input.scaleFactor * 2) / 2; // round to 0.5kg
        }
        changeDescriptions.push(`Applied ${pct}% deload reduction to target load`);
      }
    }

    const updatedEx = {
      ...oldEx,
      sets,
    };

    return {
      targetIndex: res.index,
      oldExercise: oldEx,
      updatedExercise: updatedEx,
      changesSummary: changeDescriptions.join("; ") || "Adjusted workout parameters",
      workoutDate,
    };
  },

  preview: async (resolved: ResolvedVolumeAdjustment): Promise<CommandPreview> => {
    const oldSummary = (resolved.oldExercise.sets || [])
      .map((s: any) => `${s.targetReps}r @ ${s.targetWeightKg}kg`)
      .join(", ");
    const newSummary = (resolved.updatedExercise.sets || [])
      .map((s: any) => `${s.targetReps}r @ ${s.targetWeightKg}kg`)
      .join(", ");

    return {
      commandName: "workout.adjustVolume",
      category: "workout",
      risk: "low",
      summary: `${resolved.updatedExercise.name}: ${resolved.changesSummary}`,
      changes: [
        {
          target: resolved.updatedExercise.name,
          description: resolved.changesSummary,
          before: oldSummary || `${resolved.oldExercise.sets?.length || 3} sets`,
          after: newSummary || `${resolved.updatedExercise.sets?.length || 3} sets`,
        },
      ],
    };
  },

  execute: async (resolved: ResolvedVolumeAdjustment, ctx: ExecutionContext) => {
    const userRef = ctx.db.collection("users").doc(ctx.uid);
    const workoutRef = userRef.collection("workouts").doc(resolved.workoutDate);
    const workoutDoc = await workoutRef.get();

    let exercises: any[] = [];
    let workoutData: any = {};
    if (workoutDoc.exists) {
      workoutData = workoutDoc.data() || {};
      exercises = Array.isArray(workoutData.exercises) ? [...workoutData.exercises] : [];
    }

    if (resolved.targetIndex >= 0 && resolved.targetIndex < exercises.length) {
      exercises[resolved.targetIndex] = resolved.updatedExercise;
    } else {
      exercises.push(resolved.updatedExercise);
    }

    const updatePayload = {
      ...workoutData,
      status: "adapted",
      adaptationNote: resolved.changesSummary,
      exercises,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await workoutRef.set(updatePayload, { merge: true });
    return { success: true, result: updatePayload };
  },
};

// ─── 3. workout.adapt ────────────────────────────────────────────────

const adaptInputSchema = z.object({
  reason: z
    .string()
    .describe("Reason for adaptation, e.g. 'exhausted', 'only 30 minutes', 'low energy'"),
  timeLimitMin: z
    .number()
    .optional()
    .describe("User's available time in minutes"),
  intensityReduction: z
    .number()
    .optional()
    .describe("Percentage reduction (e.g. 20 for 20% drop)"),
});

interface ResolvedWorkoutAdaptation {
  workoutDate: string;
  originalTitle: string;
  adaptedTitle: string;
  durationBefore: number;
  durationAfter: number;
  exercisesBefore: any[];
  exercisesAfter: any[];
  reason: string;
  summary: string;
}

export const workoutAdaptCommand: CommandDefinition<
  z.infer<typeof adaptInputSchema>,
  ResolvedWorkoutAdaptation
> = {
  name: "workout.adapt",
  category: "workout",
  summary: "Adapt entire today's workout session for fatigue, time limits, or recovery needs",
  risk: "low",
  inputSchema: adaptInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedWorkoutAdaptation> => {
    const workoutDate = ctx.resolveWorkoutTarget();
    const workout = ctx.userState.workout || {};
    const exercises: any[] = Array.isArray(workout.exercises) && workout.exercises.length > 0
      ? workout.exercises.map((e: any) => ({
          ...e,
          sets: Array.isArray(e.sets) ? e.sets.map((s: any) => ({ ...s })) : [],
        }))
      : [
          {
            id: "ex_1",
            name: "Compound Movement",
            targetMuscle: "Full Body",
            equipmentRequired: "free_weight",
            sets: [
              { setNumber: 1, targetReps: 10, targetWeightKg: 20, completed: false },
              { setNumber: 2, targetReps: 10, targetWeightKg: 20, completed: false },
              { setNumber: 3, targetReps: 10, targetWeightKg: 20, completed: false },
            ],
          },
        ];

    const originalTitle = workout.title || "Daily Routine";
    const durationBefore = workout.estimatedDurationMin || 45;
    let durationAfter = durationBefore;
    let adaptedExercises = [...exercises];
    let summaryText = "";

    const lowerReason = input.reason.toLowerCase();
    const isFatigued =
      lowerReason.includes("exhausted") ||
      lowerReason.includes("tired") ||
      lowerReason.includes("fatigue") ||
      lowerReason.includes("take it easy") ||
      lowerReason.includes("sore");

    // Case 1: Time restriction
    if (input.timeLimitMin && input.timeLimitMin > 0) {
      durationAfter = Math.min(input.timeLimitMin, durationBefore);
      // If duration is cut significantly, keep only the first 2-3 primary compound exercises
      if (input.timeLimitMin <= 30 && adaptedExercises.length > 3) {
        adaptedExercises = adaptedExercises.slice(0, 3);
      }
      // Also cap sets to 2-3 per exercise
      for (const ex of adaptedExercises) {
        if (ex.sets.length > 3) {
          ex.sets = ex.sets.slice(0, 3);
        }
      }
      summaryText = `Optimized session to fit ${durationAfter} minutes (kept core movements)`;
    }
    // Case 2: Fatigue / Deload / Low energy
    else if (isFatigued || (input.intensityReduction && input.intensityReduction > 0)) {
      const reduction = input.intensityReduction || 20; // 20% default deload
      durationAfter = Math.max(25, Math.round(durationBefore * 0.8));
      // Reduce volume: 1 fewer set per exercise or drop weights by 20%
      for (const ex of adaptedExercises) {
        if (ex.sets.length > 2) {
          ex.sets.pop(); // drop 1 set
        }
        for (const s of ex.sets) {
          if (s.targetWeightKg && s.targetWeightKg > 0) {
            s.targetWeightKg = Math.round(s.targetWeightKg * (1 - reduction / 100) * 2) / 2;
          }
        }
      }
      summaryText = `Applied ${reduction}% volume deload and trimmed fatigue load`;
    } else {
      summaryText = `Adapted session for: "${input.reason}"`;
    }

    const adaptedTitle = `Adapted ${originalTitle}`;

    return {
      workoutDate,
      originalTitle,
      adaptedTitle,
      durationBefore,
      durationAfter,
      exercisesBefore: exercises,
      exercisesAfter: adaptedExercises,
      reason: input.reason,
      summary: summaryText,
    };
  },

  preview: async (resolved: ResolvedWorkoutAdaptation): Promise<CommandPreview> => {
    return {
      commandName: "workout.adapt",
      category: "workout",
      risk: "low",
      summary: resolved.summary,
      changes: [
        {
          target: resolved.originalTitle,
          description: resolved.summary,
          before: `${resolved.originalTitle} (${resolved.durationBefore} min, ${resolved.exercisesBefore.length} exercises)`,
          after: `${resolved.adaptedTitle} (${resolved.durationAfter} min, ${resolved.exercisesAfter.length} exercises)`,
        },
      ],
      warnings: [`Reason: ${resolved.reason}`],
    };
  },

  execute: async (resolved: ResolvedWorkoutAdaptation, ctx: ExecutionContext) => {
    const userRef = ctx.db.collection("users").doc(ctx.uid);
    const workoutRef = userRef.collection("workouts").doc(resolved.workoutDate);

    const updatePayload = {
      title: resolved.adaptedTitle,
      status: "adapted",
      adaptationNote: resolved.summary,
      estimatedDurationMin: resolved.durationAfter,
      exercises: resolved.exercisesAfter,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await workoutRef.set(updatePayload, { merge: true });
    return { success: true, result: updatePayload };
  },
};

// ─── 4. workout.updateStatus ─────────────────────────────────────────

const updateStatusInputSchema = z.object({
  status: z.enum(["completed", "skipped"]),
});

export const workoutUpdateStatusCommand: CommandDefinition<
  z.infer<typeof updateStatusInputSchema>,
  { status: "completed" | "skipped"; workoutDate: string }
> = {
  name: "workout.updateStatus",
  category: "workout",
  summary: "Mark today's workout as completed or skipped",
  risk: "low",
  inputSchema: updateStatusInputSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    return {
      status: input.status,
      workoutDate: ctx.resolveWorkoutTarget(),
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "workout.updateStatus",
      category: "workout",
      risk: "low",
      summary: `Workout marked as ${resolved.status}`,
      changes: [
        {
          target: "Workout Status",
          description: `Updated status to ${resolved.status}`,
          after: resolved.status,
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const workoutRef = ctx.db.collection("users").doc(ctx.uid).collection("workouts").doc(resolved.workoutDate);
    await workoutRef.set(
      {
        status: resolved.status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    return { success: true };
  },
};
