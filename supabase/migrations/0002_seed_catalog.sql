-- 0002_seed_catalog.sql — Startup Seed catalog (global, app-curated)
-- Data is synced from the open `seed-catalog/figures.json` by a worker job.

create table if not exists public.seed_packs (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  sort int not null default 0
);

create table if not exists public.seed_figures (
  id uuid primary key default gen_random_uuid(),
  pack_id uuid not null references public.seed_packs (id) on delete cascade,
  name text not null,
  bio text,
  avatar_url text,
  x_handle text,
  blog_rss text,
  github_login text,
  arxiv_author text,
  youtube text,
  topics text[] not null default '{}'
);

create table if not exists public.user_follows (
  user_id uuid not null references auth.users (id) on delete cascade,
  figure_id uuid not null references public.seed_figures (id) on delete cascade,
  followed_at timestamptz not null default now(),
  primary key (user_id, figure_id)
);

create index if not exists idx_seed_figures_pack on public.seed_figures (pack_id);

-- RLS: catalog is world-readable; follows are owner-scoped. Writes are service-role only.
alter table public.seed_packs enable row level security;
alter table public.seed_figures enable row level security;
alter table public.user_follows enable row level security;

create policy seed_packs_read on public.seed_packs for select using (true);
create policy seed_figures_read on public.seed_figures for select using (true);
create policy user_follows_owner on public.user_follows
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
