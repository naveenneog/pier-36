from datetime import UTC, datetime

from fastapi.testclient import TestClient

from app.api.ingest import get_connector_builder, run_preview
from app.config import Settings
from app.connectors.base import Connector, RawItem
from app.llm.gateway import LLMGateway
from app.main import app


class _FakeConnector(Connector):
    source_type = "fake"

    async def fetch(self) -> list[RawItem]:
        return [
            RawItem(
                external_id="1",
                url="https://e.com/1",
                title="Newer",
                content="body a",
                published_at=datetime(2026, 1, 2, tzinfo=UTC),
            ),
            RawItem(
                external_id="2",
                url="https://e.com/2",
                title="Older",
                content="body b",
                published_at=datetime(2026, 1, 1, tzinfo=UTC),
            ),
        ]


async def test_run_preview_ranks_and_summarizes() -> None:
    gateway = LLMGateway.from_settings(Settings(llm_provider="fake"))
    cards = await run_preview(
        _FakeConnector(),
        gateway,
        limit=10,
        now=datetime(2026, 1, 3, tzinfo=UTC),
    )
    assert len(cards) == 2
    assert cards[0].score >= cards[1].score
    assert cards[0].title == "Newer"
    assert cards[0].summary_short
    assert 0.0 <= cards[0].score <= 1.0


def test_ingest_preview_endpoint_is_hermetic() -> None:
    def builder(source_type: str, config: dict) -> Connector:
        return _FakeConnector(config)

    app.dependency_overrides[get_connector_builder] = lambda: builder
    try:
        client = TestClient(app)
        resp = client.post(
            "/ingest/preview",
            json={"source_type": "fake", "config": {}, "limit": 5},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) == 2
        assert data[0]["summary_short"]
        assert "score" in data[0]
    finally:
        app.dependency_overrides.clear()
