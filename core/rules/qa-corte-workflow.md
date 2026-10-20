# QA Corte Workflow — testing cut cycles (automatic detection)

> QA operates in weekly testing cycles called "cortes" (cuts).
> Each corte groups exploratory testing PBIs, related bugs, and HU/E2E scenarios.
> The agent detects active cortes automatically and adjusts priorities.

## What is a Corte

A **corte** is a time-boxed QA testing cycle (typically weekly) with a cut date.
QA creates the corte structure in ADO; the developer works the bugs within it.

## Corte structure in ADO

```
PBI: [Exploratory Testing] - [Module] (corte al DD-MM-YYYY)     ← estado: Acceptance
  ├── Bug: [description] corte al DD-MM-YYYY                     ← Dev fixes these
  ├── Bug: [description] corte al DD-MM-YYYY                     ← Dev fixes these
  └── Bug: ...

HU: [User Story title]                                           ← NO cut date in title
  └── criterio: estado = Test Passed / QA Passed

E2E Scenario: [description]                                      ← NO cut date in title
  └── criterio: estado = QA Passed
```

## Detection rules (automatic)

The agent detects a corte by these patterns:

### PBI de Corte (testing cut container)
- **Type**: PBI (Product Backlog Item)
- **Title pattern**: contains `corte al DD-MM-YYYY` (e.g., `corte al 02-10-2026`)
- **State**: `Acceptance` when active
- **Purpose**: groups exploratory testing for a module within a cut date

### Bug de Corte (bug found during cut)
- **Type**: Bug
- **Title pattern**: contains `corte al DD-MM-YYYY` at the end
- **Parent/related**: linked to a PBI de Corte
- **Developer action**: fix → test → PR → Fixed (standard bug flow)

### HU / E2E Scenario (acceptance criteria)
- **Type**: User Story or Test Case
- **Title pattern**: NO cut date — these are ongoing
- **Criterion**: state reaches `Test Passed` or `QA Passed`
- **Note**: HU/E2E do NOT have a cut date because the condition is that ALL test cases pass successfully

## Developer flow during a corte

### At session start (automatic)
1. Agent queries ADO for PBIs with `corte al` in title and state = `Acceptance`
2. If active corte found → show summary:
   ```
   📦 Corte activo: al DD-MM-YYYY
   
   PBIs de corte:
   - AB#XXXX: [Module] (corte al DD-MM-YYYY) — Acceptance
   
   Bugs pendientes del corte:
   - AB#YYYY: [bug description] — To Do / In Progress / Fixed
   - AB#ZZZZ: [bug description] — To Do
   
   HU/E2E en validación:
   - AB#WWWW: [HU title] — Test / Test Passed
   ```
3. PROPOSE to work on pending bugs from the corte (prioritize over features)

### Bug fix within corte
Same as standard bug flow (see `azure-devops-workflow.md`), with these additions:
- Branch naming: `fix/AB#id-description` (standard)
- Commits: `fix(AB#id): description` (standard)
- After fixing all bugs in a corte → notify human: "All bugs from corte al DD-MM-YYYY are Fixed. Waiting for QA."

### Priority rules
- **Bugs from active corte** take priority over features and non-corte bugs
- If user has both corte bugs and feature work: present corte bugs first
- If all corte bugs are Fixed or Done: resume normal feature/bug flow
- Agent does NOT block feature work — it suggests priority, human decides

## States specific to corte flow

| State | Who sets it | Applies to | When |
|-------|-------------|------------|------|
| Acceptance | QA | PBI de Corte | QA creates the corte PBI |
| Test Passed | QA | HU / E2E Scenario | All test cases pass |
| QA Passed | QA | HU / E2E Scenario | QA validates the functionality |

### Agent-forbidden transitions (corte-specific)
The agent NEVER sets these states:
- → `Acceptance` (QA only — corte PBI lifecycle)
- → `Test Passed` (QA only — HU validation result)
- → `QA Passed` (QA only — QA sign-off)

These are in addition to the standard forbidden transitions in `azure-devops-workflow.md`.

## Corte lifecycle

```
QA creates PBI (corte al DD-MM-YYYY) → Acceptance
  │
  ├── QA logs bugs during testing → To Do
  │     └── Dev picks up → In Progress → Fixed → QA: In Testing → Done
  │
  ├── QA validates HU → Test / Test Passed
  │
  └── Cut date arrives:
        ├── All bugs Done + HU Test Passed → Corte complete
        ├── Bugs remaining → carry over to next corte
        └── QA pre-creates next corte (al DD-MM-YYYY+7)
```

