# Implementation Notes

## What Is Implemented

- Flutter source project for Balance AI.
- Compact hero banner shared across all app pages.
- Five product screens: Assess, Wheel, Advice, Growth, and Report.
- Eight canonical life dimensions: Health, Career, Finance, Social, Mind, Home, Growth, and Leisure.
- Assessment history persisted locally per dimension.
- Save-and-next assessment flow that restores the latest saved note and rating when a dimension is revisited.
- Multi-color custom-painted life wheel.
- Riverpod state controller with local persistence.
- MiniMax M2.7 backend proxy with schema validation.
- Context-dependent recommendations that use grouped historical updates by dimension.
- Growth actions generated from the active recommendation set.
- Flutter, proxy, and prompt regression tests.

## Verification

Validated locally with:

```powershell
flutter test
cd server
npm test
npm run build
```

The Flutter web build was also generated with:

```powershell
flutter build web --dart-define=BALANCE_API_BASE_URL=http://127.0.0.1:8787
```

Flutter reports WebAssembly dry-run warnings from `flutter_secure_storage_web`, but the normal JavaScript web build succeeds.

## Privacy Defaults

- MiniMax keys stay server-side in `server/.env`.
- The Flutter app calls only the local proxy.
- MiniMax receives dimension scores and saved text history, not raw audio.
- AI failures degrade to deterministic local fallback advice.
