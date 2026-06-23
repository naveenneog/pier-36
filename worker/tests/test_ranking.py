from datetime import UTC, datetime, timedelta

from app.ranking.score import cosine_similarity, rank_score, recency_score


def test_recency_is_one_at_publish_and_decays() -> None:
    now = datetime(2026, 1, 1, tzinfo=UTC)
    assert recency_score(now, now=now) == 1.0
    older = recency_score(now - timedelta(hours=36), now=now)
    assert 0.0 < older < 1.0


def test_recency_half_life() -> None:
    now = datetime(2026, 1, 1, tzinfo=UTC)
    half = recency_score(now - timedelta(hours=18), now=now, half_life_hours=18)
    assert abs(half - 0.5) < 1e-9


def test_cosine_similarity() -> None:
    assert cosine_similarity([1, 0], [1, 0]) == 1.0
    assert cosine_similarity([1, 0], [0, 1]) == 0.0
    assert cosine_similarity([], [1]) == 0.0


def test_rank_score_is_bounded_and_max() -> None:
    now = datetime(2026, 1, 1, tzinfo=UTC)
    score = rank_score(
        published_at=now,
        source_weight=1.0,
        similarity=1.0,
        engagement=1.0,
        now=now,
    )
    assert 0.0 <= score <= 1.0
    assert abs(score - 1.0) < 1e-9
