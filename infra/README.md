# infra — Pier 36

The worker runs on **Azure Container Apps**. The image is cloud-built with **ACR build** (no local Docker).

## Live deployment
- Resource group: `pier36-rg`
- ACR: `caa5010066c2acr` (Basic, admin-enabled)
- Environment: `pier36-cae` (**eastus2** — eastus was at capacity: ManagedEnvironmentCapacityHeavyUsageError)
- App: `pier36-worker`
  - https://pier36-worker.agreeablerock-237012fd.eastus2.azurecontainerapps.io
  - `GET /health`, `GET /config/status`, `POST /ingest/preview|run|scheduler/run`
- Replicas: min 1, max 3 (min >= 1 so the in-process scheduler can run).

## Deploy / redeploy (no local Docker)
```bash
ACR=caa5010066c2acr
az acr build -r $ACR -t pier36-worker:v1 worker          # cloud build from worker/Dockerfile
az containerapp update -n pier36-worker -g pier36-rg --image $ACR.azurecr.io/pier36-worker:v1
```

## Enable Supabase + the scheduler
```bash
az containerapp secret set -n pier36-worker -g pier36-rg --secrets supabase-key=<SERVICE_ROLE_KEY>
az containerapp update -n pier36-worker -g pier36-rg \
  --set-env-vars SUPABASE_URL=https://<ref>.supabase.co \
                 SUPABASE_SERVICE_ROLE_KEY=secretref:supabase-key \
                 SCHEDULER_ENABLED=true SCHEDULER_INTERVAL_SECONDS=3600
```

## Azure OpenAI via Managed Identity (real summaries)
```bash
az containerapp identity assign -n pier36-worker -g pier36-rg --system-assigned
PRINCIPAL=$(az containerapp show -n pier36-worker -g pier36-rg --query identity.principalId -o tsv)
az role assignment create --assignee $PRINCIPAL \
  --role "Cognitive Services OpenAI User" --scope <AZURE_OPENAI_RESOURCE_ID>
az containerapp update -n pier36-worker -g pier36-rg \
  --set-env-vars LLM_PROVIDER=azure AZURE_OPENAI_ENDPOINT=https://<res>.openai.azure.com \
                 AZURE_OPENAI_DEPLOYMENT=gpt-4o-mini
```

## TODO
- [ ] GitHub OIDC -> Azure for keyless CI deploys (federated credential + a deploy-worker.yml workflow).
- [ ] main.bicep for fully reproducible IaC.
