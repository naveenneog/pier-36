"""Connector interface + shared helpers."""

from __future__ import annotations

import hashlib
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime


@dataclass
class RawItem:
    external_id: str
    url: str
    title: str
    content: str
    author: str | None = None
    published_at: datetime | None = None


class Connector(ABC):
    """A pluggable source. Configured by `config`, chosen by the factory."""

    source_type: str = "base"

    def __init__(self, config: dict | None = None) -> None:
        self.config = config or {}

    @abstractmethod
    async def fetch(self) -> list[RawItem]:
        """Return new items since the last sync (implementations must dedup upstream)."""


def content_hash(item: RawItem) -> str:
    """Stable hash for idempotent de-duplication."""
    payload = f"{item.external_id}|{item.title}|{item.content}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()
