# Spec Generation Protocol — Forward, Reverse & Hybrid Specs

> The agent NEVER writes code for a feature without an approved `requirements.md`, `design.md`, and `tasks.md`.
> Jumping directly from a chat discussion to implementation violates Hard Gates 1, 2, and 5.
> This protocol defines how to document features: new, existing (legacy), or hybrid (extending existing code).

---

## The Three Spec Modes

| Mode | Situation | Workflow |
|------|-----------|----------|
| **1. Forward Spec** | New feature (greenfield or new capability) | Discussion / WI ➔ `requirements.md` ➔ `design.md` ➔ `tasks.md` ➔ implementation |
| **2. Reverse Spec (As-Built)** | Existing code without specs (legacy/undocumented) | Codebase inspection via `codebase-memory` ➔ `requirements.md` (As-Built) ➔ `design.md` (As-Built) ➔ `tasks.md` (gaps/tests) |
| **3. Hybrid Spec (Extension)** | Existing module getting a new sub-feature (e.g. Payroll ➔ Distribution) | Inspect existing base code ➔ Document context ➔ Forward spec for the new sub-feature |

---

## Mode 1: Forward Spec (New Feature)

When creating a new feature from scratch or from an ADO User Story:

### Step 1: Requirements Generation (`requirements.md`)
1. **Gather Input via One of 3 Channels**:
   - **Channel A (Document / File)**: Parse PRD, brief, functional spec, or client file (Markdown, PDF, TXT, etc.).
   - **Channel B (Business Elicitation Interview)**: Conduct an interactive discovery interview (problem, actors, entities, business rules, integrations, NFRs) if requirements are underspecified or starting from scratch.
   - **Channel C (Azure DevOps / Functional Package)**: Read Functional Package (PRIMARY) or ADO User Story / Feature + linked WIs (FALLBACK).
2. Load `specs/_templates/requirements-template.md`.
3. Draft `specs/{AB#id-feature}/requirements.md`:
   - Traceability (WI ID, parent feature, branch name).
   - Overview & Business context.
   - User Stories in **EARS** notation (`WHEN/WHILE/IF/WHERE [condition], the system SHALL [behavior]`).
   - Acceptance Criteria (Given / When / Then).
   - Measurable NFRs (security, performance, compliance).
   - Use Case & supporting diagrams in Mermaid.
   - Out of Scope explicitly listed.
4. **STOP & PROPOSE**: Present `requirements.md` to the human. **DO NOT generate design yet.** Wait for explicit approval.

### Step 2: Technical Design (`design.md`)
1. Once `requirements.md` is approved, load `specs/_templates/design-template.md`.
2. Draft `specs/{AB#id-feature}/design.md`:
   - Traceability linking back to `requirements.md`.
   - Technology decisions & justifications.
   - System overview & Component diagrams in Mermaid.
   - Data design: DB tables, DTOs, schemas, validation rules.
   - API contracts (endpoints, methods, payloads, status codes).
   - State machine diagrams (if stateful transitions exist).
   - Error handling & edge cases.
3. **STOP & PROPOSE**: Present `design.md` to the human. **DO NOT generate tasks yet.** Wait for explicit approval.

### Step 3: Task Breakdown (`tasks.md`)
1. Once `design.md` is approved, load `specs/_templates/tasks-template.md`.
2. Draft `specs/{AB#id-feature}/tasks.md`:
   - Group tasks into logical Waves (Wave 1: Data/Models, Wave 2: Backend/Services, Wave 3: UI, Wave 4: Integration/E2E).
   - Apply estimation rules: maximum **4 hours** per task.
   - Build the dependency graph in Mermaid.
   - Define exact verification criteria for each task.
3. **STOP & PROPOSE**: Present `tasks.md` to the human.
4. **Handoff**: Only after `tasks.md` is approved can implementation begin in `sdd-build` (Task by task).

---

## Mode 2: Reverse Spec (Documenting Existing Code)

When a module was built without SDD specs and needs documentation for compliance, audit, QA, or future maintenance:

### Step 1: Code Mining with codebase-memory & Git Archeology (MANDATORY)

Code tells you **WHAT** is there; Git history tells you **WHY** it was built that way.

1. **MCP Graph Discovery**:
   - `search_graph(name_pattern=...)`: locate models, controllers, services, routes, UI components.
   - `get_code_snippet`: read signatures, validations, schemas, SQL queries, DTOs.
   - `trace_path`: trace the execution path from entrypoint (route/button) to DB.
   - Identify existing DB tables, columns, relations, and enums.

