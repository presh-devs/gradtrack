# 01 · Architecture

## System overview

```
 ┌────────────────────────────┐        ┌──────────────────────────────────────────┐
 │ Flutter Web PWA            │  HTTPS │ Supabase                                 │
 │  presentation (Riverpod)   │◀──────▶│  Auth (magic link)                       │
 │  domain (pure Dart)        │        │  PostgREST ──▶ Postgres (RLS on all)     │
 │  data (supabase_flutter)   │        │                 ├ tables                 │
 └────────────────────────────┘        │                 ├ professor_outreach_    │
        static hosting                 │                 │   status (view)        │
   (Cloudflare Pages / Netlify)        │                 ├ attention_feed() (rpc) │
                                       │                 └ pg_cron ─┐             │
                                       │  Edge Function: send-digests ◀┘          │
                                       └──────────────────────┬───────────────────┘
                                                              │
                                                       Resend (email)
```

**Principle:** the client renders and edits. Rules that must agree everywhere — what counts as overdue, how the feed is ranked, what a follow-up state is — live in Postgres (views and functions), so the Today screen and the digest never disagree, and a future mobile app or public API inherits them.

## Flutter layering (feature-first, clean boundaries)

```
lib/
  main.dart                     # bootstrap: env, Supabase.initialize, ProviderScope
  app/
    router.dart                 # go_router, auth redirect, shell routes
    shell.dart                  # NavigationRail (≥ 840 px) / NavigationBar (< 840 px)
    theme.dart
  core/
    env.dart                    # --dart-define values
    supabase.dart               # supabaseClientProvider
    failure.dart                # sealed Failure types
    time/                       # Deadline value object, tz formatting
    widgets/                    # shared: CountdownChip, StatusChip, EmptyState, CopyButton
  features/
    auth/
    applications/               # incl. requirements + checklist UI
    letters/                    # recommenders + letter_requests
    outreach/                   # professors, messages, templates
    tasks/
    attention/                  # Today screen (reads attention_feed rpc)
    import/                     # CSV import wizard
    settings/                   # profile, digest prefs, export
  # each feature:
  #   domain/        entities (freezed), repository interfaces, pure logic
  #   data/          DTOs (json_serializable), Supabase repository impls
  #   presentation/  controllers (Riverpod Notifier/AsyncNotifier), screens, widgets
```

**Dependency rule:** `presentation → domain ← data`. `domain` imports no Flutter and no Supabase. Repositories are interfaces in `domain`, implemented in `data`, wired by providers. This keeps the backend swappable (custom API later) and makes domain logic unit-testable without mocks of Supabase.

Controllers never call `Supabase.instance` directly; screens never call repositories directly.

### Packages

| Concern | Package |
|---|---|
| State / DI | `flutter_riverpod` 3, `riverpod_annotation` + `riverpod_generator` (code-gen) |
| Routing | `go_router` (`StatefulShellRoute`, path URL strategy) |
| Models | `freezed` (domain entities, `copyWith`, equality) |
| Backend | `supabase_flutter` (publishable key) |
| Time zones | `timezone` (IANA db), `intl` |
| Icons | `iconsax_plus` (primary), `hugeicons` (where the Innixx board uses them) |
| Tests | `flutter_test`, `mocktail` |

## State management (Riverpod 3)

Rules used throughout `lib/`:

1. **Repositories are providers** (`keepAlive`). Each switches on `backendProvider` (Supabase or demo), so tests and demo mode override one provider, not call sites.
2. **One `AsyncNotifier` per server collection** (`ApplicationsController`, `TodayController`), `keepAlive: true`. It's the client-side cache: switching tabs never refetches.
3. **Derive, don't refetch.** `applicationById(id)`, `nextDeadline`, `stageCounts`, `filteredApplications` and `todayGroups` `watch` the cached collection. An edit in one place updates every screen, and loading/error states flow through automatically.
4. **Mutations live on the notifier**, applied optimistically: update `state`, call the repository, roll back and rethrow on failure. They then `ref.invalidate` the providers whose server-computed result changed (e.g. a stage change invalidates `todayControllerProvider`).
5. **Every async UI goes through `AsyncValue`.** `AsyncValueView` (or a `switch` on `AsyncValue` patterns) gives a skeleton on first load, keeps data with a progress bar while refreshing, shows an error card when there's no data, and an inline banner when cached data exists.
6. **Form submissions are `AsyncNotifier`s too** (`SignInController`: idle → loading → sent | error), so buttons disable and errors render without local `setState` flags.
7. UI-only state that should survive navigation (stage filter, theme mode) is a small `Notifier`, not widget state.

## Routing (go_router)

