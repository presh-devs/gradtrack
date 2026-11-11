# Sign in with Google

Google sign-in needs **no email from gradll**, so it works before your domain and Resend are set up. Email links keep working alongside it.

gradll uses Google's own button (Google Identity Services). Google signs the person in on gradll's page and hands back an ID token, which Supabase checks (including a one-time nonce) and turns into a session. Because nothing redirects through Supabase, Google's prompt names **gradll.pages.dev**, not the Supabase project address. To show the name **gradll** instead, Google requires brand verification, which needs a domain you own (homepage and privacy policy on it).

**Who can sign up with Google:** anyone, until there are 25 accounts in total ([supabase.md §5](supabase.md#5-who-can-sign-up)). Emails on `signup_allowlist` always get in. If you've already signed in with an email link, Google with the same address opens the same account.

## 1. Google Cloud (you, ~10 minutes)

1. Open [console.cloud.google.com](https://console.cloud.google.com/) → project picker → **New project** → name it `gradll`.
2. **APIs & Services → OAuth consent screen** (also called *Google Auth Platform*) → **Get started**:
   - App name `gradll`, your email as support and contact email.
   - Audience: **External**.
3. **Audience → Publish app** (status *In production*). gradll only asks for name and email, which needs no Google review. (Leaving it in *Testing* also works, but then each friend's Gmail must be added under *Test users*.)
4. **Clients → Create client** → *Web application*, name `gradll web`:
   - **Authorized JavaScript origins:** `https://gradll.pages.dev` and `http://localhost:8080`
   - **Authorized redirect URIs:** `https://qvvzfsyxboyqdubephpn.supabase.co/auth/v1/callback`
5. Copy the **Client ID** and **Client secret**.

## 2. Supabase (you)

*Authentication → Sign In / Providers → Google* → enable, paste the Client ID and Client secret, **Save**.

The secret stays in the dashboard only; never put it in git.

## 3. Keep `config.toml` in step

`supabase config push` compares providers too, so record the provider in `supabase/config.toml` (the Client ID is not secret):

```toml
[auth.external.google]
enabled = true
client_id = "1234-abc.apps.googleusercontent.com"
secret = "env(SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET)"
skip_nonce_check = false
```

Before a later `config push`, either export `SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET` or answer **no** if the push wants to change the Google provider.

## 4. Client ID in the app

Google's button needs the Client ID at build time. Add it to `env.json` (see `env.example.json`):

```json
"GOOGLE_CLIENT_ID": "1234-abc.apps.googleusercontent.com"
```

Without it, the button is hidden and email sign-in still works. Then deploy:

```bash
tool/deploy_web.sh
```

Every address the app is opened from must be an **Authorized JavaScript origin** (step 1.4), or Google's button shows an error.

## What friends see

1. Open https://gradll.pages.dev → **Continue with Google** → a Google popup to pick an account, naming `gradll.pages.dev`.
2. They're in. If 25 accounts already exist and they aren't on the allowlist, they see *"gradll is full right now…"* and no account is created.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| No Google button | `GOOGLE_CLIENT_ID` missing from `env.json` at build time, or Google's script was blocked (ad blocker). |
| Google says "origin is not allowed" / `origin_mismatch` | Add the site's address to *Authorized JavaScript origins*. |
| "Unacceptable audience" or "nonce" error | The Client ID in `env.json` differs from the one in Supabase's Google provider. |
| Popup opens and closes, nothing happens | The browser blocked third-party sign-in; try another browser or use the email link. |
