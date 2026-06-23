# supabase — Pier 36

SQL migrations for the Postgres + pgvector backend.

## Apply
```bash
# With the Supabase CLI (recommended)
supabase db push
# …or paste each file in migrations/ into the SQL editor, in order.
```

## Files
- `migrations/0001_init.sql` — core schema, pgvector, indexes (incl. keyset + ivfflat), RLS policies.
- `migrations/0002_seed_catalog.sql` — Startup Seed catalog (`seed_packs`, `seed_figures`, `user_follows`).

## Security model
- **RLS is enabled on every table.** Clients (Flutter via the anon/auth key) can only touch their own rows.
- The **worker writes with the service-role key**, which bypasses RLS for ingestion/ranking/write-back.
- `jobs` has RLS enabled with **no client policy** → service-role only.
- Secrets (LLM API keys) are **never** stored here — only references; Azure uses Managed Identity.
