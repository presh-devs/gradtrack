# Email for you and invited friends

gradll sends two kinds of email:

| Email | Sent by | Without this setup |
|---|---|---|
| Sign-in links | Supabase Auth | Supabase's built-in sender only emails your project's team members, a couple per hour. Friends never get a link. |
| Daily digest | `send-digests` Edge Function | Resend's test sender (`onboarding@resend.dev`) only delivers to your own Resend account. |

Both go through **one Resend account and one domain you own**, so mail reaches anyone you invite and is far less likely to land in spam.

## 1. A domain (you, ~10 minutes)

Any domain you control works. If you don't have one, a cheap one from Cloudflare Registrar or Namecheap is fine. Cloudflare is convenient because the app will likely be hosted on Cloudflare Pages too.

Send from a subdomain such as `mail.yourdomain.com`, so gradll's email reputation stays separate from anything else on the domain.

## 2. Resend (you)

1. Sign up at [resend.com](https://resend.com).
2. **Domains → Add domain** → `mail.yourdomain.com`. Add the DNS records it shows (SPF and DKIM) at your DNS provider, then wait for **Verified**.
3. **API Keys → Create**, with *Sending access* only. Keep it somewhere safe; you'll paste it twice below.

## 3. Sign-in emails through Resend (you, Supabase dashboard)

*Authentication → Emails → SMTP Settings → Enable custom SMTP*:

| Field | Value |
|---|---|
| Sender email | `login@mail.yourdomain.com` |
| Sender name | `gradll` |
| Host | `smtp.resend.com` |
| Port | `465` |
| Username | `resend` |
| Password | your Resend API key |

Then raise the sign-in email limit: *Authentication → Rate Limits → emails sent per hour* → `30` (the default is 2). `supabase config push` doesn't manage this setting, so set it in the dashboard.

The SMTP password is deliberately not in `config.toml`, so it never ends up in git.

## 4. The daily digest

```bash
RESEND_API_KEY=re_your_key DIGEST_FROM="gradll <digest@mail.yourdomain.com>" APP_BASE_URL=https://your-app.pages.dev tool/setup_digest.sh
```

Leave out `APP_BASE_URL` until the app is deployed; links then point to `localhost:8080`, which only works on your computer. Re-run the script with the real URL after deploying.

Then **Settings → Send test digest** in the app.

## 5. Invite friends

1. Turn on the invite-only hook and add their emails to `signup_allowlist` ([supabase.md §5](supabase.md#5-invite-only-sign-ups)).
2. They need a URL to open, so deploy the app first ([deploy.md](deploy.md)).
3. Each friend signs in with their invited email. Their data is private to them, and each gets their own digest at 07:00 in their own time zone (they can change it in Settings).

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Friend gets no sign-in email | Custom SMTP not enabled, or the domain isn't verified in Resend yet. Check Resend → Emails for a bounce. |
| "Email rate limit exceeded" | The hourly limit in *Authentication → Rate Limits* is still the default 2. |
| Test digest says "Email isn't set up yet" | `tool/setup_digest.sh` hasn't been run, or ran without `DIGEST_FROM`. |
| Digest lands in spam | DNS records not all verified; send from the subdomain, not `resend.dev`. |
