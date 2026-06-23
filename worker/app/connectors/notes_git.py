"""Notes (Git) connector: new/changed markdown notes in your Second Brain repo."""

from __future__ import annotations

from .base import Connector, RawItem


class NotesGitConnector(Connector):
    source_type = "notes_git"

    async def fetch(self) -> list[RawItem]:
        # TODO: clone/pull self.config["repo"], diff for new/changed markdown notes.
        return []
