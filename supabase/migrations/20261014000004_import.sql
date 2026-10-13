-- Bulk import (spec S11 / US-02): all rows in one transaction, so a failed
-- import leaves nothing behind. Runs as the caller (security invoker), so RLS
-- and the composite owner foreign keys apply exactly as for normal inserts.
--
-- p_rows: JSON array of objects (validated client-side, re-checked by table
-- constraints here):
--   institution_name, country, programme_name, degree_type, stage, priority,
--   department, research_area, programme_url, portal_url, notes,
--   deadline_at, deadline_tz, funding_deadline_at, funding_deadline_tz,
--   fee_amount, fee_currency

create or replace function public.import_applications(
  p_rows jsonb,
  p_seed_requirements boolean default false
)
returns table (created_applications integer, created_institutions integer)
language plpgsql security invoker set search_path = '' as $$
#variable_conflict use_column
declare
  v_owner     uuid := auth.uid();
  v_cycle     uuid;
  v_inst      uuid;
  v_app       uuid;
  v_row       jsonb;
  v_stage     text;
  v_apps      integer := 0;
  v_new_inst  integer := 0;
begin
  if v_owner is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if jsonb_typeof(p_rows) is distinct from 'array' then
    raise exception 'p_rows must be a JSON array' using errcode = '22023';
  end if;
  if jsonb_array_length(p_rows) > 500 then
    raise exception 'at most 500 rows per import' using errcode = '22023';
  end if;

  select c.id into v_cycle
    from public.cycles c
   where c.owner_id = v_owner and c.is_active
   order by c.created_at
   limit 1;
  if v_cycle is null then
    insert into public.cycles (name) values ('Current cycle') returning id into v_cycle;
  end if;

  for v_row in select value from jsonb_array_elements(p_rows) loop
    -- Reuse an institution case-insensitively (also within this import).
    select i.id into v_inst
      from public.institutions i
     where i.owner_id = v_owner and lower(i.name) = lower(trim(v_row->>'institution_name'))
     limit 1;
    if v_inst is null then
      insert into public.institutions (name, country, default_tz)
      values (trim(v_row->>'institution_name'), v_row->>'country', v_row->>'deadline_tz')
      returning id into v_inst;
      v_new_inst := v_new_inst + 1;
    end if;

    v_stage := coalesce(v_row->>'stage', 'researching');

    insert into public.applications (
      cycle_id, institution_id, programme_name, degree_type, stage, priority,
      department, research_area, programme_url, portal_url, notes,
      deadline_at, deadline_tz, funding_deadline_at, funding_deadline_tz,
      fee_amount, fee_currency, submitted_at
    ) values (
      v_cycle, v_inst, trim(v_row->>'programme_name'),
      coalesce(v_row->>'degree_type', 'phd'), v_stage,
      coalesce((v_row->>'priority')::smallint, 2),
      v_row->>'department', v_row->>'research_area',
      v_row->>'programme_url', v_row->>'portal_url', v_row->>'notes',
      (v_row->>'deadline_at')::timestamptz, v_row->>'deadline_tz',
      (v_row->>'funding_deadline_at')::timestamptz, v_row->>'funding_deadline_tz',
      (v_row->>'fee_amount')::numeric, v_row->>'fee_currency',
      case when v_stage in ('submitted','under_review','interview','decided') then now() end
    )
    returning id into v_app;
    v_apps := v_apps + 1;

    if p_seed_requirements then
      insert into public.requirements (application_id, kind, title, depends_on, sort_order)
      select v_app, d.kind, d.title, d.depends_on, d.sort_order
        from public.default_requirements() d;
    end if;
  end loop;

  return query select v_apps, v_new_inst;
end $$;

-- The "common requirements" set, shared by import and (later) the checklist's
-- "Add common requirements" action, so both stay identical.
create or replace function public.default_requirements()
returns table (kind text, title text, depends_on text, sort_order integer)
language sql immutable as $$
  values
    ('transcript',   'Official transcript',  'external', 1),
    ('cv',           'CV',                   'self',     2),
    ('sop',          'Statement of purpose', 'self',     3),
    ('english_test', 'English test scores',  'external', 4),
    ('fee',          'Application fee',      'self',     5)
$$;

revoke all on function public.import_applications(jsonb, boolean) from public, anon;
grant execute on function public.import_applications(jsonb, boolean) to authenticated;
