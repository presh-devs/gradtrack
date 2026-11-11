-- Open sign-ups for Google accounts, up to a cap.
--
-- Who gets an account:
--   * anyone on public.signup_allowlist, always (any sign-in method);
--   * anyone signing in with Google, while fewer than v_cap accounts exist.
-- Email-link sign-ups stay invite-only, so nobody can make gradll send
-- sign-in emails to arbitrary addresses.
--
-- To change the cap, re-run this function with a new v_cap (SQL editor or a
-- new migration). Existing accounts are never affected: this hook only runs
-- when an account is about to be created.

create or replace function public.hook_before_user_created(event jsonb)
returns jsonb
language plpgsql stable set search_path = '' as $$
declare
  v_cap constant int := 25;
  v_user jsonb := event->'user';
  v_email text := lower(trim(v_user->>'email'));
  v_google boolean :=
    v_user->'app_metadata'->>'provider' = 'google'
    or coalesce(v_user->'app_metadata'->'providers', '[]'::jsonb) ? 'google'
    or exists (
      select 1 from jsonb_array_elements(coalesce(v_user->'identities', '[]'::jsonb)) i
      where i->>'provider' = 'google'
    );
begin
  if v_email is not null and v_email <> ''
     and exists (select 1 from public.signup_allowlist a where a.email = v_email) then
    return '{}'::jsonb;
  end if;

  if v_google then
    if (select count(*) from auth.users) < v_cap then
      return '{}'::jsonb;
    end if;
    return jsonb_build_object('error', jsonb_build_object(
      'http_code', 403,
      'message', 'gradll is full right now. Ask the person who shared it with you to add your email.'
    ));
  end if;

  return jsonb_build_object('error', jsonb_build_object(
    'http_code', 403,
    'message', 'gradll is invite-only for email sign-in. Use Continue with Google, or ask the person who shared it with you to add your email.'
  ));
end $$;
