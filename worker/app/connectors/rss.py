"""RSS/Atom connector — also powers tech blogs and newsletters via feed URLs."""

from __future__ import annotations

from datetime import UTC, datetime
from time import mktime

import feedparser

from .base import Connector, RawItem


class RssConnector(Connector):
    source_type = "rss"

    async def fetch(self) -> list[RawItem]:
        url = self.config.get("url")
        if not url:
            return []
        parsed = feedparser.parse(url)
        items: list[RawItem] = []
        for entry in parsed.entries:
            published: datetime | None = None
            if getattr(entry, "published_parsed", None):
                published = datetime.fromtimestamp(mktime(entry.published_parsed), tz=UTC)
            items.append(
                RawItem(
                    external_id=entry.get("id", entry.get("link", "")),
                    url=entry.get("link", ""),
                    title=entry.get("title", ""),
                    content=entry.get("summary", ""),
                    author=entry.get("author"),
                    published_at=published,
                )
            )
        return items
