#!/usr/bin/env bash
# Phase 1a: member privileges that the API supports.
# Base permission -> none; members cannot create repos or fork private repos.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools

echo "This will change org-wide settings for $ORG:"
echo "  - base repository permission for members  -> none"
echo "  - members can create repositories         -> false (public and private)"
echo "  - members can fork private repositories   -> false"
confirm "Continue?"

gh api -X PATCH "orgs/$ORG" \
  -f default_repository_permission=none \
  -F members_can_create_repositories=false \
  -F members_can_create_public_repositories=false \
  -F members_can_create_private_repositories=false \
  -F members_can_fork_private_repositories=false >/dev/null

info "New values:"
gh api "orgs/$ORG" --jq '{default_repository_permission, members_can_create_repositories,
  members_can_create_public_repositories, members_can_create_private_repositories,
  members_can_fork_private_repositories}'

echo
echo "Next: finish Phase 1b in the web UI (visibility change, deletion/transfer,"
echo "issue deletion, team creation, outside-collaborator invites):"
echo "  https://github.com/organizations/$ORG/settings/member_privileges"
