#!/usr/bin/env bash
# Create an approved community repo from repo-template, assign its
# maintainer, fill in placeholders, then protect it.
# Usage: ./scripts/new-repo.sh NAME MAINTAINER "Description" ["topic1,topic2"]
# NAME must be lowercase-with-hyphens.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools
command -v git >/dev/null || die "git not found."

NAME="${1:-}"; MAINTAINER="${2:-}"; DESC="${3:-}"; TOPICS="${4:-flame,logik}"
[ -n "$NAME" ] && [ -n "$MAINTAINER" ] && [ -n "$DESC" ] || \
  die "Usage: $0 NAME MAINTAINER \"Description\" [\"topic1,topic2\"]"
[[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Name must be lowercase letters, numbers and hyphens."
guard_repo "$NAME"
gh api "repos/$ORG/$NAME" >/dev/null 2>&1 && die "$ORG/$NAME already exists."

echo "Create $ORG/$NAME"
echo "  maintainer:  $MAINTAINER"
echo "  description: $DESC"
echo "  topics:      $TOPICS"
confirm "Continue?"

info "Creating repo from $ORG/repo-template"
gh repo create "$ORG/$NAME" --public --template "$ORG/repo-template" --description "$DESC" >/dev/null

info "Waiting for template contents to copy"
for i in $(seq 1 20); do
  gh api "repos/$ORG/$NAME/contents/README.md" >/dev/null 2>&1 && break
  sleep 3
  [ "$i" -eq 20 ] && die "Template copy is taking too long. Re-run the remaining steps manually."
done

"$(dirname "$0")/add-maintainer.sh" "$NAME" "$MAINTAINER"
TEAM="$NAME-maintainers"

info "Filling in placeholders"
TMP=$(mktemp -d)
gh repo clone "$ORG/$NAME" "$TMP/$NAME" -- --quiet
(
  cd "$TMP/$NAME"
  printf '# Code owners are requested for review on every PR.\n* @%s/%s\n' "$ORG" "$TEAM" > .github/CODEOWNERS
  NAME="$NAME" DESC="$DESC" MAINT="$MAINTAINER" YEAR="$(date +%Y)" perl -pi -e '
    s/TOOL_NAME/$ENV{NAME}/g;
    s/ONE_LINE_DESCRIPTION/$ENV{DESC}/g;
    s/MAINTAINER_HANDLE/$ENV{MAINT}/g;
    s/Copyright \(c\) \d{4}/Copyright (c) $ENV{YEAR}/g;
  ' README.md LICENSE
  git add -A
  git commit -q -m "Set up $NAME from repo-template"
  git push -q
)
rm -rf "$TMP"

gh repo edit "$ORG/$NAME" --add-topic "$TOPICS"
"$(dirname "$0")/protect-repo.sh" "$NAME"

echo
echo "✅ https://github.com/$ORG/$NAME is ready."
echo "   If it came from a proposal, post the link in the thread and add the 'accepted' label."
