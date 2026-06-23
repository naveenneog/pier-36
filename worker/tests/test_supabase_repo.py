import httpx
import pytest

from app.config import Settings
from app.db.supabase_repo import SupabaseNotConfigured, SupabaseRepository


def _settings() -> Settings:
    return Settings(
        supabase_url="https://proj.supabase.co",
        supabase_service_role_key="svc-key",
    )


async def test_upsert_uses_config_keys_and_url() -> None:
    seen: dict[str, str | None] = {}

    def handler(request: httpx.Request) -> httpx.Response:
        seen["url"] = str(request.url)
        seen["apikey"] = request.headers.get("apikey")
        seen["auth"] = request.headers.get("authorization")
        seen["prefer"] = request.headers.get("prefer")
        return httpx.Response(201)

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as client:
        repo = SupabaseRepository(_settings(), client=client)
        count = await repo.upsert("cards", [{"id": "1"}], on_conflict="content_hash")

    assert count == 1
    assert seen["url"] is not None
    assert seen["url"].startswith("https://proj.supabase.co/rest/v1/cards")
    assert "on_conflict=content_hash" in seen["url"]
    assert seen["apikey"] == "svc-key"
    assert seen["auth"] == "Bearer svc-key"
    assert seen["prefer"] is not None
    assert "merge-duplicates" in seen["prefer"]


async def test_repository_requires_configuration() -> None:
    with pytest.raises(SupabaseNotConfigured):
        SupabaseRepository(Settings())
