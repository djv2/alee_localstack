# LocalStack PR Infrastructure Insights

A small proof of concept that provisions changed Terraform infrastructure into an ephemeral LocalStack instance for each pull request, analyzes the Terraform plan, and publishes a developer/agent-ready insight.

## What it demonstrates

- Terraform-managed S3, SQS, Lambda, and IAM resources.
- GitHub Actions starts LocalStack for each PR, runs `terraform plan`, analyzes the JSON plan, and applies the change locally.
- A concise PR comment plus `insight.json` as a workflow artifact.
- A security check for wildcard IAM permissions and public S3 access settings.

No cloud account, hosted service, dashboard, or persistent backend is required. LocalStack runs only inside the GitHub Actions job.

## Run locally

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

LocalStack is exposed at `http://localhost:4566`. The workflow uses dummy AWS credentials and Terraform's LocalStack endpoint overrides.

## Demo pull requests

- **Risky change:** grants wildcard IAM actions/resources. The insight should flag it and recommend narrowing permissions.
- **Safe change:** changes a resource tag only. The plan should complete without a security finding.

The analyzer is intentionally small and heuristic-based; it is a demonstration, not a complete IaC security scanner.
