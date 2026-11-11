-- Rebrand: GradTrack → gradll. The only user-visible text in the database is
-- the message shown to someone who isn't on the invite list. Same function,
-- same grants; only the wording changes.

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
      'message', 'gradll is invite-only. Ask the person who shared it with you to add your email.'
    )
  );
end $$;
