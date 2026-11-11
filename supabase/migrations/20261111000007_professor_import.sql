-- Bulk professor import (People → Paste from a spreadsheet), all rows in one
-- transaction. Runs as the caller (security invoker), so RLS and the
-- composite owner foreign keys apply exactly as for normal inserts.
--
-- p_rows: JSON array of objects:
--   institution_name (required), name (required), academic_title, department,
--   email, profile_url, research_interests, notes, contacted (boolean)
--
-- A row is skipped when the caller already has a professor with the same
-- email, or the same name at the same institution (case-insensitive).
-- "contacted" records one outbound email sent now, with no follow-up
-- reminder: the sheet doesn't say when it was sent.

create or replace function public.import_professors(p_rows jsonb)
returns table (created_professors integer, created_institutions integer, skipped integer)
language plpgsql security invoker set search_path = '' as $$
#variable_conflict use_column
declare
  v_owner     uuid := auth.uid();
  v_row       jsonb;
  v_inst      uuid;
  v_prof      uuid;
  v_name      text;
  v_email     text;
  v_profs     integer := 0;
  v_new_inst  integer := 0;
  v_skipped   integer := 0;
begin
  if v_owner is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'p_rows must be a JSON array' using errcode = '22023';
  end if;
  if jsonb_array_length(p_rows) > 1000 then
    raise exception 'at most 1000 rows per import' using errcode = '22023';
  end if;

  for v_row in select value from jsonb_array_elements(p_rows) loop
    v_name  := nullif(trim(v_row->>'name'), '');
    v_email := nullif(lower(trim(v_row->>'email')), '');
    if v_name is null or nullif(trim(v_row->>'institution_name'), '') is null then
      raise exception 'every row needs a name and an institution' using errcode = '22023';
    end if;

    select i.id into v_inst
      from public.institutions i
     where i.owner_id = v_owner and lower(i.name) = lower(trim(v_row->>'institution_name'))
     limit 1;
    if v_inst is null then
      insert into public.institutions (name) values (trim(v_row->>'institution_name'))
      returning id into v_inst;
      v_new_inst := v_new_inst + 1;
    end if;

    if exists (
      select 1 from public.professors p
       where p.owner_id = v_owner
         and ((v_email is not null and lower(p.email::text) = v_email)
              or (p.institution_id = v_inst and lower(p.name) = lower(v_name)))
    ) then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    insert into public.professors (
      institution_id, name, academic_title, department, email, profile_url, research_interests, notes
    ) values (
      v_inst, v_name,
      nullif(trim(v_row->>'academic_title'), ''),
      nullif(trim(v_row->>'department'), ''),
      v_email,
      nullif(trim(v_row->>'profile_url'), ''),
      nullif(trim(v_row->>'research_interests'), ''),
      nullif(trim(v_row->>'notes'), '')
    )
    returning id into v_prof;
    v_profs := v_profs + 1;

    if coalesce((v_row->>'contacted')::boolean, false) then
      insert into public.outreach_messages (professor_id, direction, kind, state, sent_at)
      values (v_prof, 'outbound', 'intro', 'sent', now());
    end if;
  end loop;

  return query select v_profs, v_new_inst, v_skipped;
end $$;

revoke all on function public.import_professors(jsonb) from public, anon;
grant execute on function public.import_professors(jsonb) to authenticated;
