-- Email the gradll owner when new feedback arrives.
--
-- After each insert, pg_net POSTs the row id to the notify-feedback Edge
-- Function, using the same Vault secrets as the digest (project_url,
-- cron_secret). Until those exist this does nothing, and it never blocks or
-- fails the insert: pg_net is asynchronous and errors are swallowed.
-- tool/setup_feedback_email.sh sets everything up.

create extension if not exists pg_net with schema extensions;

alter table public.feedback add column notified_at timestamptz;

create or replace function public.notify_new_feedback()
returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_url    text;
  v_secret text;
begin
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'cron_secret';
  if v_url is null or v_secret is null then
    return new;
  end if;
  perform net.http_post(
    url     := v_url || '/functions/v1/notify-feedback',
    headers := jsonb_build_object(
                 'Content-Type', 'application/json',
                 'Authorization', 'Bearer ' || v_secret),
    body    := jsonb_build_object('feedback_id', new.id),
    timeout_milliseconds := 30000
  );
  return new;
exception when others then
  raise warning 'notify_new_feedback: %', sqlerrm;
  return new;
end $$;

revoke all on function public.notify_new_feedback() from public, anon, authenticated;

create trigger feedback_notify after insert on public.feedback
  for each row execute function public.notify_new_feedback();
