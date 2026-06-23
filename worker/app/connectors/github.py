"""GitHub connector: releases, notable commits, trending for followed repos/users."""

from __future__ import annotations

from .base import Connector, RawItem


class GitHubConnector(Connector):
    source_type = "github"

    async def fetch(self) -> list[RawItem]:
        # TODO: GitHub REST/GraphQL for self.config["repos"] / ["users"].
        return []
