# Sign in with Google

Google sign-in lets invited friends in **without gradll sending any email**, so it works before your domain and Resend are set up. Email links keep working alongside it.

The invite-only rule still applies: Supabase runs `hook_before_user_created` for Google sign-ups too, so only emails in `signup_allowlist` get an account. Add each friend's **Google account email** (usually their Gmail) to the allowlist.

If you've already signed in with an email link, signing in with Google using the same address opens the same account.

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

## 4. Deploy

```bash
tool/deploy_web.sh
```

## What friends see

1. Open https://gradll.pages.dev → **Continue with Google** → choose the invited Google account.
2. Google's screen says it's signing in to `qvvzfsyxboyqdubephpn.supabase.co`. That's gradll's backend; a custom auth domain to hide it is a paid Supabase add-on.
3. A Google account that isn't invited comes back to the sign-in page with *"gradll is invite-only…"* and no account is created.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `redirect_uri_mismatch` from Google | The Supabase callback URL in step 1.4 is missing or mistyped. |
| A page showing `Unsupported provider: provider is not enabled` | Step 2 isn't saved. |
| "gradll is invite-only" for an invited friend | They picked a different Google account than the allowlisted email. |
| Back on the sign-in page with no message | The site isn't in *URL Configuration → Redirect URLs* ([deploy.md](deploy.md) §2). |