2. **Git Archeology & Business Intent Mining**:
   - `git log --oneline -25 -- <feature_files>`: extract the feature's evolution and all related commit messages (e.g. `feat(payroll): connect cycles...`, `refactor: clean redirects`).
   - `git log --all --grep="AB#" --oneline`: find linked User Stories and historical Bugs that touched this module.
   - `git blame -L <start>,<end> <file>` on key business logic: uncover why magic numbers, legal formulas, or regulatory rates were set (e.g., discovering `salario / 23.83 / 8` comes from MT Labor Code, or TSS `2.87% / 3.04%` from Law 87-01).
   - `git log -S "<keyword>"`: trace when and why specific business rules or validations were added or modified.
   - **CRITICAL ANTI-DISPARATE RULE (Bug != Feature)**:
     - Commits with `fix(AB#...)` or branches `fix/AB#...` are **BUGS**, NOT the Feature itself!
     - The agent SHALL NEVER put Bug IDs in the `Work Item:` header of a spec.
     - Bug IDs from git history belong STRICTLY in an optional context section: `### Bugs Históricos Resueltos en este Módulo (Contexto)`.
     - The `Work Item:` header MUST only contain an Epic, Feature, or User Story/PBI ID. If none exists in ADO, set `Work Item: Pendiente (Sin PBI / Feature asignado aún en ADO)`.

3. Combine both sources to reconstruct the original functional intent, edge case fixes, and unwritten domain rules.

### Step 2: Generate `requirements.md` (As-Built)
1. Use `requirements-template.md`.
2. Set header: `> 📋 As-Built Specification — Reverse-engineered from codebase and git history [commit hash]`.
3. Express existing business logic in formal EARS notation:
   - What the system *already does* today.
   - Domain rules justified by git commit history and PR references.
   - Known limitations or unhandled edge cases observed in code.
4. Document existing acceptance criteria verified in the code and past bug fixes.
5. PROPOSE to human for validation: "This is what the code and git history show the feature currently does. Does this match expectations?"

### Step 3: Generate `design.md` (As-Built)
1. Use `design-template.md`.
2. Document real architecture, component hierarchy, and database schemas as they exist.
3. Mermaid diagrams of the real component tree and database entity-relationships.
4. Document all existing endpoints, methods, payload structures, and external integrations discovered via graph and git.

### Step 4: Generate `tasks.md` (Gaps & Hardening)
1. The tasks for an existing module are NOT "build from scratch". They are:
   - Missing unit tests for critical business logic.
   - Playwright E2E tests for happy and edge paths.
   - Technical debt or refactoring tasks identified during mining.
   - Missing input validations or error boundaries.

---

## Mode 3: Hybrid Spec (Extending Existing Modules)

When adding a new sub-feature to an already functioning module (e.g., adding *Dispersión Bancaria* to an existing *Payroll* module):

1. **Phase 1: Map the Foundation (Existing)**:
   - Identify which existing tables, endpoints, and states the new sub-feature depends on (e.g., `payroll_cycles`, `employee_payrolls`, `disbursement_status`).
   - Note them in the `Dependencies` and `Assumptions` section of the new spec.
2. **Phase 2: Forward Spec for the New Sub-Feature**:
   - Follow **Mode 1** strictly for the new sub-feature:
     - `requirements.md` focusing on the new capability (bank file layouts, disbursement states, validations).
     - `design.md` defining new endpoints, file generator architecture, and UI.
     - `tasks.md` broken into waves.
3. **NEVER jump to code** before completing Phase 2.

---

## Spec Granularity & Macro-Feature Decomposition Protocol (Anti-Monolith Rule)

### When to Decompose a Macro-Feature
A specification represents a coherent, reviewable, and testable unit of functionality.
When documenting or planning a **Macro-Feature / Full Domain Module** (e.g. *Nómina Completa*, *Facturación Electrónica*, *Gestión de Inventario*), **DO NOT create a single monolithic `requirements.md`** mixing multiple unrelated business sub-domains.

Criteria requiring decomposition:
- The module covers more than 2 distinct business workflows or regulatory domains (e.g. TSS vs DGII vs ACH Bancario).
- The module spans multiple distinct frontend screens or URL paths.
- The module has separate state machines or independent database entity clusters.

### Modular Spec Structure for Macro-Features
```text
specs/{module-name}/
├── 01-{sub-feature-a}/
│   ├── requirements.md
│   ├── design.md
│   └── tasks.md
├── 02-{sub-feature-b}/
│   ├── requirements.md
│   ├── design.md
│   └── tasks.md
└── ...
```

### Execution Strategy: One Sub-feature at a Time (Hard Gate 2)
1. **Step 0 — Propose Modular Breakdown**: The agent lists all proposed sub-features with clear boundaries and asks for approval of the decomposition.
2. **Execute Sub-feature by Sub-feature**: Start with Sub-feature 1. Follow the full lifecycle (`requirements.md` ➔ approval ➔ `design.md` ➔ approval ➔ `tasks.md`).
3. NEVER generate specs for subsequent sub-features until the active one is approved.

