import json

import httpx

from app.config import Settings
from app.db.persistence import SupabasePersistence
from app.db.supabase_repo import SupabaseRepository
from app.pipeline.ingest import ProcessedCard


def _settings() -> Settings:
    return Settings(
        supabase_url="https://proj.supabase.co",
        supabase_service_role_key="svc-key",
    )


def _card(content_hash: str) -> ProcessedCard:
    return ProcessedCard(
        external_id=content_hash,
        url=f"https://e.com/{content_hash}",
        title=f"T-{content_hash}",
        summary_short="short",
        summary_long="long",
        tags=["AI"],
        embedding=[0.1, 0.2],
        content_hash=content_hash,
    )


async def test_persist_feed_writes_cards_then_feed_ranked() -> None:
    seen_paths: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen_paths.append(request.url.path)
        if request.url.path.endswith("/cards"):
            body = json.loads(request.content)
            return httpx.Response(
                201,
                json=[
                    {"id": f"card-{i}", "content_hash": row["content_hash"]}
                    for i, row in enumerate(body)
                ],
            )
        return httpx.Response(201)

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as client:
        persistence = SupabasePersistence(SupabaseRepository(_settings(), client=client))
        ranked = [(_card("h1"), 0.9), (_card("h2"), 0.4)]
        count = await persistence.persist_feed(
            user_id="user-1",
            source_type="github",
            source_label="GitHub",
            ranked=ranked,
        )

    assert count == 2
    assert any(p.endswith("/cards") for p in seen_paths)
    assert any(p.endswith("/feed_ranked") for p in seen_paths)


async def test_persist_feed_empty_is_noop() -> None:
    def handler(request: httpx.Request) -> httpx.Response:  # pragma: no cover
        raise AssertionError("no HTTP call expected for empty input")

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as client:
        persistence = SupabasePersistence(SupabaseRepository(_settings(), client=client))
        assert (
            await persistence.persist_feed(
                user_id="u",
                source_type="github",
                source_label="GitHub",
                ranked=[],
            )
            == 0
        )
