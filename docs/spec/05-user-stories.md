# 05 · User stories (MVP-0)

Priority: **P0** = must ship by 2 Nov · **P1** = ship if time allows, else first week of November.

## Setup

**US-01 (P0) Sign in.** As the applicant, I sign in with a magic link so only I can see my data.
- Given a new email, a profile is created with my browser's timezone.
- Signed-out users are redirected to S1. All data requests fail without a session.

**US-02 (P0) Import my spreadsheet.** I import my existing programme spreadsheet so I don't retype it.
- Columns auto-map by name. I can remap and choose a default timezone.
- Rows with errors are shown and skipped only if I confirm. Valid rows are created in one transaction.
- Institutions are deduplicated by name.

## Applications

**US-03 (P0) Add/edit an application.** I record a programme with its deadline in the university's timezone.
- Deadline shows in both the university's time and mine. A date with no time defaults to 23:59 in that zone.

**US-04 (P0) Move through stages.** I change the stage from any stage to any other.
- Moving to `submitted` records `submitted_at` (editable). Choosing an outcome requires `decided`.

**US-05 (P0) Checklist.** I keep a requirement checklist per application.
- "Add common requirements" adds Transcript, CV, SOP, English test, Fee in one tap. Individual items can be N/A'd.
- The list and workspace show progress `done / (total − N/A)`.

**US-06 (P1) Link reusable documents.** I link one CV document to several requirements.

## Letters

**US-07 (P0) Track letters across applications.** I see, for each recommender, which letters are planned/requested/invited/submitted.
- A letter appears in Today when not submitted and its effective due date is within 14 days.

## Professors

**US-08 (P0) Add professors** with institution, interests, links, and link them to applications.

**US-09 (P0) Draft and copy an email.** I write a draft (optionally from a template) and copy subject/body to my mail client.
- Copying or opening the mail app does **not** mark it sent.

**US-10 (P0) Mark sent with follow-up.** I mark an email as sent and schedule a follow-up N days later.
- Follow-up appears in Today on that date if no reply is logged.

**US-11 (P0) Log a reply.** I log a reply and the pending follow-up disappears automatically.

**US-12 (P0) Record stance.** I mark a professor as interested / not taking students / declined. The latter two suppress follow-ups.

**US-13 (P1) Templates.** I save and reuse intro/follow-up snippets.

## Today and reminders

**US-14 (P0) Today feed.** I open the app and see a ranked list of what needs attention, with inline actions.
- Matches the rules in [03-attention-feed.md](03-attention-feed.md). Overdue items always show.

**US-15 (P0) Daily digest.** I get one email each morning at my chosen hour listing the same items.
- At most one digest per local day, even across retries.
- No email on empty days unless I opt in. "Send test digest" works from Settings.

**US-16 (P1) Tasks.** I create ad-hoc tasks, optionally linked to an application or professor.

## Data ownership

**US-17 (P1) Export.** I download all my data as JSON.

**US-18 (P1) Install.** I install GradTrack to my home screen/desktop and it opens standalone.
