import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Secure Gemini Proxy Endpoint for AURA Coach.
 * Holds GEMINI_API_KEY strictly in Cloud Secret Manager.
 * Features automatic multi-model failover and resilience against transient upstream 503/429 spikes.
 */
export const callGeminiProxy = onRequest(
  {
    secrets: [geminiApiKey],
    cors: true,
    maxInstances: 20,
    invoker: "public",
  },
  async (req, res) => {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
      res.status(204).send("");
      return;
    }

    res.set("Access-Control-Allow-Origin", "*");

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed. Use POST." });
      return;
    }

    try {
      const { prompt, model, isJson, imageBase64, mimeType } = req.body || {};

      if (!prompt || typeof prompt !== "string" || prompt.trim().length === 0) {
        res.status(400).json({ error: "Missing or invalid 'prompt' field." });
        return;
      }

      if (prompt.length > 50000) {
        res.status(413).json({ error: "Prompt payload exceeds maximum allowed size (50,000 chars)." });
        return;
      }

      const apiKey = geminiApiKey.value();
      if (!apiKey) {
        res.status(500).json({ error: "Server Gemini API key secret is not configured." });
        return;
      }

      const requestedModel = model || "gemini-2.0-flash";
      // Multi-tier model fallback hierarchy
      const candidateModels = Array.from(
        new Set([requestedModel, "gemini-2.0-flash", "gemini-2.0-flash-lite", "gemini-3.7-flash"])
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
        contents: [
          {
            parts,
          },
        ],
      };

      if (isJson) {
        requestBody.generationConfig = {
          responseMimeType: "application/json",
        };
      }

      let lastError: string | null = null;
      let lastStatus = 500;

      for (let i = 0; i < candidateModels.length; i++) {
        const targetModel = candidateModels[i];
        const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${targetModel}:generateContent?key=${apiKey}`;

        try {
          console.log(`[GEMINI PROXY] Attempting inference with model: ${targetModel}`);
          const response = await fetch(geminiEndpoint, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(requestBody),
          });

          if (response.ok) {
            const data: any = await response.json();
            const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

            res.status(200).json({
              text: rawText,
              model: targetModel,
            });
            return;
          }

          lastStatus = response.status;
          lastError = await response.text();
          console.warn(`[GEMINI PROXY] Model ${targetModel} failed with status ${response.status}: ${lastError}. Attempting fallback...`);

          if (response.status === 400) {
            res.status(400).json({ error: "Gemini API bad request", details: lastError });
            return;
          }

          // Backoff before trying next model in chain
          if (i < candidateModels.length - 1) {
            await sleep(350);
          }
        } catch (fetchErr: any) {
          console.warn(`[GEMINI PROXY] Network error invoking ${targetModel}:`, fetchErr?.message);
          lastError = fetchErr?.message ?? "Network error";
          if (i < candidateModels.length - 1) {
            await sleep(350);
          }
        }
      }

      // If all models failed
      res.status(lastStatus).json({
        error: "All Gemini models in fallback chain were unavailable",
        details: lastError,
      });
    } catch (error: any) {
      console.error("[GEMINI PROXY] Internal error:", error);
      res.status(500).json({ error: "Internal server error", message: error?.message });
    }
  }
);
