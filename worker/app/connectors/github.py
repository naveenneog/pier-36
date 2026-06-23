"""GitHub connector: latest releases for followed repos."""

from __future__ import annotations

from .base import Connector, RawItem, parse_iso8601


class GitHubConnector(Connector):
    source_type = "github"

    async def fetch(self) -> list[RawItem]:
        repos = self.config.get("repos", [])
        if not repos:
            return []
        per_page = int(self.config.get("per_page", 5))
        token = self.config.get("token")
        headers = {
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }
        if token:
            headers["Authorization"] = f"Bearer {token}"

        items: list[RawItem] = []
        async with self._http() as client:
            for repo in repos:
                resp = await client.get(
                    f"https://api.github.com/repos/{repo}/releases",
                    params={"per_page": per_page},
                    headers=headers,
                )
                resp.raise_for_status()
                for rel in resp.json():
                    author = rel.get("author") or {}
                    name = rel.get("name") or rel.get("tag_name") or "release"
                    items.append(
                        RawItem(
                            external_id=f"{repo}#{rel.get('id')}",
                            url=rel.get("html_url", ""),
                            title=f"{repo}: {name}",
                            content=rel.get("body") or "",
                            author=author.get("login"),
                            published_at=parse_iso8601(rel.get("published_at")),
                        )
                    )
        return items
