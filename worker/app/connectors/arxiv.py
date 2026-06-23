"""arXiv connector: new papers by category / keyword / author."""

from __future__ import annotations

from .base import Connector, RawItem


class ArxivConnector(Connector):
    source_type = "arxiv"

    async def fetch(self) -> list[RawItem]:
        # TODO: arXiv Atom API for self.config["categories"] / ["keywords"].
        return []
