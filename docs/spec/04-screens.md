# 04 · Screens (MVP-0)

Breakpoints: compact < 600 px, medium 600–839, expanded ≥ 840.
Navigation: `NavigationBar` on compact/medium, `NavigationRail` on expanded.
Top-level destinations: **Today · Applications · People · Tasks · Settings**.

## S1 Sign in
Email field → "Send magic link" → confirmation state. A deep link returns to the app signed in. No passwords.

## S2 Today (default route `/`)
- Header: "Good morning, {name}" · count chips: *3 overdue · 4 this week*.
- Groups: **Overdue**, **Today**, **Next 7 days**, **Later (≤ 14 days)**, ranked by score inside each group.
- Row: icon by type · title · context line · reason · due chip (countdown; red when overdue) · inline actions (see 03).
- Empty state: "Nothing needs you right now", with the next deadline shown below.
- Below the feed: compact pipeline summary (count per stage) that links to filtered Applications.

## S3 Applications list `/applications`
- Expanded: table with columns University · Programme · Degree · Deadline (local + countdown) · Stage · Checklist `4/7` · Letters `1/3` · Priority ★.
- Compact: cards with the same data stacked.
- Filters: stage (multi), cycle, priority. Sort: deadline (default), priority, updated.
- Toggle "Show archived". FAB / button: **Add application**, **Import CSV**.

## S4 Application workspace `/applications/:id`
- Header: institution, programme, degree · deadline in university time and in your time · countdown · stage dropdown · outcome (when decided) · links (programme, portal, funding) as buttons.
- Sections (tabs on compact, two-column on expanded):
  1. **Checklist**: requirements with status toggles, depends-on badge, internal due date, linked document; "Add common requirements" adds the default set in one tap.
  2. **Letters**: one row per recommender with status stepper; "Add recommender" picks an existing person or creates one.
  3. **Professors**: linked professors with thread state and stance chips.
  4. **Tasks** for this application.
  5. **Details**: all programme fields, fees, fee waiver, portal username, notes.

## S5 Application form (create/edit)
Required: institution (autocomplete with inline create), programme name, degree. Deadline input = date + time (default 23:59) + timezone (defaults to the institution's zone). Everything else is optional and collapsed under "More details".

## S6 People `/people`
Segmented control: **Professors | Recommenders**.
- Professors list: name, institution, thread-state chip, stance chip, next follow-up. Filters: thread state, institution, stance. Quick filter "Follow-up due".
- Recommenders list: name, letters `submitted/total`, next letter due.

## S7 Professor detail `/people/professors/:id`
- Profile card: title, name, department, email (copy), profile/lab links, research interests, linked applications, stance selector, "Close conversation".
- Conversation timeline (newest first): outbound/inbound messages with subject, date, follow-up badge.
- Actions: **New email**, **Log reply**, **Log sent email** (for emails written elsewhere).

## S8 Compose email (sheet/dialog)
- Template picker (inserts subject/body; placeholders come in MVP-1).
- Subject and body editors, autosaved as a draft.
- **Copy subject** · **Copy body** (clipboard; primary path) · **Open in mail app** (`mailto:` with subject only plus the body when short; shows a note that long bodies should be pasted).
- **Mark as sent…** opens a dialog: sent date (default now), follow-up in [7] days (on/off), thread URL (optional). This is the only path that sets `state = sent`.

## S9 Recommender detail `/people/recommenders/:id`
Contact info, relationship, agreed date, and a table of letter requests across applications with status, due date and quick status advance. Copy email.

## S10 Tasks `/tasks`
Chronological list grouped Overdue / Upcoming / No date / Done (collapsed). Filters: application, priority, status. Quick add bar: title + optional due date.

## S11 Import CSV `/applications/import`
Steps: pick file → map columns (auto-matched, editable) → choose default timezone → preview with per-row errors → import (single transaction) → summary with link to the list.

## S12 Settings `/settings`
Profile name · timezone · digest on/off, hour, "send even when empty" · **Send test digest** · Templates management · **Export my data (JSON)** · Sign out.

## Cross-cutting
- Every date shows relative and absolute time on hover/long-press.
- Keyboard: `N` new (context-aware), `/` search on lists, `G T`/`G A` navigation. Visible focus rings.
- Accessibility: wrap custom rows in `Semantics` with labels such as "Requirement, Statement of purpose, not started, due in 3 days". Minimum 48 px touch targets and WCAG AA contrast in both themes.
- Long text that users copy uses `SelectableText`.
