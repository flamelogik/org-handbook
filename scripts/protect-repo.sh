#!/usr/bin/env bash
# Apply standard settings, private vulnerability reporting and the
# default-branch ruleset to one repo. Safe to re-run.
# Usage: ./scripts/protect-repo.sh REPO
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
require_tools
REPO="${1:-}"; guard_repo "$REPO"

standard_settings "$REPO"
info "Enabling private vulnerability reporting on $ORG/$REPO"
gh api -X PUT "repos/$ORG/$REPO/private-vulnerability-reporting" >/dev/null || \
  echo "   (could not enable; turn on under Settings → Code security)"
apply_ruleset "$REPO"
info "Done. Verify at https://github.com/$ORG/$REPO/settings/rules"
