# 06 · Daily email digest

SQL: [../../supabase/migrations/20261013000003_digest.sql](../../supabase/migrations/20261013000003_digest.sql).

## Flow

```
pg_cron (every 15 min)
  └─ pg_net POST /functions/v1/send-digests   (Authorization: Bearer <cron_secret>)
       └─ Edge Function (service role)
            1. rows = rpc('claim_due_digests')          -- atomic claim, idempotent
            2. for each row (concurrency ≤ 5):
                 items = rpc('attention_feed_for', {p_owner: row.owner_id, p_horizon: '14 days'})
                 if items empty and !row.send_when_empty → finish(run, 'skipped_empty', 0)
                 else render HTML + text → Resend.send(idempotency key = run_id)
                      ok   → finish(run, 'sent', n, message_id)
                      fail → finish(run, 'failed', error)        -- retried next tick, max 3 attempts
```

## Why it can't double-send

1. `digest_runs (owner_id, digest_date)` is unique. A user gets one row per local day, and `INSERT … ON CONFLICT DO NOTHING` means overlapping cron ticks can't both claim it.
2. Retries reclaim only `failed` runs, or `claimed` runs older than 30 min (a crashed function), using `FOR UPDATE SKIP LOCKED`.
3. The provider call carries `run_id` as its idempotency key, so a retry after "sent but we crashed before recording it" doesn't create a second email.

Verified: the first claim returned both due users, a second claim returned 0, and a failed run was reclaimed once with `attempts = 2`.

## Local-time rules

- `digest_date` = today in the user's IANA timezone. "Due" = local hour ≥ `digest_hour_local`. So if the function is down at 07:00 it still sends at 07:15, 07:30 …, but never twice.
- Changing timezone mid-day can at worst skip or add one digest. That's acceptable.

## Email content

Subject: `GradTrack · 2 overdue, 3 due this week` (or `GradTrack · All clear today`).

Body (HTML + plain-text alternative):
- Sections **Overdue / Today / This week / Later**, each item: title, context, reason, due date in the user's time (plus university time for deadlines).
- Each item links to the app route, e.g. `https://app…/applications/<id>`.
- Footer: "Change digest time" → Settings. Unsubscribe link → turns off `digest_enabled` via a signed one-time token (P1; MVP-0 links to Settings).

## Edge Function contract

- Rejects requests without the `cron_secret` bearer token.
- Secrets: `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`, `CRON_SECRET`, `APP_BASE_URL`, `DIGEST_FROM`.
- `POST /send-digests?test=1` with a user JWT sends a test digest for the caller only, without a `digest_runs` row (Settings → Send test digest).
- Logs one structured line per run: run_id, status, item_count, duration.

## Later

Generalise `digest_runs` into `notification_deliveries(channel, dedupe_key, …)` when per-item reminders and push arrive. The same claim/finish pattern carries over.
