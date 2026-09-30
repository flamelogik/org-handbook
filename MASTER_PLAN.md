# Logik GitHub Master Plan

**Version:** 1.0 (2026-09-21) · **Plan owner:** the acting org owner · **Target launch:** week of Oct 26, 2026

This is a living checklist. Tick boxes as you finish them, and add notes directly under a task when something differs from the plan.

---

## Goals

1. Lock the org down so nobody can change things on their own, and make every change go through a reviewed pull request.
2. Give every repo the same foundation: license, README standard, templates, security settings and branch protection.
3. Launch with at least one real community repo, built and maintained by the acting owner, so newcomers have something to fork, test and file issues against. *(Rewritten 2026-09-30. The original goal was to revive two legacy repos; see the decision log for why they were deleted instead.)*
4. Open a clear, public path for any Flame artist to contribute to an existing repo or propose a new one.
5. Leave LogikProjekt exactly as it is.

## Ground rule: LogikProjekt stays out of scope

No ruleset, file, team or repo setting in this plan targets LogikProjekt. That covers two repos, `LOGIK-PROJEKT` and its private companion `PROJEKT-DEVELOPMENT`, which the same maintainer runs. Every script that touches repos refuses to run against either.

A few settings are **organization-wide**, though, and reach every repo automatically. These are the only places the plan touches LogikProjekt at all:

| Org-wide setting | Effect on LogikProjekt | How we handle it |
|---|---|---|
| Base member permission set to **No permission** | Members who could push to it only through the org default lose that access. Its owner is an org owner, so is unaffected. | The Phase 0 audit checks who has recently committed to it. If anyone besides its owner relies on base access, ask them before changing it. |
| **Require 2FA** | *Corrected 2026-09-30 against GitHub's current docs.* Members without 2FA are **not** removed; they keep their membership but can't use org resources until they enable it. Only **outside collaborators** without 2FA are removed, and that includes six read-only collaborators on the public LogikProjekt repo. | Tell the maintainer before switching it on. Removed outside collaborators get an email from GitHub and can be reinstated within 3 months. |
| **Actions policy** (allowed actions, default token set to read) | Could break its CI if its workflows use third-party actions or rely on write-by-default. | The audit lists every action its workflows use. Allow those before tightening. |
| **Default community files** from `.github` | They show up only where that repo has no file of its own. | No action needed. This is harmless, but mention it to its maintainer. |

---

## Timeline

| Phase | Dates | Outcome |
|---|---|---|
| 0. Prep and audit | Sep 21 – 27 | You know exactly who has access to what, and the LogikProjekt owner has been told what's coming |
| 1. Lock down | Sep 28 – Oct 2 | No one can change anything except through PRs |
| 2. Foundation repos | Sep 30 – Oct 9 | `.github`, `org-handbook` and `repo-template` are live, and Discussions is open (unannounced) |
| 3. First community repo | Oct 5 – 16 | The acting owner's new tool is in the org, up to standard, released and seeded with starter issues |
| 4. Soft launch | Oct 19 – 23 | 3 to 5 trusted artists have tested the whole flow, and owner or maintainer candidates are identified |
| 5. Launch | Week of Oct 26 | Public announcement goes out |
| 6. After launch | Nov onward | 30-day and 90-day reviews, move to 2-of-3 approvals |

---

## Phase 0: Prep and audit (Sep 21 – 27)

- [x] Install the tools: `brew install gh jq`
- [x] Sign in with the scopes the scripts need:
  ```bash
  gh auth login                                   # choose GitHub.com and HTTPS
  gh auth refresh -h github.com -s admin:org,workflow
  ```
- [x] Run the read-only audit. It changes nothing.
  ```bash
  ./scripts/00-audit.sh | tee ~/logik-audit-$(date +%F).txt
  ```
  > Keep the audit file private and **don't commit it**. It lists members without 2FA.
