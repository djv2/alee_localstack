# LocalStack PR Infrastructure Insights

A proof of concept that deploys Terraform infrastructure changes into a **LocalStack Cloud ephemeral instance** for each pull request, analyzes the Terraform plan, and publishes a developer/agent-ready insight.

## What it demonstrates

- Terraform-managed S3, SQS, Lambda, and IAM resources.
- GitHub Actions starts a temporary LocalStack Cloud instance for the PR.
- Terraform plans and applies against the cloud instance endpoint.
- A Python analyzer identifies selected risky patterns and generates structured `insight.json`.
- A concise PR comment and downloadable JSON workflow artifact.
- The ephemeral instance is stopped by the LocalStack GitHub Action after the preview command completes.

No AWS account, persistent LocalStack instance, or dashboard is required. The optional Docker Compose setup is only for local development.

## GitHub setup

1. In LocalStack, create a **CI Auth Token** (recommended for automated workflows).
2. In this repository, go to **Settings → Secrets and variables → Actions → New repository secret**.
3. Add the secret named `LOCALSTACK_AUTH_TOKEN` and paste the token value.
4. Open or update a PR that changes infrastructure, app, or analyzer files.

Do not commit or paste the token into source code. The workflow uses the official `LocalStack/setup-localstack` action with the `ephemeral` state backend. The action supplies `AWS_ENDPOINT_URL` to the preview command; Terraform receives it through `TF_VAR_localstack_endpoint`.

## Run locally (optional)

Requirements: Docker Compose, Terraform, and Python 3.

```bash
docker compose up -d
cd infra
terraform init
terraform plan -out=tfplan
terraform show -json tfplan > ../plan.json
cd ..
python scripts/generate_insight.py --plan plan.json --output insight.json
cd infra && terraform apply -auto-approve
```

For local runs, the Terraform endpoint defaults to `http://localhost:4566`.

## Demo pull requests

- **Risky change:** grants wildcard IAM actions/resources. The insight should flag it and recommend narrowing permissions.
- **Safe change:** adds a tagged S3 bucket. The plan should complete without a configured security finding.

The analyzer is intentionally small and heuristic-based; it is a demonstration, not a complete IaC security scanner.
