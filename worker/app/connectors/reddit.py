"""Reddit connector: hot/top posts + top comments for followed subreddits."""

from __future__ import annotations

from .base import Connector, RawItem


class RedditConnector(Connector):
    source_type = "reddit"

    async def fetch(self) -> list[RawItem]:
        # TODO: Reddit OAuth (PRAW/httpx) for self.config["subreddits"].
        # Respect rate limits + content-use terms.
        return []
