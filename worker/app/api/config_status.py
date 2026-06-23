"""Reports which integrations are configured (booleans only; never returns secrets)."""

from __future__ import annotations

from fastapi import APIRouter

from app.config import settings

router = APIRouter(tags=["config"])


@router.get("/config/status")
async def config_status() -> dict[str, object]:
    return {
        "llm_provider": settings.llm_provider,
        "supabase_configured": settings.supabase_configured,
        "database_configured": bool(settings.database_url),
        "github_oauth_configured": bool(
            settings.github_oauth_client_id and settings.github_oauth_client_secret
        ),
    }
