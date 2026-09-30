#!/usr/bin/env bash
# READ-ONLY audit of the org. Changes nothing.
# Covers every repo in PROTECTED_REPOS (see lib.sh).
# Usage: ./scripts/00-audit.sh | tee ~/logik-audit-$(date +%F).txt
# Keep the output private: it lists members without 2FA.
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools

section() { echo; echo "===== $* ====="; }

section "Org settings"
gh api "orgs/$ORG" --jq '{
  plan: .plan.name,
  default_repository_permission,
  members_can_create_repositories,
  members_can_create_public_repositories,
  members_can_create_private_repositories,
  members_can_fork_private_repositories,
  two_factor_requirement_enabled
}'

section "Owners"
gh api "orgs/$ORG/members?role=admin" --paginate --jq '.[].login'

section "Member count (all roles)"
gh api "orgs/$ORG/members" --paginate --jq '.[].login' | wc -l | tr -d ' '

section "Members WITHOUT 2FA (removed if 2FA becomes required)"
gh api "orgs/$ORG/members?filter=2fa_disabled" --paginate --jq '.[].login'

section "Outside collaborators"
gh api "orgs/$ORG/outside_collaborators" --paginate --jq '.[].login'

section "Pending invitations"
gh api "orgs/$ORG/invitations" --paginate --jq '.[] | "\(.login // .email)\t\(.role)"'

section "Teams"
gh api "orgs/$ORG/teams" --paginate --jq '.[] | "\(.slug)\t\(.privacy)"'

section "Repos: name | visibility | archived | last push | license | rulesets"
gh repo list "$ORG" --limit 200 --json name,visibility,isArchived,pushedAt,licenseInfo \
  --jq '.[] | "\(.name)\t\(.visibility)\t\(.isArchived)\t\(.pushedAt[0:10])\t\(.licenseInfo.spdxId // "NO LICENSE")"' |
while IFS=$'\t' read -r name vis arch pushed lic; do
  rs=$(gh api "repos/$ORG/$name/rulesets" --jq '[.[].name] | join(",")' 2>/dev/null)
  printf '%s | %s | archived=%s | %s | %s | rulesets=%s\n' "$name" "$vis" "$arch" "$pushed" "$lic" "${rs:-none}"
done

audit_protected() {
  local repo="$1"
  section "$repo: direct collaborators (read-only check)"
  gh api "repos/$ORG/$repo/collaborators?affiliation=direct" --paginate \
    --jq '.[] | "\(.login)\t\(.role_name)"' 2>/dev/null || echo "(could not read)"

  section "$repo: commit authors in the last 90 days"
  local since
  since=$(date -u -v-90d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '90 days ago' +%Y-%m-%dT%H:%M:%SZ)
  gh api "repos/$ORG/$repo/commits?since=$since" --paginate \
    --jq '.[] | (.author.login // .commit.author.name)' 2>/dev/null | sort | uniq -c
  echo "(end of list; empty means no commits or could not read)"

  section "$repo: actions used by its workflows"
  local files f
  # Only real workflow files. On a 404 (no workflows folder) gh prints the
  # error body to stdout, so discard the output when the call fails.
  files=$(gh api "repos/$ORG/$repo/contents/.github/workflows" \
    --jq '.[].path | select(test("\\.ya?ml$"))' 2>/dev/null) || files=""
  if [ -z "$files" ]; then
    echo "(no workflows)"
  else
    for f in $files; do
      echo "-- $f"
      gh api "repos/$ORG/$repo/contents/$f" -H "Accept: application/vnd.github.raw" 2>/dev/null |
        grep -E '^\s*(-\s*)?uses:|^\s*permissions:' || echo "   (no 'uses:' lines)"
    done
  fi
}
for_each_protected audit_protected

echo
echo "Audit complete. Nothing was changed."
