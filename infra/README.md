# infra — Pier 36

Infrastructure notes (IaC to be added as Bicep/Terraform).

## Targets
- **Worker** → **Azure Container Apps** (scale-to-zero; KEDA scale on queue length). Auth to Azure OpenAI via
  **Managed Identity** (`DefaultAzureCredential`) — no secrets in the image.
- **Secrets** → **Azure Key Vault** (LLM keys for non-Azure providers, connector tokens), referenced by id.
- **Data/Auth/Realtime/Storage** → **Supabase** (managed Postgres + pgvector).
- **Push** → **Firebase Cloud Messaging (FCM)** for daily digests / breaking updates.

## Deploy (sketch)
```bash
# Build & push the worker image
docker build -t <registry>/pier36-worker:latest worker
docker push <registry>/pier36-worker:latest

# Create/Update the Container App (assign a managed identity with Cognitive Services OpenAI User role)
az containerapp up \
  --name pier36-worker \
  --resource-group pier36-rg \
  --image <registry>/pier36-worker:latest \
  --env-vars LLM_PROVIDER=azure AZURE_OPENAI_ENDPOINT=<endpoint> AZURE_OPENAI_DEPLOYMENT=<deployment>
```

## TODO
- [ ] `main.bicep` for resource group, Container App, Key Vault, managed identity + role assignment.
- [ ] GitHub OIDC → Azure for keyless CI deploys (no stored cloud creds).
- [ ] Supabase project provisioning + migration step in `release.yml`.
