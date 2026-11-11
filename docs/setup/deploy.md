# Deploy to Cloudflare Pages

gradll's web build is a folder of static files, so it runs on Cloudflare Pages' free plan: HTTPS, unlimited bandwidth, and an address like `gradll.pages.dev`. Supabase still handles data, sign-in and the digest.

## 1. One-time setup (you)

1. Create a free account at [dash.cloudflare.com](https://dash.cloudflare.com/sign-up).
2. Log the command-line tool in (opens your browser):

   ```bash
   npx wrangler@4 login
   ```

3. Create the Pages project:

   ```bash
   npx wrangler@4 pages project create gradll --production-branch main
   ```

   It prints the address, usually `https://gradll.pages.dev`. If that name is taken on `pages.dev`, Cloudflare adds a suffix (e.g. `gradll-4xk.pages.dev`), so use whatever it prints below.

## 2. Allow sign-in links to land on the new address

In `supabase/config.toml`, under `[auth]`:

```toml
site_url = "https://gradll.pages.dev"
additional_redirect_urls = ["https://gradll.pages.dev/**", "http://localhost:8080/**", "http://127.0.0.1:8080/**"]
```

Then:

```bash
supabase config push
```

Without this, a sign-in link opened on the deployed app sends you back to `localhost`.

## 3. Deploy

```bash
tool/deploy_web.sh
```

It builds with your `env.json` (the real Supabase project; it refuses to deploy the demo build) and uploads `build/web`. Re-run it whenever you want the live app to catch up with your code. Each deploy also gets its own preview URL, and earlier deploys can be rolled back from *Workers & Pages → gradll → Deployments*.

Deep links such as `/applications/…` work without extra config: with no `404.html` in the build, Pages serves `index.html` for unknown paths.

## 4. Point the digest at it

The daily digest's links default to `localhost:8080`. Once you've done the email setup, re-run it with the real address:

```bash
RESEND_API_KEY=re_your_key DIGEST_FROM="gradll <digest@mail.yourdomain.com>" APP_BASE_URL=https://gradll.pages.dev tool/setup_digest.sh
```

## Later: your own domain

When you buy a domain, attach it in *Workers & Pages → gradll → Custom domains* (e.g. `app.yourdomain.com`), add it to `additional_redirect_urls` and `site_url`, `supabase config push`, and re-run `tool/setup_digest.sh` with the new `APP_BASE_URL`. The `pages.dev` address keeps working.

## Install on your phone

Open the address in Safari (iPhone) or Chrome (Android) → *Share → Add to Home Screen*. gradll then opens full-screen like an app.
