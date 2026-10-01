#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${AWS_ENDPOINT_URL:-}" ]]; then
  echo "::error::LocalStack Cloud did not provide AWS_ENDPOINT_URL to preview-cmd."
  exit 1
fi

echo "Using LocalStack Cloud ephemeral endpoint: ${AWS_ENDPOINT_URL%%\?*}"
export TF_VAR_localstack_endpoint="$AWS_ENDPOINT_URL"
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

terraform -chdir=infra init -input=false
terraform -chdir=infra plan -input=false -out=tfplan
terraform -chdir=infra show -json tfplan > plan.json
python3 scripts/generate_insight.py --plan plan.json --output insight.json
terraform -chdir=infra apply -input=false -auto-approve tfplan