- Real URLs for every screen (`/`, `/applications`, `/applications/:id`, `/people`, `/tasks`, `/settings`, `/sign-in`). `usePathUrlStrategy()` removes the `#`. Hosting needs an SPA fallback (`web/_redirects` for Cloudflare Pages / Netlify).
- `StatefulShellRoute.indexedStack`: each tab keeps its own stack and scroll position.
- Auth guard: `routerProvider` bridges `authStatusProvider` into a `ValueNotifier` used as `refreshListenable`, so signing in/out re-runs `redirect` without rebuilding the router. Deep links survive sign-in via `/sign-in?from=/applications/a1`.

## Design system (Innixx v3 → web)

Source: Figma `Innixx-Mobile-v3.0-2026`. Colour palette is node 111:1757, iconography is node 19:754.

- **Type:** Satoshi (bundled in `assets/fonts`, weights 400/500/700/900).
- **Brand colours** (`GtBrand`): indigo `#14005A`, blue `#0166F4`, ink `#06011A`, canvas `#F7F8FC`, sky `#D4F0F7`, mint `#C8F5E4`, coral `#FF7979`, lemon `#FFEE65`.
- **Semantic tokens** (`GtPalette` ThemeExtension, light + dark): read with `context.gt`. Tones (`info/success/warning/danger/neutral/violet`) pair a pastel background with a darker ink, because coral and lemon fail contrast as text.
- **Components:** flat white cards (16 px radius, 1 px border, no shadow), pastel `IconWell` circles, pill `ToneChip`s, blue→indigo gradient hero card (the web take on the Innixx balance card).
- **Icons:** `GtIcons` (semantic names) → `GtGlyph` (Iconsax font glyph or Hugeicons path data) → `GtIcon` widget. Iconsax linear by default, bold for selected nav. Hugeicons for send/search/delete/close/link/user/more, as on the board. Streamline (only support/keyboard icons on the board) isn't needed yet. If it is, export the SVG from Figma.
- **Layout:** bottom `NavigationBar` < 840 px; `NavigationRail` ≥ 840 px (extended with labels ≥ 1200 px); content max width 1200 px.

## Data access patterns

- Lists and details: PostgREST selects with embedded relations, e.g.
  `applications?select=*,institution:institutions(name,country),requirements(status),letter_requests(status)`.
- Today: `rpc('attention_feed', {p_horizon: '14 days'})`.
- Demo mode: no `SUPABASE_URL` → in-memory `DemoStore` with dates relative to now. It covers the same repository interfaces.

## Security

- Auth: Supabase magic link (email). Google sign-in can be added later without schema changes.
- Every table: `owner_id default auth.uid()` + RLS `owner_id = (select auth.uid())`.
- Composite `(id, owner_id)` foreign keys stop cross-user linking (FK checks bypass RLS).
- Service-role-only functions (`attention_feed_for`, `claim_due_digests`) are revoked from `anon`/`authenticated`.
- Never store portal passwords; only `portal_username`.
- The publishable key ships in the web bundle (normal for Supabase); the service key lives only in Edge Function secrets.

## PWA

- `web/manifest.json`: name, short_name `GradTrack`, theme colour, 192/512 and maskable icons, `display: standalone`.
- Online-only with cached reads. No offline writes in MVP-0. Show a clear offline banner.
- Check the current Flutter version's service-worker behaviour at scaffold time. Recent Flutter releases have been moving away from the generated service worker, and it matters for installability and, later, for push.

## Product-readiness seams (cheap now, expensive later)

| Seam | Now | Later |
|---|---|---|
| Tenancy | `owner_id` on every row | Add `workspaces` + memberships; RLS policies change, table shapes mostly don't |
| Enumerations | text + CHECK | Add or remove values with a migration; optional lookup tables for user-configurable stages |
| Institutions | per-user rows | Shared catalogue + per-user overrides |
| Business rules | SQL functions | Same functions back a public API |
| Notifications | `digest_runs` ledger | Generalise to `notification_deliveries` (channel, item, dedupe key) |
| Backend | repository interfaces | Swap Supabase impl for a REST client without touching UI |

## Testing strategy

- **SQL:** run migrations against a local Supabase (`supabase start`) and test RLS, isolation and feed ranking with pgTAP. The scenarios in this spec were checked against PostgreSQL 16.
- **Domain:** pure Dart unit tests (deadline formatting, CSV mapping, template rendering).
- **Controllers:** Riverpod `ProviderContainer` tests with fake repositories.
- **Widgets:** golden tests for Today and the application workspace at 375 px and 1280 px.

## Hosting and cost

- Frontend: Cloudflare Pages or Netlify (free), built with `flutter build web --release`.
- Supabase free tier is enough for one user. Note: free projects are paused after a period of inactivity. Confirm whether scheduled cron activity counts. If the digest becomes critical, the Pro plan removes that risk.
- Resend free tier (≈100 emails/day) covers the digest. Use a verified sending domain, or Resend's test sender while developing.
