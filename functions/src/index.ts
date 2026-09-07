import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Prompt injection sanitizer to prevent jailbreaks and instruction overriding.
 */
function sanitizeUserPrompt(input: string): string {
  if (!input) return "";
  return input
    .replace(/```/g, "'''")
    .replace(/(?:SYSTEM INSTRUCTION|SYSTEM PROMPT|IGNORE ALL PREVIOUS INSTRUCTIONS|YOU ARE NOW|ADMIN MODE)/gi, "[redacted]");
}

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
 * Generates human readable description for pending structural actions.
 */
function generateActionDescription(action: { functionName: string; arguments: any }): string {
  const name = action.functionName;
  const args = action.arguments || {};
  switch (name) {
    case "updateEquipment": {
      const items = args.items || args.equipment || [];
      const names = items.map((i: any) => (typeof i === "string" ? i : i.name || "")).filter(Boolean);
      return `Update equipment setup to: ${names.join(", ") || "Bodyweight"}`;
    }
    case "updateGoal":
      return `Recalibrate primary fitness goal to "${args.goal || "New Goal"}"`;
    case "updateInjuries": {
      const injuries = Array.isArray(args.injuries) ? args.injuries.join(", ") : args.injuries;
      return `Update joint & mobility limitations: ${injuries || "None"}`;
    }
    case "updateSchedule":
      return `Update training frequency to ${args.daysPerWeek || 3} days per week`;
    case "regenerateWeeklyPlan":
      return "Regenerate full 7-day adaptive transformation schedule based on your recent progress";
    default:
      return `Apply configuration changes (${name})`;
  }
}

/**
 * Semantic Compression Middleware:
 * Translates raw JSON state into a dense, ~100-word natural language context paragraph.
 * Minimizes context window bloat and focuses LLM attention.
 */
function compressSemanticState(state: any): string {
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

  // Gear summary
  const equipment = Array.isArray(profile.equipmentList) && profile.equipmentList.length > 0
    ? profile.equipmentList.map((e: any) => (typeof e === "string" ? e : e.name || "")).filter(Boolean).join(", ")
    : "Bodyweight";

  // Recovery summary
  const sleepH = recovery.sleepHours ? `${recovery.sleepHours}h sleep` : "normal sleep";
  const sore = recovery.muscleSoreness ? `soreness ${recovery.muscleSoreness}/10` : "no soreness";
  const energy = recovery.energyLevel ? `energy ${recovery.energyLevel}/10` : "moderate energy";
  const recStatus = recovery.status || "Ready";

  // Nutrition summary
  const meals = Array.isArray(nutrition.meals) ? nutrition.meals : [];
  const totalCal = meals.reduce((sum: number, m: any) => sum + (Number(m.calories) || 0), 0);
  const totalProt = meals.reduce((sum: number, m: any) => sum + (Number(m.proteinG) || 0), 0);
  const targetCal = nutrition.targetCalories || 2000;
  const targetProt = nutrition.targetProteinG || 150;
  const remCal = Math.max(0, targetCal - totalCal);
  const remProt = Math.max(0, targetProt - totalProt);

  // Workout summary
  const workoutTitle = workout.title || "Daily Routine";
  const workoutStatus = workout.status || "scheduled";
  const focus = workout.focusArea || "General Fitness";

  // Injuries / constraints
  const injuries = Array.isArray(profile.activeInjuries) && profile.activeInjuries.length > 0
    ? profile.activeInjuries.join(", ")
    : "none";
  const dietPref = profile.dietaryPreference ? `diet: ${profile.dietaryPreference}` : "";
  const physiquePref = profile.targetPhysique ? `physique focus: ${profile.targetPhysique}` : "";
  const extraProfile = [dietPref, physiquePref].filter(Boolean).join(", ");
  const personalNotes = Array.isArray(profile.personalNotes) && profile.personalNotes.length > 0
    ? `Schedule & Lifestyle Notes: ${profile.personalNotes.join("; ")}.`
    : "";

  return `Client ${name} (${gender}, ${age}y, ${weight}kg -> ${targetWeight}kg, goal: ${goal}, coach: ${soul}${extraProfile ? `, ${extraProfile}` : ""}). Gear: ${equipment}. Joint safeguards: ${injuries}.${personalNotes ? ` ${personalNotes}` : ""} Recovery: ${sleepH}, ${sore}, ${energy} (${recStatus}). Fuel today: ${totalCal}/${targetCal} kcal (${remCal} left), ${totalProt}/${targetProt}g protein (${remProt}g left). Workout: ${workoutTitle} (${focus}, status: ${workoutStatus}).`;
}

/**
 * Call Gemini API with automated retry and candidate model fallback
 */
async function executeGeminiCall(apiKey: string, prompt: string, isJson: boolean = false, imageBase64?: string, mimeType?: string): Promise<{ text: string; model: string }> {
  const candidateModels = [
    "gemini-3.5-flash-lite",
    "gemini-3.1-flash-lite",
    "gemini-3.5-flash",
  ];

  const parts: Array<Record<string, any>> = [];
  if (imageBase64 && typeof imageBase64 === "string" && imageBase64.trim().length > 0) {
    parts.push({
      inlineData: {
        mimeType: mimeType || "image/jpeg",
        data: imageBase64,
      },
    });
  }
  parts.push({ text: prompt });

  const requestBody: Record<string, any> = {
    contents: [{ parts }],
  };

  if (isJson) {
    requestBody.generationConfig = {
      responseMimeType: "application/json",
    };
  }

  let lastError: string | null = null;
  let lastStatus = 500;

  for (const model of candidateModels) {
    const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    for (let attempt = 1; attempt <= 2; attempt++) {
      try {
        const response = await fetch(geminiEndpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(requestBody),
        });

        if (response.ok) {
          const data: any = await response.json();
          let rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
          if (isJson) {
            const match = rawText.match(/\{[\s\S]*\}/);
            if (match) rawText = match[0];
          }
          return { text: rawText, model };
        }

        lastStatus = response.status;
        lastError = await response.text();

        if (response.status === 400 || response.status === 401 || response.status === 403) {
          throw new Error(`Gemini API error (${response.status}): ${lastError}`);
        }

        if ((response.status === 503 || response.status === 429) && attempt < 2) {
          await sleep(400);
          continue;
        }

        if (response.status === 404) {
          break;
        }
      } catch (fetchErr: any) {
        lastError = fetchErr?.message ?? "Network error";
        if (attempt < 2) await sleep(350);
      }
    }
    await sleep(150);
  }

  // No wildcard fallback discovery — only use curated models above to prevent hallucinations

  throw new Error(`All Gemini models in fallback chain failed (${lastStatus}): ${lastError}`);
}

/**
 * Dedicated processAiCommand Cloud Function for AURA MVP:
 * Secure server-side execution of Semantic Compression, Two-Pass Schema, and domain AI tasks.
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

    const { command, message: rawMessage, imageBase64, imageUrl, mimeType, history, messageId } = req.body || {};
    const sanitizedMessage = sanitizeUserPrompt(rawMessage || "");

    let finalImageBase64 = imageBase64;
    try {
      if (imageUrl && typeof imageUrl === "string" && imageUrl.startsWith('http')) {
        const imageRes = await fetch(imageUrl);
        if (imageRes.ok) {
          const buffer = await imageRes.arrayBuffer();
          finalImageBase64 = Buffer.from(buffer).toString('base64');
        } else {
          console.error(`Failed to fetch image from URL: ${imageRes.statusText}`);
        }
      }
    } catch (e) {
      console.error(`Error fetching imageUrl: ${e}`);
    }

    const todayStr = new Date().toISOString().split("T")[0];

    // ── Canonical State Retrieval — server-side only, never trusts client payload ──
    let effectiveState: any = {};
    try {
      const db = admin.firestore();
      const userRef = db.collection("users").doc(uid);

      const [profileSnap, workoutSnap, nutritionSnap, recoverySnap] = await Promise.all([
        userRef.get(),
        userRef.collection("workouts").doc(todayStr).get(),
        userRef.collection("nutrition").doc(todayStr).get(),
        userRef.collection("recovery").doc(todayStr).get(),
      ]);

      effectiveState = {
        profile: profileSnap.exists ? (profileSnap.data() || {}) : {},
        workout: workoutSnap.exists ? (workoutSnap.data() || {}) : {},
        nutrition: nutritionSnap.exists ? (nutritionSnap.data() || {}) : {},
        recovery: recoverySnap.exists ? (recoverySnap.data() || {}) : {},
      };

      console.log(`[STATE] Loaded canonical state from Firestore for uid=${uid}`);
    } catch (dbErr) {
      console.warn(`[STATE RETRIEVAL WARNING] Failed reading Firestore state: ${dbErr}. Proceeding with empty context.`);
    }

    try {
      const compressedMemory = compressSemanticState(effectiveState);
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
          const imageSection = finalImageBase64 ? "MULTIMODAL NOTE: An image is attached. If meal, estimate macros and log. If workout display, log completion." : "";

          const prompt = `SYSTEM INSTRUCTION:
${coachToneInstruction}

CLIENT COMPRESSED CONTEXT (100-word working memory):
${compressedMemory}

INCOMING USER MESSAGE:
"${userPrompt}"
${imageSection}

TWO-PASS ORDER MANDATE:
You MUST generate your empathetic "coachResponse" string FIRST in the JSON output, before generating the "actions" array.
Available actions to emit:
- updateEquipment: { "items": [{ "name": string, "category": "free_weight"|"bodyweight"|"bands"|"cables"|"machine"|"other" }] }
- adaptWorkout: { "reason": string, "maxWeightKg": number | null }
- logNutrition: { "meals": [{ "name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number }], "waterMl": number | null, "targetDate": string | null }
- logRecovery: { "sleepHours": number | null, "sleepQuality": number | null, "muscleSoreness": number | null, "energyLevel": number | null, "stressLevel": number | null }
- logWeight: { "weightKg": number } (ONLY IF user explicitly reported scale weight)
- updateWorkoutStatus: { "status": "completed" | "skipped" }
- updateMealPortion: { "mealName": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number, "targetDate": string | null }
- removeMeal: { "mealName": string, "targetDate": string | null }
- updateGoal: { "goal": "fat_loss"|"muscle_gain"|"recomp", "targetPhysique": string | null }
- updateInjuries: { "injuries": ["string"] }
- regenerateWeeklyPlan: {}

Return strictly JSON:
{
  "coachResponse": "Empathetic conversational response directly to client...",
  "actions": [
    { "functionName": "string", "arguments": {} }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, finalImageBase64, mimeType);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          const actions: any[] = Array.isArray(parsed.actions) ? parsed.actions : [];

          // Server-side Action Execution with Idempotency Check
          const actionHashInput = `${uid}_${messageId || ""}_${sanitizedMessage}_${JSON.stringify(actions)}`;
          const actionHash = crypto.createHash("sha256").update(actionHashInput).digest("hex");
          const processedRef = admin.firestore().collection("users").doc(uid).collection("processed_actions").doc(actionHash);
          const processedDoc = await processedRef.get();

          const pendingActionsCreated: any[] = [];

          if (!processedDoc.exists && actions.length > 0) {
            const db = admin.firestore();
            const userRef = db.collection("users").doc(uid);

            for (const action of actions) {
              const fnName = action.functionName || action.name;
              const args = action.arguments || action.parameters || {};

              try {
                switch (fnName) {
                  case "logNutrition": {
                    const rawMeals = Array.isArray(args.meals) ? args.meals : [];
                    const verifiedMeals: any[] = [];
                    for (const m of rawMeals) {
                      let cal = Number(m.calories) || 300;
                      let prot = Number(m.proteinG) || 20;
                      let carb = Number(m.carbsG) || 30;
                      let fat = Number(m.fatG) || 10;
                      const verified = await lookupFoodMacros(m.name || "");
                      if (verified) {
                        cal = verified.calories ?? cal;
                        prot = verified.proteinG ?? prot;
                        carb = verified.carbsG ?? carb;
                        fat = verified.fatG ?? fat;
                      }
                      verifiedMeals.push({
                        name: m.name || "Logged Meal",
                        calories: Math.round(cal),
                        proteinG: Math.round(prot),
                        carbsG: Math.round(carb),
                        fatG: Math.round(fat),
                      });
                    }

                    const targetDate = (args.targetDate && typeof args.targetDate === "string" && args.targetDate.length === 10)
                      ? args.targetDate
                      : todayStr;
                    const waterMl = Number(args.waterMl) || 0;

                    const nutRef = userRef.collection("nutrition").doc(targetDate);
                    const nutDoc = await nutRef.get();

                    if (!nutDoc.exists) {
                      await nutRef.set({
                        date: targetDate,
                        targetCalories: effectiveState?.nutrition?.targetCalories || 2000,
                        targetProteinG: effectiveState?.nutrition?.targetProteinG || 150,
                        targetCarbsG: effectiveState?.nutrition?.targetCarbsG || 200,
                        targetFatG: effectiveState?.nutrition?.targetFatG || 65,
                        waterMl: waterMl,
                        targetWaterMl: 3200,
                        meals: verifiedMeals,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                      });
                    } else {
                      const updatePayload: any = {
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                      };
                      if (verifiedMeals.length > 0) {
                        updatePayload.meals = admin.firestore.FieldValue.arrayUnion(...verifiedMeals);
                      }
                      if (waterMl > 0) {
                        updatePayload.waterMl = admin.firestore.FieldValue.increment(waterMl);
                      }
                      await nutRef.update(updatePayload);
                    }
                    break;
                  }

                  case "updateMealPortion": {
                    const targetDate = (args.targetDate && typeof args.targetDate === "string" && args.targetDate.length === 10)
                      ? args.targetDate
                      : todayStr;
                    const nutRef = userRef.collection("nutrition").doc(targetDate);
                    const nutDoc = await nutRef.get();
                    if (nutDoc.exists) {
                      const data = nutDoc.data() || {};
                      const search = (args.mealName || "").toLowerCase();
                      const existingMeals = Array.isArray(data.meals) ? data.meals : [];
                      const updated = existingMeals.map((m: any) => {
                        if (m.name && m.name.toLowerCase().includes(search)) {
                          return {
                            ...m,
                            calories: Number(args.calories) || m.calories,
                            proteinG: Number(args.proteinG) || m.proteinG,
                            carbsG: Number(args.carbsG) || m.carbsG,
                            fatG: Number(args.fatG) || m.fatG,
                          };
                        }
                        return m;
                      });
                      await nutRef.update({ meals: updated, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
                    }
                    break;
                  }

                  case "removeMeal": {
                    const targetDate = (args.targetDate && typeof args.targetDate === "string" && args.targetDate.length === 10)
                      ? args.targetDate
                      : todayStr;
                    const nutRef = userRef.collection("nutrition").doc(targetDate);
                    const nutDoc = await nutRef.get();
                    if (nutDoc.exists) {
                      const data = nutDoc.data() || {};
                      const search = (args.mealName || "").toLowerCase();
                      const existingMeals = Array.isArray(data.meals) ? data.meals : [];
                      const updated = existingMeals.filter((m: any) => !m.name || !m.name.toLowerCase().includes(search));
                      await nutRef.update({ meals: updated, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
                    }
                    break;
                  }

                  case "logRecovery": {
                    const recRef = userRef.collection("recovery").doc(todayStr);
                    const sleepH = Number(args.sleepHours) || effectiveState?.recovery?.sleepHours || 7.5;
                    const sleepQ = Number(args.sleepQuality) || effectiveState?.recovery?.sleepQuality || 8;
                    const sore = Number(args.muscleSoreness) || effectiveState?.recovery?.muscleSoreness || 2;
                    const energy = Number(args.energyLevel) || effectiveState?.recovery?.energyLevel || 7;
                    const stress = Number(args.stressLevel) || 3;

                    const sleepScore = (Math.min(Math.max(sleepH / 8.0, 0), 1.2)) * 10 * (sleepQ / 10.0);
                    const score = Math.round(Math.min(Math.max((sleepScore * 3.5) + (energy * 3.5) + ((10 - sore) * 2.0) + ((10 - stress) * 1.0), 20), 100));

                    await recRef.set({
                      date: todayStr,
                      sleepHours: sleepH,
                      sleepQuality: sleepQ,
                      muscleSoreness: sore,
                      energyLevel: energy,
                      stressLevel: stress,
                      recoveryScore: score,
                      status: score >= 75 ? "Optimal" : score >= 50 ? "Moderate" : "Needs Rest",
                      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    }, { merge: true });
                    break;
                  }

                  case "logWeight": {
                    const weight = Number(args.weightKg);
                    if (weight && weight > 0) {
                      await userRef.update({
                        weightKg: weight,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                      });
                      await userRef.collection("progress").doc(todayStr).set({
                        date: todayStr,
                        weightKg: weight,
                        notes: "Logged via Coach Conversation",
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                      }, { merge: true });
                    }
                    break;
                  }

                  case "updateWorkoutStatus": {
                    const status = args.status === "completed" ? "completed" : "skipped";
                    const wRef = userRef.collection("workouts").doc(todayStr);
                    await wRef.set({
                      status: status,
                      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    }, { merge: true });
                    break;
                  }

                  case "adaptWorkout": {
                    const reason = args.reason || sanitizedMessage;
                    const wRef = userRef.collection("workouts").doc(todayStr);
                    await wRef.set({
                      status: "adapted",
                      adaptationNote: reason,
                      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    }, { merge: true });
                    break;
                  }

                  // ─── Structural Actions (Gate behind Pending Approval) ───
                  case "updateEquipment":
                  case "updateGoal":
                  case "updateInjuries":
                  case "updateSchedule":
                  case "regenerateWeeklyPlan": {
                    const actionId = `action_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
                    const pendingDoc = {
                      id: actionId,
                      actionType: fnName,
                      arguments: args,
                      description: generateActionDescription({ functionName: fnName, arguments: args }),
                      status: "pending",
                      createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    };
                    await userRef.collection("pending_actions").doc(actionId).set(pendingDoc);
                    pendingActionsCreated.push({
                      id: actionId,
                      actionType: fnName,
                      arguments: args,
                      description: pendingDoc.description,
                      status: "pending",
                    });
                    break;
                  }
                }
              } catch (actErr) {
                console.error(`[ACTION EXECUTION ERROR] ${fnName}:`, actErr);
              }
            }

            // Mark hash as processed
            await processedRef.set({
              processedAt: admin.firestore.FieldValue.serverTimestamp(),
              actionCount: actions.length,
            });
          }

          res.status(200).json({
            coachResponse: parsed.coachResponse || "Got it.",
            actions: actions,
            pendingActions: pendingActionsCreated,
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
3. Extract any specific lifestyle constraints, fasting habits (e.g. "Water fast on Mondays"), preferred days of week (e.g. "Tue, Thu, Sat"), and dietary nuances (e.g. "Vegetarian") into "lifestyleNotes".
4. Determine if intake is complete (isComplete: true) - true ONLY when both daysPerWeek (2-6) and equipment are firmly established.
5. Generate 2 to 3 contextual quick-reply pills (dynamicQuickReplies) that directly relate to what you just asked in followUpQuestion.

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
Do NOT output boring tables or static chart lists; write an authentic 3-paragraph coaching debrief directly to the user.

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
            const todayStr = new Date().toISOString().split('T')[0];
            const mealDoc = {
              name: parsed.name || mealDesc,
              calories: parsed.calories || 300,
              proteinG: parsed.proteinG || 15,
              carbsG: parsed.carbsG || 30,
              fatG: parsed.fatG || 10,
            };
            await admin.firestore().collection("users").doc(uid).collection("nutrition").doc(todayStr).set({
              meals: admin.firestore.FieldValue.arrayUnion(mealDoc),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateMetabolicPlan": {
          const profile = effectiveState?.profile || {};
          const prompt = `You are an expert fitness nutritionist generating a daily baseline metabolic plan.
Client: ${profile.name || 'Client'}, Goal: ${profile.goal || 'general'}, Weight: ${profile.weightKg || 70}kg
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
            const todayStr = new Date().toISOString().split('T')[0];
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
            await admin.firestore().collection("users").doc(uid).collection("nutrition").doc(todayStr).set(nutritionDoc, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "synthesizeTodayFocus": {
          const prompt = `Based on the context below, write one action-focused sentence for the client's day:
${compressedMemory}`;
          const result = await executeGeminiCall(apiKey, prompt, false);
          res.status(200).json({ focus: result.text.trim() });
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
            const todayStr = new Date().toISOString().split('T')[0];
            await admin.firestore().collection("users").doc(uid).collection("nutrition").doc(todayStr).set({
              targetCalories: parsed.targetCalories,
              targetProteinG: parsed.targetProteinG,
              targetCarbsG: parsed.targetCarbsG,
              targetFatG: parsed.targetFatG,
              targetWaterMl: parsed.targetWaterMl,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateAdaptedWorkout": {
          const reason = sanitizedMessage || "General adaptation";
          const prompt = `SYSTEM INSTRUCTION:
You are an expert strength coach adapting today's workout on the fly.
Current Context: ${compressedMemory}

User's limitation/deviation: "${reason}"

Modify the workout. If they have an injury or lack equipment, swap the exercises for safe alternatives that target the same focus area. Do NOT drastically increase volume.
Return JSON:
{
  "title": "string (e.g., 'Adapted Pull Day')",
  "adaptationNote": "string explaining changes to the user",
  "exercises": [
    {
      "name": "string",
      "targetMuscle": "string",
      "equipmentRequired": "bodyweight | free_weight | cables | machine",
      "targetSets": number,
      "targetReps": number,
      "targetWeightKg": number,
      "notes": "string"
    }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const todayStr = new Date().toISOString().split('T')[0];
            const exercises = (parsed.exercises || []).map((ex: any, idx: number) => {
              const sets = Array.from({ length: ex.targetSets || 3 }).map((_, sIdx) => ({
                setNumber: sIdx + 1,
                targetReps: ex.targetReps || 10,
                targetWeightKg: ex.targetWeightKg || 0,
                completed: false
              }));
              return {
                id: `adapt_ex_${idx + 1}_${Date.now()}`,
                name: ex.name || `Exercise ${idx + 1}`,
                targetMuscle: ex.targetMuscle || 'Full Body',
                equipmentRequired: ex.equipmentRequired || 'bodyweight',
                sets: sets,
                notes: ex.notes || ''
              };
            });
            await admin.firestore().collection("users").doc(uid).collection("workouts").doc(todayStr).set({
              title: parsed.title || "Adapted Workout",
              status: "adapted",
              adaptationNote: parsed.adaptationNote || "Adapted by AURA AI",
              exercises: exercises,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateWeeklyPlan": {
          const prompt = `SYSTEM INSTRUCTION:
You are an expert fitness coach generating a 7-day adaptive workout and nutrition schedule.
Client Context: ${compressedMemory}

CRITICAL SCHEDULING CONSTRAINTS:
1. Examine Client Context carefully for explicit preferred training days (e.g. "Tue, Thu, Sat") and fasting protocols (e.g. "Water fast on Mondays").
2. You MUST strictly place workout days (isRestDay: false) on the client's designated training days.
3. If the client has a fasting day (e.g., Monday water fast), you MUST designate that day as active recovery/rest (isRestDay: true) and specify a fasting/hydration protocol in "nutritionFocus".
4. Design a weekly split matching their training frequency (${effectiveState?.profile?.daysPerWeek || 3} days/week). For rest days, focus on active recovery and mobility. For training days, assign a specific focus area and 3-5 core exercises.
Return JSON:
{
  "overview": "string (1 paragraph overview of the week's strategy)",
  "coachNote": "string (motivational note from their coach)",
  "days": [
    {
      "dayName": "string (e.g., 'Monday')",
      "date": "string (ISO date if possible, or just skip)",
      "title": "string (e.g., 'Upper Body Push' or 'Active Recovery')",
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
               date: dayDate.toISOString().split('T')[0],
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
            await admin.firestore().collection("users").doc(uid).collection("weekly_plans").doc(weekId).set(planDoc);
            await admin.firestore().collection("users").doc(uid).collection("weekly_plans").doc("current").set(planDoc);
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
  "focusArea": "string (e.g., 'Chest & Triceps' or 'Full Body')",
  "estimatedDurationMin": number,
  "adaptationNote": "string (Encouraging feedback on their log)",
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
            const todayStr = new Date().toISOString().split('T')[0];
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
                targetMuscle: ex.targetMuscle || 'Full Body',
                equipmentRequired: ex.equipmentRequired || 'bodyweight',
                sets: sets.length > 0 ? sets : [{ setNumber: 1, targetReps: 10, targetWeightKg: 0.0, completed: true }],
                notes: ex.notes || '',
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
            await admin.firestore().collection("users").doc(uid).collection("workouts").doc(todayStr).set(workoutDoc, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateCoachResponse": {
          const userPrompt = sanitizedMessage;
          const prompt = `SYSTEM INSTRUCTION:
${coachToneInstruction}

User Transformation Context:
${compressedMemory}

User Message: ${userPrompt}`;
          const result = await executeGeminiCall(apiKey, prompt, false);
          res.status(200).json({ response: result.text.trim() });
          return;
        }

        case "parseQuickLog": {
          const rawText = sanitizedMessage;
          const prompt = `User Context:
${compressedMemory}

Analyze this natural language daily fitness log entry: "${rawText}"
Scheduled Workout for today: ${effectiveState?.workout?.title || 'Unknown'}

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

        case "adaptWorkoutWithAI": {
          const adaptationRequest = sanitizedMessage;
          const prompt = `You are an elite strength coach adapting a workout plan.
User Context:
${compressedMemory}

Adaptation Request: "${adaptationRequest}"
Current Workout: ${effectiveState?.workout?.title || 'Unknown'}

Modify the exercises to suit the adaptation request.
Return JSON:
{
  "title": "string",
  "adaptationNote": "string",
  "exercises": [{"name": "string", "targetMuscle": "string", "equipmentRequired": "string", "targetSets": 3, "targetReps": 10, "targetWeightKg": 0, "notes": "string"}]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());

          if (uid) {
            const todayStr = new Date().toISOString().split('T')[0];
            const exercises = (parsed.exercises || []).map((ex: any, idx: number) => {
              const sets = Array.from({ length: ex.targetSets || 3 }).map((_, sIdx) => ({
                setNumber: sIdx + 1,
                targetReps: ex.targetReps || 10,
                targetWeightKg: ex.targetWeightKg || 0,
                completed: false
              }));
              return {
                id: `adapt_ex_${idx + 1}_${Date.now()}`,
                name: ex.name || `Exercise ${idx + 1}`,
                targetMuscle: ex.targetMuscle || 'Full Body',
                equipmentRequired: ex.equipmentRequired || 'bodyweight',
                sets: sets,
                notes: ex.notes || ''
              };
            });
            await admin.firestore().collection("users").doc(uid).collection("workouts").doc(todayStr).set({
              title: parsed.title || "Adapted Workout",
              status: "adapted",
              adaptationNote: parsed.adaptationNote || adaptationRequest,
              exercises: exercises,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
          }

          res.status(200).json(parsed);
          return;
        }

        case "generateEngineDailyInsight": {
          const prompt = `Write a short, punchy, 1-sentence daily insight for the user based on their context:
${compressedMemory}
Keep it warm, encouraging, plain English, and action-focused.`;
          const result = await executeGeminiCall(apiKey, prompt, false);
          res.status(200).json({ insight: result.text.trim() });
          return;
        }

        case "generateAIInitialWorkout": {
          const profile = effectiveState?.profile || {};
          const prompt = `You are an elite fitness coach designing an initial 1-day workout for a new client.
Client: ${profile.name || 'Client'}, Goal: ${profile.goal || 'general'}, Equipment: ${(profile.equipmentList || []).map((e: any) => e.name).join(", ")}

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
            const todayStr = new Date().toISOString().split('T')[0];
            const exercises = (parsed.exercises || []).map((ex: any, idx: number) => {
              const sets = Array.from({ length: ex.targetSets || 3 }).map((_, sIdx) => ({
                setNumber: sIdx + 1,
                targetReps: ex.targetReps || 10,
                targetWeightKg: ex.targetWeightKg || 0,
                completed: false
              }));
              return {
                id: `init_ex_${idx + 1}_${Date.now()}`,
                name: ex.name || `Exercise ${idx + 1}`,
                targetMuscle: ex.targetMuscle || 'Full Body',
                equipmentRequired: ex.equipmentRequired || 'bodyweight',
                sets: sets,
                notes: ex.notes || ''
              };
            });
            const workoutDoc = {
              id: `w_${Date.now()}`,
              date: todayStr,
              title: parsed.title || 'Initial Plan',
              focusArea: parsed.focusArea || 'Full Body',
              estimatedDurationMin: parsed.estimatedDurationMin || 45,
              status: "scheduled",
              exercises: exercises,
              adaptationNote: parsed.adaptationNote || 'Ready to start.',
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            await admin.firestore().collection("users").doc(uid).collection("workouts").doc(todayStr).set(workoutDoc, { merge: true });
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

