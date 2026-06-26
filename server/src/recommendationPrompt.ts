import { z } from 'zod';

const canonicalDimensions = ['health', 'career', 'finance', 'social', 'mind', 'home', 'growth', 'leisure'] as const;

const scoreSchema = z.object({
  type: z.string(),
  score: z.number(),
  baseline: z.number().optional(),
  note: z.string().optional(),
});

const answerSchema = z.object({
  dimension: z.string(),
  rating: z.number(),
  transcript: z.string().max(12000),
  createdAt: z.string(),
});

export const recommendationsRequestSchema = z.object({
  scores: z.array(scoreSchema).min(1).max(8),
  answers: z.array(answerSchema).max(120).default([]),
});

type RecommendationsRequest = z.infer<typeof recommendationsRequestSchema>;

export function buildRecommendationPrompt(input: RecommendationsRequest): string {
  return JSON.stringify(
    {
      task:
        'Generate the top 3 life-balance recommendations for a Flutter app. Focus on dimensions below baseline or with low user rating. Suggestions must be actionable today and low-risk.',
      canonicalDimensions,
      requiredJsonShape: {
        recommendations: [
          {
            dimension: 'health | career | finance | social | mind | home | growth | leisure',
            score: 'integer 0-100 matching urgency/score display',
            title: 'short card title',
            reason: 'specific explanation grounded in scores and answer transcripts',
            suggestions: ['2-4 concrete low-risk actions'],
            ctaLabel: 'short imperative button label',
          },
        ],
      },
      safetyRules: [
        'Do not diagnose health or mental-health conditions.',
        'Do not provide investment, legal, medical, or therapy instructions.',
        'If finance is low, recommend visibility and budgeting reflection, not investment products.',
        'If health or mind is low, recommend habits and support-seeking, not clinical claims.',
      ],
      scores: normalizeScores(input.scores),
      dimensionHistory: buildDimensionHistory(input.answers),
      recentAnswers: input.answers.slice(-24).map((answer) => ({
        ...answer,
        transcript: truncate(answer.transcript, 1800),
      })),
    },
    null,
    2,
  );
}

export function buildDimensionHistory(answers: RecommendationsRequest['answers']) {
  return canonicalDimensions.map((dimension) => {
    const dimensionAnswers = answers.filter((answer) => answer.dimension === dimension);
    const latest = dimensionAnswers.at(-1);
    return {
      dimension,
      savedUpdates: dimensionAnswers.length,
      latest: latest
        ? {
            rating: latest.rating,
            createdAt: latest.createdAt,
            transcript: truncate(latest.transcript, 1800),
          }
        : null,
      previousUpdates: dimensionAnswers.slice(-5, -1).map((answer) => ({
        rating: answer.rating,
        createdAt: answer.createdAt,
        transcript: truncate(answer.transcript, 900),
      })),
    };
  });
}

export function normalizeScores(scores: RecommendationsRequest['scores']): RecommendationsRequest['scores'] {
  return canonicalDimensions.map((dimension) => {
    const score = scores.find((item) => item.type === dimension);
    return score ?? { type: dimension, score: 6, baseline: 7, note: '' };
  });
}

function truncate(value: string, maxLength: number): string {
  if (value.length <= maxLength) return value;
  return `${value.slice(0, maxLength - 15).trimEnd()} [truncated]`;
}
