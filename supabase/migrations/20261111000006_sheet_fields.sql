-- Fields needed to replace a typical application spreadsheet (phase 1).
--
--   * deadline_precision: many sheets only know the month ("Dec-26"). A
--     month-precision deadline is stored as the 1st of that month, 23:59 in
--     deadline_tz, so every reminder fires early rather than late; the UI shows
--     "Dec 2026 · date not confirmed" instead of a fake exact time.
--   * opens_on / decision_expected_on: calendar dates (no time of day), each
--     with day or month precision.
--   * import_applications() now also carries portal_username, tuition,
--     fee_waiver, the new dates, and per-row requirements parsed from the sheet.

alter table public.applications
  add column deadline_precision text not null default 'exact'
    check (deadline_precision in ('exact','month')),
  add column opens_on date,
  add column opens_precision text check (opens_precision in ('day','month')),
  add column decision_expected_on date,
  add column decision_expected_precision text
    check (decision_expected_precision in ('day','month')),
  add constraint applications_opens_precision_chk
    check ((opens_on is null) = (opens_precision is null)),
  add constraint applications_decision_precision_chk
    check ((decision_expected_on is null) = (decision_expected_precision is null));

-- p_rows: JSON array of objects (validated client-side, re-checked by table
-- constraints here):
--   institution_name, country, programme_name, degree_type, stage, priority,
--   department, research_area, programme_url, portal_url, portal_username,
--   notes, deadline_at, deadline_tz, deadline_precision,
--   funding_deadline_at, funding_deadline_tz, fee_amount, fee_currency,
--   fee_waiver, tuition_estimate, tuition_currency,
--   opens_on, opens_precision, decision_expected_on, decision_expected_precision,
--   requirements: [{kind, title, depends_on}]   (optional; replaces the default seed)
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
      department, research_area, programme_url, portal_url, portal_username, notes,
      deadline_at, deadline_tz, deadline_precision,
      funding_deadline_at, funding_deadline_tz,
      fee_amount, fee_currency, fee_waiver, tuition_estimate, tuition_currency,
      opens_on, opens_precision, decision_expected_on, decision_expected_precision,
      submitted_at
    ) values (
      v_cycle, v_inst, trim(v_row->>'programme_name'),
      coalesce(v_row->>'degree_type', 'phd'), v_stage,
      coalesce((v_row->>'priority')::smallint, 2),
      v_row->>'department', v_row->>'research_area',
      v_row->>'programme_url', v_row->>'portal_url', v_row->>'portal_username', v_row->>'notes',
      (v_row->>'deadline_at')::timestamptz, v_row->>'deadline_tz',
      coalesce(v_row->>'deadline_precision', 'exact'),
      (v_row->>'funding_deadline_at')::timestamptz, v_row->>'funding_deadline_tz',
      (v_row->>'fee_amount')::numeric, v_row->>'fee_currency',
      coalesce(v_row->>'fee_waiver', 'none'),
      (v_row->>'tuition_estimate')::numeric, v_row->>'tuition_currency',
      (v_row->>'opens_on')::date, v_row->>'opens_precision',
      (v_row->>'decision_expected_on')::date, v_row->>'decision_expected_precision',
      case when v_stage in ('submitted','under_review','interview','decided') then now() end
    )
    returning id into v_app;
    v_apps := v_apps + 1;

    if jsonb_typeof(v_row->'requirements') = 'array'
       and jsonb_array_length(v_row->'requirements') > 0 then
      insert into public.requirements (application_id, kind, title, depends_on, sort_order)
      select v_app, coalesce(r.value->>'kind', 'other'), trim(r.value->>'title'),
             coalesce(r.value->>'depends_on', 'self'), r.ordinality::integer
        from jsonb_array_elements(v_row->'requirements') with ordinality as r(value, ordinality)
       where coalesce(trim(r.value->>'title'), '') <> '';
    elsif p_seed_requirements then
      insert into public.requirements (application_id, kind, title, depends_on, sort_order)
      select v_app, d.kind, d.title, d.depends_on, d.sort_order
        from public.default_requirements() d;
    end if;
  end loop;

  return query select v_apps, v_new_inst;
end $$;

revoke all on function public.import_applications(jsonb, boolean) from public, anon;
grant execute on function public.import_applications(jsonb, boolean) to authenticated;
