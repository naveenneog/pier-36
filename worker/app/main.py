"""FastAPI entrypoint."""

from __future__ import annotations

import asyncio
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api import config_status, ingest
from app.config import settings
from app.pipeline.scheduler import scheduler_loop


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    task: asyncio.Task[None] | None = None
    if settings.scheduler_enabled:
        task = asyncio.create_task(scheduler_loop(settings.scheduler_interval_seconds))
    try:
        yield
    finally:
        if task is not None:
            task.cancel()


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)
app.include_router(ingest.router)
app.include_router(config_status.router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok", "service": settings.app_name}
