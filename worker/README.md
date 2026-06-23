# worker — Pier 36 (Python / FastAPI)

Connectors, the **LLM Gateway**, the ingest pipeline, and ranking. Runs on Azure Container Apps in prod.

## Run locally
```bash
cd worker
python -m venv .venv
# Windows: .venv\Scripts\Activate.ps1   |   *nix: . .venv/bin/activate
pip install -e ".[dev]"
uvicorn app.main:app --reload    # http://localhost:8000/health
pytest -q
```

## LLM Gateway
Pluggable provider, chosen by `LLM_PROVIDER`:
- `fake` (default) — deterministic, **no extra deps**; great for tests/offline.
- `azure` — **Azure OpenAI via `DefaultAzureCredential` (Managed Identity)**. Install extras: `pip install -e ".[llm]"`.
- `openai_compatible` — OpenAI / OpenRouter / Ollama via `OPENAI_BASE_URL` + `OPENAI_API_KEY`.

Azure uses Managed Identity — **no API key stored**. See `.env.example`.

## Layout
```
app/
  config.py            settings (env-driven)
  main.py              FastAPI app (+ /health)
  llm/                 gateway + providers (base, fake, azure_openai, openai_compatible)
  connectors/          base + github, arxiv, rss, reddit, notes_git
  pipeline/            ingest orchestration
  ranking/             scoring (recency, source, similarity, engagement)
tests/                 pytest (health, gateway, ranking, connectors)
```
