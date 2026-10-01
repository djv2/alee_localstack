#!/usr/bin/env python3
"""Convert Terraform plan JSON into a concise actionable insight."""
import argparse, json
from pathlib import Path


def walk(value):
    if isinstance(value, dict):
        for key, child in value.items():
            yield key, child
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def analyze(plan):
    changes, findings = [], []
    for item in plan.get("resource_changes", []):
        change = item.get("change", {})
        actions = change.get("actions", [])
        if actions == ["no-op"]: continue
        address = item.get("address", item.get("type", "resource"))
        changes.append({"address": address, "actions": actions})
        after = change.get("after") or {}
        for key, val in walk(after):
            if key == "policy" and isinstance(val, str):
                try: val = json.loads(val)
                except (ValueError, TypeError): continue
                for pkey, pval in walk(val):
                    if pkey == "Action" and (pval == "*" or (isinstance(pval, list) and "*" in pval)):
                        findings.append({"id":"IAM_WILDCARD_ACTIONS","severity":"high","resource":address,"message":"IAM policy grants wildcard actions.","recommendation":"Replace '*' with only the API actions the workload requires."})
                    if pkey == "Resource" and (pval == "*" or (isinstance(pval, list) and "*" in pval)):
                        findings.append({"id":"IAM_WILDCARD_RESOURCE","severity":"high","resource":address,"message":"IAM policy applies to all resources.","recommendation":"Scope the policy to the exact resource ARN needed."})
        if item.get("type") == "aws_s3_bucket_public_access_block" and (after.get("block_public_acls") is False or after.get("block_public_policy") is False):
            findings.append({"id":"S3_PUBLIC_ACCESS_ENABLED","severity":"high","resource":address,"message":"S3 public-access protections are disabled.","recommendation":"Keep public-access block settings enabled unless public access is explicitly required and reviewed."})
    findings = list({(f["id"], f["resource"]): f for f in findings}.values())
    return {"schema_version":"1.0","summary":"Infrastructure review found actionable risk." if findings else "No configured security rules were triggered.","status":"action_required" if findings else "clear","change_count":len(changes),"changes":changes,"findings":findings,"agent_instruction":"Address the findings, update the infrastructure code, and rerun the plan." if findings else "No action required by configured checks. Review the plan normally before merging."}


if __name__ == "__main__":
    parser=argparse.ArgumentParser(); parser.add_argument("--plan",required=True); parser.add_argument("--output",required=True); args=parser.parse_args()
    result=analyze(json.loads(Path(args.plan).read_text())); Path(args.output).write_text(json.dumps(result,indent=2)+"\n"); print(json.dumps(result,indent=2))
