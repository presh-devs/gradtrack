# 07 · Build plan

Today: Tue 13 Oct 2026 · MVP-0 in daily use: **Mon 2 Nov 2026**.

**Before writing code (today):** put every deadline that falls before 15 Nov in your current spreadsheet or calendar. The tool must not be your only safety net while it's being built.

## Week 1 · 13–18 Oct — Foundation + data in

- [x] `flutter create`, packages, lint rules, folder structure (01)
- [ ] Supabase project, `supabase init`, migrations 001–002, pgTAP tests for RLS and the feed
- [x] Auth (magic link), router with auth redirect, responsive shell
- [x] `Deadline` value object + timezone formatting (unit tested)
- [x] Applications list + form + workspace header/details (S3–S5)
- [ ] CSV import (S11), **then import your real spreadsheet**

Exit: your real applications are in GradTrack with correct deadlines.

## Week 2 · 19–25 Oct — Checklists, letters, Today

- [ ] Requirements checklist with "Add common requirements" (US-05)
- [ ] Recommenders + letter requests (US-07, S9)
- [ ] Today screen on `attention_feed` with inline actions (S2). Feed and grouping are done; inline actions are still to do
- [ ] Deploy web build to Cloudflare Pages / Netlify; start using it daily

Exit: Today is the first thing you open each morning.

## Week 3 · 26 Oct–1 Nov — Outreach + digest

- [ ] Professors, link to applications (US-08)
- [ ] Compose / copy / mark-as-sent / log reply / follow-up (US-09–12)
- [ ] Migration 003, `send-digests` Edge Function, cron, Resend (US-15)
- [ ] Settings: timezone, digest prefs, test digest
- [ ] PWA manifest + icons

Exit (2 Nov): digest arrives every morning; no spreadsheet needed for new updates.

## Cut line (if behind)

Drop in this order: templates (US-13) → tasks screen (US-16; keep quick-add only) → export (US-17) → install polish (US-18) → recommender detail screen (keep letters inside the workspace).
**Never cut:** import, deadlines with timezones, checklist, Today, follow-ups, digest.

## After MVP-0

| Phase | When | Scope |
|---|---|---|
| MVP-1 | Nov | Template placeholders, activity history (triggers), calendar view, per-item reminder offsets, unsubscribe token |
| MVP-2 | Dec–Jan (light touch, deadline season) | Bug fixes only; interview stage tooling |
| 2 | Feb–Apr | Decisions & funding comparison, document versions, BCC logging (inbound email webhook), push notifications |
| 3 | Post-cycle | Product track: workspaces, shared institution catalogue, onboarding, requirement templates, Gmail integration (needs Google's restricted-scope review) |
