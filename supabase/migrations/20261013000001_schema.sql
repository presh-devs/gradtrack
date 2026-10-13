-- GradTrack MVP-0 schema (Supabase / PostgreSQL 15+)
--
-- Conventions
--   * Every user-owned table has owner_id (defaults to auth.uid()) and RLS.
--   * Enumerations are text + CHECK, not Postgres ENUM types: values can be
--     added *and removed* in later migrations without type rewrites.
--   * Child rows reference parents through composite (id, owner_id) foreign
--     keys. FK checks bypass RLS, so a plain FK would let a user attach a row
--     to someone else's application by guessing its id. The composite FK makes
--     that impossible at the database level.
--   * States that depend on "now" (overdue, follow-up due) are never stored;
--     they are computed in views/functions (see 002_attention_feed.sql).
--   * All instants are timestamptz. Deadlines also store the IANA zone they
--     were published in (deadline_tz) so the UI can show "23:59 ET" faithfully.

create extension if not exists citext;

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------------------
-- Profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id                 uuid primary key references auth.users (id) on delete cascade,
  display_name       text,
  timezone           text not null default 'UTC',          -- IANA, e.g. 'Africa/Lagos'
  digest_enabled     boolean not null default true,
  digest_hour_local  smallint not null default 7 check (digest_hour_local between 0 and 23),
  digest_send_when_empty boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- Create a profile automatically on sign-up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1)));
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Application cycles
-- ---------------------------------------------------------------------------

create table public.cycles (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name         text not null,                               -- 'Fall 2027'
  start_term   text check (start_term in ('spring','summer','fall','winter')),
  start_year   smallint,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (id, owner_id)
);

create trigger cycles_updated_at before update on public.cycles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Institutions (owner-scoped for v1; can become a shared catalogue later)
-- ---------------------------------------------------------------------------

create table public.institutions (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name         text not null,
  country      text,                                        -- ISO 3166-1 alpha-2
  website_url  text,
  default_tz   text,                                        -- prefills deadline_tz
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (id, owner_id),
  unique (owner_id, name)
);

create trigger institutions_updated_at before update on public.institutions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Applications (programme + application combined for v1)
-- ---------------------------------------------------------------------------

create table public.applications (
  id                    uuid primary key default gen_random_uuid(),
  owner_id              uuid not null default auth.uid() references auth.users (id) on delete cascade,
  cycle_id              uuid not null,
  institution_id        uuid not null,

  -- programme facts
  department            text,
  programme_name        text not null,
  degree_type           text not null default 'phd'
                          check (degree_type in ('msc','ma','mphil','mres','phd','other')),
  research_area         text,
  programme_url         text,
  portal_url            text,
  portal_username       text,          -- never store portal passwords
  funding_url           text,
  source_url            text,          -- where the info was verified

  -- dates (instant + zone it was published in)
  deadline_at           timestamptz,
  deadline_tz           text,
  funding_deadline_at   timestamptz,
  funding_deadline_tz   text,

  -- money
  fee_amount            numeric(10,2),
  fee_currency          char(3),
  fee_waiver            text not null default 'none'
                          check (fee_waiver in ('none','eligible','requested','granted','denied')),
  tuition_estimate      numeric(12,2),
  tuition_currency      char(3),

  -- progress
  stage                 text not null default 'researching'
                          check (stage in ('researching','shortlisted','preparing','ready',
                                           'submitted','under_review','interview','decided')),
  outcome               text check (outcome in ('accepted','rejected','waitlisted','withdrawn')),
  funding_outcome       text check (funding_outcome in ('funded','partial','unfunded','pending')),
  priority              smallint not null default 2 check (priority between 1 and 3), -- 1 = top choice
  submitted_at          timestamptz,
  decided_at            timestamptz,

  notes                 text,
  archived_at           timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  unique (id, owner_id),
  foreign key (cycle_id, owner_id)       references public.cycles (id, owner_id) on delete cascade,
  foreign key (institution_id, owner_id) references public.institutions (id, owner_id),
  check (outcome is null or stage = 'decided'),
  check (deadline_at is null or deadline_tz is not null),
  check (funding_deadline_at is null or funding_deadline_tz is not null)
);

create index applications_owner_deadline_idx on public.applications (owner_id, deadline_at)
  where archived_at is null;
create index applications_cycle_idx on public.applications (cycle_id);
create index applications_institution_idx on public.applications (institution_id);

create trigger applications_updated_at before update on public.applications
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Documents (links in MVP-0; storage objects later)
-- ---------------------------------------------------------------------------

create table public.documents (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title          text not null,                     -- 'CV (research version)'
  kind           text not null default 'other'
                   check (kind in ('cv','sop','research_statement','personal_statement',
                                   'transcript','certificate','test_report','writing_sample',
                                   'portfolio','other')),
  url            text,                              -- Drive / OneDrive link
  version_label  text,
  notes          text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (id, owner_id)
);

create trigger documents_updated_at before update on public.documents
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Requirements (per-application checklist; actionable in their own right)
-- ---------------------------------------------------------------------------

create table public.requirements (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  application_id  uuid not null,
  kind            text not null default 'other'
                    check (kind in ('transcript','certificate','cv','sop','research_statement',
                                    'personal_statement','english_test','standardized_test',
                                    'writing_sample','portfolio','fee','other')),
  title           text not null,
  status          text not null default 'not_started'
                    check (status in ('not_started','in_progress','done','not_applicable')),
  depends_on      text not null default 'self'
                    check (depends_on in ('self','external')),   -- e.g. registrar, test agency
  due_at          timestamptz,                                   -- internal deadline
  document_id     uuid,
  instructions    text,
  notes           text,
  sort_order      integer not null default 0,
  completed_at    timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete cascade,
  foreign key (document_id, owner_id)    references public.documents (id, owner_id)
);

