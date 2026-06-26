# Balance AI MiniMax Proxy

Node/Express backend proxy for Flutter. It keeps MiniMax API keys out of the mobile/web client and validates model responses before returning recommendations to Flutter.

```powershell
Copy-Item ..\.env.example .env
npm install
npm run dev
```

Environment variables:

- `MINIMAX_API_KEY`: required server-side secret.
- `MINIMAX_API`: `anthropic-messages` for the MiniMax Anthropic-compatible API, or `openai-chat` for OpenAI-style chat completions.
- `MINIMAX_BASE_URL`: use `https://api.minimax.io/anthropic` with `anthropic-messages`.
- `MINIMAX_MODEL`: defaults to `MiniMax/M2.7` for `anthropic-messages`.
- `PORT`: defaults to `8787`.

Endpoints:

- `GET /health`
- `POST /api/recommendations`

The recommendation endpoint receives Flutter scores and saved assessment history, groups history by dimension, calls MiniMax, and returns schema-validated recommendations.
