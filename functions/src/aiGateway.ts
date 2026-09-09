/**
 * AURA Multi-Model AI Gateway
 *
 * Routes incoming AI commands across high-capability free-tier models via OpenRouter:
 * - The Supporter: DeepSeek V3 (empathy, rapport, validation)
 * - The Pro: Meta Llama 3.3 70B (direct accountability, structured execution)
 * - The Teacher: Qwen 2.5 72B (biomechanics, metabolic explanations)
 * - Deep Reasoning: DeepSeek R1 (weekly plan generation & cross-domain debriefs)
 * - Multimodal: Gemini 2.0 Flash (instant food & workout photo recognition)
 *
 * Employs automatic cross-provider failover and seamlessly falls back to direct
 * Google Gemini API if OpenRouter keys are not configured or rate-limited.
 */

import { executeGeminiCall, sanitizeUserPrompt } from "./gemini";

export type CoachSoulType = "supporter" | "pro" | "teacher";

export type AiTaskType = "chat" | "reasoning" | "vision" | "action" | "general";

export interface AiGatewayOptions {
  prompt: string;
  systemInstruction?: string;
  isJson?: boolean;
  soul?: CoachSoulType;
  taskType?: AiTaskType;
  imageBase64?: string;
  mimeType?: string;
  openrouterApiKey?: string;
  geminiApiKey: string;
  preferredGeminiModel?: string;
}

export interface AiGatewayResult {
  text: string;
  model: string;
  provider: "openrouter" | "gemini";
}

/**
 * Strips reasoning tokens (<think>...</think>) produced by reasoning models like DeepSeek R1.
 */
export function stripReasoningTokens(rawText: string): string {
  if (!rawText) return "";
  return rawText.replace(/<think>[\s\S]*?<\/think>/gi, "").trim();
}

/**
 * Extracts and cleans JSON from raw LLM output, removing markdown fences or leading/trailing prose.
 */
export function extractCleanJson(rawText: string): string {
  if (!rawText) return "";
  let text = stripReasoningTokens(rawText);
  // Remove markdown code fences
  text = text.replace(/```json\s*/gi, "").replace(/```\s*/g, "").trim();
  const jsonMatch = text.match(/(\{[\s\S]*\}|\[[\s\S]*\])/);
  if (jsonMatch) {
    return jsonMatch[0].trim();
  }
  return text.trim();
}

/**
 * Resolves the optimal free-tier candidate models for a given task and coach persona.
 */
export function resolveFreeModelHierarchy(options: {
  taskType?: AiTaskType;
  soul?: CoachSoulType;
  hasImage?: boolean;
}): string[] {
  // If an image is provided, route to verified multimodal omni models
  if (options.hasImage) {
    return [
      "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free", // Verified text+image->text omni model (~1.7s)
      "google/gemma-4-31b-it:free",
      "google/gemma-4-26b-a4b-it:free",
    ];
  }

  // Complex reasoning tasks: Periodization, Weekly Plan, Cross-Domain Debriefs
  if (options.taskType === "reasoning") {
    return [
      "nvidia/nemotron-3-super-120b-a12b:free",
      "nvidia/nemotron-3-ultra-550b-a55b:free",
      "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
    ];
  }

  // Fast, conversational coaching models verified for low latency & strict JSON adherence
  return [
    "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free", // ~1.7s response, 30B parameter, omni reasoning
    "nvidia/nemotron-3-super-120b-a12b:free", // 120B parameter MoE high precision
    "nvidia/nemotron-3.5-lightning:free", // 1M context fast fallback
  ];
}

/**
 * Executes an AI call through the OpenRouter multi-model gateway with automatic Gemini fallback.
 */
export async function executeAiGatewayCall(options: AiGatewayOptions): Promise<AiGatewayResult> {
  const {
    prompt,
    systemInstruction,
    isJson = false,
    soul,
    taskType = "general",
    imageBase64,
    mimeType,
    openrouterApiKey,
    geminiApiKey,
    preferredGeminiModel,
  } = options;

  const hasImage = !!(imageBase64 && imageBase64.trim().length > 0);

  // If OpenRouter key is available, attempt multi-model routing
  if (openrouterApiKey && openrouterApiKey.trim().length > 0) {
    const candidateModels = resolveFreeModelHierarchy({ taskType, soul, hasImage });

    try {
      const messages: any[] = [];
      if (systemInstruction) {
        messages.push({ role: "system", content: systemInstruction });
      }

      if (hasImage) {
        messages.push({
          role: "user",
          content: [
            { type: "text", text: prompt },
            {
              type: "image_url",
              image_url: {
                url: `data:${mimeType || "image/jpeg"};base64,${imageBase64}`,
              },
            },
          ],
        });
      } else {
        messages.push({ role: "user", content: prompt });
      }

      // Explicit generous token budget: 4000 for 7-day plans/reasoning, 2500 for chat/actions
      const maxTokens = taskType === "reasoning" ? 4000 : 2500;

      const requestBody: Record<string, any> = {
        models: candidateModels,
        messages,
        max_tokens: maxTokens,
        temperature: taskType === "reasoning" || isJson ? 0.2 : 0.7,
      };

      if (isJson) {
        requestBody.response_format = { type: "json_object" };
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 45000); // 45-second gateway timeout

      const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${openrouterApiKey.trim()}`,
          "HTTP-Referer": "https://aura-wellness.app",
          "X-Title": "AURA Adaptive Coach",
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        const data: any = await response.json();
        const rawContent = data?.choices?.[0]?.message?.content || data?.choices?.[0]?.message?.reasoning || "";
        const modelUsed = data?.model || candidateModels[0];

        let finalContent = stripReasoningTokens(rawContent);
        if (isJson) {
          finalContent = extractCleanJson(finalContent);
          // Verify JSON integrity before declaring success; if invalid, trigger fallback
          try {
            JSON.parse(finalContent);
          } catch (parseErr) {
            console.warn(
              `[AI GATEWAY WARNING] OpenRouter model ${modelUsed} returned non-parsable JSON: ${parseErr}. Content preview: "${finalContent.slice(0, 100)}...". Falling back to Gemini API.`
            );
            throw new Error(`OpenRouter model ${modelUsed} returned invalid JSON: ${parseErr}`);
          }
        }

        return {
          text: finalContent,
          model: modelUsed,
          provider: "openrouter",
        };
      }

      const errorText = await response.text();
      console.warn(
        `[AI GATEWAY WARNING] OpenRouter returned status ${response.status}: ${errorText}. Falling back to Gemini API.`
      );
    } catch (orErr: any) {
      console.warn(`[AI GATEWAY WARNING] OpenRouter request failed: ${orErr?.message || orErr}. Falling back to Gemini API.`);
    }
  }

  // Graceful Fallback: Call direct Gemini API
  console.log(`[AI GATEWAY] Routing via direct Google Gemini API (preferred=${preferredGeminiModel || "default"}).`);
  const fullPrompt = systemInstruction ? `${systemInstruction}\n\n${prompt}` : prompt;
  const geminiResult = await executeGeminiCall(
    geminiApiKey,
    fullPrompt,
    isJson,
    imageBase64,
    mimeType,
    preferredGeminiModel
  );

  let cleanText = geminiResult.text;
  if (isJson) {
    cleanText = extractCleanJson(cleanText);
  }

  return {
    text: cleanText,
    model: geminiResult.model,
    provider: "gemini",
  };
}

export { sanitizeUserPrompt };
