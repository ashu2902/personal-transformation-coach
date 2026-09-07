/**
 * Gemini API client with resilient multi-model fallback chain and prompt injection sanitizer.
 */

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Prompt injection sanitizer to prevent instruction overriding.
 */
export function sanitizeUserPrompt(input: string): string {
  if (!input) return "";
  return input
    .replace(/```/g, "'''")
    .replace(/(?:SYSTEM INSTRUCTION|SYSTEM PROMPT|IGNORE ALL PREVIOUS INSTRUCTIONS|YOU ARE NOW|ADMIN MODE)/gi, "[redacted]");
}

/**
 * Call Gemini API with automated retry and candidate model fallback.
 */
export async function executeGeminiCall(
  apiKey: string,
  prompt: string,
  isJson: boolean = false,
  imageBase64?: string,
  mimeType?: string
): Promise<{ text: string; model: string }> {
  const candidateModels = [
    "gemini-2.5-flash-lite",
    "gemini-2.5-flash",
    "gemini-2.0-flash",
    "gemini-1.5-flash",
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

  throw new Error(`All Gemini models in fallback chain failed (${lastStatus}): ${lastError}`);
}
