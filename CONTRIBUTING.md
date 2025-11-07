# Contributing and Tactical Plan

## 1. Task tracking (GitHub Projects)

- System: GitHub Issues + Projects (`Tasks` board).
- Issue classification: labels `epic`, `feature`, `task`, `bug`, `spike`.
- Board workflow: Backlog → Selected for Sprint → In Progress → In Review → Verify → Done.
- Each issue includes: concise title, short description, acceptance criteria, estimate, assignee, and labels.
- Every pull request links the issue using closing keywords (e.g., `Fixes #123`).

Recommended issue template (paste into Description):

```markdown
Context
- What problem are we solving and why now?

Expected outcome
- One or two sentences describing the result

Acceptance criteria
- [ ] Checkable criterion 1
- [ ] Checkable criterion 2

Notes / links
- Diagrams, references, risks
```

## 2. Verifying that a task is done

A task is considered Done when all of the following are true:
- All acceptance criteria in the GitHub issue are satisfied.
- Code is merged to `main` via a reviewed pull request (no direct pushes).
- CI is green (build/lint/tests as applicable).
- Documentation and/or diagrams are updated when behavior or architecture changes.
- For UI/report changes, a short screenshot or demo is attached to the issue.
- The issue links to the PR/commits and the card is moved to Done on `Tasks`.

Pull request checklist:
- [ ] Linked to GitHub issue (e.g., `Fixes #123`).
- [ ] Card is on Projects `Tasks` board in the correct column.
- [ ] Meets acceptance criteria.
- [ ] CI green; no linter/type errors.
- [ ] Tests or manual verification steps included.
- [ ] Docs/diagrams updated if relevant.

## 3. Tasks not completed in one iteration

- During the sprint review, unfinished work is either split into smaller follow‑up items or moved to the next sprint with an updated estimate.
- If the scope changed, close the current issue and create a new, well‑scoped one; otherwise keep the same issue.
- Add the label `carryover` and briefly document the reason.

## 4. Task assignment

- Default mode is self‑assignment during planning within reasonable WIP limits per person.
- The lead (or on‑call) resolves conflicts, prioritizes urgent items, and reassigns when needed.
- Pairing is recommended for complex items (both may watch the issue; one assignee).
- Exactly one assignee is set at any time.

## 5. Quality expectations

- Branching: `feature/<slug>`, `fix/<slug>`, `docs/<slug>`; `main` is protected.
- Commit messages follow Conventional Commits (`feature:`, `fix:`, `docs:` …).
- Review: at least one approval; target response time is within one business day.
- CI before merge: lint/format and build/tests (when present).
- Architecture decisions: record impactful choices as ADRs in `docs/`.
- Diagrams: keep PlantUML/DSL models in version control; attach exports or diffs when it helps reviewers.
- Security and hygiene: no secrets in the repository; verify licenses for new dependencies.

---

## Workflow summary
1. Create or pick a GitHub issue with acceptance criteria and an estimate, and add it to Projects `Tasks`.
2. Assign the issue to yourself, move the card to In Progress, and create a feature branch.
3. Implement the change and keep the issue updated with relevant notes or screenshots.
4. Open a PR referencing the issue, request review, and ensure CI is green.
5. Merge, update documentation if needed, and move the card to Done.
