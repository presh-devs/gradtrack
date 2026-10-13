# 02 · Data model

Source of truth: [../../supabase/migrations/20261013000001_schema.sql](../../supabase/migrations/20261013000001_schema.sql).

## Entity relationships

```
profiles 1─1 auth.users
cycles 1─* applications *─1 institutions 1─* professors
applications 1─* requirements *─0..1 documents
applications 1─* letter_requests *─1 recommenders
applications *─* professors            (application_professors)
professors 1─* outreach_messages *─0..1 applications
tasks *─0..1 applications, *─0..1 professors
email_templates (standalone)
digest_runs *─1 auth.users
```

## Entities

| Table | Purpose | Key fields |
|---|---|---|
| `profiles` | Preferences | `timezone`, `digest_enabled`, `digest_hour_local`, `digest_send_when_empty` |
| `cycles` | Admission cycle | `name`, `start_term`, `start_year`, `is_active` |
| `institutions` | University | `name`, `country`, `website_url`, `default_tz` |
| `applications` | Programme *and* its application (D3) | programme facts, `deadline_at/_tz`, `funding_deadline_at/_tz`, fees, `fee_waiver`, `stage`, `outcome`, `funding_outcome`, `priority` |
| `requirements` | Per-application checklist item, actionable itself | `kind`, `status`, `depends_on` (self/external), `due_at`, `document_id` |
| `documents` | Reusable material (link) | `title`, `kind`, `url`, `version_label` |
| `recommenders` | A person writing letters | `name`, `email`, `relationship`, `agreed_at` |
| `letter_requests` | Recommender × application | `status`, `requested_at`, `invited_at`, `submitted_at`, `due_at` |
| `professors` | Potential supervisor | `institution_id`, `research_interests`, `stance`, `closed_at` |
| `outreach_messages` | One email in a conversation | `direction`, `kind`, `state` (draft/sent), `sent_at`, `follow_up_at`, `follow_up_cleared_at`, `thread_url` |
| `email_templates` | Saved snippets | `name`, `kind`, `subject`, `body` |
| `tasks` | Anything that isn't a requirement, letter or follow-up | `due_at`, `priority`, `status` |
| `digest_runs` | Digest ledger (idempotency) | `digest_date`, `status`, `attempts` |

## Enumerations

**Application stage** (not a strict sequence; any transition is allowed):
`researching → shortlisted → preparing → ready → submitted → under_review → interview → decided`

**Outcome** (only when `stage = decided`): `accepted | rejected | waitlisted | withdrawn`
**Funding outcome** (independent): `funded | partial | unfunded | pending`
**Requirement status:** `not_started | in_progress | done | not_applicable`
**Letter status:** `planned | requested | invited | submitted | declined`
**Professor stance:** `unknown | interested | not_taking_students | declined`

Side effects handled in the client controllers (MVP-0) and moved to triggers in the activity-history phase:
- stage → `submitted` sets `submitted_at` if empty.
- stage → `decided` sets `decided_at`.
- requirement → `done` sets `completed_at`; leaving `done` clears it.
- letter → `submitted` sets `submitted_at`.

## Derived state (never stored)

Defined in [../../supabase/migrations/20261013000002_attention_feed.sql](../../supabase/migrations/20261013000002_attention_feed.sql) as the `professor_outreach_status` view:

| thread_state | Rule |
|---|---|
| `closed` | `professors.closed_at` set |
| `to_contact` | no sent outbound, no drafts |
| `drafting` | no sent outbound, ≥ 1 draft |
| `awaiting_reply` | latest sent outbound is newer than latest inbound |
| `replied` | an inbound exists at or after the latest sent outbound |

`next_follow_up_at` is the latest sent outbound's `follow_up_at`, but only while `awaiting_reply`, not cleared, and the stance isn't `not_taking_students`/`declined`. "Follow-up due" = `next_follow_up_at <= now()`.

This matches the concept's rule: the app flags a follow-up only from what the user recorded. Logging a reply clears it automatically, and it never assumes "no reply" from missing data beyond the date the user set.

**Thread state vs stance:** the concept's 11 outreach statuses are split into a derived `thread_state` (where the conversation is) and a user-set `stance` (what the professor said). A professor can be `interested` while the thread is `awaiting_reply`.

## Email draft lifecycle

```
draft ──(Copy / Open in mail app: no state change)──▶ draft
draft ──(user taps "Mark as sent", picks sent date, optional follow-up in N days)──▶ sent
```

Opening `mailto:` or copying text **never** changes state. Default follow-up offset: 7 days for intro emails, editable per message. Logging an inbound reply → thread becomes `replied` → follow-up disappears from the feed.

## Security model

- RLS on every table, policy `owner_id = (select auth.uid())` for all operations.
- Composite FKs `(x_id, owner_id) → parent(id, owner_id)`: verified that user B cannot attach a requirement to user A's application even with a known UUID.
- `digest_runs`: clients can read their own rows only; writes go through service-role functions.

## CSV import (MVP-0)

Code: `lib/features/import/` · SQL: `import_applications()` in [20261014000004_import.sql](../../supabase/migrations/20261014000004_import.sql).

- **Input:** a file (.csv/.tsv) or a paste from Excel/Sheets (tab-separated). The delimiter is detected from the header line. BOM, CRLF and quoted commas are handled. Limit: 500 rows.
- **Columns:** auto-matched by alias (e.g. *School* → University, *Due date* → Deadline, *Status* → Stage). Each field maps to at most one column, and the user can remap. Only University and Programme are required.
- **Dates:** ISO, numeric (day/month order is a wizard setting, inferred when one part is > 12), and month names, with optional 12/24-hour times and a trailing zone abbreviation (`EST`, `PST`, `GMT`, `CET`, `AoE` → `Etc/GMT+12`, …). A date with no time means 23:59.
- **Deadline zone, first match wins:** zone column → zone named in the date → the university's saved zone → country default → wizard default.
- **Lenient values:** unknown degree → Other, unknown stage → Researching, unknown priority → Normal. Each produces a warning, not an error. A fee without a determinable currency is dropped with a warning. Bare domains get `https://`.
- **Skipped rows:** validation errors (same rules as the form), duplicates of an existing application (same university, programme and degree, ignoring case and punctuation), and repeats within the file.
- **Save:** one RPC, one transaction; institutions are reused case-insensitively. Optionally seeds `default_requirements()` (transcript, CV, SOP, English test, fee) on each new application.
