-- Daily email digest: bookkeeping + scheduling.
-- Delivery itself happens in the `send-digests` Edge Function (see 06-digest.md).

create table public.digest_runs (
  id                  uuid primary key default gen_random_uuid(),
  owner_id            uuid not null references auth.users (id) on delete cascade,
  digest_date         date not null,              -- in the user's local timezone
  status              text not null default 'claimed'
                        check (status in ('claimed','sent','skipped_empty','failed')),
  attempts            smallint not null default 1,
  item_count          integer,
  provider_message_id text,
  last_error          text,
  claimed_at          timestamptz not null default now(),
  finished_at         timestamptz,
  unique (owner_id, digest_date)                  -- idempotency: one digest per user per local day
);

alter table public.digest_runs enable row level security;
create policy "read own digest runs" on public.digest_runs
  for select to authenticated using (owner_id = (select auth.uid()));
-- No client write policies: only the service role writes here.

-- Atomically claim every user whose local digest hour has arrived today and who
-- has not been claimed yet, plus failed runs eligible for retry. Safe to call
-- repeatedly or concurrently: the unique key and SKIP LOCKED make double sends
-- impossible at this layer.
create or replace function public.claim_due_digests(p_now timestamptz default now(), p_max_attempts int default 3)
returns table (run_id uuid, owner_id uuid, email text, display_name text, timezone text,
               digest_date date, send_when_empty boolean)
language plpgsql security definer set search_path = '' as $$
#variable_conflict use_column
begin
  -- retry failed / stuck runs
  return query
  update public.digest_runs r
     set status = 'claimed', attempts = r.attempts + 1, claimed_at = p_now, last_error = null
   where r.id in (
     select r2.id from public.digest_runs r2
      where r2.attempts < p_max_attempts
        and (r2.status = 'failed'
             or (r2.status = 'claimed' and r2.claimed_at < p_now - interval '30 minutes'))
      for update skip locked)
  returning r.id, r.owner_id,
            (select u.email::text from auth.users u where u.id = r.owner_id),
            (select p.display_name from public.profiles p where p.id = r.owner_id),
            (select p.timezone from public.profiles p where p.id = r.owner_id),
            r.digest_date,
            (select p.digest_send_when_empty from public.profiles p where p.id = r.owner_id);

  -- new runs for today
  return query
  with due as (
    select p.id, p.timezone, p.display_name, p.digest_send_when_empty,
           (p_now at time zone p.timezone)::date as local_date
      from public.profiles p
     where p.digest_enabled
       and extract(hour from (p_now at time zone p.timezone)) >= p.digest_hour_local
  ),
  ins as (
    insert into public.digest_runs (owner_id, digest_date)
    select d.id, d.local_date from due d
    on conflict (owner_id, digest_date) do nothing
    returning id, digest_runs.owner_id, digest_runs.digest_date
  )
  select ins.id, ins.owner_id, u.email::text, d.display_name, d.timezone, ins.digest_date, d.digest_send_when_empty
    from ins
    join due d on d.id = ins.owner_id
    join auth.users u on u.id = ins.owner_id;
end $$;

revoke all on function public.claim_due_digests(timestamptz, int) from public, anon, authenticated;
grant execute on function public.claim_due_digests(timestamptz, int) to service_role;

create or replace function public.finish_digest_run(
  p_run_id uuid, p_status text, p_item_count int default null,
  p_provider_message_id text default null, p_error text default null)
returns void language sql security definer set search_path = '' as $$
  update public.digest_runs
     set status = p_status, item_count = p_item_count,
         provider_message_id = p_provider_message_id, last_error = p_error,
         finished_at = case when p_status <> 'failed' then now() end
   where id = p_run_id and status = 'claimed'
$$;

revoke all on function public.finish_digest_run(uuid, text, int, text, text) from public, anon, authenticated;
grant execute on function public.finish_digest_run(uuid, text, int, text, text) to service_role;

-- ---------------------------------------------------------------------------
-- Schedule (Supabase: enable pg_cron + pg_net; store secrets in Vault)
-- Runs every 15 minutes so users in half-hour timezones still get a timely
-- digest; the claim function makes extra invocations harmless.
-- ---------------------------------------------------------------------------
-- select cron.schedule(
--   'send-digests', '*/15 * * * *',
--   $$
--   select net.http_post(
--     url     := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url')
--                || '/functions/v1/send-digests',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret')),
--     body    := '{}'::jsonb
--   );
--   $$
-- );
