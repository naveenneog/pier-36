"""Connector interface + shared helpers."""

from __future__ import annotations

import contextlib
import hashlib
from abc import ABC, abstractmethod
from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, datetime
from time import mktime, struct_time

import httpx


@dataclass
class RawItem:
    external_id: str
    url: str
    title: str
    content: str
    author: str | None = None
    published_at: datetime | None = None


class Connector(ABC):
    """A pluggable source. Configured by `config`, chosen by the factory.

    An optional httpx client can be injected for hermetic tests; otherwise a
    short-lived client is created per fetch.
    """

    source_type: str = "base"

    def __init__(self, config: dict | None = None, client: httpx.AsyncClient | None = None) -> None:
        self.config = config or {}
        self._client = client

    @abstractmethod
    async def fetch(self) -> list[RawItem]:
        """Return new items since the last sync (implementations must dedup upstream)."""

    @contextlib.asynccontextmanager
    async def _http(self) -> AsyncIterator[httpx.AsyncClient]:
        if self._client is not None:
            yield self._client
        else:
            async with httpx.AsyncClient(timeout=15.0, follow_redirects=True) as client:
                yield client


def content_hash(item: RawItem) -> str:
    """Stable hash for idempotent de-duplication."""
    payload = f"{item.external_id}|{item.title}|{item.content}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def parse_iso8601(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def feed_published(parsed_time: struct_time | None) -> datetime | None:
    if not parsed_time:
        return None
    return datetime.fromtimestamp(mktime(parsed_time), tz=UTC)
