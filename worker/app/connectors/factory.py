"""Factory: build a connector from a source type + config (Factory pattern)."""

from __future__ import annotations

from .arxiv import ArxivConnector
from .base import Connector
from .github import GitHubConnector
from .notes_git import NotesGitConnector
from .reddit import RedditConnector
from .rss import RssConnector

_REGISTRY: dict[str, type[Connector]] = {
    "github": GitHubConnector,
    "arxiv": ArxivConnector,
    "rss": RssConnector,
    "blog": RssConnector,
    "newsletter": RssConnector,
    "reddit": RedditConnector,
    "notes_git": NotesGitConnector,
}


def build_connector(source_type: str, config: dict | None = None) -> Connector:
    try:
        cls = _REGISTRY[source_type]
    except KeyError as exc:
        raise ValueError(f"Unknown source type: {source_type}") from exc
    return cls(config)
