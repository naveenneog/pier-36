"""Per-user ranking score: recency + source weight + semantic similarity + engagement."""

from __future__ import annotations

import math
from dataclasses import dataclass
from datetime import UTC, datetime


@dataclass(frozen=True)
class RankWeights:
    recency: float = 0.4
    source: float = 0.2
    similarity: float = 0.3
    engagement: float = 0.1


def recency_score(
    published_at: datetime,
    *,
    now: datetime | None = None,
    half_life_hours: float = 18.0,
) -> float:
    """Exponential time-decay in (0, 1]; 1.0 at publish time, 0.5 after one half-life."""
    now = now or datetime.now(UTC)
    age_hours = max(0.0, (now - published_at).total_seconds() / 3600.0)
    return 0.5 ** (age_hours / half_life_hours)


def cosine_similarity(a: list[float], b: list[float]) -> float:
    if not a or not b or len(a) != len(b):
        return 0.0
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def rank_score(
    *,
    published_at: datetime,
    source_weight: float,
    similarity: float,
    engagement: float,
    weights: RankWeights = RankWeights(),
    now: datetime | None = None,
) -> float:
    """Weighted blend. Inputs are expected in [0, 1]; output is in [0, 1]."""
    return _clamp01(
        weights.recency * recency_score(published_at, now=now)
        + weights.source * _clamp01(source_weight)
        + weights.similarity * _clamp01(similarity)
        + weights.engagement * _clamp01(engagement)
    )


def _clamp01(x: float) -> float:
    return max(0.0, min(1.0, x))
