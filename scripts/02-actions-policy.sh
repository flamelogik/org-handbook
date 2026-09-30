#!/usr/bin/env bash
# Phase 1d: org-wide GitHub Actions policy.
#  - Only GitHub-owned actions, verified-creator actions and ALLOW_PATTERNS may run
#  - Default GITHUB_TOKEN is read-only; workflows can't approve PRs
# ALLOW_PATTERNS: comma-separated, e.g. "owner/action@*,other/thing@v2"
# Put every third-party action LogikProjekt uses here (see 00-audit.sh output)
# so its CI keeps working.
# Requires jq (brew install jq).
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools
command -v jq >/dev/null || die "jq not found. Install with: brew install jq"

ALLOW_PATTERNS="${ALLOW_PATTERNS:-}"
echo "Actions policy for $ORG:"
echo "  allowed: GitHub-owned, verified creators, plus: ${ALLOW_PATTERNS:-(nothing extra)}"
echo "  default workflow token: read-only; workflows may not approve PRs"
confirm "Continue?"

gh api -X PUT "orgs/$ORG/actions/permissions" \
  -f enabled_repositories=all -f allowed_actions=selected >/dev/null

jq -n --arg p "$ALLOW_PATTERNS" \
  '{github_owned_allowed: true, verified_allowed: true,
    patterns_allowed: ($p | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0)))}' |
  gh api -X PUT "orgs/$ORG/actions/permissions/selected-actions" --input - >/dev/null

gh api -X PUT "orgs/$ORG/actions/permissions/workflow" \
  -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false >/dev/null

info "Done. Current policy:"
gh api "orgs/$ORG/actions/permissions/selected-actions"
gh api "orgs/$ORG/actions/permissions/workflow"
