#!/usr/bin/env bash
# Phase 2b: create teams and the three foundation repos from the kit.
# Run from the kit's top folder (the one containing dot-github/).
# Safe to re-run: existing repos/teams are skipped, settings re-applied.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools
command -v git >/dev/null || die "git not found."
[ -d dot-github ] && [ -d org-handbook ] && [ -d repo-template ] || \
  die "Run this from the kit's top folder (where dot-github/ lives)."

if grep -rq "TODO:" dot-github repo-template 2>/dev/null; then
  echo "Placeholders still need filling in:"
  grep -rn "TODO:" dot-github repo-template
  confirm "Push anyway?"
fi

ME=$(gh api user --jq .login)
echo "Bootstrapping $ORG as $ME:"
echo "  teams: owners, maintainers"
echo "  repos: .github, org-handbook, repo-template (public)"
confirm "Continue?"

ensure_team owners "Active org owners; code owners for org infrastructure repos"
add_to_team owners "$ME"
ensure_team maintainers "All community repo maintainers (parent team; no repo access of its own)"

create_from_folder() {
  local folder="$1" repo="$2" desc="$3"
  if gh api "repos/$ORG/$repo" >/dev/null 2>&1; then
    info "$ORG/$repo already exists, skipping creation"
    return
  fi
  info "Creating $ORG/$repo from $folder/"
  local tmp; tmp=$(mktemp -d)
  cp -R "$folder/." "$tmp/"
  (
    cd "$tmp"
    git init -q -b main
    git add -A
    git commit -q -m "Initial commit from Logik GitHub kit"
    gh repo create "$ORG/$repo" --public --source=. --push --description "$desc" >/dev/null
  )
  rm -rf "$tmp"
}

create_from_folder dot-github    ".github"       "Community health files, policies and templates for the Logik GitHub org"
create_from_folder org-handbook  "org-handbook"  "Owner handbook, master plan and decision log for the Logik GitHub org"
create_from_folder repo-template "repo-template" "Starting point for new Logik community repos"

for r in .github org-handbook repo-template; do
  standard_settings "$r"
  grant_team owners "$r" maintain
  apply_ruleset "$r"
done

info "Marking repo-template as a template repository"
gh repo edit "$ORG/repo-template" --template

info "Enabling Discussions on .github and creating proposal labels"
gh repo edit "$ORG/.github" --enable-discussions
gh label create proposal --repo "$ORG/.github" --color 5319E7 --description "New repo proposal" --force
gh label create accepted --repo "$ORG/.github" --color 0E8A16 --description "Proposal accepted" --force
gh label create declined --repo "$ORG/.github" --color B60205 --description "Proposal declined" --force

echo
echo "✅ Bootstrap complete."
echo "Next:"
echo "  1. Check one ruleset: https://github.com/$ORG/org-handbook/settings/rules"
echo "  2. Turn on org Discussions (source repo: .github) and create the categories (MASTER_PLAN 2c)"
echo "  3. Work from clones from now on, e.g.: gh repo clone $ORG/org-handbook"
