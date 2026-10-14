# Supabase setup

About 15 minutes. Steps marked **you** need your Supabase account or credentials. Never paste the database password or the secret key into chat or into the app.

## 1. Create the project (you)

1. Go to <https://supabase.com/dashboard> and sign in (GitHub sign-in is fine).
2. **New project**:
   - **Name:** `gradtrack`
   - **Database password:** use **Generate a password** and save it in your password manager. You need it once, in step 3.
   - **Region:** the one closest to you. From Nigeria, a European region such as London (`eu-west-2`) or Frankfurt (`eu-central-1`) is usually closest.
   - **Plan:** Free.
3. Wait a minute or two for the project to finish provisioning.

## 2. Copy the two public values into `env.json` (you)

In the dashboard:

- **Project URL:** *Project Settings → Data API* (`https://<ref>.supabase.co`). The `<ref>` part is your **project ref**.
- **Publishable key:** *Project Settings → API Keys* (`sb_publishable_…`).

Both are designed to ship in a web app. Your data is protected by row-level security, not by hiding these.

```bash
cp env.example.json env.json
```

Edit `env.json` with those two values. It's git-ignored.

## 3. Link the repo and apply the database (you run, in this folder)

```bash
supabase login
```

```bash
supabase link --project-ref YOUR_PROJECT_REF
```

`link` asks for the database password from step 1.

Preview, then apply the migrations (schema, row-level security, attention feed, digest bookkeeping, import):

```bash
supabase db push --dry-run
```

```bash
supabase db push
```

Apply the auth settings from `supabase/config.toml` (site URL and redirect URLs for `localhost:8080`):

```bash
supabase config diff
```

```bash
supabase config push
```

## 4. Run against Supabase

```bash
tool/run_web.sh
```

Open <http://localhost:8080> and sign in with your email. Opening the magic link lands you back in the app, signed in.

> **Email limits.** Supabase's built-in email service is meant for testing: it only sends to a small number of addresses (typically your project's team members, i.e. the email you signed up to Supabase with) and is heavily rate-limited. Sign in with that email. The daily digest (week 3) needs a proper sender (Resend), which will also be set as the auth SMTP.

## 5. Invite-only sign-ups

Sign-ups are **on but invite-only**. Before Supabase creates any account, it calls `public.hook_before_user_created`, which only allows emails listed in `public.signup_allowlist` (migration `20261014000005`). Anyone else sees *"GradTrack is invite-only…"*, and no account is created and no email is sent. Existing accounts, including yours, aren't affected.

Apply it with migrations **first**, then config, because the hook function must exist before Auth is told to call it:

```bash
supabase db push
```

```bash
supabase config push
```

**Invite a friend:** *Table Editor → `signup_allowlist` → Insert row* (email plus an optional note), or in the SQL editor:

```sql
insert into public.signup_allowlist (email, note) values ('friend@example.com', 'Ada');
```

They then open GradTrack and sign in with that email. Each person gets their own private workspace; nobody can see anyone else's applications.

**Before friends can actually use it**, two more things are needed (planned for week 3):

1. **A public URL.** The app currently runs only on your machine (`localhost:8080`). Deploy the web build (Cloudflare Pages or Netlify), add its URL to `additional_redirect_urls` in `supabase/config.toml`, and run `supabase config push`.
2. **Real email delivery.** Supabase's built-in sender only emails project team members, so friends would never receive their sign-in link. Set up custom SMTP (Resend, the same service the daily digest uses) under *Authentication → Emails → SMTP*.

## 6. Import your spreadsheet

*Applications → Import CSV*, then upload your file or paste the cells.

## Troubleshooting

| Symptom | Fix |
|---|---|
| App still says "Demo data" | `env.json` missing or empty; rebuild with `tool/run_web.sh`. |
| Magic link opens but you're not signed in | The URL you opened the app on must be in `additional_redirect_urls`; run `supabase config push`. |
| "Email rate limit exceeded" | Wait an hour, or configure custom SMTP (*Authentication → Emails → SMTP*). |
| A friend sees "GradTrack is invite-only" | Their exact email isn't in `signup_allowlist` (check for typos or a different address). |
| Sign-up fails with "Error running hook URI" | `supabase config push` ran before `supabase db push`; push the migrations. |
| `db push` says a migration already ran | Someone ran SQL by hand. `supabase migration list` shows local and remote; ask before using `migration repair`. |
| Free project paused | Free projects pause after a period of inactivity. Restore it from the dashboard. |
