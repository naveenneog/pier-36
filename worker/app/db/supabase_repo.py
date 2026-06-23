"""Config-driven Supabase (PostgREST) persistence for the worker."""

from __future__ import annotations

import contextlib
from collections.abc import AsyncIterator, Sequence

import httpx

from app.config import Settings


class SupabaseNotConfigured(RuntimeError):
    """Raised when the Supabase URL/service-role key are missing from config."""


class SupabaseRepository:
    """Writes rows via the Supabase REST API using keys read from config.

    Nothing is hardcoded: the base URL and service-role key come from [Settings].
    """

    def __init__(self, settings: Settings, client: httpx.AsyncClient | None = None) -> None:
        if not settings.supabase_url or not settings.supabase_service_role_key:
            raise SupabaseNotConfigured("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
        self._base = settings.supabase_url.rstrip("/") + "/rest/v1"
        self._key = settings.supabase_service_role_key
        self._client = client

    def _headers(self, *, upsert: bool) -> dict[str, str]:
        prefer = "resolution=merge-duplicates,return=minimal" if upsert else "return=minimal"
        return {
            "apikey": self._key,
            "Authorization": f"Bearer {self._key}",
            "Content-Type": "application/json",
            "Prefer": prefer,
        }

    @contextlib.asynccontextmanager
    async def _http(self) -> AsyncIterator[httpx.AsyncClient]:
        if self._client is not None:
            yield self._client
        else:
            async with httpx.AsyncClient(timeout=15.0) as client:
                yield client

    async def insert(self, table: str, rows: Sequence[dict]) -> int:
        if not rows:
            return 0
        async with self._http() as client:
            resp = await client.post(
                f"{self._base}/{table}",
                headers=self._headers(upsert=False),
                json=list(rows),
            )
            resp.raise_for_status()
        return len(rows)

    async def upsert(self, table: str, rows: Sequence[dict], *, on_conflict: str) -> int:
        if not rows:
            return 0
        async with self._http() as client:
            resp = await client.post(
                f"{self._base}/{table}",
                params={"on_conflict": on_conflict},
                headers=self._headers(upsert=True),
                json=list(rows),
            )
            resp.raise_for_status()
        return len(rows)

    async def upsert_returning(
        self, table: str, rows: Sequence[dict], *, on_conflict: str
    ) -> list[dict]:
        if not rows:
            return []
        headers = self._headers(upsert=True)
        headers["Prefer"] = "resolution=merge-duplicates,return=representation"
        async with self._http() as client:
            resp = await client.post(
                f"{self._base}/{table}",
                params={"on_conflict": on_conflict},
                headers=headers,
                json=list(rows),
            )
            resp.raise_for_status()
            data = resp.json()
        return list(data)

    async def get(self, table: str, params: dict | None = None) -> list[dict]:
        async with self._http() as client:
            resp = await client.get(
                f"{self._base}/{table}",
                params=params or {},
                headers={"apikey": self._key, "Authorization": f"Bearer {self._key}"},
            )
            resp.raise_for_status()
            return list(resp.json())