- [x] Review the audit (2026-09-21; details in DECISIONS.md and the private audit file):
  - [x] **Base permission.** Result: `read`, so Phase 1 is not urgent. If it says `write` or `admin`, all ~30 members can currently push to every repo. That makes Phase 1 urgent, so do it right after the heads-up below.
  - [x] **Members without 2FA.** Result: 30 of 38 members. Three of them are read-only collaborators on LOGIK-PROJEKT. Note who would be removed in Phase 1.
  - [x] **LogikProjekt commit authors and direct collaborators.** Result: no commits in 90 days; 10 direct collaborators, all read-only; its ruleset is disabled. Does anyone besides its owner commit there? If so, do they have direct access, or only access through the org default?
  - [x] **LogikProjekt workflow actions.** Result: no workflows in either protected repo, so `ALLOW_PATTERNS` stays empty. Copy any `uses:` entries that aren't `actions/...` or `github/...`. You'll need them for Phase 1.
  - [x] **Repo licenses.** Result: every repo, including both that the acting owner maintains. Note which repos say `NO LICENSE`.
- [x] Send the LogikProjekt owner a heads-up (draft below). Sent 2026-09-21; reply window closes 2026-09-28. Wait up to a week for a reply. If there is no response, go ahead with the changes the audit shows won't affect how that repo works.

<details>
<summary>Draft heads-up message to the LogikProjekt owner</summary>

