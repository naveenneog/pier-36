"""Persists ranked cards to Supabase: a denormalized `cards` read model + per-user `feed_ranked`."""

from __future__ import annotations

from app.db.supabase_repo import SupabaseRepository
from app.pipeline.ingest import ProcessedCard


class SupabasePersistence:
    def __init__(self, repo: SupabaseRepository) -> None:
        self._repo = repo

    async def persist_feed(
        self,
        *,
        user_id: str,
        source_type: str,
        source_label: str,
        ranked: list[tuple[ProcessedCard, float]],
    ) -> int:
        """Upsert cards (by content_hash), then upsert the user's feed_ranked rows."""
        if not ranked:
            return 0

        card_rows = [
            {
                "source_type": source_type,
                "source_label": source_label,
                "title": card.title,
                "url": card.url,
                "summary_short": card.summary_short,
                "summary_long": card.summary_long,
                "tags": card.tags,
                "embedding": card.embedding,
                "content_hash": card.content_hash,
                "published_at": card.published_at.isoformat() if card.published_at else None,
            }
            for card, _ in ranked
        ]
        inserted = await self._repo.upsert_returning("cards", card_rows, on_conflict="content_hash")
        id_by_hash = {row["content_hash"]: row["id"] for row in inserted}

        feed_rows = [
            {"user_id": user_id, "card_id": id_by_hash[card.content_hash], "score": score}
            for card, score in ranked
            if card.content_hash in id_by_hash
        ]
        await self._repo.upsert("feed_ranked", feed_rows, on_conflict="user_id,card_id")
        return len(feed_rows)
