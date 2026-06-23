import pytest

from app.connectors.base import RawItem, content_hash
from app.connectors.factory import build_connector


def _item(content: str = "body") -> RawItem:
    return RawItem(external_id="x1", url="https://example.com", title="T", content=content)


def test_content_hash_stable_and_sensitive() -> None:
    assert content_hash(_item("body")) == content_hash(_item("body"))
    assert content_hash(_item("body")) != content_hash(_item("other"))


def test_build_connector_known_types() -> None:
    for source_type in ["github", "arxiv", "rss", "blog", "newsletter", "reddit", "notes_git"]:
        connector = build_connector(source_type, {})
        assert hasattr(connector, "fetch")


def test_build_connector_unknown_raises() -> None:
    with pytest.raises(ValueError):
        build_connector("nope")


async def test_stub_fetch_returns_list() -> None:
    connector = build_connector("github", {"repos": ["flutter/flutter"]})
    assert await connector.fetch() == []
