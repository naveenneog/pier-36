# Pier 36

> Your knowledge, delivered as stories. A curated multi-source aggregator that watches your notes, GitHub,
> arXiv, tech blogs, and Reddit (X in v2), turns updates into AI-summarized cards, and serves them as a
> swipeable, Stories/Reels-style feed — with a two-way **Second Brain** write-back loop.

**Status:** scaffolding (pre-MVP). See [`docs/design-doc.md`](docs/design-doc.md) (HLD) and
[`docs/lld-design.md`](docs/lld-design.md) (LLD). Progress & decisions live in [`CHANGELOG.md`](CHANGELOG.md).

## Architecture (at a glance)

| Layer         | Tech                                                                 |
|---------------|----------------------------------------------------------------------|
| Client        | **Flutter** (Riverpod, go_router, Drift) — `app/`                     |
| Backend data  | **Supabase** (Postgres + pgvector, Auth, Storage, Realtime, RLS) — `supabase/` |
| Workers       | **Python / FastAPI** on Azure Container Apps — `worker/`              |
| LLM           | Pluggable gateway; default **Azure OpenAI via `DefaultAzureCredential`** |
| Notes store   | **Git/GitHub** markdown (the Second Brain)                            |

## Monorepo layout

```
app/            Flutter client (Clean Architecture, feature-first)
worker/         Python FastAPI: connectors, LLM gateway, pipeline, ranking
supabase/       SQL migrations: schema, pgvector, indexes, RLS policies
seed-catalog/   Open JSON catalog of AI figures (Startup Seed packs)
infra/          IaC notes (Azure Container Apps, Key Vault, FCM)
docs/           HLD + LLD design docs
.github/        CI/CD workflows
```

## Quickstart

### App (Flutter)
```bash
cd app
# one-time: generate platform folders (this scaffold ships Dart code only)
flutter create . --platforms=android,ios --org com.pier36
flutter pub get
flutter run            # uses the mock feed repository by default
flutter test           # unit + widget + golden
```

### Worker (Python)
```bash
cd worker
python -m venv .venv && . .venv/Scripts/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -e ".[dev]"
uvicorn app.main:app --reload                       # http://localhost:8000/health
pytest -q
```

### Supabase
Apply migrations in `supabase/migrations` (via the Supabase CLI or SQL editor). They create the schema,
pgvector, indexes, and RLS policies.

## Conventions
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/) → drives semver + CHANGELOG.
- **Branching:** trunk-based; short-lived `feat/…`, `fix/…` branches via PR.
- **Quality gates:** `dart analyze` / `flutter test`, `ruff` + `black` + `mypy` + `pytest`. See `.github/workflows/ci.yml`.

## License
MIT — see [`LICENSE`](LICENSE).
