-- "Needs attention" feed: one ranked list shared by the Today screen and the
-- daily digest. Business rules live here, not in Flutter or the Edge Function,
-- so both consumers always agree and future clients (mobile, product API)
-- get the same behaviour for free.

-- ---------------------------------------------------------------------------
-- Derived outreach state per professor (never stored)
-- ---------------------------------------------------------------------------

create or replace view public.professor_outreach_status
with (security_invoker = true) as
with last_out as (
  select distinct on (m.professor_id)
         m.professor_id, m.id as message_id, m.sent_at, m.follow_up_at, m.follow_up_cleared_at
  from public.outreach_messages m
  where m.direction = 'outbound' and m.state = 'sent'
  order by m.professor_id, m.sent_at desc
),
last_in as (
  select m.professor_id, max(m.sent_at) as received_at
  from public.outreach_messages m
  where m.direction = 'inbound'
  group by m.professor_id
),
drafts as (
  select m.professor_id, count(*) as draft_count
  from public.outreach_messages m
  where m.direction = 'outbound' and m.state = 'draft'
  group by m.professor_id
),
base as (
  select p.id as professor_id,
         p.owner_id,
         p.stance,
         lo.message_id   as last_sent_message_id,
         lo.sent_at      as last_sent_at,
         li.received_at  as last_reply_at,
         coalesce(d.draft_count, 0) as draft_count,
         case
           when p.closed_at is not null                    then 'closed'
           when lo.sent_at is null and d.draft_count > 0   then 'drafting'
           when lo.sent_at is null                         then 'to_contact'
           when li.received_at >= lo.sent_at               then 'replied'
           else 'awaiting_reply'
         end as thread_state,
         lo.follow_up_at,
         lo.follow_up_cleared_at
  from public.professors p
  left join last_out lo on lo.professor_id = p.id
  left join last_in  li on li.professor_id = p.id
  left join drafts   d  on d.professor_id  = p.id
)
select b.professor_id, b.owner_id, b.stance, b.thread_state,
       b.last_sent_message_id, b.last_sent_at, b.last_reply_at, b.draft_count,
       case
         when b.thread_state = 'awaiting_reply'
          and b.follow_up_cleared_at is null
          and b.stance not in ('not_taking_students','declined')
         then b.follow_up_at
       end as next_follow_up_at
from base b;

-- ---------------------------------------------------------------------------
-- Ranked feed
-- ---------------------------------------------------------------------------

-- Urgency bucket from time remaining. Tunable in one place.
create or replace function public.attention_urgency(p_due timestamptz, p_now timestamptz)
returns integer language sql immutable as $$
  select case
    when p_due <  p_now                       then 100   -- overdue
    when p_due <  p_now + interval '24 hours' then 90
    when p_due <  p_now + interval '3 days'   then 75
    when p_due <  p_now + interval '7 days'   then 50
    else 25
  end
$$;

-- Internal: feed for an arbitrary owner. Only the service role may call it
-- (used by the digest Edge Function). Clients call attention_feed() below.
create or replace function public.attention_feed_for(
  p_owner   uuid,
  p_now     timestamptz default now(),
  p_horizon interval    default interval '14 days'
)
returns table (
  item_type       text,         -- application_deadline | funding_deadline | requirement | letter | follow_up | task
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
         a.stage in ('researching','shortlisted','preparing','ready') as pre_submission
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
         case when oc.open_reqs + oc.open_letters = 0 then 'Everything ticked off — submit it'
              else concat_ws(', ',
                     case when oc.open_reqs > 0 then oc.open_reqs || ' requirement(s)' end,
                     case when oc.open_letters > 0 then oc.open_letters || ' letter(s)' end)
                   || ' outstanding'
         end,
         a.deadline_at, a.deadline_tz,
         public.attention_urgency(a.deadline_at, p_now) + 20
           + case when a.priority = 1 then 5 else 0 end
           + case when oc.open_reqs + oc.open_letters > 0 then 5 else 0 end
  from apps a join open_counts oc on oc.application_id = a.id
  where a.pre_submission and a.deadline_at is not null

  union all
  -- 2. Funding deadlines (skip when identical to the application deadline)
  select 'funding_deadline', a.id, a.id, null,
         'Funding deadline', a.ctx, 'Scholarship / funding application',
         a.funding_deadline_at, a.funding_deadline_tz,
         public.attention_urgency(a.funding_deadline_at, p_now) + 15
  from apps a
  where a.funding_deadline_at is not null
    and a.funding_deadline_at is distinct from a.deadline_at
    and a.funding_outcome is null

  union all
  -- 3. Open requirements (internal due date, else the application deadline)
  select 'requirement', r.id, a.id, null,
         r.title, a.ctx,
         case when r.depends_on = 'external' then 'Depends on someone else — chase early'
              when r.status = 'in_progress' then 'In progress'
              else 'Not started' end,
         coalesce(r.due_at, a.deadline_at),
         case when r.due_at is null then a.deadline_tz end,
         public.attention_urgency(coalesce(r.due_at, a.deadline_at), p_now)
           + case when r.depends_on = 'external' then 10 else 0 end
           + case when a.priority = 1 then 5 else 0 end
  from public.requirements r join apps a on a.id = r.application_id
  where a.pre_submission and r.status in ('not_started','in_progress')
    and coalesce(r.due_at, a.deadline_at) is not null

  union all
  -- 4. Letters not yet submitted
  select 'letter', l.id, a.id, null,
         'Letter from ' || rc.name, a.ctx,
         case l.status
           when 'planned'   then 'Not requested yet'
           when 'requested' then 'Requested — portal invite not sent'
           when 'invited'   then 'Invited — not submitted yet'
         end,
         coalesce(l.due_at, a.deadline_at),
         case when l.due_at is null then a.deadline_tz end,
         public.attention_urgency(coalesce(l.due_at, a.deadline_at), p_now) + 10
  from public.letter_requests l
  join apps a on a.id = l.application_id
  join public.recommenders rc on rc.id = l.recommender_id
  where l.status in ('planned','requested','invited')
    and coalesce(l.due_at, a.deadline_at) is not null

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
)
select * from items i(item_type, item_id, application_id, professor_id, title, context, reason, due_at, due_tz, score)
where i.due_at <= p_now + p_horizon
order by i.score desc, i.due_at asc
$$;

revoke all on function public.attention_feed_for(uuid, timestamptz, interval) from public, anon, authenticated;
grant execute on function public.attention_feed_for(uuid, timestamptz, interval) to service_role;

-- Client entry point: always scoped to the caller.
create or replace function public.attention_feed(p_horizon interval default interval '14 days')
returns table (
  item_type text, item_id uuid, application_id uuid, professor_id uuid,
  title text, context text, reason text, due_at timestamptz, due_tz text, score integer
)
language sql stable security definer set search_path = '' as $$
  select * from public.attention_feed_for((select auth.uid()), now(), p_horizon)
  where (select auth.uid()) is not null
$$;

revoke all on function public.attention_feed(interval) from public, anon;
grant execute on function public.attention_feed(interval) to authenticated;
