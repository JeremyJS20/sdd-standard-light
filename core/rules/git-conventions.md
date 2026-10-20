# Git Conventions

> All branches and commits must follow these conventions.
> Every commit must reference an AB# work item.

## Branch naming

| Type | Format | Example |
|------|--------|---------|
| Feature | `feat/AB#id-description` | `feat/AB#5678-export-excel-reportes` |
| Bug fix | `fix/AB#id-description` | `fix/AB#1234-login-google-oauth` |
| Hotfix | `hotfix/description` | `hotfix/critical-auth-bypass` |
| Release (corte → qa) | `release/corte-DD-MM-YYYY` | `release/corte-02-10-2026` |
| Release (qa → prod) | `release/prod-DD-MM-YYYY` | `release/prod-02-10-2026` |

Version tags:
- Format: `vMAJOR.MINOR.PATCH` (e.g., `v1.2.0`)
- Created after merge to main/prod
- See `qa-corte-workflow.md` §Semver versioning strategy

Rules:
- Use kebab-case for description (lowercase, hyphens, no spaces)
- Keep description short but descriptive (max 40 chars)
- ALWAYS include AB#id for features and bugs
- DO NOT use underscores in branch names
- DO NOT use camelCase in branch names

## Conventional commits

| Type | When | Example |
|------|------|---------|
| `feat` | New feature or functionality | `feat(AB#5678): add export to Excel endpoint` |
| `fix` | Bug fix | `fix(AB#1234): resolve Google OAuth token passing` |
| `docs` | Documentation only | `docs(AB#5678): update API documentation` |
| `refactor` | Code refactor, no behavior change | `refactor(AB#5678): extract validation to shared module` |
| `test` | Adding or updating tests | `test(AB#5678): add E2E tests for export flow` |
| `chore` | Maintenance, deps, config | `chore: update dependencies` |
| `release` | QA corte release branch PR | `release: corte al 02-10-2026` |

Rules:
- ALWAYS include AB# in parentheses for features and bugs: `feat(AB#5678): ...`
- Keep subject line under 72 characters
- Use imperative mood: "add" not "added", "resolve" not "resolved"
- DO NOT end commit message with a period

## Surgical Release Cuts & Cherry-Pick Dependency Rules (Hard Gate 19)

When preparing a QA corte (`release/corte-DD-MM-YYYY`) or cherry-picking specific bug IDs from `develop` to `qa`:

1. **Never Cherry-Pick Blindly from a Static List/PDF**:
   - A bug in the corte (`AB#A`) may have introduced a regression in `develop` that was fixed hours later by a follow-up commit (`AB#B`) not listed in the QA PDF, or `AB#A` may depend on a shared helper introduced in an earlier commit.
   - Before cherry-picking, always scan `origin/qa..origin/develop` for **coupled commits** that modify the same functions/components, fix regressions on those files, or provide shared utilities imported by the scoped commits (see `qa-corte-workflow.md` §Audit before release).
2. **Present Coupled Commits to the Human Before Cherry-Picking**:
   - Group the audit into: `✅ In Scope`, `🔗 Coupled / Dependent Commits Detected (Recommended)`, `ℹ️ Already in QA`, and `🚫 Excluded`.
   - Wait for explicit human approval on which coupled commits to include so QA can be notified.
3. **Post-Cherry-Pick Static & Structural Integrity Verification**:
   - After cherry-picking and resolving any conflicts, `npm run build` alone is insufficient.
   - Verify on all touched files (`git diff --name-only origin/qa..HEAD`):
     - **React Rules of Hooks**: No `useEffect` / `useState` / `useMemo` / `useCallback` placed below an early `if (...) return null;`.
     - **SQL Query & Alias Integrity**: No duplicate table aliases (`JOIN ... AS x` twice) or duplicate columns after conflict resolution.
     - **Import & Symbol Resolution**: Every imported symbol exists in the target branch.

## What NEVER to do
- DO NOT commit without AB# (except chore and release commits)
- DO NOT commit directly to main or master — always via PR
- DO NOT commit directly to qa — always via release/corte branch + PR (unless human explicitly orders a direct emergency cherry-pick after dependency verification)
- DO NOT cherry-pick a corte list without scanning `origin/qa..origin/develop` for coupled follow-up fixes on the same files/functions (Hard Gate 19)
- DO NOT auto-merge PRs — human review is mandatory
- DO NOT force-push without explicit human approval
- DO NOT amend commits that have been pushed (unless explicitly asked)
- DO NOT merge develop directly to qa without auditing scope — use release/corte branch (see `qa-corte-workflow.md`)
- DO NOT merge qa directly to main without auditing scope — use release/prod branch (see `qa-corte-workflow.md`)
- DO NOT create or modify git tags without human approval
- DO NOT force-push tags (no `git push --force --tags`)
