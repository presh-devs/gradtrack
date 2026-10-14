# GradTrack

Graduate school application tracker: deadlines (in each university's time zone), checklists, recommendation letters, professor follow-ups and a daily digest. Flutter Web PWA + Supabase.

Spec: [docs/spec/README.md](docs/spec/README.md)

## Run

Demo mode (no backend, in-memory sample data — any email signs you in):

```bash
flutter run -d chrome
```

Against Supabase (first-time setup: [docs/setup/supabase.md](docs/setup/supabase.md)):

```bash
cp env.example.json env.json
```

Fill in the project URL and publishable key, then:

```bash
tool/run_web.sh
```

Database migrations live in `supabase/migrations/`:

```bash
supabase db push
```

## Develop

```bash
dart run build_runner watch
```

```bash
flutter analyze && flutter test
```

Static preview of a release build (SPA fallback so deep links work):

```bash
flutter build web --release && python3 tool/serve_web.py 8080
```

## Layout

```
lib/
  app/        router (go_router), responsive shell, MaterialApp
  core/       env, backend switch, theme (Innixx tokens, Satoshi, Iconsax), time, shared widgets, demo store
  features/<feature>/
    domain/        entities (freezed) + repository interfaces — no Flutter/Supabase imports
    data/          Supabase + demo implementations, repository providers
    presentation/  Riverpod controllers (AsyncNotifier) and screens
supabase/migrations/   schema, RLS, attention feed, digest
```
