# GradTrack — Technical Specification (MVP-0)

Status: draft v0.1 · 13 Oct 2026
Target: **MVP-0 in daily use by Mon 2 Nov 2026** (Fall 2027 cycle, deadlines Dec–Jan)

## Decisions locked

| # | Decision | Consequence |
|---|---|---|
| D1 | Personal tool now, product later | Single-user UX, but per-user isolation (RLS) and layered architecture from day one. No onboarding, templates marketplace or analytics in MVP-0. |
| D2 | Applying this cycle | Hard date: 2 Nov. Scope is cut to what earns its place before then (see [07-plan.md](07-plan.md)). |
| D3 | Programme + application combined | One `applications` row per programme applied to; `stage = researching` covers "just looking". Split later for multi-cycle. |
| D4 | Daily email digest is the first reminder channel | `pg_cron` → Edge Function → Resend. Push notifications deferred. |
| D5 | Supabase (Postgres, Auth, RLS, pg_cron, Edge Functions) | *Assumed — not yet confirmed.* Business rules that must agree across clients live in SQL. |
| D6 | Store dates, compute states | "Overdue", "follow-up due", "awaiting reply" are derived at query time, never stored. |
| D7 | Deadlines carry their source timezone | `deadline_at timestamptz` + `deadline_tz` (IANA). UI shows both the university's local time and the user's. |

## Documents

1. [01-architecture.md](01-architecture.md) — system overview, Flutter layering, folder structure, packages, product-readiness seams
2. [02-data-model.md](02-data-model.md) — entities, relationships, derived state, security model
3. [03-attention-feed.md](03-attention-feed.md) — the ranked "needs attention" query that drives Today and the digest
4. [04-screens.md](04-screens.md) — screen inventory and behaviour
5. [05-user-stories.md](05-user-stories.md) — MVP-0 stories with acceptance criteria
6. [06-digest.md](06-digest.md) — daily digest job design and idempotency
7. [07-plan.md](07-plan.md) — 3-week build plan, cut line, later phases

SQL in `supabase/migrations/` (verified against PostgreSQL 16 with RLS and cross-user isolation tests):

- [20261013000001_schema.sql](../../supabase/migrations/20261013000001_schema.sql) — tables, constraints, RLS
- [20261013000002_attention_feed.sql](../../supabase/migrations/20261013000002_attention_feed.sql) — outreach status view + ranked feed
- [20261013000003_digest.sql](../../supabase/migrations/20261013000003_digest.sql) — digest bookkeeping, claim/finish functions, cron schedule

Apply with `supabase db push` (remote) or `supabase start` (local).

## Out of scope for MVP-0

Calendar view · activity history · per-item reminders · push notifications · email template placeholders · file uploads · Gmail / BCC logging · offline writes · multi-cycle comparison · analytics.
