#!/usr/bin/env bash
# One-time setup for the daily digest email (docs/spec/06-digest.md).
#
#   RESEND_API_KEY=re_... DIGEST_FROM="gradll <digest@yourdomain.com>" \
#   APP_BASE_URL=https://your-app.pages.dev tool/setup_digest.sh
#
#   DIGEST_FROM   sender on a domain verified in Resend (docs/setup/email.md).
#                 Resend's test sender (onboarding@resend.dev) only delivers to
#                 your own Resend account, so friends would get nothing.
#   APP_BASE_URL  where links in the email point (default http://localhost:8080,
#                 which only works on your own machine)
#
# It generates a shared cron secret, stores it (and the project URL) in Vault
# for pg_cron, sets the function's secrets, and deploys send-digests.
# Safe to re-run: secrets are updated in place.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${RESEND_API_KEY:?Set RESEND_API_KEY (from resend.com → API Keys)}"
: "${DIGEST_FROM:?Set DIGEST_FROM, e.g. \"gradll <digest@yourdomain.com>\" on a domain verified in Resend}"
APP_BASE_URL="${APP_BASE_URL:-http://localhost:8080}"
case "$DIGEST_FROM" in
  *@resend.dev*)
    echo "Note: $DIGEST_FROM is Resend's test sender; only your own Resend account email will receive digests." >&2 ;;
esac
case "$APP_BASE_URL" in
  *localhost*|*127.0.0.1*)
    echo "Note: links in the email point to $APP_BASE_URL, which only works on this computer." >&2 ;;
esac

ref="$(cat supabase/.temp/project-ref 2>/dev/null || true)"
[ -n "$ref" ] || { echo "Run 'supabase link' first." >&2; exit 1; }
project_url="https://${ref}.supabase.co"
cron_secret="$(openssl rand -hex 32)"

echo "→ Function secrets"
supabase secrets set \
  RESEND_API_KEY="$RESEND_API_KEY" \
  CRON_SECRET="$cron_secret" \
  APP_BASE_URL="$APP_BASE_URL" \
  DIGEST_FROM="$DIGEST_FROM" >/dev/null

echo "→ Vault secrets for pg_cron"
supabase db query --linked "
do \$\$
declare v_id uuid;
begin
  select id into v_id from vault.secrets where name = 'project_url';
  if v_id is null then perform vault.create_secret('${project_url}', 'project_url');
  else perform vault.update_secret(v_id, '${project_url}'); end if;

  select id into v_id from vault.secrets where name = 'cron_secret';
  if v_id is null then perform vault.create_secret('${cron_secret}', 'cron_secret');
  else perform vault.update_secret(v_id, '${cron_secret}'); end if;
end \$\$;" >/dev/null

echo "→ Deploying send-digests"
supabase functions deploy send-digests --no-verify-jwt

echo
echo "Done. Settings → Send test digest emails you today's digest now;"
echo "the scheduled one arrives at your chosen hour (checked every 15 minutes)."
