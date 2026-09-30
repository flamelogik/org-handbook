#!/usr/bin/env bash
# Give a user Maintain access to one repo via a per-repo team
# (REPO-maintainers, a child of the 'maintainers' parent team so
# @flamelogik/maintainers reaches every maintainer).
# Usage: ./scripts/add-maintainer.sh REPO USERNAME
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools
REPO="${1:-}"; USERNAME="${2:-}"
guard_repo "$REPO"
[ -n "$USERNAME" ] || die "Usage: $0 REPO USERNAME"

TEAM=$(echo "$REPO-maintainers" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

ensure_team maintainers "All community repo maintainers (parent team; no repo access of its own)"
ensure_team "$TEAM" "Maintainers of $ORG/$REPO" maintainers
add_to_team "$TEAM" "$USERNAME"
grant_team "$TEAM" "$REPO" maintain

echo
echo "Done. Make sure $REPO has .github/CODEOWNERS containing:"
echo "  * @$ORG/$TEAM"
