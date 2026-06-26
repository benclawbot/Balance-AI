import assert from 'node:assert/strict';
import test from 'node:test';

import { inferMiniMaxApi, parseRecommendationContent, readMiniMaxConfig } from './minimax.js';
import {
  buildDimensionHistory,
  buildRecommendationPrompt,
  normalizeScores,
  recommendationsRequestSchema,
} from './recommendationPrompt.js';

test('infers Anthropic-compatible MiniMax API from Pi base URL', () => {
  assert.equal(inferMiniMaxApi('https://api.minimax.io/anthropic'), 'anthropic-messages');
});

test('uses Pi-compatible defaults for Anthropic MiniMax config', () => {
  const config = readMiniMaxConfig({
    MINIMAX_API: 'anthropic-messages',
    MINIMAX_BASE_URL: 'https://api.minimax.io/anthropic',
  });

  assert.equal(config.api, 'anthropic-messages');
  assert.equal(config.model, 'MiniMax/M2.7');
});

test('parses fenced recommendation JSON from model output', () => {
  const content = [
    '```json',
    '{',
    '  "recommendations": [',
    '    {',
    '      "dimension": "health",',
    '      "score": 72,',
    '      "title": "Protect your energy",',
    '      "reason": "Your health score is below baseline, so a small routine change is the safest first improvement.",',
    '      "suggestions": ["Take a ten minute walk today", "Set a consistent bedtime reminder"],',
    '      "ctaLabel": "Start small"',
    '    }',
    '  ]',
    '}',
    '```',
  ].join('\n');

  const parsed = parseRecommendationContent(content);

  assert.equal(parsed.recommendations[0].dimension, 'health');
});

test('normalizes incomplete score payloads to all canonical dimensions', () => {
  const scores = normalizeScores([{ type: 'health', score: 4, baseline: 7, note: 'Tired' }]);

  assert.equal(scores.length, 8);
  assert.equal(scores[0].type, 'health');
  assert.equal(scores[0].score, 4);
  assert.equal(scores[1].type, 'career');
  assert.equal(scores[1].score, 6);
});

test('accepts longer assessment histories while bounding prompt transcripts', () => {
  const parsed = recommendationsRequestSchema.parse({
    scores: [{ type: 'health', score: 4, baseline: 7 }],
    answers: [
      {
        dimension: 'health',
        rating: 4,
        transcript: 'x'.repeat(5000),
        createdAt: new Date('2026-06-26T18:00:00.000Z').toISOString(),
      },
    ],
  });

  const prompt = JSON.parse(buildRecommendationPrompt(parsed)) as {
    scores: unknown[];
    recentAnswers: Array<{ transcript: string }>;
  };

  assert.equal(prompt.scores.length, 8);
  assert.equal(prompt.recentAnswers.length, 1);
  assert.ok(prompt.recentAnswers[0].transcript.length < 1900);
  assert.match(prompt.recentAnswers[0].transcript, /\[truncated\]$/);
});

test('groups saved history by dimension for context-dependent recommendations', () => {
  const history = buildDimensionHistory([
    {
      dimension: 'health',
      rating: 4,
      transcript: 'Afternoons are low energy.',
      createdAt: new Date('2026-06-25T18:00:00.000Z').toISOString(),
    },
    {
      dimension: 'health',
      rating: 6,
      transcript: 'Morning walks helped but sleep is still inconsistent.',
      createdAt: new Date('2026-06-26T18:00:00.000Z').toISOString(),
    },
    {
      dimension: 'career',
      rating: 5,
      transcript: 'Too many context switches.',
      createdAt: new Date('2026-06-26T19:00:00.000Z').toISOString(),
    },
  ]);

  const health = history.find((item) => item.dimension === 'health');
  const career = history.find((item) => item.dimension === 'career');

  assert.equal(health?.savedUpdates, 2);
  assert.equal(health?.latest?.rating, 6);
  assert.match(health?.latest?.transcript ?? '', /Morning walks/);
  assert.equal(health?.previousUpdates.length, 1);
  assert.equal(career?.savedUpdates, 1);
});
