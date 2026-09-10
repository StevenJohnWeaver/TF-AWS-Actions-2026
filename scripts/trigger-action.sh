#!/usr/bin/env bash
# trigger-action.sh — invokes the aws_ec2_stop_instance action against
# Cloudability-Run-Task-2026 via the HCP Terraform Runs API.
#
# Demo framing: this simulates a maintenance runbook (cron job, ticketing
# system webhook, etc.) kicking off a "stop for maintenance" workflow
# without anyone touching the HCP Terraform UI.
#
# Why this works even though the workspace is VCS-connected: this call
# does NOT push a new configuration from the CLI (that's what "terraform
# apply" does locally, and it's blocked for VCS-driven workspaces). It
# creates a run against the workspace's existing, already-ingressed VCS
# configuration and tells that run which action address to invoke — the
# same thing that happens when you click "Invoke action" in the UI.
#
# Usage:
#   TFE_TOKEN=<your-token> TFE_WORKSPACE_ID=ws-XXXXXXXX ./scripts/trigger-action.sh
#
# The TFE_TOKEN must have permission to create runs in the workspace.
# Find the workspace ID in HCP Terraform: Workspace → Settings → General → Workspace ID.

set -euo pipefail

: "${TFE_TOKEN:?Set TFE_TOKEN to an HCP Terraform API token}"
: "${TFE_WORKSPACE_ID:?Set TFE_WORKSPACE_ID to the Cloudability-Run-Task-2026 workspace ID (ws-...)}"

TFE_HOST="${TFE_HOST:-app.terraform.io}"
TFE_ORG="${TFE_ORG:-steve-weaver-demo-org}"
TFE_WORKSPACE_NAME="${TFE_WORKSPACE_NAME:-Cloudability-Run-Task-2026}"

curl -sS --fail-with-body \
  --header "Authorization: Bearer ${TFE_TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @- \
  "https://${TFE_HOST}/api/v2/runs" <<EOF
{
  "data": {
    "type": "runs",
    "attributes": {
      "message": "Maintenance runbook: stopping web instance for scheduled maintenance",
      "invoke-action-addrs": ["action.aws_ec2_stop_instance.web_maintenance"],
      "auto-apply": true
    },
    "relationships": {
      "workspace": {
        "data": { "type": "workspaces", "id": "${TFE_WORKSPACE_ID}" }
      }
    }
  }
}
EOF

echo ""
echo "Run triggered. Check https://${TFE_HOST}/app/${TFE_ORG}/workspaces/${TFE_WORKSPACE_NAME}/runs"
