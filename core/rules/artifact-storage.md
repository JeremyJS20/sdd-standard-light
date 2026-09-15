# Artifact Storage

> Know where each artifact lives and whether it is committed or gitignored.

## Git repo (committed, team-shared)

| Artifact | Location | Who creates |
|----------|----------|-------------|
| .opencode/rules/ (11 files) | repo | sdd-init.sh |
| .opencode/agents/ (2 files) | repo | sdd-init.sh |
| specs/_templates/ (3 files) | repo | sdd-init.sh |
| specs/{AB#id}/requirements.md | repo | Agent (from ADO) |
| specs/{AB#id}/design.md | repo | Developer |
| specs/{AB#id}/tasks.md | repo | Developer |
| .sdd-config.json | repo | sdd-init.sh |
| .env.example | repo | sdd-init.sh |
| .gitignore | repo | sdd-init.sh |

## Gitignored (local, NOT committed)

| Artifact | Why |
|----------|-----|
| opencode.json | Contains PATs/credentials |
| .sdd-memory/memory.jsonl | Local session memory |
| .env | Secrets (PATs) |
| .sdd-credentials.json | Credentials |
| sdd-init.sh | Installer script (not project code) |

## Azure DevOps (NOT in repo)

| Artifact | Who creates |
|----------|-------------|
| Work Items (Epics, Features, Bugs) | Analyst |
| Pull Requests | Agent (with approval) |
| Pipelines | Developer |
| Wiki | Agent (with approval) |

## Bidirectional traceability
- The requirement lives in ADO as WI → agent brings it to repo as requirements.md
- The PR is created in ADO → linked to WI (AB#id)
- WI state is updated from repo (New → Active → Resolved → Closed)
- Every commit references AB# → traceable from code to WI
- Every WI has a branch → traceable from WI to code

## What NEVER to do
- DO NOT commit opencode.json (contains credentials)
- DO NOT commit .env (contains secrets)
- DO NOT commit .sdd-memory/ (local memory)
- DO NOT store specs outside the repo (they are team-shared)
- DO NOT store work items in the repo (they live in ADO)