## Release strategy for corte (CRITICAL — never skip)

> **NEVER merge develop directly to qa.** Always audit scope and create a surgical release branch.

### Why not merge develop → qa directly?
- `develop` may contain work **outside the corte scope**: features in progress, bugs deferred to next corte, experimental code
- Merging blindly can **leak unscoped work** into the QA environment
- Bugs moved to the next corte by QA must NOT appear in the current corte's release

### Audit before release (mandatory — Hard Gate 19)

Before creating the release branch or cherry-picking any corte list/PDF, the agent MUST perform a **3-Layer Release Cut Dependency & Coupled Commit Audit**:

1. **List all AB# in the corte** — get the PBIs with `corte al DD-MM-YYYY`, their child bugs, HU/E2E, or the explicit list of AB# IDs from the QA Corte document/PDF.
2. **Audit develop commit-by-commit** — for each PR/commit in `origin/qa..origin/develop`:
   - Is this AB# already in `origin/qa`? → **mark as already in QA**
   - Is this AB# explicitly part of the corte? → **include**
   - Is this AB# deferred to a future corte or an unrelated feature? → **candidate for exclusion** (subject to Layer 3 Coupled Dependency Scan below)
   - Is there a fix branch NOT yet merged to develop? → **flag it** (it would be left out)
3. **Coupled Commit & Regression Hotfix Scan (CRITICAL — prevents partial cherry-pick breakage)**:
   In real-world development, an in-scope bug (`AB#A`) often modifies the same component, function, or SQL query as a subsequent commit (`AB#B`) in `develop`—such as a follow-up hotfix fixing a regression introduced by `AB#A` (e.g., conditional React Hook violation, null pointer, or broken SQL alias), or a shared utility created in an earlier commit. Cherry-picking `AB#A` strictly from a PDF without `AB#B` breaks `qa` even when `develop` works fine.
   For every in-scope commit in `origin/qa..origin/develop`, the agent MUST scan all non-scoped commits in `origin/qa..origin/develop` across 2 discovery channels:
   - **Channel A — Code & Hunk Overlap (`git log` + `codebase-memory`)**:
     - Identify all files and functions modified by the in-scope corte commits.
     - Find any non-scoped commits in `origin/qa..origin/develop` that:
       1. Are subsequent `fix(...)` commits touching the **same functions, components, or line ranges** (hunk overlap) as an in-scope commit.
       2. Create or modify **shared utilities, validation helpers, types, or DTOs** (`src/lib/validation/*`, `src/lib/utils/*`, etc.) imported by an in-scope commit (`trace_path`).
   - **Channel B — Azure DevOps Work Item Relations (`wit_get_work_item`)**:
     - Check if any in-scope AB# has ADO links (`Related`, `Successor`, `Predecessor`, `Child`, `Duplicate`) pointing to another Bug not listed in the corte PDF, or if a Bug was logged within 48 hours in the same module to fix a side effect of an in-scope AB#.
4. **Present audit results** to human (grouped into 5 clear blocks):
   ```
   📋 Auditoría de release para corte al DD-MM-YYYY:
   
   ✅ Incluidos (en scope del corte / PDF):
   - AB#XXXX: [description] — commit <hash> / PR #N
   - AB#YYYY: [description] — commit <hash> / PR #N
   
   🔗 Bugs / Commits Acoplados Detectados (Recomendados por dependencia técnica):
   - AB#ZZZZ (<hash>): [description]
     ↳ Razón de acoplamiento: Modifica la misma función/componente ([File.tsx :: FunctionName]) que AB#XXXX y corrige una regresión directa / provee utilidad compartida requerida por AB#XXXX.
   
   ℹ️ Ya existentes en QA:
   - AB#AAAA: [description] — ya presente en origin/qa
   
   🚫 Excluidos (fuera de scope y sin acoplamiento técnico):
   - AB#BBBB: [description] — razón: deferred to corte al DD-MM-YYYY+7 (sin solapamiento con archivos del corte)
   - feat/integrations — razón: feature not in corte scope
   
   ⚠️ Riesgo (fix del corte no mergeado a develop):
   - AB#WWWW: [description] — rama fix/AB#WWWW-... existe pero no está en develop
   ```
