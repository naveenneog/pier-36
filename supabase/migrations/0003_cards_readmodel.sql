-- 0003_cards_readmodel.sql
-- Denormalize the display fields onto `cards` so the feed reads from one place
-- (CQRS-lite read model), and make `content_hash` unique for idempotent upserts.

alter table public.cards add column if not exists content_hash text;
alter table public.cards add column if not exists source_type text;
alter table public.cards add column if not exists source_label text;
alter table public.cards add column if not exists title text;
alter table public.cards add column if not exists url text;
alter table public.cards add column if not exists author text;
alter table public.cards add column if not exists published_at timestamptz;

-- A card can now exist without a stored raw item.
alter table public.cards alter column item_id drop not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'cards_content_hash_key'
  ) then
    alter table public.cards add constraint cards_content_hash_key unique (content_hash);
  end if;
end $$;
