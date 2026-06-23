"""Auto-ingest scheduler: iterate enabled sources, ingest, and persist per user."""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime

from app.config import settings
from app.connectors.base import Connector
from app.connectors.factory import build_connector
from app.db.persistence import SupabasePersistence
from app.db.supabase_repo import SupabaseNotConfigured, SupabaseRepository
from app.llm.gateway import LLMGateway
from app.pipeline.ingest import ingest
from app.pipeline.rank import rank_cards

logger = logging.getLogger(__name__)

ConnectorBuilder = Callable[[str, dict], Connector]


@dataclass
class IngestStats:
    sources: int
    cards: int


async def run_all_sources(
    *,
    sources: list[dict],
    gateway: LLMGateway,
    persistence: SupabasePersistence,
    build: ConnectorBuilder = build_connector,
    now: datetime | None = None,
    limit: int = 20,
) -> IngestStats:
    total = 0
    for source in sources:
        connector = build(source["type"], source.get("config") or {})
        processed = await ingest(connector, gateway)
        ranked = rank_cards(processed, now=now)[:limit]
        total += await persistence.persist_feed(
            user_id=str(source["owner"]),
            source_type=str(source["type"]),
            source_label=str(source.get("name") or source["type"]),
            ranked=ranked,
        )
    return IngestStats(sources=len(sources), cards=total)


async def ingest_all(
    repo: SupabaseRepository,
    *,
    build: ConnectorBuilder = build_connector,
    limit: int = 20,
) -> IngestStats:
    sources = await repo.get(
        "sources",
        {"enabled": "eq.true", "select": "id,owner,type,name,config"},
    )
    gateway = LLMGateway.from_settings(settings)
    persistence = SupabasePersistence(repo)
    return await run_all_sources(
        sources=sources,
        gateway=gateway,
        persistence=persistence,
        build=build,
        limit=limit,
    )


async def scheduler_loop(interval_seconds: int) -> None:
    """Run ingestion for all enabled sources on a fixed interval (in-process)."""
    while True:
        try:
            stats = await ingest_all(SupabaseRepository(settings))
            logger.info("scheduler: ingested %s sources -> %s cards", stats.sources, stats.cards)
        except SupabaseNotConfigured:
            logger.warning("scheduler: Supabase not configured; skipping run")
        except Exception:  # noqa: BLE001
            logger.exception("scheduler: run failed")
        await asyncio.sleep(interval_seconds)