create index requirements_application_idx on public.requirements (application_id);
create index requirements_open_idx on public.requirements (owner_id)
  where status in ('not_started','in_progress');

create trigger requirements_updated_at before update on public.requirements
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Recommenders and letter requests
-- ---------------------------------------------------------------------------

create table public.recommenders (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name            text not null,
  academic_title  text,
  email           citext,
  institution     text,
  relationship    text,                -- 'Final-year project supervisor'
  agreed_at       timestamptz,         -- agreed to write (in general)
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (id, owner_id)
);

create trigger recommenders_updated_at before update on public.recommenders
  for each row execute function public.set_updated_at();

create table public.letter_requests (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  recommender_id  uuid not null,
  application_id  uuid not null,
  status          text not null default 'planned'
                    check (status in ('planned','requested','invited','submitted','declined')),
  requested_at    timestamptz,         -- asked the recommender for this programme
  invited_at      timestamptz,         -- portal invitation sent
  submitted_at    timestamptz,
  due_at          timestamptz,         -- recommender deadline if different from application
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (recommender_id, application_id),
  foreign key (recommender_id, owner_id) references public.recommenders (id, owner_id) on delete cascade,
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete cascade
);

create index letter_requests_application_idx on public.letter_requests (application_id);

create trigger letter_requests_updated_at before update on public.letter_requests
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Professors and outreach
-- ---------------------------------------------------------------------------

create table public.professors (
  id                  uuid primary key default gen_random_uuid(),
  owner_id            uuid not null default auth.uid() references auth.users (id) on delete cascade,
  institution_id      uuid not null,
  name                text not null,
  academic_title      text,
  department          text,
  email               citext,
  profile_url         text,
  lab_url             text,
  research_interests  text,
  stance              text not null default 'unknown'
                        check (stance in ('unknown','interested','not_taking_students','declined')),
  closed_at           timestamptz,     -- user ended the conversation
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (id, owner_id),
  foreign key (institution_id, owner_id) references public.institutions (id, owner_id)
);

create index professors_institution_idx on public.professors (institution_id);

create trigger professors_updated_at before update on public.professors
  for each row execute function public.set_updated_at();

create table public.application_professors (
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  application_id  uuid not null,
  professor_id    uuid not null,
  created_at      timestamptz not null default now(),
  primary key (application_id, professor_id),
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete cascade,
  foreign key (professor_id, owner_id)   references public.professors (id, owner_id) on delete cascade
);

create index application_professors_professor_idx on public.application_professors (professor_id);

-- One row per email (or other message) in a professor conversation.
-- Outbound rows move draft -> sent. Opening a mail client never changes state;
-- only an explicit "Mark as sent" sets state = 'sent' and sent_at.
create table public.outreach_messages (
  id               uuid primary key default gen_random_uuid(),
  owner_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  professor_id     uuid not null,
  application_id   uuid,
  direction        text not null check (direction in ('outbound','inbound')),
  kind             text not null default 'intro'
                     check (kind in ('intro','follow_up','reply','other')),
  state            text not null default 'draft'
                     check (state in ('draft','sent')),
  subject          text,
  body             text,
  sent_at          timestamptz,        -- outbound: when sent; inbound: when received
  thread_url       text,               -- link to the conversation in the mail client
  follow_up_at     timestamptz,        -- outbound only
  follow_up_cleared_at timestamptz,    -- user cancelled / handled the follow-up
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  foreign key (professor_id, owner_id)   references public.professors (id, owner_id) on delete cascade,
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete set null (application_id),
  check (direction = 'outbound' or (state = 'sent' and follow_up_at is null)),
  check (state = 'draft' or sent_at is not null)
);

create index outreach_messages_professor_idx on public.outreach_messages (professor_id, sent_at);

create trigger outreach_messages_updated_at before update on public.outreach_messages
  for each row execute function public.set_updated_at();

-- Reusable snippets for emails (plain text; placeholders arrive in MVP-1).
create table public.email_templates (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null,
  kind        text not null default 'intro' check (kind in ('intro','follow_up','other')),
  subject     text,
  body        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger email_templates_updated_at before update on public.email_templates
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Tasks (only things that are not requirements / letters / outreach)
-- ---------------------------------------------------------------------------

create table public.tasks (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  application_id  uuid,
  professor_id    uuid,
  title           text not null,
  description     text,
  due_at          timestamptz,
  priority        smallint not null default 2 check (priority between 1 and 3), -- 1 = high
  status          text not null default 'open' check (status in ('open','done','cancelled')),
  completed_at    timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete cascade,
  foreign key (professor_id, owner_id)   references public.professors (id, owner_id) on delete cascade
);

create index tasks_open_idx on public.tasks (owner_id, due_at) where status = 'open';

create trigger tasks_updated_at before update on public.tasks
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- (select auth.uid()) is evaluated once per statement instead of per row.
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
create policy "own profile" on public.profiles
  for all to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

do $$
declare t text;
begin
  foreach t in array array[
    'cycles','institutions','applications','documents','requirements',
    'recommenders','letter_requests','professors','application_professors',
    'outreach_messages','email_templates','tasks'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "owner access" on public.%I for all to authenticated
         using (owner_id = (select auth.uid()))
         with check (owner_id = (select auth.uid()))', t);
    execute format('create index if not exists %I on public.%I (owner_id)', t || '_owner_idx', t);
  end loop;
end $$;
