-- "Fill from a programme page": every extraction the extract-programme Edge
-- Function runs, used for
--   * the per-user daily limit (each row is one Claude call), and
--   * a short-lived cache, so the same public programme page isn't sent to
--     Claude again by anyone within a few days.
-- Only the function (service role) touches this table; RLS with no policies
-- keeps it invisible to the app.

create table public.programme_extractions (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references auth.users (id) on delete cascade,
  source_url  text,                 -- null when the user pasted page text
  result      jsonb not null,
  model       text not null,
  created_at  timestamptz not null default now()
);

create index programme_extractions_owner_idx on public.programme_extractions (owner_id, created_at desc);
create index programme_extractions_url_idx on public.programme_extractions (source_url, created_at desc)
  where source_url is not null;

alter table public.programme_extractions enable row level security;
revoke all on table public.programme_extractions from anon, authenticated, public;
