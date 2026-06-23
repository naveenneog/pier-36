"""RSS/Atom connector - also powers tech blogs and newsletters via feed URLs."""

from __future__ import annotations

import feedparser

from .base import Connector, RawItem, feed_published


class RssConnector(Connector):
    source_type = "rss"

    async def fetch(self) -> list[RawItem]:
        urls = list(self.config.get("urls") or [])
        single = self.config.get("url")
        if single:
            urls.append(single)
        if not urls:
            return []

        items: list[RawItem] = []
        async with self._http() as client:
            for url in urls:
                resp = await client.get(url)
                resp.raise_for_status()
                parsed = feedparser.parse(resp.content)
                for entry in parsed.entries:
                    items.append(
                        RawItem(
                            external_id=entry.get("id", entry.get("link", "")),
                            url=entry.get("link", ""),
                            title=entry.get("title", ""),
                            content=entry.get("summary", ""),
                            author=entry.get("author"),
                            published_at=feed_published(entry.get("published_parsed")),
                        )
                    )
        return items
