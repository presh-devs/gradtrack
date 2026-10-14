-- Invite-only sign-ups.
--
-- Sign-ups stay enabled, but Supabase Auth calls hook_before_user_created()
-- before creating ANY account (magic link, OAuth, admin-created). The hook
-- allows only emails on signup_allowlist; everyone else is rejected before
-- a user row exists, so strangers get no account, use no quota and are sent
-- no email. Existing users are unaffected (the hook only runs on creation).
--
-- Invite someone (SQL editor, or Table Editor → signup_allowlist):
--   insert into public.signup_allowlist (email, note) values ('friend@example.com', 'Ada');
-- Revoke an invite that hasn't been used yet:
--   delete from public.signup_allowlist where email = 'friend@example.com';
-- (Removing an email doesn't delete an account that already exists — do that
--  under Authentication → Users.)

create table public.signup_allowlist (
  email     text primary key check (email = lower(trim(email)) and email like '%_@_%'),
  note      text,
  added_at  timestamptz not null default now()
);

-- Store emails trimmed and lower-case however they're typed in.
create or replace function public.normalise_allowlist_email()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.email := lower(trim(new.email));
  return new;
end $$;

create trigger signup_allowlist_normalise before insert or update on public.signup_allowlist
  for each row execute function public.normalise_allowlist_email();

-- Clients can never see or change the list. No policies for anon/authenticated
-- means RLS denies them everything; the explicit revoke is belt and braces.
alter table public.signup_allowlist enable row level security;
revoke all on table public.signup_allowlist from anon, authenticated, public;

-- The Auth service runs hooks as supabase_auth_admin; it needs read access.
grant select on table public.signup_allowlist to supabase_auth_admin;
create policy "auth service reads allowlist" on public.signup_allowlist
  for select to supabase_auth_admin using (true);

create or replace function public.hook_before_user_created(event jsonb)
returns jsonb
language plpgsql stable set search_path = '' as $$
declare
  v_email text := lower(trim(event->'user'->>'email'));
begin
  if v_email is not null and v_email <> ''
     and exists (select 1 from public.signup_allowlist a where a.email = v_email) then
    return '{}'::jsonb;
  end if;

  return jsonb_build_object(
    'error', jsonb_build_object(
      'http_code', 403,
      'message', 'GradTrack is invite-only. Ask the person who shared it with you to add your email.'
    )
  );
end $$;

grant execute on function public.hook_before_user_created(jsonb) to supabase_auth_admin;
revoke execute on function public.hook_before_user_created(jsonb) from authenticated, anon, public;
