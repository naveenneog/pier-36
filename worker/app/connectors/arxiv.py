"""arXiv connector: recent papers by category/keyword via the Atom API."""

from __future__ import annotations

import feedparser

from .base import Connector, RawItem, feed_published

_ENDPOINT = "http://export.arxiv.org/api/query"


class ArxivConnector(Connector):
    source_type = "arxiv"

    async def fetch(self) -> list[RawItem]:
        categories = self.config.get("categories", [])
        keywords = self.config.get("keywords", [])
        terms = [f"cat:{c}" for c in categories] + [f"all:{k}" for k in keywords]
        if not terms:
            return []
        params: dict[str, str | int] = {
            "search_query": " OR ".join(terms),
            "start": 0,
            "max_results": int(self.config.get("max_results", 10)),
            "sortBy": "submittedDate",
            "sortOrder": "descending",
        }
        async with self._http() as client:
            resp = await client.get(_ENDPOINT, params=params)
            resp.raise_for_status()
            parsed = feedparser.parse(resp.content)

        items: list[RawItem] = []
        for entry in parsed.entries:
            authors = entry.get("authors") or []
            items.append(
                RawItem(
                    external_id=entry.get("id", ""),
                    url=entry.get("link", ""),
                    title=" ".join(entry.get("title", "").split()),
                    content=" ".join(entry.get("summary", "").split()),
                    author=authors[0].get("name") if authors else None,
                    published_at=feed_published(entry.get("published_parsed")),
                )
            )
        return items
