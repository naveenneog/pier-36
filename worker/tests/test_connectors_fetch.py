import httpx

from app.connectors.arxiv import ArxivConnector
from app.connectors.github import GitHubConnector
from app.connectors.rss import RssConnector


def _client(handler) -> httpx.AsyncClient:
    return httpx.AsyncClient(transport=httpx.MockTransport(handler))


async def test_github_fetch_parses_releases() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        assert "api.github.com" in str(request.url)
        return httpx.Response(
            200,
            json=[
                {
                    "id": 1,
                    "name": "v1.0",
                    "tag_name": "v1.0",
                    "html_url": "https://github.com/o/r/releases/v1.0",
                    "body": "notes",
                    "published_at": "2026-01-01T00:00:00Z",
                    "author": {"login": "alice"},
                }
            ],
        )

    async with _client(handler) as client:
        connector = GitHubConnector({"repos": ["o/r"]}, client=client)
        items = await connector.fetch()

    assert len(items) == 1
    assert items[0].external_id == "o/r#1"
    assert items[0].author == "alice"
    assert items[0].url.endswith("/v1.0")
    assert items[0].published_at is not None


async def test_arxiv_fetch_parses_atom() -> None:
    atom = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<feed xmlns="http://www.w3.org/2005/Atom">'
        "<entry>"
        "<id>http://arxiv.org/abs/2601.00001</id>"
        "<title>Test Paper</title>"
        "<summary>Summary text</summary>"
        '<link href="http://arxiv.org/abs/2601.00001"/>'
        "<published>2026-01-01T00:00:00Z</published>"
        "<author><name>Jane Doe</name></author>"
        "</entry>"
        "</feed>"
    )

    def handler(request: httpx.Request) -> httpx.Response:
        assert "export.arxiv.org" in str(request.url)
        return httpx.Response(200, text=atom)

    async with _client(handler) as client:
        connector = ArxivConnector({"categories": ["cs.CL"]}, client=client)
        items = await connector.fetch()

    assert len(items) == 1
    assert items[0].title == "Test Paper"
    assert items[0].url.endswith("2601.00001")
    assert items[0].author == "Jane Doe"


async def test_rss_fetch_parses_feed() -> None:
    rss = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<rss version="2.0"><channel><title>Blog</title>'
        "<item><title>Post 1</title><link>https://b.com/1</link>"
        "<description>Hello</description><guid>https://b.com/1</guid>"
        "<pubDate>Wed, 01 Jan 2026 00:00:00 GMT</pubDate></item>"
        "</channel></rss>"
    )

    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(200, text=rss)

    async with _client(handler) as client:
        connector = RssConnector({"url": "https://b.com/feed"}, client=client)
        items = await connector.fetch()

    assert len(items) == 1
    assert items[0].title == "Post 1"
    assert items[0].url == "https://b.com/1"
