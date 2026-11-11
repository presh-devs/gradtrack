-- Schedule the daily digest (docs/spec/06-digest.md).
--
-- Every 15 minutes pg_cron POSTs to the send-digests Edge Function through
-- pg_net. The function decides who is due (claim_due_digests), so extra or
-- overlapping calls are harmless.
--
-- The URL and shared secret live in Vault, not in this file:
--   select vault.create_secret('https://<project-ref>.supabase.co', 'project_url');
--   select vault.create_secret('<random secret>', 'cron_secret');
-- The same secret must be set on the function: supabase secrets set CRON_SECRET=...
-- (tool/setup_digest.sh does all three). Until both Vault secrets exist the
-- job does nothing, so applying this migration early is safe.

create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

select cron.schedule(
  'send-digests',
  '*/15 * * * *',
  $job$
  select net.http_post(
    url     := s.url || '/functions/v1/send-digests',
    headers := jsonb_build_object(
                 'Content-Type', 'application/json',
                 'Authorization', 'Bearer ' || s.secret),
    body    := '{}'::jsonb,
    timeout_milliseconds := 60000
  )
  from (
    select (select decrypted_secret from vault.decrypted_secrets where name = 'project_url') as url,
           (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret') as secret
  ) s
  where s.url is not null and s.secret is not null
  $job$
);
