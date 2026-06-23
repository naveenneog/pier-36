"""Azure OpenAI provider — auth via DefaultAzureCredential (Managed Identity), no API key."""

from __future__ import annotations

import json

from .base import SUMMARY_SYSTEM, LLMProvider, Summary

_AZURE_SCOPE = "https://cognitiveservices.azure.com/.default"


class AzureOpenAIProvider(LLMProvider):
    def __init__(
        self,
        *,
        endpoint: str,
        deployment: str,
        api_version: str,
        embed_deployment: str,
        managed_identity_client_id: str | None = None,
    ) -> None:
        # Lazy imports so the package is usable without the optional `llm` extra.
        from azure.identity import DefaultAzureCredential, get_bearer_token_provider
        from openai import AsyncAzureOpenAI

        credential = (
            DefaultAzureCredential(managed_identity_client_id=managed_identity_client_id)
            if managed_identity_client_id
            else DefaultAzureCredential()
        )
        token_provider = get_bearer_token_provider(credential, _AZURE_SCOPE)

        self._client = AsyncAzureOpenAI(
            azure_endpoint=endpoint,
            api_version=api_version,
            azure_ad_token_provider=token_provider,
        )
        self._deployment = deployment
        self._embed_deployment = embed_deployment

    async def summarize(self, text: str, *, system: str | None = None) -> Summary:
        resp = await self._client.chat.completions.create(
            model=self._deployment,
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": system or SUMMARY_SYSTEM},
                {"role": "user", "content": text},
            ],
        )
        data = json.loads(resp.choices[0].message.content or "{}")
        return Summary(
            short=str(data.get("short", "")),
            long=str(data.get("long", "")),
            tags=[str(t) for t in data.get("tags", [])],
        )

    async def embed(self, text: str) -> list[float]:
        resp = await self._client.embeddings.create(model=self._embed_deployment, input=text)
        return list(resp.data[0].embedding)
