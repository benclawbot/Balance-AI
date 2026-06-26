import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

import { generateRecommendationsFromMiniMax, readMiniMaxConfig } from './minimax.js';
import { buildRecommendationPrompt, recommendationsRequestSchema } from './recommendationPrompt.js';

dotenv.config();

const app = express();
const port = Number(process.env.PORT ?? 8787);
const minimaxConfig = readMiniMaxConfig();

app.use(cors());
app.use(express.json({ limit: '768kb' }));

app.get('/health', (_req, res) => {
  res.json({ ok: true, api: minimaxConfig.api, model: minimaxConfig.model });
});

app.post('/api/recommendations', async (req, res) => {
  const parsed = recommendationsRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Invalid request', details: parsed.error.flatten() });
  }
  if (!minimaxConfig.apiKey) {
    return res.status(503).json({ error: 'MINIMAX_API_KEY is not configured' });
  }

  const prompt = buildRecommendationPrompt(parsed.data);

  try {
    const recommendations = await generateRecommendationsFromMiniMax(prompt, minimaxConfig);
    if (recommendations.recommendations.length === 0) {
      return res.status(502).json({ error: 'MiniMax returned an empty response' });
    }
    return res.json(recommendations);
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    return res.status(502).json({ error: 'MiniMax recommendation generation failed' });
  }
});

app.listen(port, () => {
  console.log(`Balance AI MiniMax proxy listening on :${port}`);
  console.log(`Using ${minimaxConfig.api}: ${minimaxConfig.model}`);
});
