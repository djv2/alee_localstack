# LocalStack PR Infrastructure Insights

A small proof of concept: on infrastructure pull requests, GitHub Actions starts a temporary LocalStack instance, plans and applies Terraform changes, analyzes the plan, and posts an actionable insight.

## Flow

1. Start LocalStack with the `lstk` CLI.
2. Run Terraform plan against LocalStack.
3. Generate `insight.json` with the configured security checks.
4. Apply the plan, post the insight to the PR, and upload the JSON artifact.

The demo provisions an S3 bucket, SQS queue, and IAM role/policy. The analyzer currently flags wildcard IAM actions/resources and selected S3 public-access settings. It is a small heuristic demo, not a full security scanner.

## GitHub setup

Add a repository Actions secret named `LOCALSTACK_AUTH_TOKEN` containing your LocalStack CI Auth Token. The workflow follows the current LocalStack GitHub Actions guidance and installs/runs `lstk` directly.

## Run locally (optional)

Start LocalStack, then run:

```bash
lstk start
terraform -chdir=infra init
terraform -chdir=infra plan -out=tfplan
terraform -chdir=infra show -json tfplan > plan.json
python3 scripts/generate_insight.py --plan plan.json --output insight.json
terraform -chdir=infra apply -auto-approve tfplan
```

Terraform configuration is kept in one file: `infra/main.tf`.
