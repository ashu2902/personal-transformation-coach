import * as admin from "firebase-admin";
import { z } from "zod";
import { CommandChange, CommandDefinition, CommandPreview, ExecutionContext, ResolutionContext } from "./types";

const recoveryLogInputSchema = z.object({
  sleepHours: z.number().optional().describe("Hours of sleep, e.g. 6 or 7.5"),
  sleepQuality: z.number().optional().describe("Sleep quality rating 1-10"),
  muscleSoreness: z.number().optional().describe("Muscle soreness rating 1-10"),
  energyLevel: z.number().optional().describe("Energy rating 1-10"),
  stressLevel: z.number().optional().describe("Stress rating 1-10"),
});

interface ResolvedRecoveryLog {
  sleepHours: number;
  sleepQuality: number;
  muscleSoreness: number;
  energyLevel: number;
  stressLevel: number;
  recoveryScore: number;
  status: string;
  todayStr: string;
  beforeRecovery?: any;
}

export const recoveryLogCommand: CommandDefinition<
  z.infer<typeof recoveryLogInputSchema>,
  ResolvedRecoveryLog
> = {
  name: "recovery.log",
  category: "recovery",
  summary: "Log sleep, muscle soreness, energy, and calculate adaptive recovery score",
  risk: "low",
  inputSchema: recoveryLogInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedRecoveryLog> => {
    const existing = ctx.userState.recovery || {};

    const sleepH = input.sleepHours ?? existing.sleepHours ?? 7.5;
    const sleepQ = input.sleepQuality ?? existing.sleepQuality ?? 8;
    const sore = input.muscleSoreness ?? existing.muscleSoreness ?? 2;
    const energy = input.energyLevel ?? existing.energyLevel ?? 7;
    const stress = input.stressLevel ?? existing.stressLevel ?? 3;

    // Deterministic recovery algorithm
    const sleepScore = Math.min(Math.max(sleepH / 8.0, 0), 1.2) * 10 * (sleepQ / 10.0);
    const score = Math.round(
      Math.min(
        Math.max(sleepScore * 3.5 + energy * 3.5 + (10 - sore) * 2.0 + (10 - stress) * 1.0, 20),
        100
      )
    );
    const status = score >= 75 ? "Optimal" : score >= 50 ? "Moderate" : "Needs Rest";

    return {
      sleepHours: sleepH,
      sleepQuality: sleepQ,
      muscleSoreness: sore,
      energyLevel: energy,
      stressLevel: stress,
      recoveryScore: score,
      status,
      todayStr: ctx.todayStr,
      beforeRecovery: existing,
    };
  },

  preview: async (resolved: ResolvedRecoveryLog): Promise<CommandPreview> => {
    const changes: CommandChange[] = [
      {
        target: "Sleep",
        description: `Logged ${resolved.sleepHours} hours`,
        before: resolved.beforeRecovery?.sleepHours ? `${resolved.beforeRecovery.sleepHours}h` : undefined,
        after: `${resolved.sleepHours}h`,
      },
      {
        target: "Recovery Score",
        description: `Calculated recovery readiness: ${resolved.recoveryScore}% (${resolved.status})`,
        before: resolved.beforeRecovery?.recoveryScore ? `${resolved.beforeRecovery.recoveryScore}%` : undefined,
        after: `${resolved.recoveryScore}% (${resolved.status})`,
      },
    ];

    if (resolved.muscleSoreness !== undefined) {
      changes.push({
        target: "Muscle Soreness",
        description: `Soreness: ${resolved.muscleSoreness}/10`,
        after: `${resolved.muscleSoreness}/10`,
      });
    }

    return {
      commandName: "recovery.log",
      category: "recovery",
      risk: "low",
      summary: `Logged recovery: ${resolved.sleepHours}h sleep -> Recovery Score ${resolved.recoveryScore}% (${resolved.status})`,
      changes,
    };
  },

  execute: async (resolved: ResolvedRecoveryLog, ctx: ExecutionContext) => {
    const recRef = ctx.db.collection("users").doc(ctx.uid).collection("recovery").doc(resolved.todayStr);
    const payload = {
      date: resolved.todayStr,
      sleepHours: resolved.sleepHours,
      sleepQuality: resolved.sleepQuality,
      muscleSoreness: resolved.muscleSoreness,
      energyLevel: resolved.energyLevel,
      stressLevel: resolved.stressLevel,
      recoveryScore: resolved.recoveryScore,
      status: resolved.status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await recRef.set(payload, { merge: true });
    return { success: true, result: payload };
  },
};