5. **Wait for human approval** before proceeding — the human explicitly decides whether to include the `🔗 Coupled / Dependent Commits` (and can notify QA which extra bug IDs are included due to technical dependency).

### Creating the surgical release branch

After audit approval:

1. **Create branch from qa**: `git checkout -b release/corte-DD-MM-YYYY origin/qa`
2. **Bring ONLY scoped + human-approved coupled commits** — two strategies depending on context:
   - **Cherry-pick** individual commits in chronological order (`git cherry-pick <hash>`) if develop has mixed scoped/unscoped work
   - **Merge specific fix branches** directly into the release branch if cleaner
3. **Merge any fix branches not yet in develop** that ARE in corte scope
4. **Verify every in-scope fix is in the branch**: for each AB# in scope → `git branch --contains <fix-commit>` (or cherry-pick equivalence check) must confirm presence in `release/corte-DD-MM-YYYY`. Any missing → STOP and report
5. **Post-Cherry-Pick Static & Structural Integrity Gate (MANDATORY before PR or push)**:
   TypeScript compilation (`tsc` / `npm run build`) alone does NOT catch runtime hook violations or malformed SQL strings introduced by partial cherry-picks or conflict resolutions. On all files modified in the release branch (`git diff --name-only origin/qa..HEAD`), the agent MUST verify:
   - **React Rules of Hooks Integrity**: Confirm no React component places `useEffect`, `useState`, `useMemo`, `useCallback`, `useRef`, or custom `use*` hooks *below* an early conditional return (`if (...) return null;`).
   - **SQL Query & Alias Integrity**: Confirm no raw SQL query or query builder statement has duplicate table aliases (`JOIN ... AS x` repeated), duplicate column projections, or mismatched parameter placeholders after resolving cherry-pick conflicts.
   - **Symbol & Import Resolution**: Confirm every helper, constant, or type imported by the cherry-picked code exists in the release branch.
   - **Build, Lint & Tests**: Run `npm run build` (or project build command), linter, and relevant test suites.
6. **Collect deploy requirements** from each fix's evidence report (migrations, env vars, feature flags, seed data) → list them in the PR body so they are applied in the QA environment
7. **PROPOSE**: "Release branch verified (build + hooks/SQL/symbol integrity OK). I will create PR: `release/corte-DD-MM-YYYY` → `qa`" → wait for approval
8. **Create PR**:
   - Title: `release: corte al DD-MM-YYYY (scope summary)`
   - Body: list of AB# included, coupled AB# included by technical dependency, AB# excluded, rationale, and deploy requirements for QA
   - Base: `qa`
   - Compare: `release/corte-DD-MM-YYYY`
9. **Human merges PR** (agent never auto-merges — Gate 4)
10. CI/CD deploys automatically to QA environment
11. **QA deployment verification** for each fix — see `bug-fix-protocol.md` §7.2 (pipeline OK, env parity, smoke test)

### After merge to qa
- Sync qa branch to all remotes (if dual remote: GitHub + Azure DevOps)
- Update corte bugs in ADO: those merged are now in QA environment for testing
- Notify human: "Release corte al DD-MM-YYYY deployed to QA. QA can begin validation."
- **Post audit comment** on each PBI de Corte in ADO (see §Audit trail below)

### Out-of-scope items & Coupled Technical Dependencies (human-approved additions)
Sometimes work outside the initial corte PDF/list needs to go to QA—either because it is a **coupled technical dependency / regression hotfix** detected in Layer 3 of the audit, or an unplanned business addition:
- The agent flags it during audit under `🔗 Coupled / Dependent Commits` (if technically coupled to an in-scope bug) or `🚫 Excluded` (if unrelated)
- **If human explicitly approves inclusion** → include it in the release branch
- Mark it in the audit trail as "included by technical dependency on AB#XXXX (human-approved)" or "included by human approval (out of corte scope)"
- NEVER include out-of-scope items without explicit human confirmation

### Audit trail (mandatory after release)

After the release PR is created (or merged), the agent posts a formal audit comment on each PBI de Corte in ADO via MCP. This creates a traceable record for QA and compliance.

