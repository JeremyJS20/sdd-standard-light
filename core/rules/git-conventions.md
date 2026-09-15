# Git Conventions

> All branches and commits must follow these conventions.
> Every commit must reference an AB# work item.

## Branch naming

| Type | Format | Example |
|------|--------|---------|
| Feature | `feat/AB#id-description` | `feat/AB#5678-export-excel-reportes` |
| Bug fix | `fix/AB#id-description` | `fix/AB#1234-login-google-oauth` |
| Hotfix | `hotfix/description` | `hotfix/critical-auth-bypass` |

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

Rules:
- ALWAYS include AB# in parentheses for features and bugs: `feat(AB#5678): ...`
- Keep subject line under 72 characters
- Use imperative mood: "add" not "added", "resolve" not "resolved"
- DO NOT end commit message with a period

## What NEVER to do
- DO NOT commit without AB# (except chore commits for maintenance)
- DO NOT commit directly to main or master — always via PR
- DO NOT auto-merge PRs — human review is mandatory
- DO NOT force-push without explicit human approval
- DO NOT amend commits that have been pushed (unless explicitly asked)
