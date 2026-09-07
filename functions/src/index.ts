import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import { executeGeminiCall, sanitizeUserPrompt } from "./gemini";
import { buildResolutionContext, compressSemanticState } from "./context/contextBuilder";
import { defaultCommandRegistry } from "./commands/registry";
import { ExecutionContext } from "./commands/types";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

/**
 * OpenFoodFacts API Integration for macro verification and enrichment.
 */
async function lookupFoodMacros(foodName: string): Promise<{ calories?: number; proteinG?: number; carbsG?: number; fatG?: number } | null> {
  try {
    const url = `https://world.openfoodfacts.org/cgi/search.pl?search_terms=${encodeURIComponent(foodName)}&search_simple=1&action=process&json=1&page_size=1`;
    const res = await fetch(url, {
      headers: { "User-Agent": "AuraCoach - NodeFunctions/1.0" },
      signal: AbortSignal.timeout(3500),
    });
    if (!res.ok) return null;
    const data: any = await res.json();
    const product = data?.products?.[0];
    if (!product || !product.nutriments) return null;
    const nutriments = product.nutriments;
    const cal = nutriments["energy-kcal_100g"] ?? nutriments["energy-kcal_value"] ?? nutriments["energy-kcal"];
    const p = nutriments["proteins_100g"] ?? nutriments["proteins_value"] ?? nutriments["proteins"];
    const c = nutriments["carbohydrates_100g"] ?? nutriments["carbohydrates_value"] ?? nutriments["carbohydrates"];
    const f = nutriments["fat_100g"] ?? nutriments["fat_value"] ?? nutriments["fat"];
    if (cal !== undefined && Number(cal) > 0) {
      return {
        calories: Math.round(Number(cal) || 0),
        proteinG: Math.round(Number(p) || 0),
        carbsG: Math.round(Number(c) || 0),
        fatG: Math.round(Number(f) || 0),
      };
    }
    return null;
  } catch (e) {
    console.log(`[OpenFoodFacts Lookup Skip] ${e}`);
    return null;
  }
}

/**
 * Dedicated processAiCommand Cloud Function for AURA:
 * Secure server-side execution of Command Orchestrator, Context Envelope, and AI tasks.
 */
