-- 0001_init.sql — Pier 36 core schema (Postgres + pgvector + RLS)
-- Apply via Supabase CLI (`supabase db push`) or the SQL editor.

create extension if not exists "vector";
create extension if not exists "pgcrypto"; -- gen_random_uuid()

-- ── Sources ────────────────────────────────────────────────────────────────
create table if not exists public.sources (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references auth.users (id) on delete cascade,
  type text not null check (
    type in ('github', 'arxiv', 'rss', 'blog', 'x', 'reddit', 'notes_git', 'newsletter')
  ),
  name text not null,
  config jsonb not null default '{}'::jsonb,
  schedule text not null default '@daily',
  enabled boolean not null default true,
  last_synced_at timestamptz,
  created_at timestamptz not null default now()
);

-- ── Raw ingested items ─────────────────────────────────────────────────────
create table if not exists public.source_items (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.sources (id) on delete cascade,
  external_id text not null,
  url text,
  title text,
  author text,
  raw_content text,
  content_hash text not null,
  published_at timestamptz,
  fetched_at timestamptz not null default now(),
  unique (source_id, external_id)
);

-- ── Processed cards (hybrid summary + embedding) ───────────────────────────
create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.source_items (id) on delete cascade,
  summary_short text not null,
  summary_long text,
  tags text[] not null default '{}',
  embedding vector(1536),
  media_url text,
  blurhash text,
  importance_score double precision not null default 0,
  created_at timestamptz not null default now()
);

-- ── Interests + ranking read model (CQRS-lite) ─────────────────────────────
create table if not exists public.user_interests (
  user_id uuid not null references auth.users (id) on delete cascade,
  topic text not null,
  weight double precision not null default 1,
  embedding vector(1536),
  primary key (user_id, topic)
);

create table if not exists public.feed_ranked (
  user_id uuid not null references auth.users (id) on delete cascade,
  card_id uuid not null references public.cards (id) on delete cascade,
  score double precision not null,
  created_at timestamptz not null default now(),
  primary key (user_id, card_id)
);

create table if not exists public.feed_state (
  user_id uuid not null references auth.users (id) on delete cascade,
  card_id uuid not null references public.cards (id) on delete cascade,
  seen boolean not null default false,
  saved boolean not null default false,
  liked boolean not null default false,
  dismissed boolean not null default false,
  seeded_to_brain boolean not null default false,
  seen_at timestamptz,
  primary key (user_id, card_id)
);

-- ── Collections ────────────────────────────────────────────────────────────
create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.collection_items (
  collection_id uuid not null references public.collections (id) on delete cascade,
  card_id uuid not null references public.cards (id) on delete cascade,
  primary key (collection_id, card_id)
);

-- ── Second Brain write-back ────────────────────────────────────────────────
create table if not exists public.brain_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  card_id uuid not null references public.cards (id) on delete cascade,
  repo text not null,
  file_path text,
  commit_sha text,
  frontmatter jsonb,
  status text not null default 'queued' check (status in ('queued', 'committed', 'failed')),
  created_at timestamptz not null default now()
);

-- ── LLM provider config (secrets stored by reference only) ─────────────────
create table if not exists public.llm_providers (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references auth.users (id) on delete cascade,
  name text not null,
  provider_type text not null,
  auth_method text not null,
  config jsonb not null default '{}'::jsonb,
  is_default boolean not null default false,
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

-- ── Job queue ──────────────────────────────────────────────────────────────
create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued' check (status in ('queued', 'running', 'done', 'failed')),
  attempts int not null default 0,
  run_after timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- ── Indexes ────────────────────────────────────────────────────────────────
create index if not exists idx_source_items_source on public.source_items (source_id);
create index if not exists idx_source_items_hash on public.source_items (content_hash);
create index if not exists idx_cards_item on public.cards (item_id);
create index if not exists idx_cards_created on public.cards (created_at desc);
-- Keyset-pagination covering index for the feed read path.
create index if not exists idx_feed_ranked_keyset on public.feed_ranked (user_id, score desc, card_id desc);
create index if not exists idx_jobs_due on public.jobs (status, run_after);
-- Vector ANN index (cosine). Best built after data exists; safe to keep here for dev.
create index if not exists idx_cards_embedding on public.cards
  using ivfflat (embedding vector_cosine_ops) with (lists = 100);

-- ── Row-Level Security ─────────────────────────────────────────────────────
-- The worker writes with the service role (bypasses RLS). Clients use anon/auth keys.
alter table public.sources enable row level security;
alter table public.source_items enable row level security;
alter table public.cards enable row level security;
alter table public.user_interests enable row level security;
alter table public.feed_ranked enable row level security;
alter table public.feed_state enable row level security;
alter table public.collections enable row level security;
alter table public.collection_items enable row level security;
alter table public.brain_entries enable row level security;
alter table public.llm_providers enable row level security;
alter table public.jobs enable row level security; -- no client policy: service-role only

create policy sources_owner on public.sources
  for all using (owner = auth.uid()) with check (owner = auth.uid());

create policy source_items_owner on public.source_items
  for select using (
    exists (select 1 from public.sources s where s.id = source_id and s.owner = auth.uid())
  );

create policy cards_visible on public.cards
  for select using (
    exists (select 1 from public.feed_ranked fr where fr.card_id = id and fr.user_id = auth.uid())
  );

create policy interests_owner on public.user_interests
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy feed_ranked_owner on public.feed_ranked
  for select using (user_id = auth.uid());

create policy feed_state_owner on public.feed_state
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy collections_owner on public.collections
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy collection_items_owner on public.collection_items
  for all using (
    exists (select 1 from public.collections c where c.id = collection_id and c.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.collections c where c.id = collection_id and c.user_id = auth.uid())
  );

create policy brain_entries_owner on public.brain_entries
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy llm_providers_owner on public.llm_providers
  for all using (owner = auth.uid()) with check (owner = auth.uid());
