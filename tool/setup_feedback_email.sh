#!/usr/bin/env bash
# Email yourself whenever someone sends feedback from Settings.
#
#   RESEND_API_KEY=re_... FEEDBACK_NOTIFY_TO=you@example.com tool/setup_feedback_email.sh
#
#   FEEDBACK_NOTIFY_TO  where notifications go.
#   FEEDBACK_FROM       optional sender. Without a verified domain, leave it out:
#                       Resend's test sender (onboarding@resend.dev) is used,
#                       which only delivers to the email your Resend account
#                       was created with, so use that as FEEDBACK_NOTIFY_TO.
#                       After verifying a domain, e.g. "gradll <feedback@mail.yourdomain.com>".
#
# Shares the Vault secrets and CRON_SECRET with the daily digest; if the digest
# is already set up its secret is reused, otherwise a new one is created.
# Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${RESEND_API_KEY:?Set RESEND_API_KEY (from resend.com → API Keys)}"
: "${FEEDBACK_NOTIFY_TO:?Set FEEDBACK_NOTIFY_TO to the email that should receive feedback}"
FEEDBACK_FROM="${FEEDBACK_FROM:-gradll <onboarding@resend.dev>}"

ref="$(cat supabase/.temp/project-ref 2>/dev/null || true)"
[ -n "$ref" ] || { echo "Run 'supabase link' first." >&2; exit 1; }
project_url="https://${ref}.supabase.co"

# Reuse the digest's shared secret if there is one, so both keep working.
if supabase secrets list 2>/dev/null | grep -q '"CRON_SECRET"\|CRON_SECRET '; then
  echo "→ Reusing the existing CRON_SECRET"
  set_cron=""
else
  cron_secret="$(openssl rand -hex 32)"
  set_cron="CRON_SECRET=$cron_secret"
  echo "→ Creating a shared secret"
  supabase db query --linked "
  do \$\$
  declare v_id uuid;
  begin
    select id into v_id from vault.secrets where name = 'cron_secret';
    if v_id is null then perform vault.create_secret('${cron_secret}', 'cron_secret');
    else perform vault.update_secret(v_id, '${cron_secret}'); end if;
  end \$\$;" >/dev/null
fi

echo "→ Vault project URL"
supabase db query --linked "
do \$\$
declare v_id uuid;
begin
  select id into v_id from vault.secrets where name = 'project_url';
  if v_id is null then perform vault.create_secret('${project_url}', 'project_url');
  else perform vault.update_secret(v_id, '${project_url}'); end if;
end \$\$;" >/dev/null

echo "→ Function secrets"
# shellcheck disable=SC2086
supabase secrets set \
  RESEND_API_KEY="$RESEND_API_KEY" \
  FEEDBACK_NOTIFY_TO="$FEEDBACK_NOTIFY_TO" \
  FEEDBACK_FROM="$FEEDBACK_FROM" \
  $set_cron >/dev/null

echo "→ Deploying notify-feedback"
supabase functions deploy notify-feedback --no-verify-jwt

echo
echo "Done. Send something from Settings → Feedback to try it."
