# Design Doc — Pier 36

> A curated knowledge aggregator that watches your sources (your notes, GitHub, arXiv, blogs/RSS, newsletters),
> turns updates into AI-summarized short cards, and serves them as a swipeable, Stories/Reels-style feed.

**Status:** Draft v0.1 — for review & agreement before build
**Owner:** @naveenneog
**Last updated:** 2026-06-23
**Related:** `lld-design.md` (low-level design, patterns, latency & design system) · `CHANGELOG.md` (decision & change log)

**App name:** Pier 36  _(earlier candidates: Synapse, Cortex, Pulse, Recall, NeuroReel, BrainFeed)._

---

## 1. Vision & Concept

"TikTok/Stories for your Second Brain." Instead of doom-scrolling generic feeds, you scroll *your* knowledge:
the repos you follow, the papers in your field, the blogs you trust, and your own notes — distilled into
glanceable cards. Tap any card to expand into the full source. The app keeps you current on *changes and news*
in the topics you care about, with near-zero effort.

It pulls from your own notes plus the places ideas break first — **tech blogs, X (Twitter) accounts, Reddit
discussion threads, GitHub, and arXiv**. Crucially, the Second Brain is a **two-way hub**: external platforms
*seed* content in, you curate, and curated knowledge flows *back out* into the feed as topic-status cards — a
compounding knowledge loop.

**One-liner:** *Your knowledge, delivered as stories.*

---

## 2. Goals & Non-Goals

### Goals
- Aggregate multiple personal-knowledge sources into one unified feed.
- Deliver content in a short-form, swipeable, Stories/Reels UX (fast, glanceable, delightful).
- Hybrid cards: AI short summary up front, tap-to-expand to full source.
- Surface *what changed / what's new* (releases, new papers, new commits, new posts).
- Personalize ranking by interest (explicit topics now, semantic/behavioral later).
- Start with a small user base but be **cloud-native and horizontally scalable** from day one.
- Pluggable LLM gateway: default to **Azure via DefaultAzureCredential (Managed Identity)**, easy config for others.

