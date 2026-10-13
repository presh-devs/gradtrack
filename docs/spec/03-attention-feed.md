# 03 · "Needs attention" feed

The feed is the core of the product. It is a single Postgres function, so the Today screen and the daily digest show the same items in the same order.

- Client: `select * from attention_feed('14 days')` via `supabase.rpc('attention_feed')`. Always scoped to `auth.uid()`.
- Digest: `attention_feed_for(owner_id, now(), '14 days')`, callable by the service role only.

## Sources

| item_type | Included when | Effective due |
|---|---|---|
| `application_deadline` | stage ∈ researching…ready, not archived, no outcome | `deadline_at` |
| `funding_deadline` | `funding_outcome` empty and date differs from the application deadline | `funding_deadline_at` |
| `requirement` | status ∈ not_started/in_progress, application pre-submission | `coalesce(due_at, application.deadline_at)` |
| `letter` | status ∈ planned/requested/invited | `coalesce(due_at, application.deadline_at)` |
| `follow_up` | `professor_outreach_status.next_follow_up_at` is set | `next_follow_up_at` |
| `task` | status = open, has `due_at` | `due_at` |

Only items due within the horizon are returned. Overdue items are always included.

## Score = urgency + weight

**Urgency** (`attention_urgency()`):

| Time remaining | Points |
|---|---|
| overdue | 100 |
| < 24 h | 90 |
| < 3 days | 75 |
| < 7 days | 50 |
| ≤ horizon | 25 |

**Weights:**

| Condition | Points |
|---|---|
| Application deadline | +20 (+5 if items outstanding) |
| Funding deadline | +15 |
| Depends on someone else (letters, `depends_on = external`) | +10 (other people need lead time) |
| Top-choice application (`priority = 1`) | +5 |
| Follow-up | +5 |
| Task priority high / low | +10 / −10 |

Ties are broken by the earliest due date. All the numbers are in one SQL function, so they can be tuned without a client release.

## Reasons are written for humans

Each row carries a `reason`, so the UI and email need no logic:
- Application deadline: *"2 requirement(s), 1 letter(s) outstanding"*, or *"Everything ticked off — submit it"*
- Requirement: *"Depends on someone else — chase early"* / *"In progress"* / *"Not started"*
- Letter: *"Not requested yet"* / *"Requested — portal invite not sent"* / *"Invited — not submitted yet"*
- Follow-up: *"No reply since 05 Oct"*

## Verified example

Seed: one top-choice application due in 3 days, an overdue external transcript, an unstarted SOP, an invited letter, an intro email sent 8 days ago with follow-up due, a high-priority task in 2 days, and a funding deadline in 10 days. Result:

```
requirement          Official transcript        Depends on someone else — chase early       115
follow_up            Follow up with Prof. Smith No reply since 05 Oct                       105
application_deadline Application deadline       2 requirement(s), 1 letter(s) outstanding   105
task                 Prep interview             High priority task                           85
letter               Letter from Dr. Ade        Invited — not submitted yet                  85
requirement          Statement of purpose       Not started                                  80
funding_deadline     Funding deadline           Scholarship / funding application            40
```

Logging an inbound reply from Prof. Smith removed the follow-up row. A second user saw zero rows.

## Inline actions (Today screen)

| item_type | Primary action | Secondary |
|---|---|---|
| application_deadline | Open workspace | Mark submitted |
| requirement | Mark done | Set in progress · Open |
| letter | Advance status (requested → invited → submitted) | Open recommender |
| follow_up | Compose follow-up (opens draft with template) | Log reply · Snooze 3 days (sets new `follow_up_at`) · Clear |
| task | Mark done | Edit due date |
