-- Extra links for an application beyond the programme page and portal:
-- scholarship pages, faculty lists, admission FAQs, forum threads, etc.

create table public.application_links (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  application_id  uuid not null,
  label           text check (char_length(label) <= 200),
  url             text not null
                    check (url ~* '^https?://' and char_length(url) <= 2000),
  sort_order      integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  foreign key (application_id, owner_id) references public.applications (id, owner_id) on delete cascade
);

create index application_links_application_idx on public.application_links (application_id, sort_order);
create index application_links_owner_idx on public.application_links (owner_id);

create trigger application_links_updated_at before update on public.application_links
  for each row execute function public.set_updated_at();

alter table public.application_links enable row level security;
create policy "owner access" on public.application_links for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

-- Explicit, so the table is reachable through the API whatever the
-- project's default privileges are. RLS above limits rows to the owner.
revoke all on table public.application_links from anon, public;
grant select, insert, update, delete on table public.application_links to authenticated;
