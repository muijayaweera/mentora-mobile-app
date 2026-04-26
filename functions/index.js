require("dotenv").config();

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const OpenAI = require("openai");

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

exports.chatWithMentoraV2 = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request) => {
    const data = request.data || {};
    const message = (data.message || "").trim();

    if (!message) {
      throw new HttpsError("invalid-argument", "Message is required.");
    }

    if (message.length > 1000) {
      throw new HttpsError("invalid-argument", "Message is too long.");
    }

    try {
      const response = await client.responses.create({
        model: "gpt-4.1-mini",
        input: [
          {
            role: "system",
            content: `
You are Mentora, an educational ostomy training assistant for nurses.

Rules:
- Answer ONLY questions related to ostomy, stoma care, pouching, peristomal skin care, common ostomy complications, and ostomy nursing education.
- If the question is unrelated, politely refuse and say you can only help with ostomy-related training topics.
- Do NOT diagnose with certainty.
- Do NOT replace a doctor, surgeon, or wound/ostomy care specialist.
- If the user describes urgent danger signs, advise prompt review by a qualified clinician.
- Keep answers clear, supportive, and educational.
- Prefer short paragraphs in plain text.
`,
          },
          {
            role: "user",
            content: message,
          },
        ],
        max_output_tokens: 300,
      });

      const reply =
        response.output_text?.trim() ||
        "Sorry, I couldn’t generate a reply right now.";

      return { reply };
    } catch (error) {
      logger.error("chatWithMentoraV2 failed", {
        message: error.message,
        status: error.status,
        code: error.code,
        type: error.type,
      });

      throw new HttpsError(
        "internal",
        error.message || "Mentora could not respond right now."
      );
    }
  }
);