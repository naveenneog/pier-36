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


settings = Settings()
