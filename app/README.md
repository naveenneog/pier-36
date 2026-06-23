# app — Pier 36 (Flutter)

This package ships **Dart source only**. Platform folders (`android/`, `ios/`, …) are generated locally so the
repo stays lean until you build.

## First run
```bash
cd app
flutter create . --platforms=android,ios --org com.pier36   # generate platform folders
flutter pub get
dart format .            # CI enforces formatting
flutter analyze          # CI enforces lints
flutter test             # unit + widget
flutter run              # boots into the mock feed
```

## Architecture
Clean Architecture, feature-first:
```
lib/
  core/            router, network, errors, env
  design_system/   tokens, gradients, theme, shared widgets  ← the "Fresh Stories" UI kit
  features/
    feed/   { domain, data, presentation }   ← Reels/Stories feed (mock data for now)
    seed/   { data, presentation }           ← Startup Seed (AI-figures starter packs)
```

- **State/DI:** Riverpod (plain providers; code-gen can be added later).
- **Navigation:** go_router (`/feed`, `/seed`).
- **Data:** mock repositories now; swap to Supabase + Worker API when the backend lands.

## Tests
- `test/design_system/` — gradient mapping.
- `test/features/feed/` — controller logic + StoryCard widget.
- `integration_test/` — app boot smoke test (run with `flutter test integration_test`).
