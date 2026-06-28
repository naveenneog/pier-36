import pytest

from app.config import Settings
from app.llm.gateway import LLMGateway
from app.llm.providers.base import Summary


async def test_fake_gateway_summarize_and_embed() -> None:
    gateway = LLMGateway.from_settings(Settings(llm_provider="fake"))
    summary = await gateway.summarize("Hello world. " * 50)
    assert isinstance(summary, Summary)
    assert summary.short
    assert len(summary.short) <= 120
    embedding = await gateway.embed("hello")
    assert len(embedding) == 1536


def test_azure_requires_endpoint() -> None:
    with pytest.raises(ValueError):
        LLMGateway.from_settings(Settings(llm_provider="azure", azure_openai_endpoint=None))


def test_unknown_provider_raises() -> None:
    with pytest.raises(ValueError):
        LLMGateway.from_settings(Settings(llm_provider="bogus"))
