# Scripts

GitHub CLI scripts for running the org. They need `gh`, and `02-actions-policy.sh` also needs `jq` (`brew install gh jq`). Run them from the `org-handbook` folder unless noted. Lint with `shellcheck -x -P SCRIPTDIR scripts/*.sh`.

Every script that modifies a repo **refuses to touch LogikProjekt** (`LOGIK-PROJEKT` and `PROJEKT-DEVELOPMENT`). The scripts that change something ask for confirmation first.

| Script | What it does | Changes things? |
|---|---|---|
| `00-audit.sh` | Full read-only audit of members, 2FA, repos, rulesets and the protected repos' collaborators, commits and workflows | No |
| `01-lockdown.sh` | Sets base permission to none and turns off member repo creation and private forking | Yes, org-wide |
| `02-actions-policy.sh` | Actions allow-list, read-only default token | Yes, org-wide |
| `03-bootstrap.sh` | Creates teams and the `.github`, `org-handbook` and `repo-template` repos (run from the kit's top folder) | Yes |
| `protect-repo.sh REPO` | Standard settings, vulnerability reporting and the branch ruleset | Yes, one repo |
| `add-maintainer.sh REPO USER` | Creates the `REPO-maintainers` team, adds the user and grants Maintain | Yes, one repo |
| `new-repo.sh NAME USER "desc" "topics"` | Creates an approved repo from the template and sets everything up | Yes, one repo |
| `lib.sh` | Shared helpers, sourced by the others | – |

You can override defaults with environment variables: `ORG` (default `flamelogik`) and `PROTECTED_REPOS` (default `LOGIK-PROJEKT,PROJEKT-DEVELOPMENT`, comma-separated).
