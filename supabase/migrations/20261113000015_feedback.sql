-- Feedback and feature requests sent from Settings. Users can send and read
-- their own; the owner reads everything (and sets status) in the Supabase
-- dashboard: Table Editor → feedback.

create table public.feedback (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind        text not null default 'other' check (kind in ('feature','problem','other')),
  message     text not null check (char_length(trim(message)) between 1 and 4000),
  status      text not null default 'new' check (status in ('new','planned','done','declined')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index feedback_owner_idx on public.feedback (owner_id, created_at desc);
create index feedback_new_idx on public.feedback (created_at desc) where status = 'new';

create trigger feedback_updated_at before update on public.feedback
  for each row execute function public.set_updated_at();

alter table public.feedback enable row level security;

-- Send and read your own; no editing or deleting from the app (status is
-- set by the owner in the dashboard, which bypasses RLS).
create policy "read own feedback" on public.feedback for select to authenticated
  using (owner_id = (select auth.uid()));
create policy "send own feedback" on public.feedback for insert to authenticated
  with check (owner_id = (select auth.uid()) and status = 'new');

revoke all on table public.feedback from anon, authenticated, public;
grant select, insert on table public.feedback to authenticated;
