import * as admin from "firebase-admin";
import { z } from "zod";
import { CommandDefinition, CommandPreview, ExecutionContext, ResolutionContext } from "./types";

// ─── 1. nutrition.logMeal ───────────────────────────────────────────

const logMealInputSchema = z.object({
  meals: z
    .array(
      z.object({
        name: z.string().describe("Meal or food item name"),
        calories: z.number().optional().describe("Estimated calories"),
        proteinG: z.number().optional().describe("Protein in grams"),
        carbsG: z.number().optional().describe("Carbohydrates in grams"),
        fatG: z.number().optional().describe("Fat in grams"),
      })
    )
    .optional()
    .default([])
    .describe("List of meals or foods to log"),
  waterMl: z.number().nullish().describe("Water intake in milliliters to add"),
  targetDate: z.string().nullish().describe("Date 'YYYY-MM-DD', defaults to today"),
});

interface ResolvedMealLog {
  meals: Array<{
    name: string;
    calories: number;
    proteinG: number;
    carbsG: number;
    fatG: number;
  }>;
  waterMl: number;
  targetDate: string;
}

export const nutritionLogMealCommand: CommandDefinition<
  z.infer<typeof logMealInputSchema>,
  ResolvedMealLog
> = {
  name: "nutrition.logMeal",
  category: "nutrition",
  summary: "Log meals, foods, and hydration with automated macro validation",
  risk: "low",
  inputSchema: logMealInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedMealLog> => {
    const targetDate = (input.targetDate && input.targetDate.length === 10)
      ? input.targetDate
      : ctx.todayStr;

    const verifiedMeals: ResolvedMealLog["meals"] = [];

    for (const m of input.meals) {
      const lowerName = m.name.toLowerCase().trim();
      // Skip pure water entries from solid food list if waterMl is logged
      if (lowerName === "water" || lowerName === "glass of water" || lowerName === "bottle of water" || lowerName === "hydration") {
        continue;
      }

      let cal = Number(m.calories) || 0;
      let prot = Number(m.proteinG) || 0;
      let carb = Number(m.carbsG) || 0;
      let fat = Number(m.fatG) || 0;

      // If user provided a meal with no/low macros, enrich with basic estimation if available
      if (cal === 0 && prot === 0) {
        if (lowerName.includes("water") || lowerName.includes("black coffee") || lowerName.includes("green tea") || lowerName.includes("diet soda") || lowerName.includes("diet coke")) {
          cal = 0;
          prot = 0;
          carb = 0;
          fat = 0;
        } else if (lowerName.includes("egg")) {
          const countMatch = lowerName.match(/(\d+)\s*egg/);
          const count = countMatch ? parseInt(countMatch[1], 10) : 1;
          cal = count * 75;
          prot = count * 6;
          carb = count * 1;
          fat = count * 5;
        } else {
          cal = 300;
          prot = 15;
          carb = 30;
          fat = 10;
        }
      }

      verifiedMeals.push({
        name: m.name.trim() || "Logged Meal",
        calories: Math.round(cal),
        proteinG: Math.round(prot),
        carbsG: Math.round(carb),
        fatG: Math.round(fat),
      });
    }

    return {
      meals: verifiedMeals,
      waterMl: Number(input.waterMl) || 0,
      targetDate,
    };
  },

  preview: async (resolved: ResolvedMealLog): Promise<CommandPreview> => {
    const totalCal = resolved.meals.reduce((sum, m) => sum + m.calories, 0);
    const totalProt = resolved.meals.reduce((sum, m) => sum + m.proteinG, 0);
    const names = resolved.meals.map((m) => m.name).join(", ");

    const changes = resolved.meals.map((m) => ({
      target: m.name,
      description: `Logged: ${m.calories} kcal, ${m.proteinG}g P, ${m.carbsG}g C, ${m.fatG}g F`,
      after: `${m.calories} kcal (${m.proteinG}g protein)`,
    }));

    if (resolved.waterMl > 0) {
      changes.push({
        target: "Hydration",
        description: `Added +${resolved.waterMl}ml water`,
        after: `+${resolved.waterMl}ml`,
      });
    }

    return {
      commandName: "nutrition.logMeal",
      category: "nutrition",
      risk: "low",
      summary: `Logged ${resolved.meals.length} meal(s): ${names} (+${totalCal} kcal, +${totalProt}g P)`,
      changes,
    };
  },

  execute: async (resolved: ResolvedMealLog, ctx: ExecutionContext) => {
    const userRef = ctx.db.collection("users").doc(ctx.uid);
    const nutRef = userRef.collection("nutrition").doc(resolved.targetDate);
    const nutDoc = await nutRef.get();

    if (!nutDoc.exists) {
      await nutRef.set({
        date: resolved.targetDate,
        targetCalories: ctx.userState?.nutrition?.targetCalories || 2000,
        targetProteinG: ctx.userState?.nutrition?.targetProteinG || 150,
        targetCarbsG: ctx.userState?.nutrition?.targetCarbsG || 200,
        targetFatG: ctx.userState?.nutrition?.targetFatG || 65,
        waterMl: resolved.waterMl,
        targetWaterMl: 3200,
        meals: resolved.meals,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      const updatePayload: any = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (resolved.meals.length > 0) {
        updatePayload.meals = admin.firestore.FieldValue.arrayUnion(...resolved.meals);
      }
      if (resolved.waterMl > 0) {
        updatePayload.waterMl = admin.firestore.FieldValue.increment(resolved.waterMl);
      }
      await nutRef.update(updatePayload);
    }

    return { success: true, result: resolved };
  },
};

// ─── 2. nutrition.updatePortion ─────────────────────────────────────

const updatePortionInputSchema = z.object({
  mealName: z.string().describe("Name of the meal to adjust portion for"),
  calories: z.number().describe("Corrected calories"),
  proteinG: z.number().describe("Corrected protein in grams"),
  carbsG: z.number().optional().default(0),
  fatG: z.number().optional().default(0),
  targetDate: z.string().optional(),
});

interface ResolvedPortionUpdate {
  mealName: string;
  beforeMeal?: any;
  afterMeal: {
    name: string;
    calories: number;
    proteinG: number;
    carbsG: number;
    fatG: number;
  };
  targetDate: string;
}

export const nutritionUpdatePortionCommand: CommandDefinition<
  z.infer<typeof updatePortionInputSchema>,
  ResolvedPortionUpdate
> = {
  name: "nutrition.updatePortion",
  category: "nutrition",
  summary: "Update portion or macro calculations for an existing logged meal",
  risk: "low",
  inputSchema: updatePortionInputSchema,

  resolve: async (input, ctx: ResolutionContext): Promise<ResolvedPortionUpdate> => {
    const targetDate = input.targetDate || ctx.todayStr;
    const existingMeals: any[] = Array.isArray(ctx.userState.nutrition?.meals)
      ? ctx.userState.nutrition.meals
      : [];

    const search = input.mealName.toLowerCase();
    const found = existingMeals.find(
      (m: any) => m.name && m.name.toLowerCase().includes(search)
    );

    return {
      mealName: input.mealName,
      beforeMeal: found,
      afterMeal: {
        name: found?.name || input.mealName,
        calories: Math.round(input.calories),
        proteinG: Math.round(input.proteinG),
        carbsG: Math.round(input.carbsG || 0),
        fatG: Math.round(input.fatG || 0),
      },
      targetDate,
    };
  },

  preview: async (resolved: ResolvedPortionUpdate): Promise<CommandPreview> => {
    const beforeStr = resolved.beforeMeal
      ? `${resolved.beforeMeal.calories} kcal (${resolved.beforeMeal.proteinG}g P)`
      : "Original Portion";
    const afterStr = `${resolved.afterMeal.calories} kcal (${resolved.afterMeal.proteinG}g P)`;

    return {
      commandName: "nutrition.updatePortion",
      category: "nutrition",
      risk: "low",
      summary: `Updated portion for ${resolved.afterMeal.name} to ${afterStr}`,
      changes: [
        {
          target: resolved.afterMeal.name,
          description: `Adjusted portion: ${beforeStr} -> ${afterStr}`,
          before: beforeStr,
          after: afterStr,
        },
      ],
    };
  },

  execute: async (resolved: ResolvedPortionUpdate, ctx: ExecutionContext) => {
    const nutRef = ctx.db.collection("users").doc(ctx.uid).collection("nutrition").doc(resolved.targetDate);
    const nutDoc = await nutRef.get();
    if (!nutDoc.exists) return { success: false, error: "Nutrition document not found" };

    const data = nutDoc.data() || {};
    const meals = Array.isArray(data.meals) ? [...data.meals] : [];
    const search = resolved.mealName.toLowerCase();
    let replaced = false;

    const updated = meals.map((m: any) => {
      if (!replaced && m.name && m.name.toLowerCase().includes(search)) {
        replaced = true;
        return resolved.afterMeal;
      }
      return m;
    });

    if (!replaced) updated.push(resolved.afterMeal);

    await nutRef.update({
      meals: updated,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, result: resolved.afterMeal };
  },
};

// ─── 3. nutrition.removeMeal ────────────────────────────────────────

const removeMealInputSchema = z.object({
  mealName: z.string().describe("Name of the meal to remove"),
  targetDate: z.string().optional(),
});

export const nutritionRemoveMealCommand: CommandDefinition<
  z.infer<typeof removeMealInputSchema>,
  { mealName: string; removedMeal?: any; targetDate: string }
> = {
  name: "nutrition.removeMeal",
  category: "nutrition",
  summary: "Remove an incorrectly logged meal from today's food log",
  risk: "low",
  inputSchema: removeMealInputSchema,

  resolve: async (input, ctx: ResolutionContext) => {
    const targetDate = input.targetDate || ctx.todayStr;
    const existingMeals: any[] = Array.isArray(ctx.userState.nutrition?.meals)
      ? ctx.userState.nutrition.meals
      : [];
    const search = input.mealName.toLowerCase();
    const found = existingMeals.find((m: any) => m.name && m.name.toLowerCase().includes(search));

    return {
      mealName: input.mealName,
      removedMeal: found,
      targetDate,
    };
  },

  preview: async (resolved) => {
    return {
      commandName: "nutrition.removeMeal",
      category: "nutrition",
      risk: "low",
      summary: `Removed meal: ${resolved.removedMeal?.name || resolved.mealName}`,
      changes: [
        {
          target: resolved.removedMeal?.name || resolved.mealName,
          description: "Removed from daily food log",
          before: resolved.removedMeal
            ? `${resolved.removedMeal.calories} kcal (${resolved.removedMeal.proteinG}g P)`
            : "Logged Meal",
          after: "Removed",
        },
      ],
    };
  },

  execute: async (resolved, ctx: ExecutionContext) => {
    const nutRef = ctx.db.collection("users").doc(ctx.uid).collection("nutrition").doc(resolved.targetDate);
    const nutDoc = await nutRef.get();
    if (!nutDoc.exists) return { success: false };

    const data = nutDoc.data() || {};
    const existingMeals: any[] = Array.isArray(data.meals) ? data.meals : [];
    const search = resolved.mealName.toLowerCase();
    const updated = existingMeals.filter((m: any) => !m.name || !m.name.toLowerCase().includes(search));

    await nutRef.update({
      meals: updated,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  },
};
