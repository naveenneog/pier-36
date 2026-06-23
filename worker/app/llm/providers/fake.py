"""Deterministic, dependency-free provider for tests and offline runs."""

from __future__ import annotations

import hashlib

from .base import LLMProvider, Summary


class FakeProvider(LLMProvider):
    async def summarize(self, text: str, *, system: str | None = None) -> Summary:
        clean = " ".join(text.split())
        short = (clean[:117] + "...") if len(clean) > 120 else clean
        return Summary(short=short or "(empty)", long=clean, tags=[])

    async def embed(self, text: str) -> list[float]:
        digest = hashlib.sha256(text.encode("utf-8")).digest()
        return [b / 255.0 for b in digest[:16]]
