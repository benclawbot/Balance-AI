import { z } from 'zod';

const SYSTEM_PROMPT =
  'You are Balance AI, a practical life-balance assistant. Return only valid JSON. Do not give medical, legal, or financial advice. Use low-risk behavioral suggestions.';

const miniMaxApiSchema = z.enum(['anthropic-messages', 'openai-chat']);

export const recommendationResponseSchema = z.object({
  recommendations: z.array(
    z.object({
      dimension: z.enum(['health', 'career', 'finance', 'social', 'mind', 'home', 'growth', 'leisure']),
      score: z.number().int().min(0).max(100),
      title: z.string().min(3).max(80),
      reason: z.string().min(20).max(600),
      suggestions: z.array(z.string().min(5).max(140)).min(2).max(4),
      ctaLabel: z.string().min(3).max(40),
    }),
  ).min(1).max(3),
});

export type RecommendationResponse = z.infer<typeof recommendationResponseSchema>;

export interface MiniMaxConfig {
  api: z.infer<typeof miniMaxApiSchema>;
  apiKey?: string;
  baseUrl: string;
  model: string;
}

export function readMiniMaxConfig(env: NodeJS.ProcessEnv = process.env): MiniMaxConfig {
  const baseUrl = env.MINIMAX_BASE_URL ?? 'https://api.minimax.io/v1';
  const api = miniMaxApiSchema.catch(inferMiniMaxApi(baseUrl)).parse(env.MINIMAX_API);

  return {
    api,
    apiKey: env.MINIMAX_API_KEY,
    baseUrl,
    model: env.MINIMAX_MODEL ?? (api === 'anthropic-messages' ? 'MiniMax/M2.7' : 'MiniMax-M2.7'),
  };
}

export function inferMiniMaxApi(baseUrl: string): MiniMaxConfig['api'] {
  return baseUrl.toLowerCase().includes('/anthropic') ? 'anthropic-messages' : 'openai-chat';
}

export async function generateRecommendationsFromMiniMax(prompt: string, config: MiniMaxConfig): Promise<RecommendationResponse> {
  if (!config.apiKey) {
    throw new Error('MINIMAX_API_KEY is not configured');
  }

  const content = config.api === 'anthropic-messages'
    ? await requestAnthropicMessages(prompt, config)
    : await requestOpenAiChat(prompt, config);

  return parseRecommendationContent(content);
}

export function parseRecommendationContent(content: string): RecommendationResponse {
  const jsonText = stripJsonFence(content);
  return recommendationResponseSchema.parse(JSON.parse(jsonText));
}

function stripJsonFence(content: string): string {
  return content
    .trim()
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```$/i, '')
    .trim();
}

async function requestAnthropicMessages(prompt: string, config: MiniMaxConfig): Promise<string> {
  const response = await postJson(`${trimSlash(config.baseUrl)}/v1/messages`, {
    accept: 'application/json',
    'content-type': 'application/json',
    'x-api-key': config.apiKey ?? '',
    'anthropic-version': '2023-06-01',
  }, {
    model: config.model,
    max_tokens: 1400,
    temperature: 0.4,
    system: SYSTEM_PROMPT,
    messages: [{ role: 'user', content: prompt }],
  });

  const textBlocks = z.object({
    content: z.array(z.object({
      type: z.string(),
      text: z.string().optional(),
    })),
  }).parse(response).content;

  return textBlocks.map((block) => block.text ?? '').join('\n').trim();
}

async function requestOpenAiChat(prompt: string, config: MiniMaxConfig): Promise<string> {
  const response = await postJson(`${trimSlash(config.baseUrl)}/chat/completions`, {
    accept: 'application/json',
    authorization: `Bearer ${config.apiKey}`,
    'content-type': 'application/json',
  }, {
    model: config.model,
    temperature: 0.4,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
  });

  return z.object({
    choices: z.array(z.object({
      message: z.object({ content: z.string().nullable() }),
    })),
  }).parse(response).choices[0]?.message.content?.trim() ?? '';
}

async function postJson(url: string, headers: Record<string, string>, body: unknown): Promise<unknown> {
  const response = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`MiniMax request failed (${response.status}): ${text.slice(0, 240)}`);
  }
  return JSON.parse(text) as unknown;
}

function trimSlash(value: string): string {
  return value.replace(/\/+$/, '');
}
