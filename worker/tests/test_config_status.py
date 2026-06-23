from fastapi.testclient import TestClient

from app.main import app


def test_config_status_reports_booleans_without_secrets() -> None:
    client = TestClient(app)
    resp = client.get("/config/status")
    assert resp.status_code == 200
    body = resp.json()
    assert body["llm_provider"] == "fake"
    assert body["supabase_configured"] is False
    assert body["database_configured"] is False
    assert body["github_oauth_configured"] is False
    # Never leak secret values
    assert "service_role" not in resp.text.lower()
