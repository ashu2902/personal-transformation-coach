import { test, describe } from "node:test";
import assert from "node:assert/strict";
import {
  stripReasoningTokens,
  extractCleanJson,
  resolveFreeModelHierarchy,
  executeAiGatewayCall,
} from "../src/aiGateway";

describe("AURA AI Gateway — OpenRouter Free Models & Fallback Suite", () => {
  describe("Model Resolution Hierarchy", () => {
    test("Routes vision requests to verified multimodal omni free models", () => {
      const models = resolveFreeModelHierarchy({ hasImage: true });
      assert.ok(models.length > 0);
      assert.equal(models[0], "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free");
      assert.equal(models[1], "google/gemma-4-31b-it:free");
    });

    test("Routes reasoning tasks to Nemotron Super 120B reasoning model", () => {
      const models = resolveFreeModelHierarchy({ taskType: "reasoning" });
      assert.equal(models[0], "nvidia/nemotron-3-super-120b-a12b:free");
      assert.ok(models.includes("nvidia/nemotron-3-ultra-550b-a55b:free"));
    });

    test("Routes coaching chat to Nemotron 30B Omni Reasoning (sub-2s, strict JSON)", () => {
      const models = resolveFreeModelHierarchy({ soul: "supporter", taskType: "chat" });
      assert.equal(models[0], "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free");
      assert.ok(models.includes("nvidia/nemotron-3-super-120b-a12b:free"));
    });
  });

  describe("Reasoning Token Stripping & JSON Extraction", () => {
    test("Strips DeepSeek R1 <think>...</think> tags", () => {
      const raw = `<think>
The user is tired and has knee soreness. I should propose adapting squats to leg press.
</think>
{"coachResponse": "Let's take it easy on your knees today.", "commands": []}`;

      const cleaned = stripReasoningTokens(raw);
      assert.ok(!cleaned.includes("<think>"));
      assert.ok(!cleaned.includes("The user is tired"));
      assert.ok(cleaned.includes("coachResponse"));
    });

    test("Extracts JSON wrapped in markdown code fences and reasoning tags", () => {
      const raw = `<think>
Planning response...
</think>
Here is your plan:
\`\`\`json
{
  "targetCalories": 2200,
  "targetProteinG": 160
}
\`\`\`
Let me know if this works!`;

      const json = extractCleanJson(raw);
      const parsed = JSON.parse(json);
      assert.equal(parsed.targetCalories, 2200);
      assert.equal(parsed.targetProteinG, 160);
    });

    test("Extracts JSON array properly", () => {
      const raw = `\`\`\`json
[
  {"name": "Barbell Squat", "targetSets": 3}
]
\`\`\``;
      const json = extractCleanJson(raw);
      const parsed = JSON.parse(json);
      assert.ok(Array.isArray(parsed));
      assert.equal(parsed[0].name, "Barbell Squat");
    });
  });

  describe("Gateway Execution & Fallback Mechanism", () => {
    test("Executes via OpenRouter when API key is provided and succeeds", async () => {
      const originalFetch = globalThis.fetch;
      try {
        // Mock fetch to simulate successful OpenRouter response
        globalThis.fetch = async (url: any, init?: any) => {
          if (String(url).includes("openrouter.ai")) {
            return {
              ok: true,
              status: 200,
              json: async () => ({
                id: "gen-123",
                model: "deepseek/deepseek-chat:free",
                choices: [
                  {
                    message: {
                      role: "assistant",
                      content: JSON.stringify({ coachResponse: "You crushed it today!", commands: [] }),
                    },
                  },
                ],
              }),
            } as any;
          }
          return originalFetch(url, init);
        };

        const result = await executeAiGatewayCall({
          prompt: "I finished my workout!",
          isJson: true,
          soul: "supporter",
          openrouterApiKey: "sk-or-test-key",
          geminiApiKey: "test-gemini-key",
        });

        assert.equal(result.provider, "openrouter");
        assert.equal(result.model, "deepseek/deepseek-chat:free");
        const parsed = JSON.parse(result.text);
        assert.equal(parsed.coachResponse, "You crushed it today!");
      } finally {
        globalThis.fetch = originalFetch;
      }
    });

    test("Falls back to Gemini when OpenRouter returns an error", async () => {
      const originalFetch = globalThis.fetch;
      try {
        // Mock fetch to simulate OpenRouter 429/500 error, followed by successful Gemini API response
        globalThis.fetch = async (url: any, init?: any) => {
          if (String(url).includes("openrouter.ai")) {
            return {
              ok: false,
              status: 429,
              text: async () => "Rate limit exceeded on free pool",
            } as any;
          }
          if (String(url).includes("generativelanguage.googleapis.com")) {
            return {
              ok: true,
              status: 200,
              json: async () => ({
                candidates: [
                  {
                    content: {
                      parts: [{ text: JSON.stringify({ coachResponse: "Fallback response from Gemini", commands: [] }) }],
                    },
                  },
                ],
              }),
            } as any;
          }
          return originalFetch(url, init);
        };

        const result = await executeAiGatewayCall({
          prompt: "Log 300 calories",
          isJson: true,
          soul: "pro",
          openrouterApiKey: "sk-or-test-key",
          geminiApiKey: "test-gemini-key",
        });

        assert.equal(result.provider, "gemini");
        const parsed = JSON.parse(result.text);
        assert.equal(parsed.coachResponse, "Fallback response from Gemini");
      } finally {
        globalThis.fetch = originalFetch;
      }
    });

    test("Falls back to Gemini when OpenRouter returns truncated/invalid JSON", async () => {
      const originalFetch = globalThis.fetch;
      try {
        globalThis.fetch = async (url: any, init?: any) => {
          if (String(url).includes("openrouter.ai")) {
            return {
              ok: true,
              status: 200,
              json: async () => ({
                choices: [
                  {
                    message: {
                      role: "assistant",
                      content: '{"coachResponse": "Truncated mid sentence...', // Missing closing bracket
                    },
                  },
                ],
              }),
            } as any;
          }
          if (String(url).includes("generativelanguage.googleapis.com")) {
            return {
              ok: true,
              status: 200,
              json: async () => ({
                candidates: [
                  {
                    content: {
                      parts: [{ text: JSON.stringify({ coachResponse: "Recovered via Gemini", commands: [] }) }],
                    },
                  },
                ],
              }),
            } as any;
          }
          return originalFetch(url, init);
        };

        const result = await executeAiGatewayCall({
          prompt: "Log 300 calories",
          isJson: true,
          soul: "pro",
          openrouterApiKey: "sk-or-test-key",
          geminiApiKey: "test-gemini-key",
        });

        assert.equal(result.provider, "gemini");
        const parsed = JSON.parse(result.text);
        assert.equal(parsed.coachResponse, "Recovered via Gemini");
      } finally {
        globalThis.fetch = originalFetch;
      }
    });

    test("Directly calls Gemini when OpenRouter API key is missing", async () => {
      const originalFetch = globalThis.fetch;
      try {
        let openRouterCalled = false;
        globalThis.fetch = async (url: any, init?: any) => {
          if (String(url).includes("openrouter.ai")) {
            openRouterCalled = true;
            return { ok: false, status: 500 } as any;
          }
          if (String(url).includes("generativelanguage.googleapis.com")) {
            return {
              ok: true,
              status: 200,
              json: async () => ({
                candidates: [
                  {
                    content: {
                      parts: [{ text: JSON.stringify({ targetCalories: 2100 }) }],
                    },
                  },
                ],
              }),
            } as any;
          }
          return originalFetch(url, init);
        };

        const result = await executeAiGatewayCall({
          prompt: "Generate plan",
          isJson: true,
          soul: "teacher",
          openrouterApiKey: "", // Empty key
          geminiApiKey: "test-gemini-key",
        });

        assert.equal(openRouterCalled, false);
        assert.equal(result.provider, "gemini");
        const parsed = JSON.parse(result.text);
        assert.equal(parsed.targetCalories, 2100);
      } finally {
        globalThis.fetch = originalFetch;
      }
    });
  });
});
