-- Today feed: month-only deadlines and application opening dates.
--
--   * A month-only deadline (deadline_precision = 'month', stored as the 1st
--     of the month) counts down to the 1st, then to the end of that month
--     once it has begun, and its reason says the exact date isn't confirmed.
--     Requirements and letters that inherit the deadline follow the same rule.
--   * New item type 'application_opens' for applications whose portal opens
--     within the horizon, until 3 days after it opens. Ranked below real
--     deadlines (urgency − 20).
--
-- Same signature as before, so attention_feed() and its grants are unchanged.

create or replace function public.attention_feed_for(
  p_owner   uuid,
  p_now     timestamptz default now(),
  p_horizon interval    default interval '14 days'
)
returns table (
  item_type       text,         -- application_deadline | funding_deadline | requirement | letter | follow_up | task | application_opens
  item_id         uuid,
  application_id  uuid,
  professor_id    uuid,
  title           text,
  context         text,         -- 'University of Toronto · PhD Computer Science'
  reason          text,         -- why it is here, human readable
  due_at          timestamptz,
  due_tz          text,
  score           integer
)
language sql stable security definer set search_path = '' as $$
with apps as (
  select a.*, i.name as institution_name,
         i.name || ' · ' || case a.degree_type
                              when 'phd' then 'PhD' when 'msc' then 'MSc' when 'ma' then 'MA'
                              when 'mphil' then 'MPhil' when 'mres' then 'MRes' else 'Other' end
                || ' ' || a.programme_name as ctx,
         a.stage in ('researching','shortlisted','preparing','ready') as pre_submission,
         -- A month-only deadline is stored as the 1st (so reminders start
         -- early). Once that month has begun, count down to its last day
         -- instead of reporting it overdue.
         case
           when a.deadline_precision = 'month' and a.deadline_at <= p_now
           then ((date_trunc('month', a.deadline_at at time zone a.deadline_tz) + interval '1 month' - interval '1 minute')
                 at time zone a.deadline_tz)
           else a.deadline_at
         end as due_deadline_at,
         -- Portal opening, 09:00 in the university's zone.
         (a.opens_on + time '09:00') at time zone coalesce(a.deadline_tz, i.default_tz, 'UTC') as opens_at
  from public.applications a
  join public.institutions i on i.id = a.institution_id
  where a.owner_id = p_owner and a.archived_at is null and a.outcome is null
),
open_counts as (
  select a.id as application_id,
         (select count(*) from public.requirements r
           where r.application_id = a.id and r.status in ('not_started','in_progress')) as open_reqs,
         (select count(*) from public.letter_requests l
           where l.application_id = a.id and l.status not in ('submitted','declined'))  as open_letters
  from apps a
),
items as (
  -- 1. Application deadlines (only before submission)
  select 'application_deadline'::text, a.id, a.id, null::uuid,
         'Application deadline'::text, a.ctx,
         case when a.deadline_precision = 'month' then 'Exact date not confirmed — check the portal. ' else '' end ||
         case when oc.open_reqs + oc.open_letters = 0 then 'Everything ticked off — submit it'
              else concat_ws(', ',
                     case when oc.open_reqs > 0 then oc.open_reqs || ' requirement(s)' end,
                     case when oc.open_letters > 0 then oc.open_letters || ' letter(s)' end)
                   || ' outstanding'
         end,
         a.due_deadline_at, a.deadline_tz,
         public.attention_urgency(a.due_deadline_at, p_now) + 20
           + case when a.priority = 1 then 5 else 0 end
           + case when oc.open_reqs + oc.open_letters > 0 then 5 else 0 end
  from apps a join open_counts oc on oc.application_id = a.id
  where a.pre_submission and a.due_deadline_at is not null

  union all
  -- 2. Funding deadlines (skip when identical to the application deadline)
  select 'funding_deadline', a.id, a.id, null,
         'Funding deadline', a.ctx, 'Scholarship / funding application',
         a.funding_deadline_at, a.funding_deadline_tz,
         public.attention_urgency(a.funding_deadline_at, p_now) + 15
  from apps a
  where a.funding_deadline_at is not null
    and a.funding_deadline_at is distinct from a.due_deadline_at
    and a.funding_outcome is null

  union all
  -- 3. Open requirements (internal due date, else the application deadline)
  select 'requirement', r.id, a.id, null,
         r.title, a.ctx,
         case when r.depends_on = 'external' then 'Depends on someone else — chase early'
              when r.status = 'in_progress' then 'In progress'
              else 'Not started' end,
         coalesce(r.due_at, a.due_deadline_at),
         case when r.due_at is null then a.deadline_tz end,
         public.attention_urgency(coalesce(r.due_at, a.due_deadline_at), p_now)
           + case when r.depends_on = 'external' then 10 else 0 end
           + case when a.priority = 1 then 5 else 0 end
  from public.requirements r join apps a on a.id = r.application_id
  where a.pre_submission and r.status in ('not_started','in_progress')
    and coalesce(r.due_at, a.due_deadline_at) is not null

  union all
  -- 4. Letters not yet submitted
  select 'letter', l.id, a.id, null,
         'Letter from ' || rc.name, a.ctx,
         case l.status
           when 'planned'   then 'Not requested yet'
           when 'requested' then 'Requested — portal invite not sent'
           when 'invited'   then 'Invited — not submitted yet'
         end,
         coalesce(l.due_at, a.due_deadline_at),
         case when l.due_at is null then a.deadline_tz end,
         public.attention_urgency(coalesce(l.due_at, a.due_deadline_at), p_now) + 10
  from public.letter_requests l
  join apps a on a.id = l.application_id
  join public.recommenders rc on rc.id = l.recommender_id
  where l.status in ('planned','requested','invited')
    and coalesce(l.due_at, a.due_deadline_at) is not null

  union all
  -- 5. Professor follow-ups
  select 'follow_up', s.last_sent_message_id, null, p.id,
         'Follow up with ' || coalesce(p.academic_title || ' ', '') || p.name,
         i.name,
         'No reply since ' || to_char(s.last_sent_at, 'DD Mon'),
         s.next_follow_up_at, null,
         public.attention_urgency(s.next_follow_up_at, p_now) + 5
  from public.professor_outreach_status s
  join public.professors p   on p.id = s.professor_id
  join public.institutions i on i.id = p.institution_id
  where s.owner_id = p_owner and s.next_follow_up_at is not null

  union all
  -- 6. Free-standing tasks
  select 'task', t.id, t.application_id, t.professor_id,
         t.title, a.ctx,
         case t.priority when 1 then 'High priority task' else 'Task' end,
         t.due_at, null,
         public.attention_urgency(t.due_at, p_now)
           + case t.priority when 1 then 10 when 3 then -10 else 0 end
  from public.tasks t
  left join apps a on a.id = t.application_id
  where t.owner_id = p_owner and t.status = 'open' and t.due_at is not null

  union all
  -- 7. Applications opening (shown until 3 days after the portal opens)
  select 'application_opens', a.id, a.id, null,
         'Applications open', a.ctx,
         case when a.opens_precision = 'month'
              then 'Opens in ' || to_char(a.opens_on, 'FMMonth YYYY') || ' — check the portal for the date'
              else 'Portal opens' end,
         a.opens_at, coalesce(a.deadline_tz, 'UTC'),
         public.attention_urgency(a.opens_at, p_now) - 20
  from apps a
  where a.pre_submission and a.opens_on is not null
    and a.opens_at > p_now - interval '3 days'
)
select * from items i(item_type, item_id, application_id, professor_id, title, context, reason, due_at, due_tz, score)
where i.due_at <= p_now + p_horizon
order by i.score desc, i.due_at asc
$$;