export const processAiCommand = onRequest(
  {
    secrets: [geminiApiKey],
    cors: true,
    timeoutSeconds: 180,
    maxInstances: 20,
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed. Use POST." });
      return;
    }

    // Verify Firebase Auth ID Token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Unauthorized: Missing Bearer token." });
      return;
    }
    const idToken = authHeader.split("Bearer ")[1]?.trim();
    let uid: string;
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      uid = decoded.uid;
    } catch (authError: any) {
      res.status(401).json({ error: "Unauthorized: Invalid Firebase ID token.", details: authError.message });
      return;
    }

    const apiKey = geminiApiKey.value();
    if (!apiKey) {
      res.status(500).json({ error: "Server Gemini API key secret is not configured." });
      return;
    }

    const {
      command,
      message: rawMessage,
      contextEnvelope,
      imageBase64,
      imageUrl,
      mimeType,
      history,
      messageId,
    } = req.body || {};
    const sanitizedMessage = sanitizeUserPrompt(rawMessage || "");

    let finalImageBase64 = imageBase64;
    try {
      if (imageUrl && typeof imageUrl === "string" && imageUrl.startsWith("http")) {
        const imageRes = await fetch(imageUrl);
        if (imageRes.ok) {
          const buffer = await imageRes.arrayBuffer();
          finalImageBase64 = Buffer.from(buffer).toString("base64");
        } else {
          console.error(`Failed to fetch image from URL: ${imageRes.statusText}`);
        }
      }
    } catch (e) {
      console.error(`Error fetching imageUrl: ${e}`);
    }

    const todayStr = new Date().toISOString().split("T")[0];

    // ── Canonical State Retrieval — server-side only ──
    let effectiveState: any = {};
    const db = admin.firestore();
    try {
      const userRef = db.collection("users").doc(uid);
      const [profileSnap, workoutSnap, nutritionSnap, recoverySnap] = await Promise.all([
        userRef.get(),
        userRef.collection("workouts").doc(todayStr).get(),
        userRef.collection("nutrition").doc(todayStr).get(),
        userRef.collection("recovery").doc(todayStr).get(),
      ]);

      effectiveState = {
        profile: profileSnap.exists ? profileSnap.data() || {} : {},
        workout: workoutSnap.exists ? workoutSnap.data() || {} : {},
        nutrition: nutritionSnap.exists ? nutritionSnap.data() || {} : {},
        recovery: recoverySnap.exists ? recoverySnap.data() || {} : {},
      };

      console.log(`[STATE] Loaded canonical state from Firestore for uid=${uid}`);
    } catch (dbErr) {
      console.warn(`[STATE RETRIEVAL WARNING] Failed reading Firestore state: ${dbErr}. Proceeding with empty context.`);
    }

    try {
      const compressedMemory = compressSemanticState(effectiveState, contextEnvelope);
      const soul = effectiveState?.profile?.coachSoul || "supporter";

      let coachToneInstruction = "";
      if (soul === "supporter") {
        coachToneInstruction = "You are AURA (The Supporter), an empathetic, warm, encouraging coach celebrating small wins.";
      } else if (soul === "pro") {
        coachToneInstruction = "You are AURA (The Pro), a direct, metrics-focused, high-accountability coach driving action.";
      } else {
        coachToneInstruction = "You are AURA (The Teacher), an educational, scientific coach explaining physiological mechanisms.";
      }

      // Handle Command Types
      switch (command) {
        case "chatMessage": {
          const userPrompt = sanitizedMessage;
          const imageSection = finalImageBase64
            ? "MULTIMODAL NOTE: An image is attached. If meal, estimate macros and log. If workout display, log completion."
            : "";

          const prompt = `SYSTEM INSTRUCTION:
${coachToneInstruction}

CLIENT COMPRESSED CONTEXT (100-word working memory):
${compressedMemory}

INCOMING USER MESSAGE:
"${userPrompt}"
${imageSection}

TWO-PASS ORDER MANDATE:
You MUST generate your empathetic "coachResponse" string FIRST in the JSON output, before generating the "commands" array.

AVAILABLE COMMANDS TO EMIT:
- workout.substituteExercise: { "targetExercise": string | null, "reason": string | null, "replacementExercise": string | null }
- workout.adjustVolume: { "targetExercise": string | null, "targetSetIndex": number | string | null, "deltaWeightKg": number | null, "deltaSets": number | null, "deltaReps": number | null, "scaleFactor": number | null, "reason": string | null }
- workout.adapt: { "reason": string, "timeLimitMin": number | null, "intensityReduction": number | null }
- workout.updateStatus: { "status": "completed" | "skipped" }
- nutrition.logMeal: { "meals": [{ "name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number }], "waterMl": number | null, "targetDate": string | null }
- nutrition.updatePortion: { "mealName": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number, "targetDate": string | null }
- nutrition.removeMeal: { "mealName": string, "targetDate": string | null }
- recovery.log: { "sleepHours": number | null, "sleepQuality": number | null, "muscleSoreness": number | null, "energyLevel": number | null, "stressLevel": number | null }
- profile.logWeight: { "weightKg": number } (ONLY IF user explicitly reported scale weight)
- profile.updateEquipment: { "items": [{ "name": string, "category": string, "weightKg": number | null }] }
- profile.updateInjuries: { "injuries": ["string"] }
- profile.updateGoal: { "goal": "fat_loss"|"muscle_gain"|"recomp", "targetPhysique": string | null }
- profile.updateSchedule: { "daysPerWeek": number }

INTENT & NATURAL LANGUAGE TARGET RESOLUTION RULES:
1. If the user says "swap this", "swap it", "hurts my knee, swap it" or refers to an exercise without naming it, set targetExercise to "this exercise" and extract the reason (e.g. "knee pain").
2. If the user says "make it 5kg heavier", "add 5kg", or asks to adjust weights/sets/reps, set targetExercise to "it" or the active exercise, and deltaWeightKg to 5.
3. If the user reports multi-domain updates (e.g. "ate 3 eggs and slept 6 hours"), emit MULTIPLE commands in the "commands" array (e.g. nutrition.logMeal + recovery.log).
4. If the user buys equipment (e.g. "bought 20kg kettlebell") or changes schedule (e.g. "train 4 days a week"), emit the respective profile commands.
5. If the user says "I'm exhausted today, take it easy" or has a time limit ("only 30 minutes"), emit workout.adapt with the reason or timeLimitMin.

Return strictly JSON:
{
  "coachResponse": "Empathetic conversational response directly to client...",
  "commands": [
    { "name": "command.name", "parameters": {} }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, finalImageBase64, mimeType);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          const incomingCommands: any[] = Array.isArray(parsed.commands)
            ? parsed.commands
            : (Array.isArray(parsed.actions) ? parsed.actions : []);

          // Resolution and Execution Contexts
          const resCtx = buildResolutionContext(uid, todayStr, effectiveState, contextEnvelope, db);
          const execCtx: ExecutionContext = {
            uid,
            db,
            todayStr,
            userState: effectiveState,
            envelope: contextEnvelope,
            lookupFoodMacros,
          };

          // Server-side Action Execution with Idempotency Check
          const actionHashInput = `${uid}_${messageId || ""}_${sanitizedMessage}_${JSON.stringify(incomingCommands)}`;
          const actionHash = crypto.createHash("sha256").update(actionHashInput).digest("hex");
          const processedRef = db.collection("users").doc(uid).collection("processed_actions").doc(actionHash);
          const processedDoc = await processedRef.get();

          let executionResult: {
            previews: any[];
            pendingActions: any[];
            executedCommands: string[];
          } = { previews: [], pendingActions: [], executedCommands: [] };

          if (!processedDoc.exists && incomingCommands.length > 0) {
            executionResult = await defaultCommandRegistry.executeChain(incomingCommands, resCtx, execCtx);

            await processedRef.set({
              processedAt: admin.firestore.FieldValue.serverTimestamp(),
              commandCount: incomingCommands.length,
            });
          }

          res.status(200).json({
            coachResponse: parsed.coachResponse || "Got it.",
            commands: incomingCommands,
            actions: incomingCommands, // backwards compatibility
            previews: executionResult.previews,
            pendingActions: executionResult.pendingActions,
            executedCommands: executionResult.executedCommands,
          });
          return;
        }

        case "adaptWorkoutWithAI": {
          // Unified into Command Registry
          const adaptationRequest = sanitizedMessage;
          const resCtx = buildResolutionContext(uid, todayStr, effectiveState, contextEnvelope, db);
          const execCtx: ExecutionContext = {
            uid,
            db,
            todayStr,
            userState: effectiveState,
            envelope: contextEnvelope,
          };

          const execution = await defaultCommandRegistry.executeCommand(
            "workout.adapt",
            { reason: adaptationRequest },
            resCtx,
            execCtx
          );

          res.status(200).json({
            title: execution.result?.title || "Adapted Workout",
            adaptationNote: execution.result?.adaptationNote || adaptationRequest,
            exercises: execution.result?.exercises || [],
            preview: execution.preview,
          });
          return;
        }

        case "parseLifestyleIntake": {
          const intakeText = sanitizedMessage;
          const historyStr = Array.isArray(history)
            ? history.map((m: any) => `${m.sender === "user" ? "User" : "AURA"}: ${m.text}`).join("\n")
            : "";
          const prompt = `SYSTEM INSTRUCTION:
You are the AURA Intake Engine. The user is in an interactive onboarding conversation to calibrate their weekly schedule, equipment, and fitness aspirations.

Context / Memory:
${compressedMemory}
${historyStr ? `\nConversation History:\n${historyStr}` : ""}

User's Latest Message: "${intakeText}"

Directives:
1. Preserve previously established variables (e.g. training frequency, equipment) unless the user explicitly updates them.
2. If the user mentions goals (e.g. "Diwali", "bigger arms", "V shape", "lean"), acknowledge them warmly.
3. Extract any specific lifestyle constraints, fasting habits, preferred days of week, and dietary nuances into "lifestyleNotes".
4. Determine if intake is complete (isComplete: true) - true ONLY when both daysPerWeek (2-6) and equipment are firmly established.
5. Generate 2 to 3 contextual quick-reply pills (dynamicQuickReplies).

Return strictly JSON:
{
  "isComplete": boolean,
  "daysPerWeek": number,
  "equipment": ["string"],
  "targetPhysique": string or null,
  "lifestyleNotes": ["string"],
  "missingFields": ["string"],
  "followUpQuestion": "string",
  "dynamicQuickReplies": ["string"]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "generateWeeklyDebrief": {
          const prompt = `SYSTEM INSTRUCTION:
${coachToneInstruction}

Analyze this user's weekly trajectory and synthesize a compelling Narrative Weekly Debrief:
Context: ${compressedMemory}

CRITICAL DIRECTIVE:
Connect the dots between different domains:
1. Explain how sleep/recovery impacted workout performance and strength.
2. Evaluate protein and calorie adherence relative to training load.
3. Provide 1 actionable focus point for next week.

Return strictly JSON:
{
  "headline": "Punchy 5-7 word summary title",
  "narrative": "3-paragraph synthesized debrief connecting sleep, recovery, nutrition, and training.",
  "keyAchievement": "1 standout win this week",
  "primaryNextStep": "1 actionable goal for next week",
  "adherenceScore": number
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "estimateMeal": {
          const mealDesc = sanitizedMessage;
          const prompt = `SYSTEM INSTRUCTION:
Estimate nutritional content for this meal: "${mealDesc}"
Return strictly JSON:
{
  "name": "string (Cleaned up meal name)",
  "calories": number,
  "proteinG": number,
  "carbsG": number,
  "fatG": number
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const mealDoc = {
              name: parsed.name || mealDesc,
              calories: parsed.calories || 300,
              proteinG: parsed.proteinG || 15,
              carbsG: parsed.carbsG || 30,
              fatG: parsed.fatG || 10,
            };
            await db.collection("users").doc(uid).collection("nutrition").doc(todayStr).set(
              {
                meals: admin.firestore.FieldValue.arrayUnion(mealDoc),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateMetabolicPlan": {
          const profile = effectiveState?.profile || {};
          const prompt = `You are an expert fitness nutritionist generating a daily baseline metabolic plan.
Client: ${profile.name || "Client"}, Goal: ${profile.goal || "general"}, Weight: ${profile.weightKg || 70}kg
Return strictly JSON:
{
  "targetCalories": 2000,
  "targetProteinG": 150,
  "targetCarbsG": 200,
  "targetFatG": 60,
  "targetWaterMl": 2800,
  "reasoning": "string"
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const nutritionDoc = {
              date: todayStr,
              targetCalories: parsed.targetCalories || 2000,
              targetProteinG: parsed.targetProteinG || 150,
              targetCarbsG: parsed.targetCarbsG || 200,
              targetFatG: parsed.targetFatG || 60,
              targetWaterMl: parsed.targetWaterMl || 2800,
              waterMl: 0,
              meals: [],
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await db.collection("users").doc(uid).collection("nutrition").doc(todayStr).set(nutritionDoc, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateAdaptedNutrition": {
          const reason = sanitizedMessage || "Weight stall or routine change";
          const prompt = `SYSTEM INSTRUCTION:
You are an expert nutritionist adapting the client's macro plan.
Current Context: ${compressedMemory}
Reason for adaptation: "${reason}"
Return JSON:
{
  "adaptationReason": "string (brief explanation for user)",
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number,
  "targetWaterMl": number
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            await db.collection("users").doc(uid).collection("nutrition").doc(todayStr).set(
              {
                targetCalories: parsed.targetCalories,
                targetProteinG: parsed.targetProteinG,
                targetCarbsG: parsed.targetCarbsG,
                targetFatG: parsed.targetFatG,
                targetWaterMl: parsed.targetWaterMl,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateAdaptedWorkout": {
          const reason = sanitizedMessage || "General adaptation";
          const resCtx = buildResolutionContext(uid, todayStr, effectiveState, contextEnvelope, db);
          const execCtx: ExecutionContext = { uid, db, todayStr, userState: effectiveState, envelope: contextEnvelope };
          const exec = await defaultCommandRegistry.executeCommand("workout.adapt", { reason }, resCtx, execCtx);
          res.status(200).json(exec.result || {});
          return;
        }

        case "generateWeeklyPlan": {
          const prompt = `SYSTEM INSTRUCTION:
You are an expert fitness coach generating a 7-day adaptive workout and nutrition schedule.
Client Context: ${compressedMemory}

CRITICAL SCHEDULING CONSTRAINTS:
1. Examine Client Context carefully for explicit preferred training days (e.g. "Tue, Thu, Sat") and fasting protocols.
2. You MUST strictly place workout days (isRestDay: false) on the client's designated training days.
3. If the client has a fasting day, designate that day as active recovery/rest (isRestDay: true) and specify a hydration protocol in "nutritionFocus".
4. Design a weekly split matching their training frequency (${effectiveState?.profile?.daysPerWeek || 3} days/week).
Return JSON:
{
  "overview": "string (1 paragraph overview of the week's strategy)",
  "coachNote": "string (motivational note from their coach)",
  "days": [
    {
      "dayName": "string",
      "date": "string",
      "title": "string",
      "focusArea": "string",
      "isRestDay": boolean,
      "exerciseNames": ["string"],
      "nutritionFocus": "string"
    }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          const weekId = `w_${Date.now()}`;
          const now = new Date();
          const dayOfWeek = now.getDay() === 0 ? 6 : now.getDay() - 1; // 0 = Monday, 6 = Sunday
          const monday = new Date(now);
          monday.setDate(monday.getDate() - dayOfWeek);

          const days = (parsed.days || []).map((d: any, i: number) => {
            const dayDate = new Date(monday);
            dayDate.setDate(monday.getDate() + i);
            return {
              ...d,
              date: dayDate.toISOString().split("T")[0],
            };
          });

          const planDoc = {
            ...parsed,
            weekId,
            days,
            startDate: days[0]?.date || "",
            endDate: days[days.length - 1]?.date || "",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };

          if (uid) {
            await db.collection("users").doc(uid).collection("weekly_plans").doc(weekId).set(planDoc);
            await db.collection("users").doc(uid).collection("weekly_plans").doc("current").set(planDoc);
          }

          res.status(200).json({
            ...planDoc,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          });
          return;
        }

        case "parseNaturalWorkout": {
          const workoutText = sanitizedMessage;
          const prompt = `Parse this natural language workout log into a structured data format:
"${workoutText}"

Identify exercises, sets, reps, and weights. If weight is not mentioned, use 0.0. If reps are not mentioned, assume 10.
Return JSON:
{
  "title": "string (Summarize the workout in 3-5 words)",
  "focusArea": "string",
  "estimatedDurationMin": number,
  "adaptationNote": "string",
  "exercises": [
    {
      "name": "string",
      "targetMuscle": "string",
      "equipmentRequired": "bodyweight",
      "sets": [
        {
          "setNumber": number,
          "targetReps": number,
          "targetWeightKg": number,
          "completed": true
        }
      ],
      "notes": "string"
    }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const exercises = (parsed.exercises || []).map((ex: any, idx: number) => {
              const sets = (ex.sets || []).map((s: any, sIdx: number) => ({
                setNumber: Number(s.setNumber) || sIdx + 1,
                targetReps: Number(s.targetReps) || 10,
                targetWeightKg: Number(s.targetWeightKg) || 0.0,
                completed: s.completed ?? true,
              }));
              return {
                id: ex.id || `ex_${Date.now()}_${idx + 1}`,
                name: ex.name || `Exercise ${idx + 1}`,
                targetMuscle: ex.targetMuscle || "Full Body",
                equipmentRequired: ex.equipmentRequired || "bodyweight",
                sets: sets.length > 0 ? sets : [{ setNumber: 1, targetReps: 10, targetWeightKg: 0.0, completed: true }],
                notes: ex.notes || "",
              };
            });
            const workoutDoc = {
              id: `natural_log_${todayStr}_${Date.now()}`,
              date: todayStr,
              title: parsed.title || "Today's Logged Workout",
              focusArea: parsed.focusArea || "Completed Workout",
              estimatedDurationMin: parsed.estimatedDurationMin || 45,
              status: "completed",
              exercises: exercises,
              adaptationNote: parsed.adaptationNote || workoutText,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await db.collection("users").doc(uid).collection("workouts").doc(todayStr).set(workoutDoc, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "parseQuickLog": {
          const rawText = sanitizedMessage;
          const prompt = `User Context:
${compressedMemory}

Analyze this natural language daily fitness log entry: "${rawText}"
Scheduled Workout for today: ${effectiveState?.workout?.title || "Unknown"}

Extract structured data. Return JSON:
{
  "workoutStatus": "completed" | "skipped" | "adapted" | null,
  "workoutReason": "string or null",
  "mealsToAdd": [{"name": "string", "calories": 0, "proteinG": 0, "carbsG": 0, "fatG": 0}],
  "skippedMeals": ["string"],
  "sleepHours": 0,
  "weightKg": 0,
  "energyLevel": 0,
  "coachFeedback": "1-2 sentences feedback written in your specific personality style"
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "generateAIInitialWorkout": {
          const profile = effectiveState?.profile || {};
          const prompt = `You are an elite fitness coach designing an initial 1-day workout for a new client.
Client: ${profile.name || "Client"}, Goal: ${profile.goal || "general"}, Equipment: ${(profile.equipmentList || []).map((e: any) => e.name).join(", ")}

Return strictly JSON:
{
  "title": "string",
  "focusArea": "string",
  "estimatedDurationMin": 45,
  "adaptationNote": "string",
  "exercises": [{"name": "string", "targetMuscle": "string", "equipmentRequired": "string", "targetSets": 3, "targetReps": 10, "targetWeightKg": 0, "notes": "string"}]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const exercises = (parsed.exercises || []).map((ex: any, idx: number) => {
              const sets = Array.from({ length: ex.targetSets || 3 }).map((_, sIdx) => ({
                setNumber: sIdx + 1,
                targetReps: ex.targetReps || 10,
                targetWeightKg: ex.targetWeightKg || 0,
                completed: false,
              }));
              return {
                id: `init_ex_${idx + 1}_${Date.now()}`,
                name: ex.name || `Exercise ${idx + 1}`,
                targetMuscle: ex.targetMuscle || "Full Body",
                equipmentRequired: ex.equipmentRequired || "bodyweight",
                sets: sets,
                notes: ex.notes || "",
              };
            });
            const workoutDoc = {
              id: `w_${Date.now()}`,
              date: todayStr,
              title: parsed.title || "Initial Plan",
              focusArea: parsed.focusArea || "Full Body",
              estimatedDurationMin: parsed.estimatedDurationMin || 45,
              status: "scheduled",
              exercises: exercises,
              adaptationNote: parsed.adaptationNote || "Ready to start.",
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await db.collection("users").doc(uid).collection("workouts").doc(todayStr).set(workoutDoc, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        default: {
          res.status(400).json({ error: `Unknown command: ${command}` });
          return;
        }
      }
    } catch (err: any) {
      console.error("[PROCESS AI COMMAND ERROR]", err);
      res.status(500).json({ error: "AI command processing failed", details: err?.message });
    }
  }
);

/**
 * Endpoint to approve or reject pending structural actions.
 */
export const handlePendingAction = onRequest(
  {
    cors: true,
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed. Use POST." });
      return;
    }

    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Unauthorized: Missing Bearer token." });
      return;
    }

    const idToken = authHeader.split("Bearer ")[1]?.trim();
    let uid: string;
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      uid = decoded.uid;
    } catch (e: any) {
      res.status(401).json({ error: "Invalid token", details: e.message });
      return;
    }

    const { actionId, decision } = req.body || {};
    if (!actionId || !decision) {
      res.status(400).json({ error: "actionId and decision ('approve' | 'reject') are required." });
      return;
    }

    const actionRef = admin.firestore().collection("users").doc(uid).collection("pending_actions").doc(actionId);
    const actionDoc = await actionRef.get();
    if (!actionDoc.exists) {
      res.status(404).json({ error: "Pending action not found." });
      return;
    }

    const actionData = actionDoc.data()!;
    if (actionData.status !== "pending") {
      res.status(400).json({ error: `Action is already ${actionData.status}.` });
      return;
    }

    if (decision === "reject") {
      await actionRef.update({
        status: "rejected",
        resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      res.status(200).json({ success: true, status: "rejected" });
      return;
    }

    if (decision === "approve") {
      const userRef = admin.firestore().collection("users").doc(uid);
      const actionType = actionData.actionType;
      const args = actionData.arguments || {};

      const batch = admin.firestore().batch();

      if (actionType === "updateEquipment") {
        const rawItems = args.items || args.equipment;
        const newItems: any[] = [];
        if (Array.isArray(rawItems)) {
          for (const item of rawItems) {
            if (typeof item === "object") newItems.push(item);
            else if (typeof item === "string") newItems.push({ name: item, category: "other" });
          }
        }
        batch.update(userRef, {
          equipmentList: newItems.length > 0 ? newItems : [{ name: "Bodyweight", category: "bodyweight" }],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else if (actionType === "updateGoal") {
        const updateData: any = { updatedAt: admin.firestore.FieldValue.serverTimestamp() };
        if (args.goal) updateData.goal = args.goal;
        if (args.targetPhysique) updateData.targetPhysique = args.targetPhysique;
        if (args.daysPerWeek) updateData.daysPerWeek = args.daysPerWeek;
        batch.update(userRef, updateData);
      } else if (actionType === "updateInjuries") {
        batch.update(userRef, {
          activeInjuries: Array.isArray(args.injuries) ? args.injuries : [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else if (actionType === "updateSchedule") {
        batch.update(userRef, {
          daysPerWeek: Number(args.daysPerWeek) || 3,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else if (actionType === "regenerateWeeklyPlan") {
        batch.update(userRef, {
          needsWeeklyPlanRegen: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      batch.update(actionRef, {
        status: "approved",
        resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await batch.commit();
      res.status(200).json({ success: true, status: "approved" });
      return;
    }

    res.status(400).json({ error: "Invalid decision. Use 'approve' or 'reject'." });
  }
);

export const migrateEnterpriseToStandard = onRequest(
  { cors: true, timeoutSeconds: 540, memory: "1GiB" },
  async (req, res) => {
    const MIGRATION_SECRET = "aura-migrate-enterprise-standard-2026";
    const authHeader = req.headers.authorization;
    const secretParam = req.query.secret || req.body?.secret;

    let isAuthorized = false;
    if (secretParam === MIGRATION_SECRET) {
      isAuthorized = true;
    } else if (authHeader?.startsWith("Bearer ")) {
      try {
        const token = authHeader.split("Bearer ")[1];
        await admin.auth().verifyIdToken(token);
        isAuthorized = true;
      } catch {
        // Invalid token
      }
    }

    if (!isAuthorized) {
      res.status(401).json({
        error: "Unauthorized. Provide Authorization Bearer token or ?secret=aura-migrate-enterprise-standard-2026",
      });
      return;
    }

    const isDryRun = req.query.dryRun === "true" || req.body?.dryRun === true;
    try {
      const { runEnterpriseToStandardMigration } = await import("../scripts/run_migrations");
      const summary = await runEnterpriseToStandardMigration(isDryRun);
      res.status(200).json({ success: true, isDryRun, summary });
    } catch (err: any) {
      console.error("Migration endpoint error:", err);
      res.status(500).json({ error: err.message || String(err) });
    }
  }
);
