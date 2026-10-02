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

### Audit before release (mandatory)

Before creating the release branch, the agent MUST:

1. **List all AB# in the corte** — get the PBIs with `corte al DD-MM-YYYY`, their child bugs, and HU/E2E
2. **Audit develop commit-by-commit** — for each PR/commit in develop since the last qa merge:
   - Is this AB# part of the corte? → **include**
   - Is this AB# deferred to a future corte? → **exclude**
   - Is this a feature not related to the corte? → **exclude**
   - Is there a fix branch NOT yet merged to develop? → **flag it** (it would be left out)
3. **Present audit results** to human:
   ```
   📋 Auditoría de release para corte al DD-MM-YYYY:
   
   ✅ Incluidos (en scope del corte):
   - AB#XXXX: [description] — PR #N
   - AB#YYYY: [description] — PR #N
   
   🚫 Excluidos (fuera de scope):
   - AB#ZZZZ: [description] — razón: deferred to corte al DD-MM-YYYY+7
   - feat/integrations — razón: feature not in corte scope
   
   ⚠️ Riesgo (fix no mergeado a develop):
   - AB#WWWW: [description] — rama fix/AB#WWWW-... existe pero no está en develop
   ```
4. **Wait for human approval** before proceeding

### Creating the surgical release branch

After audit approval:

1. **Create branch from qa**: `git checkout -b release/corte-DD-MM-YYYY origin/qa`
2. **Bring ONLY scoped commits** — two strategies depending on context:
   - **Cherry-pick** individual merge commits if develop has mixed scoped/unscoped work
   - **Merge specific fix branches** directly into the release branch if cleaner
3. **Merge any fix branches not yet in develop** that ARE in corte scope
4. **Verify**: run tests, lint, ensure no regressions
5. **PROPOSE**: "Release branch ready. I will create PR: `release/corte-DD-MM-YYYY` → `qa`" → wait for approval
6. **Create PR**:
   - Title: `release: corte al DD-MM-YYYY (scope summary)`
   - Body: list of AB# included, AB# excluded, and rationale
   - Base: `qa`
   - Compare: `release/corte-DD-MM-YYYY`
7. **Human merges PR** (agent never auto-merges — Gate 4)
8. CI/CD deploys automatically to QA environment

### After merge to qa
- Sync qa branch to all remotes (if dual remote: GitHub + Azure DevOps)
- Update corte bugs in ADO: those merged are now in QA environment for testing
- Notify human: "Release corte al DD-MM-YYYY deployed to QA. QA can begin validation."
- **Post audit comment** on each PBI de Corte in ADO (see §Audit trail below)

### Out-of-scope items (human-approved additions)
Sometimes work outside the corte scope needs to go to QA (e.g., an unplanned feature, a fix from another sprint).
- The agent flags it during audit as "not in corte scope"
- **If human explicitly approves inclusion** → include it in the release branch
- Mark it in the audit as "included by human approval (out of corte scope)"
- NEVER include out-of-scope items without explicit human confirmation

### Audit trail (mandatory after release)

After the release PR is created (or merged), the agent posts a formal audit comment on each PBI de Corte in ADO via MCP. This creates a traceable record for QA and compliance.

**Audit comment template** (posted to ADO PBI discussion):
```
📋 Auditoría de Entrega — Corte al DD-MM-YYYY

Fecha de Entrega: DD de [Month] de YYYY
Rama de Release: release/corte-DD-MM-YYYY
Pull Request a QA: [Repo#N](PR_URL)

Bugs incluidos y resueltos:
- AB#XXXX: [description]
- AB#YYYY: [description]
- AB#ZZZZ: [description]

Componentes adicionales (aprobados por humano):
- [description] (out of corte scope, included by human approval)

Exclusiones autorizadas (postergadas al corte DD-MM-YYYY):
- AB#WWWW: [description]

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
