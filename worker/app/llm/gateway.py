"""Gateway facade: picks a provider from settings and exposes summarize/embed."""

from __future__ import annotations

from app.config import Settings
from app.config import settings as default_settings

from .providers.base import LLMProvider, Summary
from .providers.fake import FakeProvider


class LLMGateway:
    def __init__(self, provider: LLMProvider) -> None:
        self._provider = provider

    @classmethod
    def from_settings(cls, settings: Settings | None = None) -> LLMGateway:
        settings = settings or default_settings
        name = settings.llm_provider.lower()

        if name == "fake":
            return cls(FakeProvider())

        if name == "azure":
            if not settings.azure_openai_endpoint:
                raise ValueError("AZURE_OPENAI_ENDPOINT is required for the 'azure' provider")
            from .providers.azure_openai import AzureOpenAIProvider

            return cls(
                AzureOpenAIProvider(
                    endpoint=settings.azure_openai_endpoint,
                    deployment=settings.azure_openai_deployment,
                    api_version=settings.azure_openai_api_version,
                    embed_deployment=settings.azure_openai_embed_deployment,
                    managed_identity_client_id=settings.azure_managed_identity_client_id,
                )
            )

        if name == "openai_compatible":
            if not settings.openai_api_key:
                raise ValueError("OPENAI_API_KEY is required for 'openai_compatible'")
            from .providers.openai_compatible import OpenAICompatibleProvider

            return cls(
                OpenAICompatibleProvider(
                    api_key=settings.openai_api_key,
                    model=settings.openai_model,
                    base_url=settings.openai_base_url,
                )
            )

        raise ValueError(f"Unknown LLM_PROVIDER: {settings.llm_provider}")

    async def summarize(self, text: str, *, system: str | None = None) -> Summary:
        return await self._provider.summarize(text, system=system)

    async def embed(self, text: str) -> list[float]:
        return await self._provider.embed(text)