**Audit comment template** (posted to ADO PBI discussion):
```
📋 Auditoría de Entrega — Corte al DD-MM-YYYY

Fecha de Entrega: DD de [Month] de YYYY
Rama de Release: release/corte-DD-MM-YYYY
Pull Request a QA: [Repo#N](PR_URL)

Bugs incluidos y resueltos (en alcance del corte):
- AB#XXXX: [description]
- AB#YYYY: [description]

Bugs / Commits incluidos por dependencia técnica (aprobados para evitar regresión):
- AB#ZZZZ: [description] (acoplado a AB#XXXX en [File/Component])

Componentes adicionales (aprobados por humano):
- [description] (out of corte scope, included by human approval)

Exclusiones autorizadas (postergadas al corte DD-MM-YYYY):
- AB#WWWW: [description]

Verificación de Integridad Estática:
- Build / Type-check: OK
- React Rules of Hooks / SQL Aliases / Imports: OK

Ambiente destino: QA ([environment_name])
```

**PR body** must also contain:
- List of AB# included with descriptions
- List of AB# excluded with reasons
- Any out-of-scope items and who approved them

This audit trail serves as:
- **QA reference**: QA knows exactly what to test and what NOT to test
- **Compliance record**: traceable decisions with human approval
- **Post-mortem data**: if something leaks or is missing, the audit shows why

### What the agent NEVER does during release
- NEVER merges develop → qa directly without audit
- NEVER includes work outside the corte scope
- NEVER excludes work inside the corte scope without flagging it
- NEVER merges the PR (human only — Gate 4)
- NEVER skips the audit even if "everything looks fine"
- NEVER assumes a fix branch is in develop — verify explicitly

## ADO query pattern (for agent)

To find active cortes, the agent queries ADO:
- **PBIs de Corte**: `[Work Item Type] = 'Product Backlog Item' AND [Title] CONTAINS 'corte al' AND [State] = 'Acceptance'`
- **Bugs del Corte**: `[Work Item Type] = 'Bug' AND [Title] CONTAINS 'corte al DD-MM-YYYY' AND [State] IN ('To Do', 'In Progress', 'Fixed', 'In Testing')`
- **HU/E2E del Corte**: linked to the same parent/area as the corte PBIs, state NOT in `Test Passed` or `QA Passed`

## What the agent NEVER does in corte context
- NEVER creates PBIs de Corte (QA only)
- NEVER moves PBIs to Acceptance (QA only)
- NEVER moves HU/E2E to Test Passed or QA Passed (QA only)
- NEVER decides the cut date (QA only)
- NEVER creates bugs in ADO (developer receives, does not report — Gate 10)
- NEVER skips corte bugs to work on features without asking human first

## What the agent ALWAYS does in corte context
- Detects active corte at session start (automatic)
- Shows corte summary with bug status breakdown
- Prioritizes corte bugs in work suggestions
- Notifies when all corte bugs are Fixed
- Follows standard bug flow for each bug (no design, no tasks)

---

## Production release flow

> After QA certifies a corte, the code is promoted from qa to prod.
> Same surgical approach as the corte release: audit, filter, PR, human merges.

### Environments

```
develop  →  qa  →  prod (main)
   │          │         │
   │          │         └── Production — end users
   │          └── QA — testing/certification
   └── Development — active work
```

### When to promote to prod
A corte is ready for prod when:
- All corte bugs are `Done` in ADO (QA validated)
- All HU/E2E are `Test Passed` or `QA Passed`
- QA Lead confirms: "corte certificado" (formal comment in ADO or chat)

### Audit before prod release (mandatory)

Same principle as the corte audit — qa may have **multiple cortes** or work in different states.

1. **List certified cortes** — which cortes has QA fully certified?
2. **Audit qa branch** — for each PR/commit in qa since last prod release:
   - Is this from a certified corte? → **include**
   - Is this from a corte still in testing? → **exclude**
   - Is this a hotfix already in prod? → **skip** (already there)
3. **Present audit results** to human:
   ```
   📋 Auditoría de Release a Producción

   ✅ Cortes certificados para producción:
   - Corte al DD-MM-YYYY: [N bugs Done, M HU QA Passed]

   ✅ Incluidos:
   - AB#XXXX: [description] — Done
   - AB#YYYY: [description] — Done

   🚫 Excluidos (corte aún en testing):
   - AB#ZZZZ: [description] — In Testing (corte al DD-MM-YYYY+7)

   📦 Versión propuesta: vX.Y.0
   ```
4. **Wait for human approval** before proceeding

### Creating the prod release branch

