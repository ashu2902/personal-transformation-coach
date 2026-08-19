import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Secure Gemini Proxy Endpoint for AURA Coach.
 * Holds GEMINI_API_KEY strictly in Cloud Secret Manager.
 * Features automated retry on transient 503 capacity spikes and multi-tier model fallback.
 */
export const callGeminiProxy = onRequest(
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
      res.status(401).json({ error: "Unauthorized: Missing or invalid Bearer token in Authorization header." });
      return;
    }

    const idToken = authHeader.split("Bearer ")[1]?.trim();
    if (!idToken) {
      res.status(401).json({ error: "Unauthorized: Malformed Bearer token." });
      return;
    }

    try {
      await admin.auth().verifyIdToken(idToken);
    } catch (authError: any) {
      res.status(401).json({ error: "Unauthorized: Invalid or expired Firebase ID token.", details: authError.message });
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

      // Validate model parameter against strict format to prevent SSRF / Path Traversal
      if (model && (typeof model !== "string" || !/^[a-zA-Z0-9][a-zA-Z0-9.\-]*$/.test(model))) {
        res.status(400).json({ error: "Invalid model identifier format." });
        return;
      }

      // Validate image payload size (max ~5MB base64)
      if (imageBase64 && (typeof imageBase64 !== "string" || imageBase64.length > 5000000)) {
        res.status(413).json({ error: "Image payload exceeds maximum allowed size (5MB base64)." });
        return;
      }

      const apiKey = geminiApiKey.value();
      if (!apiKey) {
        res.status(500).json({ error: "Server Gemini API key secret is not configured." });
        return;
      }

      const requestedModel = model || "gemini-3.6-flash";
      // Active verified candidate models in v1beta
      const candidateModels = Array.from(
        new Set([
          requestedModel,
          "gemini-3.6-flash",
          "gemini-3.5-flash",
          "gemini-3.7-flash",
          "gemini-flash-latest",
          "gemini-pro-latest",
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

      for (const targetModel of candidateModels) {
        const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${targetModel}:generateContent?key=${apiKey}`;

        // Try model with up to 2 retries on 503 / 429 capacity spikes
        for (let attempt = 1; attempt <= 2; attempt++) {
          try {
            console.log(`[GEMINI PROXY] Attempting inference with model: ${targetModel} (Attempt ${attempt})`);
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
            console.warn(`[GEMINI PROXY] Model ${targetModel} attempt ${attempt} returned status ${response.status}: ${lastError}`);

            // Stop immediately on non-transient bad requests (400, 401, 403)
            if (response.status === 400 || response.status === 401 || response.status === 403) {
              res.status(response.status).json({ error: `Gemini API error (${response.status})`, details: lastError });
              return;
            }

            // On 503 or 429 capacity spikes, backoff and retry the same model
            if ((response.status === 503 || response.status === 429) && attempt < 2) {
              await sleep(400);
              continue;
            }

            // If 404 (model ID not found), break inner loop immediately to move to next candidate model
            if (response.status === 404) {
              break;
            }
          } catch (fetchErr: any) {
            console.warn(`[GEMINI PROXY] Network error invoking ${targetModel}:`, fetchErr?.message);
            lastError = fetchErr?.message ?? "Network error";
            if (attempt < 2) {
              await sleep(350);
            }
          }
        }

        // Small delay before moving to next fallback candidate model
        await sleep(150);
      }

      // Dynamic fallback: Query ListModels to find any model available to this key
      try {
        console.log("[GEMINI PROXY] Querying ListModels to discover available models for this key...");
        const listResp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
        const listData: any = await listResp.json();
        if (listData?.models && Array.isArray(listData.models)) {
          const available = listData.models.map((m: any) => m.name);
          console.log(`[GEMINI PROXY] Discovered models:`, available);

          for (const m of listData.models) {
            if (m.supportedGenerationMethods?.includes("generateContent")) {
              const modelName = m.name.replace(/^models\//, "");
              console.log(`[GEMINI PROXY] Attempting inference with discovered model: ${modelName}`);
              const dynResp = await fetch(
                `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`,
                {
                  method: "POST",
                  headers: { "Content-Type": "application/json" },
                  body: JSON.stringify(requestBody),
                }
              );
              if (dynResp.ok) {
                const dynData: any = await dynResp.json();
                const rawText = dynData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
                res.status(200).json({ text: rawText, model: modelName });
                return;
              }
            }
          }
        } else if (listData?.error) {
          lastError = `ListModels response: ${JSON.stringify(listData.error)}`;
        }
      } catch (listErr: any) {
        console.warn("[GEMINI PROXY] Model discovery error:", listErr);
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
