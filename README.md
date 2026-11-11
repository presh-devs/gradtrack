# gradll

Graduate school application tracker: deadlines (in each university's time zone), checklists, recommendation letters, professor follow-ups and a daily digest. Flutter Web PWA + Supabase.

Spec: [docs/spec/README.md](docs/spec/README.md)

## Run

Against Supabase (needs `env.json`, see below):

```bash
flutter run -d chrome --dart-define-from-file=env.json --web-port 8080
```

Keep `--web-port 8080`: that's the port in Supabase's allowed redirect URLs, so magic links come back to the app. In VS Code, use the **gradll (Supabase)** launch configuration. Without the `--dart-define-from-file`, the app falls back to demo data and logs a warning.

Demo mode (no backend, sample data, any email signs you in):

```bash
flutter run -d chrome --dart-define=GT_DEMO=true
```

First-time Supabase setup: [docs/setup/supabase.md](docs/setup/supabase.md).

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

Deploy to Cloudflare Pages ([docs/setup/deploy.md](docs/setup/deploy.md) has the one-time setup):

```bash
tool/deploy_web.sh
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
