import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

/**
 * Secure Gemini Proxy Endpoint for AURA Coach.
 * Holds GEMINI_API_KEY strictly in Cloud Secret Manager.
 * Validates request payload and invokes Gemini API server-to-server.
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

      const targetModel = model || "gemini-3.7-flash";
      const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${targetModel}:generateContent?key=${apiKey}`;

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

      const response = await fetch(geminiEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        console.error(`[GEMINI PROXY] Gemini API error: ${response.status}`, errorBody);
        res.status(response.status).json({ error: "Gemini API error", details: errorBody });
        return;
      }

      const data: any = await response.json();
      const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

      res.status(200).json({
        text: rawText,
        model: targetModel,
      });
    } catch (error: any) {
      console.error("[GEMINI PROXY] Internal error:", error);
      res.status(500).json({ error: "Internal server error", message: error?.message });
    }
  }
);
