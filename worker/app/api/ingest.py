"""Preview ingestion: connector -> LLM gateway -> ranked cards (no persistence)."""

from __future__ import annotations

from collections.abc import Callable
from datetime import UTC, datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.config import settings
from app.connectors.base import Connector
from app.connectors.factory import build_connector
from app.llm.gateway import LLMGateway
from app.pipeline.ingest import ingest
from app.ranking.score import rank_score

router = APIRouter(tags=["ingest"])

ConnectorBuilder = Callable[[str, dict], Connector]


class PreviewRequest(BaseModel):
    source_type: str
    config: dict = Field(default_factory=dict)
    limit: int = 10


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


async def run_preview(
    connector: Connector,
    gateway: LLMGateway,
    *,
    limit: int = 10,
    now: datetime | None = None,
) -> list[CardOut]:
    now = now or datetime.now(UTC)
    processed = await ingest(connector, gateway)
    cards = [
        CardOut(
            external_id=card.external_id,
            url=card.url,
            title=card.title,
            summary_short=card.summary_short,
            summary_long=card.summary_long,
            tags=card.tags,
            score=round(
                rank_score(
                    published_at=card.published_at or now,
                    source_weight=0.5,
                    similarity=0.0,
                    engagement=0.0,
                    now=now,
                ),
                4,
            ),
            published_at=card.published_at,
        )
        for card in processed
    ]
    cards.sort(key=lambda c: c.score, reverse=True)
    return cards[:limit]


@router.post("/ingest/preview", response_model=list[CardOut])
async def ingest_preview(
    request: PreviewRequest,
    build: ConnectorBuilder = Depends(get_connector_builder),
) -> list[CardOut]:
    connector = build(request.source_type, request.config)
    gateway = LLMGateway.from_settings(settings)
    return await run_preview(connector, gateway, limit=request.limit)
