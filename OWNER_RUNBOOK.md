# Owner Runbook

This covers the recurring jobs owners handle. Every command assumes you're in the `org-handbook` folder and signed in with `gh` (see MASTER_PLAN Phase 0).

**Current approval rule:** one owner's approval is enough for now. Once the org has two active owners, every item below marked 🔑 needs 2 of 3. See [GOVERNANCE](https://github.com/flamelogik/.github/blob/main/GOVERNANCE.md).

---

## 🔑 Reviewing a repo proposal

Proposals arrive in **Discussions → Repo Proposals**, labeled `proposal`.

1. **Acknowledge it within a week.** Thank them, and ask about anything missing from the form.
2. **Leave it open for comments for at least 7 days,** so the community can weigh in and spot duplicates.
3. **Check it against these criteria:**
   - [ ] Useful to Flame artists beyond the proposer's own facility
   - [ ] Doesn't duplicate an existing community repo. If it overlaps, suggest contributing to that repo instead.
   - [ ] A named maintainer who commits to responding to issues and PRs
   - [ ] MIT license, or another OSI-approved license with a stated reason
   - [ ] Clear provenance: no code of unknown origin, and nothing under a non-commercial license (common with Shadertoy ports)
   - [ ] No Autodesk-proprietary material, client media or secrets
   - [ ] For compiled tools (OpenFX plugins, apps): the source code is included, and the maintainer agrees to build releases with GitHub Actions
4. **Decide** and post the outcome in the thread.
   - **Accepted:** add the `accepted` label and run:
     ```bash
     ./scripts/new-repo.sh repo-name maintainer-github-username "One-line description" "flame,logik,flame-python,flame-timeline"
     ```
     The topics list is `flame,logik`, then at least one kind topic and one area topic from the tables in [REPO_STANDARDS](https://github.com/flamelogik/.github/blob/main/REPO_STANDARDS.md). Take them from the Type and Area answers in the proposal.
     Post the new repo's link in the thread, then mark the discussion answered or close it.
   - **Declined:** add the `declined` label and explain why, and what would change the answer if anything. Be kind: most declines are "not yet" rather than "never."
5. **Record significant decisions** (unusual licenses, exceptions to the standards) in DECISIONS.md.

## Donating an existing repo into the org

Many Flame tools already live in personal GitHub accounts. Transferring a repo keeps its stars, issues and history, and GitHub redirects the old URL.

Members can't create repos in the org, so they can't transfer into it directly either. Use a two-step handoff:

1. The proposal is approved as usual. The form has a field for the existing repo's URL.
2. The author transfers the repo to **your personal account**: **Settings → Danger Zone → Transfer**. Then you accept it.
3. You transfer it on to the org:
   ```bash
   gh api repos/YOUR-USERNAME/REPO/transfer -f new_owner=flamelogik
   ```
4. Bring it up to standard, as in MASTER_PLAN Phase 3:
   ```bash
   ./scripts/add-maintainer.sh REPO author-username
   ./scripts/protect-repo.sh REPO
   ```

## 🔑 Adding a maintainer

The criteria are in GOVERNANCE. In short: a track record in that repo, usually 3 or more merged PRs or solid issue triage, plus owner approval.

```bash
./scripts/add-maintainer.sh REPO their-github-username
```

If they aren't an org member yet, GitHub emails them an invitation. They get **Maintain** access to that repo only, through the `REPO-maintainers` team.

## Stepping a maintainer down

This happens if they ask, or after 12 months of inactivity following a friendly check-in.

```bash
gh api -X DELETE orgs/flamelogik/teams/REPO-maintainers/memberships/USERNAME
```

Thank them publicly. Credit them as an emeritus maintainer in the repo's README.

## 🔑 Archiving a repo

Archive a repo when it has no maintainer for 6 months *and* a call for maintainers has gone unanswered for 30 days, or when it no longer works with any supported Flame version.

1. Open a PR that changes the README status line to `**Status:** Archived (reason, date)`, and merge it.
2. Archive the repo:
   ```bash
   gh repo archive flamelogik/REPO --yes
   ```
Archived repos stay readable and forkable, and they can be unarchived later. **Never delete a community repo.**

## Handling a security report

Reports come in privately through the repo's **Security → Advisories** tab.

1. Acknowledge it within 7 days.
2. Work on the fix with the maintainer inside the private advisory. It includes a temporary private fork for this.
3. Release the fix, then publish the advisory so users are notified.

If a published **binary** turns out to be malicious or compromised, delete that release right away, post in Announcements and on the forum, and investigate afterward.

## Handling a code of conduct report

Reports arrive at `conduct@logik.tv`, a shared mailbox read by the active owners and the Logik community leads.

1. Acknowledge it privately within 3 days. Keep the reporter's identity confidential.
2. The mailbox readers (minus anyone involved) review it, using the enforcement ladder in CODE_OF_CONDUCT.md.
3. Tools, depending on severity:
   - Hide or lock the comment or discussion.
   - Block the person from the org: **Org Settings → Moderation → Blocked users**.
   - Use temporary interaction limits: **Org Settings → Moderation → Interaction limits**.
4. Keep a short private record of the outcome. **Don't** put it in this public repo.

## Quarterly audit

```bash
./scripts/00-audit.sh | tee ~/logik-audit-$(date +%F).txt
```

- [ ] Base permission is still `none`, and member repo creation is still `false`.
- [ ] No unexpected owners, outside collaborators or pending invitations.
- [ ] Every repo except LogikProjekt has a license and the `protect-default-branch` ruleset.
- [ ] Every repo has at least one active maintainer, or a "Seeking maintainer" status and a call for help.
- [ ] Check for open Dependabot or secret-scanning alerts: **Org → Security** tab.
- [ ] Check whether any maintainer or owner has been inactive long enough to need a check-in.
