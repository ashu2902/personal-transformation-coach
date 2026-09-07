import * as admin from "firebase-admin";
import { z } from "zod";
import { CommandDefinition, ExecutionContext, ResolutionContext } from "./types";

// Helper to create pending structural action document
async function createPendingAction(
  ctx: ExecutionContext,
  actionType: string,
  args: any,
  description: string
): Promise<{ id: string; actionType: string; description: string; status: string; arguments: any }> {
  const actionId = `action_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
  const pendingDoc = {
    id: actionId,
    actionType,
    arguments: args,
    description,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await ctx.db
    .collection("users")
    .doc(ctx.uid)
    .collection("pending_actions")
    .doc(actionId)
    .set(pendingDoc);

  return {
    id: actionId,
    actionType,
    description,
    status: "pending",
    arguments: args,
  };
}

// ─── 1. profile.updateEquipment (High Risk) ──────────────────────────

const updateEquipmentSchema = z.object({
  items: z
    .array(
      z.object({
        name: z.string(),
        category: z.string().optional().default("free_weight"),
        weightKg: z.number().optional(),
      })
    )
    .min(1)
    .describe("List of equipment available, e.g. [{ name: '20kg kettlebell', weightKg: 20 }]"),
});

export const profileUpdateEquipmentCommand: CommandDefinition<
  z.infer<typeof updateEquipmentSchema>,
  { items: any[]; currentEquipment: string; summary: string }
> = {
  name: "profile.updateEquipment",
  category: "profile",
  summary: "Update user's physical training equipment configuration (Requires Confirmation)",
  risk: "high",
  inputSchema: updateEquipmentSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    const profile = ctx.userState.profile || {};
    const existingList = Array.isArray(profile.equipmentList)
      ? profile.equipmentList.map((e: any) => (typeof e === "string" ? e : e.name || "")).filter(Boolean)
      : ["Bodyweight"];

    const newNames = input.items.map((i) => (i.weightKg ? `${i.name} (${i.weightKg}kg)` : i.name));
    return {
      items: input.items,
      currentEquipment: existingList.join(", ") || "Bodyweight",
      summary: `Update equipment gear setup to: ${newNames.join(", ")}`,
    };
  },

  preview: async (resolved) => {
    const newNames = resolved.items.map((i) => (i.weightKg ? `${i.name} (${i.weightKg}kg)` : i.name)).join(", ");
    return {
      commandName: "profile.updateEquipment",
      category: "profile",
      risk: "high",
      summary: resolved.summary,
      changes: [
        {
          target: "Training Equipment",
          description: "Structural update to available equipment list",
          before: resolved.currentEquipment,
          after: newNames,
        },
      ],
      warnings: ["Requires confirmation before updating workout generator calibration"],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const pending = await createPendingAction(
      ctx,
      "updateEquipment",
      { items: resolved.items },
      resolved.summary
    );
    return { success: true, pendingAction: pending };
  },
};

// ─── 2. profile.updateInjuries (High Risk) ───────────────────────────

const updateInjuriesSchema = z.object({
  injuries: z
    .array(z.string())
    .describe("List of active injuries or mobility restrictions, e.g. ['knee pain', 'left shoulder impingement']"),
});

export const profileUpdateInjuriesCommand: CommandDefinition<
  z.infer<typeof updateInjuriesSchema>,
  { injuries: string[]; currentInjuries: string[]; summary: string }
> = {
  name: "profile.updateInjuries",
  category: "profile",
  summary: "Update joint safeguards and mobility restrictions (Requires Confirmation)",
  risk: "high",
  inputSchema: updateInjuriesSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    const current = Array.isArray(ctx.userState.profile?.activeInjuries)
      ? ctx.userState.profile.activeInjuries
      : [];
    return {
      injuries: input.injuries,
      currentInjuries: current,
      summary: `Update joint limitations: ${input.injuries.join(", ") || "None"}`,
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "profile.updateInjuries",
      category: "profile",
      risk: "high",
      summary: resolved.summary,
      changes: [
        {
          target: "Joint Safeguards & Injuries",
          description: "Safety bounds for exercise selection",
          before: resolved.currentInjuries.join(", ") || "None",
          after: resolved.injuries.join(", ") || "None",
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const pending = await createPendingAction(
      ctx,
      "updateInjuries",
      { injuries: resolved.injuries },
      resolved.summary
    );
    return { success: true, pendingAction: pending };
  },
};

// ─── 3. profile.updateGoal (High Risk) ───────────────────────────────

const updateGoalSchema = z.object({
  goal: z.enum(["fat_loss", "muscle_gain", "recomp"]),
  targetPhysique: z.string().optional(),
});

export const profileUpdateGoalCommand: CommandDefinition<
  z.infer<typeof updateGoalSchema>,
  { goal: string; targetPhysique?: string; currentGoal: string; summary: string }
> = {
  name: "profile.updateGoal",
  category: "profile",
  summary: "Recalibrate primary fitness goal (fat_loss, muscle_gain, recomp)",
  risk: "high",
  inputSchema: updateGoalSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    const current = ctx.userState.profile?.goal || "recomp";
    return {
      goal: input.goal,
      targetPhysique: input.targetPhysique,
      currentGoal: current,
      summary: `Recalibrate primary transformation goal to "${input.goal}"`,
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "profile.updateGoal",
      category: "profile",
      risk: "high",
      summary: resolved.summary,
      changes: [
        {
          target: "Primary Fitness Goal",
          description: "Alters macro targets and progressive overload direction",
          before: resolved.currentGoal,
          after: resolved.goal,
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const pending = await createPendingAction(
      ctx,
      "updateGoal",
      { goal: resolved.goal, targetPhysique: resolved.targetPhysique },
      resolved.summary
    );
    return { success: true, pendingAction: pending };
  },
};

// ─── 4. profile.updateSchedule (High Risk) ───────────────────────────

const updateScheduleSchema = z.object({
  daysPerWeek: z.number().min(2).max(7).describe("Training days per week (2-7)"),
});

export const profileUpdateScheduleCommand: CommandDefinition<
  z.infer<typeof updateScheduleSchema>,
  { daysPerWeek: number; currentDays: number; summary: string }
> = {
  name: "profile.updateSchedule",
  category: "profile",
  summary: "Update weekly workout training frequency (Requires Confirmation)",
  risk: "high",
  inputSchema: updateScheduleSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    const current = ctx.userState.profile?.daysPerWeek || 3;
    return {
      daysPerWeek: input.daysPerWeek,
      currentDays: current,
      summary: `Update training schedule to ${input.daysPerWeek} days per week`,
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "profile.updateSchedule",
      category: "profile",
      risk: "high",
      summary: resolved.summary,
      changes: [
        {
          target: "Weekly Training Frequency",
          description: "Adjusts 7-day adaptive workout split",
          before: `${resolved.currentDays} days/week`,
          after: `${resolved.daysPerWeek} days/week`,
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const pending = await createPendingAction(
      ctx,
      "updateSchedule",
      { daysPerWeek: resolved.daysPerWeek },
      resolved.summary
    );
    return { success: true, pendingAction: pending };
  },
};

// ─── 5. profile.logWeight (Low Risk) ─────────────────────────────────

const logWeightSchema = z.object({
  weightKg: z.number().positive().describe("Scale body weight in kilograms"),
});

export const profileLogWeightCommand: CommandDefinition<
  z.infer<typeof logWeightSchema>,
  { weightKg: number; currentWeight?: number }
> = {
  name: "profile.logWeight",
  category: "profile",
  summary: "Log daily scale body weight",
  risk: "low",
  inputSchema: logWeightSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    return {
      weightKg: input.weightKg,
      currentWeight: ctx.userState.profile?.weightKg,
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "profile.logWeight",
      category: "profile",
      risk: "low",
      summary: `Logged scale weight: ${resolved.weightKg}kg`,
      changes: [
        {
          target: "Body Weight",
          description: "Updated profile weight and logged progress point",
          before: resolved.currentWeight ? `${resolved.currentWeight}kg` : undefined,
          after: `${resolved.weightKg}kg`,
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const userRef = ctx.db.collection("users").doc(ctx.uid);
    await userRef.update({
      weightKg: resolved.weightKg,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await userRef.collection("progress").doc(ctx.todayStr).set(
      {
        date: ctx.todayStr,
        weightKg: resolved.weightKg,
        notes: "Logged via Coach Conversation",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { success: true };
  },
};
