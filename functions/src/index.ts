import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

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

  return `Client ${name} (${gender}, ${age}y, ${weight}kg -> ${targetWeight}kg, goal: ${goal}, coach: ${soul}). Gear: ${equipment}. Joint safeguards: ${injuries}. Recovery: ${sleepH}, ${sore}, ${energy} (${recStatus}). Fuel today: ${totalCal}/${targetCal} kcal (${remCal} left), ${totalProt}/${targetProt}g protein (${remProt}g left). Workout: ${workoutTitle} (${focus}, status: ${workoutStatus}).`;
}

/**
 * Call Gemini API with automated retry and candidate model fallback
 */
async function executeGeminiCall(apiKey: string, prompt: string, isJson: boolean = false, requestedModel?: string, imageBase64?: string, mimeType?: string): Promise<{ text: string; model: string }> {
  const targetModel = requestedModel || "gemini-3.5-flash-lite";
  const candidateModels = Array.from(
    new Set([
      targetModel,
      "gemini-3.5-flash-lite",
      "gemini-3.1-flash-lite",
      "gemini-3.5-flash",
    ])
  );

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
    try {
      await admin.auth().verifyIdToken(idToken);
    } catch (authError: any) {
      res.status(401).json({ error: "Unauthorized: Invalid Firebase ID token.", details: authError.message });
      return;
    }

    const apiKey = geminiApiKey.value();
    if (!apiKey) {
      res.status(500).json({ error: "Server Gemini API key secret is not configured." });
      return;
    }

    const { command, state, message, imageBase64, mimeType, model, history } = req.body || {};

    try {
      const compressedMemory = compressSemanticState(state);
      const soul = state?.profile?.coachSoul || "supporter";

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
          const userPrompt = message || "";
          const imageSection = imageBase64 ? "MULTIMODAL NOTE: An image is attached. If meal, estimate macros and log. If workout display, log completion." : "";

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
- logRecovery: { "sleepHours": number | null, "sleepQuality": number | null, "muscleSoreness": number | null, "energyLevel": number | null }
- logWeight: { "weightKg": number } (ONLY IF user explicitly reported scale weight)
- updateWorkoutStatus: { "status": "completed" | "skipped" }
- updateMealPortion: { "mealName": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number }
- removeMeal: { "mealName": string }
- regenerateWeeklyPlan: {}

Return strictly JSON:
{
  "coachResponse": "Empathetic conversational response directly to client...",
  "actions": [
    { "functionName": "string", "arguments": {} }
  ]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model, imageBase64, mimeType);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "parseLifestyleIntake": {
          const intakeText = message || "";
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
3. Determine if intake is complete (isComplete: true) - true ONLY when both daysPerWeek (2-6) and equipment are firmly established.
4. Generate 2 to 3 contextual quick-reply pills (dynamicQuickReplies) that directly relate to what you just asked in followUpQuestion.

Return strictly JSON:
{
  "isComplete": boolean,
  "daysPerWeek": number,
  "equipment": ["string"],
  "targetPhysique": string or null,
  "missingFields": ["string"],
  "followUpQuestion": "string",
  "dynamicQuickReplies": ["string"]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model);
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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "estimateMeal": {
          const mealDescription = message || "";
          const prompt = `Analyze this food description and estimate macros accurately:
"${mealDescription}"

Return strictly JSON:
{
  "name": "Clean concise meal name",
  "calories": number,
  "proteinG": number,
  "carbsG": number,
  "fatG": number,
  "breakdown": "1-sentence portion and ingredient explanation"
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }


        case "generateMetabolicPlan": {
          const profile = state?.profile || {};
          const prompt = `Calculate optimal daily calories and macros for this person using the Mifflin-St Jeor equation, appropriate gender correction, and goal-based deficit/surplus:
Name: ${profile.name || 'Client'}
Gender: ${profile.gender || 'unspecified'}
Age: ${profile.age || 25} years
Height: ${profile.heightCm || 170} cm
Current Weight: ${profile.weightKg || 70} kg
Target Weight: ${profile.targetWeightKg || 70} kg
Goal: ${profile.goal || 'recomp'} (Target Physique: ${profile.targetPhysique || 'general fitness'})
Training Frequency: ${profile.daysPerWeek || 3} days/week

Apply correct gender-specific BMR formula. Return JSON:
{
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number,
  "targetWaterMl": number,
  "reasoning": "string (1 sentence explaining the calorie target)"
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "synthesizeTodayFocus": {
          const prompt = `Based on the context below, write one action-focused sentence for the client's day:
${compressedMemory}`;
          const result = await executeGeminiCall(apiKey, prompt, false, model);
          res.status(200).json({ focus: result.text.trim() });
          return;
        }

        case "generateAdaptedNutrition": {
          const reason = message || "General adaptation";
          const prompt = `SYSTEM INSTRUCTION:
You are an expert sports nutritionist adapting a client's daily targets based on their feedback/deviation.
Current Context: ${compressedMemory}

User's deviation reason: "${reason}"

Analyze the deviation and adjust the macros ONLY IF biologically necessary. If they missed a meal, maybe bump up protein slightly for the rest of the day, or adjust calories. Keep hydration targets aggressive if they trained hard.
Return JSON:
{
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number,
  "targetWaterMl": number,
  "adaptationReason": "string explaining why targets shifted"
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "generateAdaptedWorkout": {
          const reason = message || "General adaptation";
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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "generateWeeklyPlan": {
          const prompt = `SYSTEM INSTRUCTION:
You are an expert fitness coach generating a 7-day adaptive workout and nutrition schedule.
Client Context: ${compressedMemory}

Design a weekly split matching their training frequency (${state?.profile?.daysPerWeek || 3} days/week). 
For rest days, focus on active recovery and hydration. For training days, assign a specific focus area and 3-5 core exercises.
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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "parseNaturalWorkout": {
          const workoutText = message || "";
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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }


        case "generateCoachResponse": {
          const userPrompt = message || "";
          const prompt = `SYSTEM INSTRUCTION:
${coachToneInstruction}

User Transformation Context:
${compressedMemory}

User Message: ${userPrompt}`;
          const result = await executeGeminiCall(apiKey, prompt, false, model);
          res.status(200).json({ response: result.text.trim() });
          return;
        }

        case "parseQuickLog": {
          const rawText = message || "";
          const prompt = `User Context:
${compressedMemory}

Analyze this natural language daily fitness log entry: "${rawText}"
Scheduled Workout for today: ${state?.workout?.title || 'Unknown'}

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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "adaptWorkoutWithAI": {
          const adaptationRequest = message || "";
          const prompt = `You are an elite strength coach adapting a workout plan.
User Context:
${compressedMemory}

Adaptation Request: "${adaptationRequest}"
Current Workout: ${state?.workout?.title || 'Unknown'}

Modify the exercises to suit the adaptation request.
Return JSON:
{
  "title": "string",
  "adaptationNote": "string",
  "exercises": [{"name": "string", "targetMuscle": "string", "equipmentRequired": "string", "targetSets": 3, "targetReps": 10, "targetWeightKg": 0, "notes": "string"}]
}`;
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
          res.status(200).json(parsed);
          return;
        }

        case "generateEngineDailyInsight": {
          const prompt = `Write a short, punchy, 1-sentence daily insight for the user based on their context:
${compressedMemory}
Keep it warm, encouraging, plain English, and action-focused.`;
          const result = await executeGeminiCall(apiKey, prompt, false, model);
          res.status(200).json({ insight: result.text.trim() });
          return;
        }

        case "generateAIInitialWorkout": {
          const profile = state?.profile || {};
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
          const result = await executeGeminiCall(apiKey, prompt, true, model);
          const parsed = JSON.parse(result.text.replace(/```json/g, "").replace(/```/g, "").trim());
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