---

## Explicit Human Approval Protocol (Hard Gate 1 Enforcement)

- **Approval MUST BE EXPLICIT**: The agent SHALL NEVER assume approval based on general continuation, follow-up questions, or feedback comments.
- **Valid Approval Keywords**: "Aprobado", "Acepto", "Proceder con el diseño", "Adelante con tasks", "LGTM".
- **Invalid Signals**: "continúa", "¿por qué hiciste X?", "¿qué opinas de Y?", or silence.
- If the human asks a question, points out a bug, or raises a concern: **STOP IMMEDIATELY**. Address the question, provide clarifications, and **WAIT** for explicit approval. **NEVER advance to the next artifact (`design.md` or `tasks.md`) without explicit confirmation.**

---

## Exhaustive Engineering Depth & Anti-Superficiality Protocol (Hard Gate 12)

Every document generated by an agent (`requirements.md`, `design.md`, `tasks.md`, `docs/architecture/*.md`, `docs/modules/*.md`) MUST provide complete, exhaustive engineering depth. Superficiality, hand-waving, and placeholders are strictly prohibited.

### 1. Mandatory Depth Standards per Artifact

| Artifact | Superficial (REJECTED) ❌ | Detailed & Production-Grade (REQUIRED) ✅ |
| :--- | :--- | :--- |
| **Requirements (`requirements.md`)** | "El sistema calcula TSS e ISR según ley dominicana." | EARS formal clauses (`WHEN... SHALL...`), exact tax brackets (DGII scale: 15%, 20%, 25%), TSS percentages (AFP 2.87%, SFS 3.04%), daily rate divisor (`salario / 23.83 / 8`), overtime multipliers (35% and 100%), and boundary conditions (`start_date <= end_date`, rounding Half-Up). |
| **Design (`design.md`)** | "Habrá una tabla de ciclos y un endpoint para crearlos." | Complete PostgreSQL DDL (`CREATE TABLE huro.payroll_cycles (...)`) with exact SQL column types (`NUMERIC(12,2)`, `UUID`, `TIMESTAMPTZ`), default values, primary/foreign key constraints, and indexing strategy. Full REST API contract with HTTP method, path, required headers (`Idempotency-Key`), JSON Request payload, 200/201 Success JSON, and RFC 7807 error responses (400, 404, 409). |
| **Architecture (`docs/architecture/`)** | Diagramas genéricos de 3 cajas ("Frontend -> Backend -> DB"). | Full C4 Container Mermaid diagram with external actors (TSS, DGII, Portales BPD/ACH), layer responsibilities table, multi-tenant logical/RLS isolation strategy, complete RBAC matrix with granular permissions, and concrete environment matrices. |
| **Module Living Docs (`docs/modules/`)** | Resumen general del módulo en 2 párrafos. | Full Capabilities Matrix with sub-feature states, module-specific Mermaid ERD with cardinalities, Master API Catalog with all route definitions, domain business rules catalog, and migration/versioning notes. |
| **Tasks (`tasks.md`)** | "Crear backend de ciclos." | Granular sub-tasks (max 4h) with specific file paths (`src/services/...`), exact test verification commands (`pnpm test:unit cycles.test.ts`), and expected assertions. |

### 2. Prohibited Anti-Patterns (Automatic Quality Rejection)
1. **The "Etc." Anti-Pattern**: Writing "... y otros campos", "etc.", or leaving attribute lists truncated.
2. **The Placeholder Anti-Pattern**: Leaving `[TODO: Completar]`, `[TBD]`, or unexpanded bracket placeholders.
3. **The Omitted Payload Anti-Pattern**: Listing an API endpoint without providing its complete JSON request and response structure.
4. **The Ambiguous Formula Anti-Pattern**: Saying "se aplica el cálculo estándar" without writing out the exact mathematical formula.

---

## What the Agent NEVER Does
- NEVER skips `requirements.md` to start coding immediately because "it seems simple".
- NEVER generates `design.md` before `requirements.md` is explicitly approved.
- NEVER generates `tasks.md` before `design.md` is explicitly approved.
- NEVER starts implementation before `tasks.md` is explicitly approved.
- NEVER invents sections outside the official templates.
- NEVER puts Bug IDs as the primary Work Item or identity of a spec (Bug != Feature).
- NEVER dumps an entire multi-workflow macro-feature into a single monolithic spec file without modular decomposition.
- NEVER advances to the next phase when the user asks a question or reports an issue.
- NEVER generates superficial, hand-wavy, or placeholder-ridden documentation without exhaustive technical detail (Hard Gate 12).