> Hey [name], I'm taking on the job of getting the flamelogik GitHub org active again, and I want you to hear the plan from me first. **Nothing about LogikProjekt changes.** It stays yours to run, and I'm excluding it from every rule and template I set up.
>
> A few org-wide settings will reach every repo, though:
> 1. Members will no longer get automatic write access. You're an owner, so you're unaffected, but anyone who pushes to LogikProjekt only through the org default would lose that access. I can see [names / nobody] committing there recently. Want me to give anyone direct access first?
> 2. 2FA will be required for everyone in the org.
> 3. GitHub Actions will be limited to GitHub-made and verified actions, plus anything LogikProjekt already uses (I'll allow those explicitly).
>
> The full plan is in github.com/flamelogik/org-handbook once it's up. Happy to jump on a call.

</details>

---

## Phase 1: Lock down (Sep 28 – Oct 2)

### 1a. Member privileges (CLI)
- [x] Run the lockdown script. It sets base permission to **none**, turns off repo creation and private forking for members, then prints the new values. Done 2026-09-30; base permission `none` and all three repo-creation flags `false`, confirmed by reading the org back.
  ```bash
  ./scripts/01-lockdown.sh
  ```

### 1b. Remaining member privileges (web, because the API doesn't expose these)
Go to **github.com/organizations/flamelogik/settings/member_privileges** and set:
- [x] Repository visibility change: **off** Done 2026-09-30; API reads `members_can_change_repo_visibility: false`.
- [x] Repository deletion and transfer: **off** Done 2026-09-30; `members_can_delete_repositories: false`.
- [x] Issue deletion: **off** Done 2026-09-30; `members_can_delete_issues: false`.
- [x] Allow members to create teams: **off** Done 2026-09-30; `members_can_create_teams: false`.
- [x] ~~Allow members to invite outside collaborators: **off**~~ Not available 2026-09-30. GitHub only offers this restriction on Enterprise Cloud, so the checkbox doesn't appear on the Free plan. It isn't needed: only a repo admin can invite an outside collaborator, maintainers get Maintain rather than Admin, and the audit shows no one but owners holds admin on any community repo.

  You can verify all of these afterwards with `gh api orgs/flamelogik --jq 'with_entries(select(.key | startswith("members_can")))'`.

### 1c. Require 2FA (web)
What GitHub does now, checked 2026-09-30: **members** without 2FA stay in the org but are locked out of its resources until they enable it. **Outside collaborators** without 2FA are removed and emailed by GitHub; they can be reinstated within 3 months.
- [x] Re-check the no-2FA lists: `gh api "orgs/flamelogik/members?filter=2fa_disabled" --jq '.[].login'` and the same with `outside_collaborators`. Done 2026-09-30: 30 of 38 members, 6 of 7 outside collaborators. All three owners and the LogikProjekt maintainer have 2FA.
- [x] Tell the LogikProjekt maintainer that six outside collaborators on `LOGIK-PROJEKT` will be removed and three members locked out until they enable 2FA. Sent 2026-09-30.
- [x] Tell the affected people. GitHub doesn't expose their email addresses, so use an issue that @mentions them plus a forum and Discord post. Sent 2026-09-30.
- [x] Turn it on in **Settings → Authentication security → Require two-factor authentication for everyone in your organization**. Done 2026-09-30; the org reads `two_factor_requirement_enabled: true`. All 38 members remain, 30 of them locked out until they enable 2FA. Six outside collaborators were removed and one remains. Owners and `PROJEKT-DEVELOPMENT` are unchanged.
- [x] Save the list of removed outside collaborators in your private audit file, so they can be re-invited. Done 2026-09-30, before the switch: 6 outside collaborators and 30 members recorded in a private file outside the repo.

### 1d. Actions policy (CLI)
- [x] Put the third-party actions LogikProjekt uses (from the audit) in `ALLOW_PATTERNS`, comma-separated, then run: Done 2026-09-30 with an empty allow-list; policy reads `selected`, GitHub-owned and verified only, default token `read`, workflows can't approve PRs.
  ```bash
  ALLOW_PATTERNS="someowner/some-action@*,other/thing@*" ./scripts/02-actions-policy.sh
  # If LogikProjekt uses no third-party actions:
  ./scripts/02-actions-policy.sh
  ```
  This allows only GitHub-made actions, verified-creator actions and your allow-list. It also sets the default workflow token to read-only and stops workflows from approving PRs.
- [x] If LogikProjekt's workflows push commits or create releases *without* declaring `permissions:` in the YAML, the read-only token will break them. In that case, tell its owner. The fix is a one-line `permissions:` block in the workflow, and it's the maintainer's to add. Not applicable 2026-09-30; the audit found no workflows in either protected repo.

### 1e. Security features (web)
- [x] **Settings → Advanced Security → Configurations** (the sidebar used to call this "Code security"; direct link: github.com/organizations/flamelogik/settings/security_products). Apply the **GitHub recommended** configuration to every repo **except LogikProjekt**. This turns on Dependabot alerts, secret scanning with push protection, and private vulnerability reporting. Done 2026-09-30 through the API instead, which avoids the web page's upgrade prompt: `gh api -X POST orgs/flamelogik/code-security/configurations/17/attach -f scope=selected -F "selected_repository_ids[]=ID" ...`. Attached to `logik-matchbox-shaders` and `flameTimewarpML`; no configuration on either protected repo.
- [x] Set that configuration as the default for new repos. Done 2026-09-30 with `gh api -X PUT orgs/flamelogik/code-security/configurations/17/defaults -f default_for_new_repos=public`; the org reads back "GitHub recommended" as the default for new public repos. `public` rather than `all`, so a private repo can never pick up a paid feature.

### 1f. Existing ~30 members
- [x] **Don't remove anyone yet.** Held 2026-09-30: no member was removed in Phase 1. With base permission set to none, membership grants no access, so it's harmless. These people are your likely early contributors. You'll message them at launch (Phase 5) and review them at 90 days (Phase 6).

---

## Phase 2: Foundation repos (Sep 30 – Oct 9)

### 2a. Fill in placeholders
- [x] Search the kit for `TODO:` (`grep -rn "TODO:" dot-github repo-template`) and fill each one in: Done 2026-09-30; the grep returns nothing.
  - [x] The conduct contact email in `dot-github/CODE_OF_CONDUCT.md`. Consider a shared address such as a Logik alias, not a personal inbox. Done 2026-09-30: `conduct@logik.tv`, a shared mailbox, confirmed set up and accessible.
  - [x] The Logik forum URL in `dot-github/.github/ISSUE_TEMPLATE/config.yml` and `dot-github/profile/README.md`. Check that it's correct. Done 2026-09-21 (`https://forum.logik.tv/`), plus the permanent Discord invite in `SUPPORT.md` and the profile README.
- [x] Read through `GOVERNANCE.md`, `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` in `dot-github/`. It's much easier to tweak them now than after launch. Done 2026-09-21; changes recorded in DECISIONS.md.

### 2b. Create the repos and teams (CLI)
- [x] From the kit's top folder (the one that contains `dot-github/`), run: Done 2026-09-30; two teams, three public repos, settings, Maintain for `owners`, ruleset, template flag, Discussions and labels all read back correctly from the API.
  ```bash
  ./org-handbook/scripts/03-bootstrap.sh
  ```
  The script does the following:
  - Creates the `owners` team and adds you, and creates the `maintainers` parent team.
  - Creates and pushes `.github`, `org-handbook` and `repo-template`, all public.
  - Applies the standard repo settings: squash-merge only, delete branches after merge, no wiki.
  - Marks `repo-template` as a template repository.
  - Gives the `owners` team Maintain access and makes it the code owner of all three repos.
  - Applies the branch ruleset to all three.
  - Enables Discussions on `.github` and creates the `proposal`, `accepted` and `declined` labels.
- [x] After the first run, check one ruleset in the web UI: **Repo → Settings → Rules → Rulesets → protect-default-branch**. Confirm it requires a PR with 1 approval and that "Organization admin" can bypass *for pull requests only*. That bypass lets you merge your own PRs while you're the only active owner. Checked 2026-09-30 through the API on `org-handbook`: PR with 1 approval, stale approvals dismissed, threads resolved, no deletion or force push, `OrganizationAdmin` bypass in `pull_request` mode only.

### 2c. Organization Discussions (web, because the API can't do this)
- [x] **Org Settings → Discussions →** enable, and choose `flamelogik/.github` as the source repo. Done 2026-09-30.
- [x] Set up these categories. They are managed on the source repo at github.com/flamelogik/.github/discussions/categories, not on the org's Discussions page. GitHub creates Announcements, Ideas, Q&A and Show and tell by default, so only Repo Proposals has to be added. Pick each emoji with the category's emoji picker instead of typing it into the name, so the URL slugs stay clean (`repo-proposals`, `q-a`, and so on). The issue-form links depend on those slugs. Done 2026-09-30; the API reads back five categories with slugs `announcements`, `ideas`, `q-a`, `repo-proposals` and `show-and-tell`.

  | Category | Format | Notes |
  |---|---|---|
  | 📣 Announcements | Announcement | Only owners and maintainers can post |
  | 💡 Repo Proposals | Open-ended discussion | **The slug must be `repo-proposals`**, which you can check in the category URL. The proposal form only loads with that exact slug. |
  | 🧠 Ideas | Open-ended discussion | Rough ideas that aren't ready to be proposals |
  | 🙏 Q&A | Question / Answer | Help using community tools |
  | 🎬 Show and Tell | Open-ended discussion | Work made with community tools |

- [x] Delete the default categories you don't want, such as General and Polls. Done 2026-09-30; both are gone.
- [x] Test it: start a new discussion in Repo Proposals and confirm the form appears. Then delete the test. Done 2026-09-30; the proposal form loads with its fields, and Announcements shows a plain title and body, which is correct because it has no template.

### 2d. Organization profile (web, because the API can't set the avatar)
- [x] **Org Settings → Profile.** Upload the existing Logik logo as the profile picture, set the description to something like "Community tools for Autodesk Flame, from the Logik user group", and put `https://forum.logik.tv/` in the URL field. The Logik community leads were told on 2026-09-22 that the existing logo and the `y9ZQFZY2BA` Discord invite are being used; swap either only if they object. Done 2026-09-30. The logo and display name were already set; the description was added, and the URL stays `www.logik.tv` because the forum is linked from the profile README anyway.
- [x] Profile README: added a "Flame tools hosted elsewhere" heading linking Logik Portal, Logik Matchbook and flameTimewarpML, so well-known tools outside the org are findable without mirroring them. Done 2026-09-30 through `.github` PRs #2 and #3, the first PRs merged with the owner bypass.

**Phase 2 complete 2026-09-30.**

---

## Phase 3: First community repo (Oct 5 – 16)

*Rewritten 2026-09-30.* The two legacy repos this phase was about turned out to be a stale fork of someone else's actively maintained project and an empty repo. Both were deleted (see DECISIONS.md, 2026-09-30). The first community repo is instead a new tool the acting owner is building. Its repo is created with `new-repo.sh`, which makes this the first real run of that script and of the whole new-repo path. Replace `REPO` with the tool's name.

- [ ] **Get the tool ready in its own working copy first.** It needs the README sections from `repo-template` (status, maintainer, what it does, compatibility table, install, usage, known issues, credits), a `CHANGELOG.md`, and a clean provenance: no adapted code without its source and license noted. Test it on at least one current Flame version and OS and record that in the compatibility table.
- [ ] **Choose the name, description and topics.** Name is lowercase-with-hyphens and describes the tool. Pick at least one kind topic and one area topic from REPO_STANDARDS.md.
- [ ] **Create the repo.** From `org-handbook/`:
  ```bash
  ./scripts/new-repo.sh REPO your-github-username "One-line description" "flame,logik,<kind-topic>,<area-topic>"
  ```
  The script creates the repo from `repo-template`, creates the `REPO-maintainers` team and adds you, fills in the README, LICENSE and CODEOWNERS placeholders, adds the topics, and applies the standard settings and the branch ruleset. Check the result at github.com/flamelogik/REPO. The "GitHub recommended" security configuration attaches automatically because it's the org default for new public repos.
- [ ] **Bring the code in through a pull request.** Clone the new repo, add the tool's files on a branch, and open a PR. The owner bypass lets you merge it without a second reviewer for now. This is the same path every contributor will use, so note anything awkward for the contributing guide.
- [ ] **Cut a release:**
  ```bash
  gh release create v1.0.0 --repo flamelogik/REPO --generate-notes
  ```
- [ ] **Open 3 to 5 starter issues** labeled `good first issue` and `help wanted`. Include at least one "test on Flame VERSION on OS and report back" issue, since that's the contribution most artists can make on day one.
- [ ] **Record what the script got wrong or missed** and fix it in `scripts/` by PR before the soft launch.

---

## Phase 4: Soft launch (Oct 19 – 23)

- [ ] Invite 3 to 5 trusted Flame artists, including a couple who've never used GitHub, to run through the whole flow:
  *Four testers were invited on 2026-09-30. Their names stay in the private working notes until they agree to be listed.*
  - [ ] Open a test repo proposal.
  - [ ] Fork one of your repos, make a small change and open a PR.
  - [ ] File a bug using the issue form.
- [ ] Fix whatever confused them, whether it's the docs, forms or templates.
- [ ] Identify **owner candidates** (goal: 1 or 2 new active owners) and **maintainer candidates**.
- [ ] Draft the launch announcement. Claude can help with this, since it's deferred until now on purpose.

---

## Phase 5: Launch (week of Oct 26)

- [ ] Pin an announcement in **Discussions → Announcements**.
- [ ] Post on the Logik forum and Discord, linking to the Discussions page and to CONTRIBUTING.
- [ ] Message the ~30 existing org members. Explain what changed and invite them to Discussions. Point out that membership no longer grants access, and that contributing works through PRs.
- [ ] Watch Discussions daily for the first week. Fast first responses set the tone.

---

## Phase 6: After launch

- [ ] **30 days (late Nov):** Review which docs or forms caused confusion, and update them through PRs.
- [ ] **90 days (late Jan):** Review the idle original members. Keep anyone who engaged. For the rest, the owners decide whether to remove them. Log that decision in DECISIONS.md.
- [ ] **When there are at least 2 active owners:**
  - [ ] Update GOVERNANCE.md so approvals require 2 of 3, and log it in DECISIONS.md.
  - [ ] Add the new owners to the `owners` team.
  - [ ] Consider removing the owner bypass from the rulesets, so owners review each other's PRs.
- [ ] **Quarterly:** Run `./scripts/00-audit.sh` and follow the audit checklist in OWNER_RUNBOOK.md.

---

## Parking lot
Ideas that are out of scope for launch, kept here so they aren't lost:
- A shared GitHub Actions workflow for building and releasing OpenFX plugins on macOS and Linux
- A logik-portal.com integration, so tagged releases appear on the portal automatically
- Applying to GitHub's nonprofit program, if Logik ever registers as a nonprofit
- An org-wide `CODEOWNERS` review rotation once there are more maintainers
