"""Preview ingestion: connector -> LLM gateway -> ranked cards (no persistence)."""

from __future__ import annotations

from collections.abc import Callable
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.config import settings
from app.connectors.base import Connector
from app.connectors.factory import build_connector
from app.db.persistence import SupabasePersistence
from app.db.supabase_repo import SupabaseNotConfigured, SupabaseRepository
from app.llm.gateway import LLMGateway
from app.pipeline.ingest import ProcessedCard, ingest
from app.ranking.score import rank_score

router = APIRouter(tags=["ingest"])

ConnectorBuilder = Callable[[str, dict], Connector]


class PreviewRequest(BaseModel):
    source_type: str
    config: dict = Field(default_factory=dict)
    limit: int = 10


class RunRequest(BaseModel):
    source_type: str
    config: dict = Field(default_factory=dict)
    source_label: str = ""
    user_id: str
    limit: int = 20


class CardOut(BaseModel):
    external_id: str
    url: str
    title: str
    summary_short: str
    summary_long: str
    tags: list[str]
    score: float
    published_at: datetime | None = None


def get_connector_builder() -> ConnectorBuilder:
    return build_connector


def get_persistence() -> SupabasePersistence:
    try:
        return SupabasePersistence(SupabaseRepository(settings))
    except SupabaseNotConfigured as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc


def rank_cards(
    processed: list[ProcessedCard], *, now: datetime | None = None
) -> list[tuple[ProcessedCard, float]]:
    now = now or datetime.now(UTC)
    scored = [
        (
            card,
            round(
                rank_score(
                    published_at=card.published_at or now,
                    source_weight=0.5,
                    similarity=0.0,
                    engagement=0.0,
                    now=now,
                ),
                4,
            ),
        )
        for card in processed
    ]
    scored.sort(key=lambda pair: pair[1], reverse=True)
    return scored


async def run_preview(
    connector: Connector,
    gateway: LLMGateway,
    *,
    limit: int = 10,
    now: datetime | None = None,
) -> list[CardOut]:
    processed = await ingest(connector, gateway)
    ranked = rank_cards(processed, now=now)[:limit]
    return [
        CardOut(
            external_id=card.external_id,
            url=card.url,
            title=card.title,
            summary_short=card.summary_short,
            summary_long=card.summary_long,
            tags=card.tags,
            score=score,
            published_at=card.published_at,
        )
        for card, score in ranked
    ]


@router.post("/ingest/preview", response_model=list[CardOut])
async def ingest_preview(
    request: PreviewRequest,
    build: ConnectorBuilder = Depends(get_connector_builder),
) -> list[CardOut]:
    connector = build(request.source_type, request.config)
    gateway = LLMGateway.from_settings(settings)
    return await run_preview(connector, gateway, limit=request.limit)


@router.post("/ingest/run")
async def ingest_run(
    request: RunRequest,
    build: ConnectorBuilder = Depends(get_connector_builder),
    persistence: SupabasePersistence = Depends(get_persistence),
) -> dict[str, int]:
    connector = build(request.source_type, request.config)
    gateway = LLMGateway.from_settings(settings)
    processed = await ingest(connector, gateway)
    ranked = rank_cards(processed)[: request.limit]
    count = await persistence.persist_feed(
        user_id=request.user_id,
        source_type=request.source_type,
        source_label=request.source_label or request.source_type,
        ranked=ranked,
    )
    return {"persisted": count}
