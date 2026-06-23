"""Environment-driven settings."""

from __future__ import annotations

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "Pier 36 Worker"

    # LLM gateway: fake | azure | openai_compatible
    llm_provider: str = "fake"

    # Azure OpenAI (auth via DefaultAzureCredential — no key)
    azure_openai_endpoint: str | None = None
    azure_openai_deployment: str = "gpt-4o-mini"
    azure_openai_api_version: str = "2024-10-21"
    azure_openai_embed_deployment: str = "text-embedding-3-small"
    azure_managed_identity_client_id: str | None = None

    # OpenAI-compatible (OpenAI / OpenRouter / Ollama)
    openai_base_url: str | None = None
    openai_api_key: str | None = None
    openai_model: str = "gpt-4o-mini"

    # Supabase (clients use the anon key; the worker writes with the service-role key)
    supabase_url: str | None = None
    supabase_anon_key: str | None = None
    supabase_service_role_key: str | None = None
    database_url: str | None = None

    # GitHub OAuth (entered in the Supabase Auth dashboard; kept here for reference/automation)
    github_oauth_client_id: str | None = None
    github_oauth_client_secret: str | None = None

    # Auto-ingest scheduler (in-process interval loop; off by default)
    scheduler_enabled: bool = False
    scheduler_interval_seconds: int = 3600

    @property
    def supabase_configured(self) -> bool:
        return bool(self.supabase_url and self.supabase_service_role_key)


settings = Settings()
