"""Fetch -> dedup -> summarize -> embed, producing processed cards."""

from __future__ import annotations

from dataclasses import dataclass

from app.connectors.base import Connector, content_hash
from app.llm.gateway import LLMGateway


@dataclass
class ProcessedCard:
    external_id: str
    url: str
    title: str
    summary_short: str
    summary_long: str
    tags: list[str]
    embedding: list[float]
    content_hash: str


async def ingest(
    connector: Connector,
    gateway: LLMGateway,
    *,
    seen_hashes: set[str] | None = None,
) -> list[ProcessedCard]:
    seen = seen_hashes if seen_hashes is not None else set()
    cards: list[ProcessedCard] = []

    for item in await connector.fetch():
        digest = content_hash(item)
        if digest in seen:
            continue
        seen.add(digest)

        summary = await gateway.summarize(f"{item.title}\n\n{item.content}")
        embedding = await gateway.embed(f"{item.title} {summary.short}")

        cards.append(
            ProcessedCard(
                external_id=item.external_id,
                url=item.url,
                title=item.title,
                summary_short=summary.short,
                summary_long=summary.long,
                tags=summary.tags,
                embedding=embedding,
                content_hash=digest,
            )
        )

    return cards
