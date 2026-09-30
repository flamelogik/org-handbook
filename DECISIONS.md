# Decision Log

Newest first. Each entry records what was decided, who decided it and why. To change a decision, add a new entry. Don't edit old ones.

---

### 2026-09-30: Conduct reports go to a shared mailbox
**Decided by:** the acting owner

- Code of conduct reports go to `conduct@logik.tv`, a shared mailbox on the Logik domain rather than any one person's inbox.
- **Why:** with one active GitHub owner, a personal address would leave someone with a complaint about that owner nowhere independent to send it. With a shared mailbox, whoever a report concerns steps aside and the others handle it.
- The mailbox is read by the acting owner and by the two Logik community leads. That replaces the fallback in the 2026-09-21 entry, which listed the leads' own addresses. The leads asked that those addresses not be published, so they are removed from the Code of Conduct and redacted in that earlier entry.
- A report about any one reader is handled by the other two. The Code of Conduct says so in general terms without naming anyone.

---

### 2026-09-22: Repos are organised with topics on two axes, not umbrella repos or submodules
**Decided by:** the acting owner

- Every repo carries at least one **kind** topic (`flame-python`, `matchbox`, `openfx`, `flame-tool`, `documentation`) and at least one **area** topic (`flame-timeline`, `flame-batch`, `flame-color`, `flame-tracking`, `flame-keying`, `flame-conform`, `flame-openclip`, `flame-publish`, `flame-pipeline`, `flame-ui`). The lists live in REPO_STANDARDS.md, and the proposal form asks for both.
- **Why:** GitHub has no folders inside an org, so grouping has to come from topics, the profile README and pinned repos. Kind determines install path, build and maintainer skills. Area is how artists look for a tool. Both matter, and topics allow several of each. Area topics carry a `flame-` prefix so they don't collide with GitHub's global `color` and `timeline` topics.
- **Not chosen:** umbrella monorepos per area, and git submodules. Submodules add a two-repo workflow for an audience that includes first-time GitHub users. Per-area monorepos would mix release cadences and give every maintainer in the group merge rights over everything in it.
- **Left open:** a collection repo for single-file Python scripts or shaders, decided when the first one is proposed or at the 30-day review. OpenFX plugins and standalone apps always get their own repo because of builds and releases.

---

### 2026-09-21: Community docs review before bootstrap
**Decided by:** the acting owner

- **Code of conduct fallback contacts.** Reports that concern the only active owner, or that someone prefers to make outside GitHub, go to the Logik community leads directly *(their addresses were removed from this entry on 2026-09-30 at their request; see the entry of that date)*. They lead the community but are not necessarily GitHub org owners. Reports are acknowledged within 7 days.
- **Interim bypass is disclosed.** GOVERNANCE.md now states that while one owner is active, that owner can merge their own PRs to the infrastructure repos without a second review. Better to publish this than have someone discover it.
- **"Active owner" is defined** as an owner who has responded to an owner request within the last 90 days. That gives the 2-of-3 switch a concrete trigger.
- **Proposal decisions** are due within 14 days of the 7-day comment period closing.

---

### 2026-09-21: PROJEKT-DEVELOPMENT is protected alongside LOGIK-PROJEKT
**Decided by:** the acting owner

- The Phase 0 audit showed the independent repo is named `LOGIK-PROJEKT` (with a hyphen), not `LogikProjekt`, and that the same maintainer also runs the private repo `PROJEKT-DEVELOPMENT`. Both are now excluded from org automation and from every rule and template in the plan.
- **Why:** the "LogikProjekt stays out of scope" ground rule is about the maintainer's independence, not one repo name. The private companion repo gets the same treatment.
- **How:** `scripts/lib.sh` now holds a comma-separated `PROTECTED_REPOS` list, and `guard_repo` compares names ignoring case, hyphens and underscores, so a spelling difference can't bypass the guard again.

---

### 2026-09-21: Master Plan v1 adopted
**Decided by:** the acting owner

- **Interim approvals.** A single owner's approval (the acting owner's) is enough for new repos, new maintainers and policy changes. The other two owners are currently inactive. When the org has at least two active owners, approvals switch to 2 of 3 (see GOVERNANCE.md).
- **LogikProjekt is independent.** Its owner runs it without oversight. No rulesets, templates or policy changes are applied to it, and it is excluded from anything the org can target by repo.
- **Contribution model.** Members get no base repository permission and cannot create repos. All changes arrive through pull requests. Owners create repos after a proposal is approved.
- **Default license** for new repos is MIT.
- **Code of conduct** is adapted from the Contributor Covenant 2.1, with Logik-specific tweaks to follow.
- **Proposals and discussion** happen in organization-level GitHub Discussions, hosted in the `.github` repo.
- **Maintainers** earn Maintain access through a track record plus owner approval, and access is reviewed yearly.
- **Tooling.** Owner operations use the GitHub CLI by default and the web interface where the CLI can't do the job.
- **Handbook location.** The handbook lives in its own public repo, `org-handbook`.
- **Launch** is targeted for late October 2026.