1. **Create branch from main**: `git checkout -b release/prod-DD-MM-YYYY origin/main`
2. **Bring ONLY certified work** from qa:
   - Cherry-pick or merge only the certified corte commits
   - Exclude anything from cortes still in testing
3. **Update VERSION file** (if versioning.version_file is enabled in .sdd-config.json)
4. **Verify**: run tests, lint, ensure no regressions
5. **PROPOSE**: "Release branch ready. I will create PR: `release/prod-DD-MM-YYYY` → `main`" → wait for approval
6. **Create PR**:
   - Title: `release: prod DD-MM-YYYY (vX.Y.Z)`
   - Body: audit trail (cortes included, AB# list, exclusions, version)
   - Base: `main`
   - Compare: `release/prod-DD-MM-YYYY`

### Sign-off for prod (2 approvals mandatory)

| # | Who | How | What they confirm |
|---|-----|-----|-------------------|
| 1 | **QA** | Comment on ADO PBIs or chat | "Corte certificado — all tests passed" |
| 2 | **Human** (Dev Lead / PO) | Merges the PR to main | Code is stable, ready for production |

The agent NEVER merges to prod (Gate 3 + Gate 4).

### After merge to prod

1. **Tag the release** with semver: `git tag vX.Y.Z` → `git push --tags`
2. **Update VERSION file** if enabled
3. **Move WIs to Done** in ADO — NOW the agent can trigger this (only after prod deploy, with approval)
4. **Post audit comment** on each PBI de Corte in ADO:
   ```
   🚀 Desplegado a Producción — DD-MM-YYYY

   Versión: vX.Y.Z
   Rama de Release: release/prod-DD-MM-YYYY
   Pull Request: [Repo#N](PR_URL)
   Tag: vX.Y.Z

   Work Items cerrados:
   - AB#XXXX: [description] → Done
   - AB#YYYY: [description] → Done
   ```
5. **Sync branches**: ensure main changes flow back to develop (merge main → develop or rebase)
6. **Notify human**: "Release vX.Y.Z deployed to production. [N] WIs moved to Done."

### Hotfix flow (emergency fix in prod)

For critical bugs found in production that cannot wait for the next corte:

1. **Create branch from main**: `hotfix/description`
2. Fix → test → PR to `main` (with approval)
3. **Bump patch version**: `vX.Y.Z` → `vX.Y.Z+1`
4. Tag and deploy
5. **Backport**: merge main → develop AND main → qa to keep branches in sync
6. Create bug in ADO with "hotfix" tag

---

## Semver versioning strategy

> Version lives in **git tags** (source of truth) and optionally in a **VERSION file**.

### Version format
```
vMAJOR.MINOR.PATCH
```

### Bump rules

| Event | Bump | Example | Who triggers |
|-------|------|---------|-------------|
| Corte promoted to prod | **minor** | `v1.0.0` → `v1.1.0` | Human (merges PR to main) |
| Hotfix to prod | **patch** | `v1.1.0` → `v1.1.1` | Human (merges hotfix PR) |
| Breaking change (API contract change) | **major** | `v1.1.0` → `v2.0.0` | Human (explicit decision) |

### How the agent determines the next version

1. Read latest git tag: `git describe --tags --abbrev=0`
2. Parse current version: `vMAJOR.MINOR.PATCH`
3. Based on release type:
   - Corte → bump minor, reset patch: `v1.1.3` → `v1.2.0`
   - Hotfix → bump patch: `v1.2.0` → `v1.2.1`
   - Breaking → bump major, reset minor and patch: `v1.2.1` → `v2.0.0`
4. PROPOSE: "Next version: vX.Y.Z" → wait for human to confirm or override

### VERSION file (optional)

If `versioning.version_file` is `true` in `.sdd-config.json`:
- File: `VERSION` at repo root (plain text, just the version number without `v` prefix)
- Updated by the agent as part of the release branch (before PR)
- Example content: `1.2.0`

### First release

If no tags exist yet:
- Agent proposes `v1.0.0` as the initial version
- Human can override (e.g., `v0.1.0` for pre-release)

### What the agent NEVER does with versioning
- NEVER tags without human approval
- NEVER decides major bump autonomously (always asks)
- NEVER skips tagging after prod release
- NEVER modifies existing tags (no force-push tags)

### Configuration in .sdd-config.json

```json
"versioning": {
  "strategy": "semver",
  "source": "git-tag",
  "version_file": true,
  "initial_version": "1.0.0"
}
```