### Non-Goals (initially)
- Public social network / comments / followers graph.
- Hosting original video/audio content.
- Being a general-purpose RSS reader (we're opinionated and summarized, not a raw inbox).
- Real-time (<1 min) updates — periodic sync is fine for v1.

---

## 3. Personas & Core Use Cases

- **The Researcher (you):** follows arXiv categories + key repos; wants a 5-minute morning scroll of "what's new in my field."
- **The Builder:** tracks releases/commits of OSS deps and trending repos; wants to know what changed without reading changelogs.
- **The Curator:** maintains an Obsidian/markdown "second brain"; wants their own notes resurfaced + connected to fresh external updates.

**Key flows**
1. Onboard → **pick a Startup Seed pack (AI figures)** → connect more sources → adjust interests.
2. Open app → vertical swipe through ranked cards → tap to expand → save/like/dismiss.
3. Receive a daily digest push ("12 new updates in AI Agents, RAG, Flutter").

---

## 4. High-Level Architecture

```
                 ┌──────────────────────────────────────────────┐
                 │                Flutter App (client)           │
                 │  Feed (Reels/Stories) · Sources · Interests   │
                 │  Saved · Settings · LLM Provider Config UI    │
                 └───────────────▲───────────────────▲───────────┘
                                 │ REST/Realtime      │ FCM push
                                 │ (Supabase client)  │
        ┌────────────────────────┴───────────────┐   │
        │                SUPABASE                  │   │
        │  Auth · Postgres(+pgvector) · Storage    │   │
        │  Realtime · Edge Functions · RLS         │   │
        └───▲───────────────▲───────────────▲──────┘   │
            │ read/write     │ jobs/queue    │ serve     │
            │                │               │           │
   ┌────────┴───────┐  ┌─────┴───────────────┴────┐  ┌──┴─────────┐
   │ Source         │  │ Worker Service (Python)   │  │ Notifier   │
   │ Connectors     │  │ on Azure Container Apps    │  │ (FCM)      │
   │ GitHub/arXiv/  │  │  • ingest & dedup          │  └────────────┘
   │ RSS/Notes-Git/ │  │  • LLM Gateway (summaries) │
   │ Newsletter     │  │  • embeddings + ranking    │
   └────────────────┘  └──────────▲─────────────────┘
                                   │ DefaultAzureCredential
                            ┌──────┴───────────────────────┐
                            │ LLM providers (Azure OpenAI / │
                            │ OpenAI / Anthropic / OpenRouter│
                            │ / Ollama) via Gateway          │
                            └────────────────────────────────┘
```

**Why this split:**
- **Supabase** = data + auth + realtime + storage + RLS + light edge functions (great DX, scales, open-source).
- **Python worker on Azure Container Apps** = heavier ingestion/summarization/embeddings, and it can authenticate to
  **Azure OpenAI via DefaultAzureCredential (Managed Identity)** — matching your actual access. Scales to zero / out.
- Clear separation lets each tier scale independently (stateless workers, queue-driven).

**Sources now span social & blogs** — GitHub, arXiv, **tech blogs**, **X (Twitter) accounts**, **Reddit threads**,
newsletters, and your Git notes — all behind one connector interface. The **Second Brain is the hub**:

```
 X / Reddit / Tech blogs / GitHub / arXiv ──► ingest ──► AI cards ──► Reels feed
                                                            │ save / auto-seed
                                                            ▼
                                              Second Brain (Git markdown notes)
                                                            │
                                                            └──► re-ingested + searchable ──► feed
```

External platforms *seed* into your Second Brain; curated notes flow *back* into the feed — a compounding loop.

---

## 5. Data Sources & Connectors

Pluggable connector interface; each source type implements `fetch() -> [RawItem]`.
The **Second Brain (Git) is both a source and a sink**: connectors seed items in, and curated cards are written
back out as markdown notes (see write-back, below).

| Source         | What we pull                                    | API / method                            |
|----------------|-------------------------------------------------|-----------------------------------------|
| Your notes     | New/changed markdown notes (your Second Brain)  | Git repo (GitHub) clone/pull + diff     |
| GitHub         | Releases, notable commits, trending, new stars  | GitHub REST/GraphQL API                 |
| arXiv          | New papers by category/keyword/author           | arXiv Atom API                          |
| Tech blogs     | New posts from a followed blog list             | RSS/Atom (+ OG-image scrape)            |
| X (Twitter)    | Posts/threads from followed accounts & lists    | X API v2 (paid tiers) / list timelines  |
| Reddit         | Hot/top posts & top comments in followed subs   | Reddit API (OAuth, PRAW)                |
| Newsletters    | New issues                                       | RSS bridge / email-to-RSS / inbox       |
| RSS (generic)  | Any feed URL                                      | RSS/Atom feeds                          |

**Follow model:** users *follow* handles/subs/blogs (e.g., `@karpathy`, `r/MachineLearning`, a blog URL); each
becomes a filtered connector instance shown in the "Sources" screen with an enable toggle.

**Write-back (seed to Second Brain):** any card can be promoted to your Git knowledge base as a structured
markdown note — frontmatter (source, url, tags, date) + AI summary + your highlights — committed via the GitHub
API. Optional **auto-seed** for high-relevance items. This makes the Brain the durable, versioned hub that
re-feeds the app.

**Connector config (per source):** type, credentials/token ref, filters (handles, subreddits, repos, categories,
keywords, authors), poll schedule (cron), enabled flag.

> ⚠️ **Platform constraints:** **X is planned for v2** (its API is paid/rate-limited — budget a tier or use list
> timelines); Reddit API has rate limits + content-use terms — respect both. Both sit behind the connector
> interface so they can be throttled or swapped without touching the pipeline.

---

## 6. Content Pipeline

```
[Scheduler] → [Connector.fetch] → [Dedup by hash/external_id] → source_items
   → [LLM Gateway: short + long summary + tags] → [Embedding (pgvector)]
   → cards → [Ranking per user] → feed → [Client + Daily digest notify]
                                            │ save / auto-seed
   markdown note ◄── [Render] ◄─────────────┘ ──► [Commit to Git repo] ──┐
        └──────────────── re-ingested as a Notes(Git) source item ◄──────┘
```

1. **Scheduler** (pg_cron or worker cron) enqueues fetch jobs per source.
2. **Ingest**: connector fetches new items; dedup via content hash + external id; store raw in `source_items`.
3. **Summarize**: LLM Gateway produces a 2–3 line **short** summary + a longer **expanded** summary + topic tags.
4. **Embed**: compute embedding for semantic interest-matching (pgvector).
5. **Rank** (per user): `score = w1·recency + w2·source_weight + w3·cosine(card, user_interests) + w4·engagement`.
6. **Serve**: client reads ranked feed via Supabase (REST + Realtime for live inserts).
7. **Notify**: daily digest (or threshold-based) push via FCM.
8. **Seed to Second Brain** (on save, or auto for high-relevance): render a markdown note (frontmatter + summary +
   highlights) and commit to the Git repo via the GitHub API; it re-enters the feed as a first-class Notes(Git) item.

Processing is **queue-driven** (a `jobs` table or Azure Storage Queue) so workers scale horizontally and retry safely.

---

## 7. Data Model (Postgres + pgvector)

```sql
-- Auth handled by Supabase (auth.users)

sources(
  id uuid pk, owner uuid fk->users, type text,         -- github|arxiv|rss|blog|x|reddit|notes_git|newsletter
  name text, config jsonb, schedule text, enabled bool,
  last_synced_at timestamptz, created_at timestamptz)

source_items(
  id uuid pk, source_id uuid fk, external_id text, url text,
  title text, author text, raw_content text, content_hash text,
  published_at timestamptz, fetched_at timestamptz,
  unique(source_id, external_id))

cards(
  id uuid pk, item_id uuid fk, summary_short text, summary_long text,
  tags text[], embedding vector(1536), media_url text,
  importance_score float, created_at timestamptz)

user_interests(
  user_id uuid fk, topic text, weight float,
  embedding vector(1536))                              -- semantic profile

-- Startup Seed catalog (global, app-curated; synced from open JSON in GitHub)
seed_packs(id uuid pk, slug text, title text, sort int)
seed_figures(
  id uuid pk, pack_id uuid fk, name text, bio text, avatar_url text,
  x_handle text, blog_rss text, github_login text, arxiv_author text,
  youtube text, topics text[])                          -- topics seed user_interests

user_follows(                                           -- who/what a user followed via Seed
  user_id uuid fk, figure_id uuid fk, followed_at timestamptz,
  primary key(user_id, figure_id))

feed_state(
  user_id uuid fk, card_id uuid fk, seen bool, saved bool,
  liked bool, dismissed bool, seeded_to_brain bool, seen_at timestamptz,
  primary key(user_id, card_id))

collections(id uuid pk, user_id uuid fk, name text)
collection_items(collection_id uuid fk, card_id uuid fk)

brain_entries(                                          -- write-back to Second Brain (Git)
  id uuid pk, user_id uuid fk, card_id uuid fk, repo text,
  file_path text, commit_sha text, frontmatter jsonb,
  status text, created_at timestamptz)                  -- queued|committed|failed

llm_providers(                                         -- see §8
  id uuid pk, owner uuid fk, name text, provider_type text,
  auth_method text, config jsonb, is_default bool, enabled bool,
  created_at timestamptz)

jobs(id uuid pk, type text, payload jsonb, status text,    -- queued|running|done|failed
  attempts int, run_after timestamptz, created_at timestamptz)
```

**RLS:** every user-owned table guarded by Supabase Row-Level Security → strict per-user isolation (and future per-org).

---

## 8. LLM Gateway (pluggable, Azure-first)

A provider-abstraction layer behind a single interface:
`summarize(text, opts)` and `embed(text)`. Providers are configured in DB and editable from an in-app UI.

### Supported providers
- `azure_openai` — **auth via DefaultAzureCredential (Managed Identity)** *(default for owner)*
- `openai`, `anthropic`, `gemini` — API key
- `openrouter`, `groq`, `together` — API key (open-weights, low cost)
- `ollama` / self-hosted — base URL (fully open)

### Configuration schema (`llm_providers.config` jsonb)

| Field            | Applies to        | Example                                  |
|------------------|-------------------|------------------------------------------|
| `provider_type`  | all               | `azure_openai`                           |
| `auth_method`    | all               | `default_azure_credential` \| `api_key` \| `base_url` |
| `endpoint`       | azure / self-host | `https://my-aoai.openai.azure.com`       |
| `deployment`     | azure             | `gpt-4o-mini`                            |
| `api_version`    | azure             | `2024-10-21`                             |
| `managed_identity_client_id` | azure (optional) | for user-assigned MI         |
| `tenant_id` / `scope` | azure (optional) | `https://cognitiveservices.azure.com/.default` |
| `api_key_ref`    | api_key providers | secret reference (never plaintext)       |
| `base_url`       | openrouter/ollama | `http://localhost:11434`                 |
| `model`          | all               | `gpt-4o-mini` / `llama3.1`               |
| `embed_model`    | all               | `text-embedding-3-small`                 |
| `temperature`, `max_tokens`, `top_p` | all | tuning params                  |
| `summary_prompt` | all               | template for short/long summary          |
| `timeout_s`, `max_retries`, `rate_limit_rpm` | all | resilience            |
| `fallback_provider_id` | all         | provider to use on failure               |
| `is_default`, `enabled` | all        | flags                                    |
| `monthly_budget_usd` | all (optional)| cost cap / alerting                      |

**Secrets:** API keys stored in a vault (Azure Key Vault or Supabase Vault), referenced by id — never in the client,
never plaintext in DB. Azure path uses Managed Identity, so **no secret to store** for the owner.

### In-app config UI (Settings → AI Providers)
- List of provider cards (name, type, default badge, enabled toggle).
- **Add / Edit / Delete** provider with a dynamic form (fields shown depend on `provider_type`/`auth_method`).
- **Test connection** button (round-trip a tiny prompt; show latency + result).
- **Set as default**; optional **per-source override** (e.g., cheap model for RSS, better model for papers).
- Budget/usage readout per provider.

---

## 9. Client App (Flutter)

### Screens
1. **Onboarding / Auth** — Supabase auth (email + OAuth).
2. **Startup Seed (starter packs)** — curated **AI Figures** to one-tap follow + adopt their interests (see below).
3. **Feed (Reels/Stories)** — full-screen vertical `PageView`, one card per page:
   - Top: source badge + topic chips + time.
   - Middle: AI short summary (big, readable).
   - Bottom: actions (save ★, like ♥, dismiss ✕, open ↗).
   - **Tap** → expand sheet with `summary_long` + link to full source (in-app reader/webview).
   - Stories-style segmented progress bar across a "channel" of cards.
4. **Sources** — add/configure connectors; per-source filters & schedule.
5. **Interests** — pick/adjust topics; (later) auto-learned profile.
6. **Saved / Collections** — bookmarked cards, foldered.
7. **Settings** — account, notifications, **AI Providers** (§8).

### Startup Seed — AI Figures Starter Packs

Solves the cold-start problem: on first run (and re-openable anytime from Sources), the user sees a curated catalog
of **major AI figures** grouped into themed packs. This bootstraps both *follows* and *interests* in seconds.

**Each figure card shows:** name, avatar, one-line bio, topic tags, and linked sources (blog/RSS, GitHub, arXiv
author, X handle, YouTube). Actions:
- **Follow** → provisions connector instances for that figure's available sources.
- **Adopt interests** → adds the figure's topic tags to your interest profile (seeds ranking/embeddings).
- **Follow entire pack** → one tap to follow everyone in a pack.

**Example packs (curated, editable, verify handles at build):**
- *Deep Learning Pioneers:* Geoffrey Hinton, Yann LeCun (@ylecun), Yoshua Bengio, Fei-Fei Li (@drfeifei)
- *Frontier Labs & LLMs:* Ilya Sutskever (@ilyasut), Andrej Karpathy (@karpathy), Jeff Dean (@JeffDean)
- *AI Leaders / Founders:* Demis Hassabis (@demishassabis), Sam Altman (@sama), Dario Amodei
- *Educators & Builders:* Andrew Ng (@AndrewYNg), Jeremy Howard (@jeremyphoward), François Chollet (@fchollet), Jim Fan (@DrJimFan)

**Catalog source:** the figure list lives as an **open, versioned JSON/YAML in a GitHub repo** (community-extensible),
synced into the Supabase `seed_figures`/`seed_packs` tables — open, and updatable without an app release.

> Note: since **X ingestion is v2**, following a figure in MVP pulls their **blog + GitHub + arXiv** now; the stored
> X handle activates automatically when the X connector ships in v2.

### UX notes
- Smooth gestures/animations (Flutter's strength) — swipe up=next, swipe down=prev, swipe left=dismiss, double-tap=like.
- Offline cache of last N cards (later).
- Light/dark themes.

---

## 10. Personalization & Ranking

- **v1:** explicit interests (chips) **+ Startup Seed** (adopt AI figures' topics/follows) + source weights + recency → ranking score.
- **v2:** semantic profile — embed your interests & engagement; rank by cosine similarity (pgvector) to card embeddings.
- **v3:** behavioral learning — likes/saves/dwell-time tune weights; dedup/cluster near-duplicate items across sources.

---

## 11. Notifications ("status updates")

- **Daily digest** push (FCM): "N new updates across your topics."
- **Threshold/breaking**: high-importance items (e.g., major release of a followed repo) can push immediately.
- All configurable per channel; quiet hours.

---

## 12. Auth, Multi-Tenancy & Security

- Supabase Auth (JWT). All data access via **RLS** keyed on `auth.uid()`.
- Future orgs/teams: add `org_id` + membership table; RLS extends to org scope (shared team feeds).
- Secrets in vault; no provider keys on device. Azure uses Managed Identity (no static secret).
- HTTPS everywhere; least-privilege tokens for connectors (e.g., GitHub fine-grained PAT or GitHub App).

---

## 13. Scalability Plan

- **Stateless workers** + **queue-driven** processing → scale horizontally (Azure Container Apps scale rules / KEDA on queue length).
- Supabase Postgres: start small; add read replicas + connection pooling (pgBouncer) as load grows.
- Partition `source_items`/`cards` by time; archive cold data to storage.
- CDN for media/thumbnails.
- Idempotent ingestion (dedup by hash) so retries/replays are safe.
- Observability: structured logs, job metrics, per-provider LLM cost/latency dashboards.

---

## 14. Feature List (prioritized)

### MVP (v1)
- [ ] Auth (Supabase)
- [ ] Source connectors: GitHub, arXiv, RSS/tech-blogs, Notes-Git, Reddit; (Newsletter via RSS bridge)
- [ ] **Startup Seed** — curated AI-figures starter packs (one-tap follow + adopt interests)
- [ ] **Save card → Second Brain** (structured markdown note committed to Git via GitHub API)
- [ ] Ingestion + dedup pipeline
- [ ] LLM Gateway with **Azure DefaultAzureCredential** default + pluggable config
- [ ] Hybrid AI cards (short + tap-to-expand long)
- [ ] Reels/Stories feed UI (swipe, save, like, dismiss, open)
- [ ] Explicit interests + basic ranking (recency + source weight + topic match)
- [ ] AI Providers config UI (list, add/edit, test connection, set default)
- [ ] Daily digest push (FCM)

### v2
- [ ] **X (Twitter) connector** — followed accounts/lists *(paid X API tier)*
- [ ] Semantic ranking via embeddings (pgvector)
- [ ] Semantic search across your knowledge
- [ ] Collections/folders + share card
- [ ] Cross-source dedup/clustering across X/Reddit/blogs/papers ("covered by 3 sources")
- [ ] Auto-seed high-relevance items to the Second Brain
- [ ] Offline caching
- [ ] In-app reader improvements
- [ ] "Ask your brain" — RAG chat over your knowledge

### v3 / Scale
- [ ] Orgs/teams + shared feeds
- [ ] Behavioral personalization & recommendations
- [ ] Connector plugin SDK (custom sources)
- [ ] Analytics dashboard
- [ ] iOS release (Flutter → App Store)

---

## 15. Tech Stack Summary

| Layer        | Choice                                                             |
|--------------|-------------------------------------------------------------------|
| Client       | **Flutter** (Android first, iOS-ready)                            |
| Backend data | **Supabase** (Postgres + pgvector, Auth, Storage, Realtime, RLS) |
| Workers      | **Python (FastAPI)** on **Azure Container Apps** (scale-to-zero)  |
| LLM          | **Pluggable gateway**; default **Azure OpenAI via DefaultAzureCredential** |
| Notes store  | **Git/GitHub** (markdown source of truth)                        |
| Notifications| **FCM**                                                          |
| Secrets      | **Azure Key Vault** / Supabase Vault                             |
| Queue/jobs   | Postgres `jobs` table or Azure Storage Queue (+KEDA)             |

---

## 16. Open Questions / Risks

1. **Notes format**: Obsidian-flavored markdown? Any wikilinks/frontmatter to parse?
2. **Newsletter ingestion**: dedicated inbox + parser, or rely on RSS bridges?
3. **LLM cost control**: cheap model for high-volume RSS vs better model for papers — per-source overrides? (planned in §8)
4. **Sync latency target**: hourly? a few times/day? user-configurable?
5. **Media**: do we generate thumbnails/hero images for cards (e.g., paper figures, OG images)?
6. **Dedup granularity**: same story across X + blog + Reddit + newsletter — cluster now or later?
7. **Auth providers**: which OAuth logins (Google, GitHub, Apple)?
8. **X (Twitter) API**: which paid tier/budget, or rely on list timelines / a bridge? (rate-limited)
9. **Reddit API**: OAuth app registration; comply with rate limits + data-use terms.
10. **Write-back layout**: where do seeded notes live in the repo (e.g., `/inbox/`, by topic)? Naming + dedup vs existing notes?
11. **Seed catalog upkeep**: who curates the AI-figures list, how often, and how are handles verified to avoid broken follows?

---

## 17. Suggested Milestones / Roadmap

- **M0 – Foundations:** Supabase project, schema + RLS, Flutter app skeleton, auth.
- **M1 – Ingestion:** GitHub + arXiv + RSS/tech-blogs + Reddit connectors → `source_items` (X deferred to v2).
- **M2 – AI cards:** LLM Gateway (Azure DefaultAzureCredential) → short/long summaries + tags.
- **M3 – Feed UX:** Reels/Stories UI, save/like/dismiss, tap-to-expand.
- **M3.5 – Knowledge loop:** Save card → Second Brain (Git write-back) + re-ingest of seeded notes.
- **M4 – Personalization:** interests + ranking + **Startup Seed starter packs**; daily digest push.
- **M5 – Config UI & polish:** AI Providers UI, source management, settings, theming.
- **M6 – Hardening:** embeddings/semantic ranking, dedup, observability, scale rules.
