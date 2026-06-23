"""OpenAI-compatible provider (OpenAI / OpenRouter / Ollama) via base_url + api_key."""

from __future__ import annotations

import json

from .base import SUMMARY_SYSTEM, LLMProvider, Summary


class OpenAICompatibleProvider(LLMProvider):
    def __init__(
        self,
        *,
        api_key: str,
        model: str,
        base_url: str | None = None,
        embed_model: str = "text-embedding-3-small",
    ) -> None:
        from openai import AsyncOpenAI

        self._client = AsyncOpenAI(api_key=api_key, base_url=base_url)
        self._model = model
        self._embed_model = embed_model

    async def summarize(self, text: str, *, system: str | None = None) -> Summary:
        resp = await self._client.chat.completions.create(
            model=self._model,
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
        resp = await self._client.embeddings.create(model=self._embed_model, input=text)
        return list(resp.data[0].embedding)
