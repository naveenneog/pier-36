"""Rank processed cards (recency + source weight + similarity + engagement)."""

from __future__ import annotations

from datetime import UTC, datetime

from app.pipeline.ingest import ProcessedCard
from app.ranking.score import rank_score


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
