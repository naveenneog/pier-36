import json

import httpx
from fastapi.testclient import TestClient

from app.config import Settings
from app.connectors.base import Connector, RawItem
from app.db.supabase_repo import SupabaseRepository
from app.llm.gateway import LLMGateway
from app.main import app
from app.pipeline.scheduler import IngestStats, ingest_all, run_all_sources


class _FakeConnector(Connector):
    source_type = "fake"

    async def fetch(self) -> list[RawItem]:
        return [RawItem(external_id="1", url="u", title="T", content="body")]


class _RecordingPersistence:
    def __init__(self) -> None:
        self.calls: list[tuple[str, int]] = []

    async def persist_feed(self, *, user_id, source_type, source_label, ranked) -> int:
        self.calls.append((user_id, len(ranked)))
        return len(ranked)


def _build(_type: str, _config: dict) -> Connector:
    return _FakeConnector(_config)


async def test_run_all_sources_persists_each_owner() -> None:
    gateway = LLMGateway.from_settings(Settings(llm_provider="fake"))
    persistence = _RecordingPersistence()
    sources = [
        {"owner": "u1", "type": "fake", "name": "S1", "config": {}},
        {"owner": "u2", "type": "fake", "name": "S2", "config": {}},
    ]
    stats = await run_all_sources(
        sources=sources,
        gateway=gateway,
        persistence=persistence,  # type: ignore[arg-type]
        build=_build,
    )
    assert stats == IngestStats(sources=2, cards=2)
    assert persistence.calls == [("u1", 1), ("u2", 1)]


async def test_ingest_all_reads_sources_then_persists() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        path = request.url.path
        if request.method == "GET" and path.endswith("/sources"):
            return httpx.Response(
                200,
                json=[{"id": "s1", "owner": "u1", "type": "fake", "name": "S1", "config": {}}],
            )
        if path.endswith("/cards"):
            body = json.loads(request.content)
            return httpx.Response(
                201,
                json=[
                    {"id": f"c{i}", "content_hash": r["content_hash"]} for i, r in enumerate(body)
                ],
            )
        return httpx.Response(201)

    settings = Settings(supabase_url="https://p.supabase.co", supabase_service_role_key="svc")
    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as client:
        repo = SupabaseRepository(settings, client=client)
        stats = await ingest_all(repo, build=_build)

    assert stats.sources == 1
    assert stats.cards == 1


def test_scheduler_endpoint_requires_supabase() -> None:
    client = TestClient(app)
    resp = client.post("/ingest/scheduler/run")
    assert resp.status_code == 503
