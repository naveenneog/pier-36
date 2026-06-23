from app.config import Settings
from app.connectors.base import Connector, RawItem
from app.llm.gateway import LLMGateway
from app.pipeline.ingest import ingest


class _OneItem(Connector):
    source_type = "test"

    async def fetch(self) -> list[RawItem]:
        return [RawItem(external_id="1", url="https://example.com", title="T", content="Body")]


async def test_ingest_produces_card() -> None:
    gateway = LLMGateway.from_settings(Settings(llm_provider="fake"))
    cards = await ingest(_OneItem(), gateway)
    assert len(cards) == 1
    assert cards[0].summary_short
    assert len(cards[0].embedding) == 16


async def test_ingest_dedup_across_runs() -> None:
    gateway = LLMGateway.from_settings(Settings(llm_provider="fake"))
    connector = _OneItem()
    seen: set[str] = set()
    first = await ingest(connector, gateway, seen_hashes=seen)
    second = await ingest(connector, gateway, seen_hashes=seen)
    assert len(first) == 1
    assert second == []
