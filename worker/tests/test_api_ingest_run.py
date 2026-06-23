from datetime import UTC, datetime

from fastapi.testclient import TestClient

from app.api.ingest import get_connector_builder, get_persistence
from app.connectors.base import Connector, RawItem
from app.main import app


class _FakeConnector(Connector):
    source_type = "fake"

    async def fetch(self) -> list[RawItem]:
        return [
            RawItem(
                external_id="1",
                url="https://e.com/1",
                title="A",
                content="body",
                published_at=datetime(2026, 1, 1, tzinfo=UTC),
            )
        ]


class _FakePersistence:
    def __init__(self) -> None:
        self.count = 0

    async def persist_feed(self, *, user_id, source_type, source_label, ranked) -> int:
        self.count = len(ranked)
        return self.count


def test_ingest_run_persists_ranked_cards() -> None:
    fake = _FakePersistence()
    app.dependency_overrides[get_connector_builder] = lambda: (
        lambda source_type, config: _FakeConnector(config)
    )
    app.dependency_overrides[get_persistence] = lambda: fake
    try:
        client = TestClient(app)
        resp = client.post(
            "/ingest/run",
            json={"source_type": "fake", "user_id": "u1", "limit": 5},
        )
        assert resp.status_code == 200
        assert resp.json() == {"persisted": 1}
        assert fake.count == 1
    finally:
        app.dependency_overrides.clear()


def test_ingest_run_requires_supabase_configured() -> None:
    client = TestClient(app)
    resp = client.post(
        "/ingest/run",
        json={"source_type": "fake", "user_id": "u1"},
    )
    assert resp.status_code == 503
