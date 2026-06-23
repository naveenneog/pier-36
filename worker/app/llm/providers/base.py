"""Provider interface + shared types."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field

SUMMARY_SYSTEM = (
    "You are a concise tech-news summarizer. Return JSON with keys "
    '"short" (<=240 chars), "long" (<=600 chars), and "tags" '
    "(an array of 3-6 short topic strings)."
)


@dataclass
class Summary:
    short: str
    long: str
    tags: list[str] = field(default_factory=list)


class LLMProvider(ABC):
    @abstractmethod
    async def summarize(self, text: str, *, system: str | None = None) -> Summary: ...

    @abstractmethod
    async def embed(self, text: str) -> list[float]: ...
