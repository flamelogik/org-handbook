#!/usr/bin/env bash
# Shared settings and helpers. Sourced by the other scripts; don't run directly.

ORG="${ORG:-flamelogik}"
# LOGIK-PROJEKT and its private companion PROJEKT-DEVELOPMENT are independently
# run. Scripts refuse to modify them. Comma-separated; override with the env var.
PROTECTED_REPOS="${PROTECTED_REPOS:-LOGIK-PROJEKT,PROJEKT-DEVELOPMENT}"

# Iterate the protected list: for_each_protected <function-name>
for_each_protected() {
  local r
  for r in $(echo "$PROTECTED_REPOS" | tr ',' ' '); do "$1" "$r"; done
}

die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

require_tools() {
  command -v gh >/dev/null || die "GitHub CLI not found. Install with: brew install gh"
  gh auth status >/dev/null 2>&1 || die "Not signed in. Run: gh auth login"
}

# Lowercase and drop hyphens/underscores, so LogikProjekt, LOGIK-PROJEKT and
# logik_projekt all compare equal. GitHub repo names are case-insensitive.
normalize_name() { echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '_-'; }

guard_repo() {
  local repo="$1" p
  [ -n "$repo" ] || die "No repo name given."
  for p in $(echo "$PROTECTED_REPOS" | tr ',' ' '); do
    if [ "$(normalize_name "$repo")" = "$(normalize_name "$p")" ]; then
      die "$repo is independently run and excluded from org automation. Not touching it."
    fi
  done
}

confirm() {
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || die "Cancelled."
}

# Standard settings for community repos: squash merges only, auto-delete
# merged branches, no wiki (docs live in the repo), issues on.
standard_settings() {
  local repo="$1"; guard_repo "$repo"
  info "Applying standard settings to $ORG/$repo"
  gh repo edit "$ORG/$repo" \
    --enable-squash-merge \
    --enable-merge-commit=false \
    --enable-rebase-merge=false \
    --delete-branch-on-merge \
    --enable-wiki=false \
    --enable-issues
}

# Creates or updates the default-branch ruleset:
#  - changes must arrive by pull request with 1 approval
#  - new pushes dismiss stale approvals; all review threads must be resolved
#  - no force pushes, no branch deletion
#  - org owners may bypass ONLY through a pull request (lets a solo owner
#    merge their own PR; still no direct pushes)
apply_ruleset() {
  local repo="$1"; guard_repo "$repo"
  local name="protect-default-branch"
  local body
  body=$(cat <<JSON
{
  "name": "$name",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "bypass_actors": [
    { "actor_id": 1, "actor_type": "OrganizationAdmin", "bypass_mode": "pull_request" }
  ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true
    } }
  ]
}
JSON
)
  local existing
  existing=$(gh api "repos/$ORG/$repo/rulesets" --jq ".[] | select(.name==\"$name\") | .id" 2>/dev/null || true)
  if [ -n "$existing" ]; then
    info "Updating ruleset '$name' on $ORG/$repo"
    echo "$body" | gh api -X PUT "repos/$ORG/$repo/rulesets/$existing" --input - >/dev/null
  else
    info "Creating ruleset '$name' on $ORG/$repo"
    echo "$body" | gh api -X POST "repos/$ORG/$repo/rulesets" --input - >/dev/null
  fi
}

team_exists() { gh api "orgs/$ORG/teams/$1" >/dev/null 2>&1; }

# ensure_team <slug> <description> [parent-slug]
ensure_team() {
  local slug="$1" desc="$2" parent="${3:-}"
  if team_exists "$slug"; then
    info "Team $slug already exists"
    return
  fi
  info "Creating team $slug"
  if [ -n "$parent" ]; then
    local parent_id
    parent_id=$(gh api "orgs/$ORG/teams/$parent" --jq .id)
    gh api "orgs/$ORG/teams" -f name="$slug" -f description="$desc" \
      -f privacy=closed -F parent_team_id="$parent_id" >/dev/null
  else
    gh api "orgs/$ORG/teams" -f name="$slug" -f description="$desc" \
      -f privacy=closed >/dev/null
  fi
}

# grant_team <team-slug> <repo> <permission: pull|triage|push|maintain|admin>
grant_team() {
  local team="$1" repo="$2" perm="$3"; guard_repo "$repo"
  info "Granting $team '$perm' on $ORG/$repo"
  gh api -X PUT "orgs/$ORG/teams/$team/repos/$ORG/$repo" -f permission="$perm" >/dev/null
}

# add_to_team <team-slug> <username>
add_to_team() {
  info "Adding $2 to team $1 (sends an org invite if they aren't a member yet)"
  gh api -X PUT "orgs/$ORG/teams/$1/memberships/$2" -f role=member >/dev/null
}
