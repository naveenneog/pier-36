"""Deterministic, dependency-free provider for tests and offline runs."""

from __future__ import annotations

import hashlib

from .base import LLMProvider, Summary

# The `cards.embedding` column is `vector(1536)`; emit a deterministic vector of
# that width so persisted cards satisfy the schema (the values aren't meaningful).
EMBED_DIM = 1536


class FakeProvider(LLMProvider):
    async def summarize(self, text: str, *, system: str | None = None) -> Summary:
        clean = " ".join(text.split())
        short = (clean[:117] + "...") if len(clean) > 120 else clean
        return Summary(short=short or "(empty)", long=clean, tags=[])

    async def embed(self, text: str) -> list[float]:
        digest = hashlib.sha256(text.encode("utf-8")).digest()  # 32 bytes
        return [digest[i % len(digest)] / 255.0 for i in range(EMBED_DIM)]
