# Azure DevOps Workflow

> The developer RECEIVES and FIXES. Does not report.
> The analyst does NOT touch the repo. Only creates WIs in ADO.
> The agent brings requirements from ADO into the repo via MCP.

## Work Item Types

The analyst documents in ADO using these work item types:

| WI Type | Purpose | Who creates it |
|---------|---------|----------------|
| Feature | New functionality or enhancement | Analyst |
| Bug | Defect to fix | Analyst |
| User Story | Requirement equivalent (user perspective) | Analyst |
| Data Dictionary | Data model/structure that supports a feature or bug | Analyst |
| Structure | Architecture/structure that supports a feature or bug | Analyst |
| Business Rule | Business rule that supports a feature or bug | Analyst |

The agent reads ALL related WIs for a given AB# — a Feature or Bug may have linked Data Dictionary, Structure, and Business Rule items that provide context.

## Work Item hierarchy
```
Epic → Feature → User Story → Task
                         ↘ Bug
                         ↘ Data Dictionary
                         ↘ Structure
                         ↘ Business Rule
```

## States and transitions

```
To Do → In Progress → Fixed → In Testing → Done
                ↑                    ↓
              Reopen ← ──────────────┘

On Hold     (any state → paused, human decision)
Fix Later   (any state → deferred, human decision)
```

| State | Who sets it | When |
|-------|-------------|------|
| To Do | Analyst (on WI creation) | WI created in ADO |
| In Progress | Developer (agent via MCP) | Starting work (creating branch) |
| Fixed | Developer (agent via MCP) | PR created |
| In Testing | QA | QA picks up the PR |
| Done | QA/Lead | PR approved and merged |
| Reopen | QA | QA finds issues during testing |
| On Hold | Human | Work paused (any state) |
| Fix Later | Human | Work deferred (any state) |

### Agent-allowed transitions
The agent (developer) can ONLY perform these transitions:
- To Do → In Progress (when creating branch)
- In Progress → Fixed (when creating PR)
- Reopen → In Progress (when starting work again)

### Agent-forbidden transitions
The agent NEVER performs these transitions:
- → Done (QA/Lead only)
- → In Testing (QA only)
- → Reopen (QA only)
- → On Hold (human decision only)
- → Fix Later (human decision only)

## Feature flow (developer receives requirement)

1. **Read WI from ADO** via azure-devops MCP
   - Get: title, description, acceptance criteria, type, parent (Epic/Feature)
   - Read ALL linked WIs: Data Dictionary, Structure, Business Rule, User Story
   - Verify type = Feature or User Story
2. **PROPOSE**: "I will create branch feat/AB#id-description" → wait for approval
3. Create branch: `feat/AB#id-description-kebab-case`
4. **Move WI to In Progress** via azure-devops MCP
5. **Bring requirement to repo**: create `specs/AB#id/requirements.md` using template
   - Copy description and acceptance criteria from WI to template
   - Include context from linked Data Dictionary, Structure, Business Rule WIs
6. **PROPOSE**: "I will create design.md: [architecture, data model, API]" → wait for approval
7. Create `specs/AB#id/design.md` (based on design-template.md)
8. **PROPOSE**: "I will create tasks.md: [task1, task2, task3...]" → wait for approval
9. Create `specs/AB#id/tasks.md` (based on tasks-template.md)
10. **Implement task by task** (each task with approval)
11. **PROPOSE**: "I will create PR and move WI to Fixed" → wait for approval
12. Create PR via azure-devops MCP, link to WI
13. **Move WI to Fixed**

## Bug flow (developer receives bug directly)

1. **Read WI from ADO** via azure-devops MCP
   - Get: title, description, repro steps, severity, priority
   - Read ALL linked WIs: Data Dictionary, Structure, Business Rule
   - Verify type = Bug
2. **PROPOSE**: "I will create branch fix/AB#id-description" → wait for approval
3. Create branch: `fix/AB#id-description-kebab-case`
4. **Move WI to In Progress** via azure-devops MCP
5. **Analyze bug**: use codebase-memory to find the code, sequential-thinking if complex
6. **PROPOSE**: "Bug is in [file:line]. Fix: [description]. Impact: [analysis]" → wait for approval
7. **Implement fix** (with approval)
   - NO design.md (it is a fix, not a feature)
   - NO tasks.md (it is a direct fix)
8. **Run tests** (with approval)
9. **PROPOSE**: "I will create PR and move WI to Fixed" → wait for approval
10. Create PR via azure-devops MCP, link to WI
11. **Move WI to Fixed**

## Rules
- Every commit references the AB# (e.g., `feat(AB#5678): add export`, `fix(AB#1234): resolve login`)
- Every change reflects in ADO WI + repo (bidirectional traceability)
- The agent NEVER creates work items (the developer receives, does not report)
- The agent NEVER moves WI to Done, In Testing, Reopen, On Hold, or Fix Later
- The agent NEVER moves to Fixed without the PR being created first
- The agent reads ALL linked WIs (Data Dictionary, Structure, Business Rule) for full context
- If azure-devops MCP is not available: warn "Cannot read ADO. Provide the AB# and description manually."

## Functional Package Authority

When a Functional Package exists at `docs/requirements/functional-packages/Functional-Package-HU-{id}-*.md`, it is the PRIMARY authority for functional requirements.

### Authority boundary
- **RQE (analyst) defines the QUÉ functional** — Business Rules, Data Dictionaries, E2E, Test Context, Acceptance Criteria
- **Development (agent) conserves the CÓMO technical** — architecture, design, components, APIs, persistence, patterns

### The agent CAN (technical decisions)
- Analyze existing code
- Propose and select architecture and technical design
- Determine components and services
- Design APIs
- Define persistence
- Select technical patterns
- Implement the functional behavior defined in the package
- Create technical tests
- Refactor technically

### The agent CANNOT (functional decisions)
- Invent new functional rules
- Change the scope of the HU
- Modify functional criteria (e.g., calculation rules, anticipation minimums)
- Change states considered for balance or overlap validation
- Change the initial state (Pendiente)
- Introduce undefined exceptions
- Reinterpret Business Rules
- Use Test Cases or Bugs to redefine requirements
- Automatically extend implementation to out-of-scope capabilities
- Silently resolve a functional contradiction or ambiguity

### Functional Escalation Protocol
If during analysis or implementation a functional ambiguity, contradiction, or uncovered behavior is found:
1. STOP implementation
2. Raise a Functional Query to the user
3. Wait for human decision (Requirements & Testing team)
4. Receive updated Functional Context
5. Continue implementation

A technical decision can continue without escalation when it does NOT modify the functional behavior defined in the package.

### Functional Package is READ-ONLY
- The agent NEVER edits files in `docs/requirements/functional-packages/`
- The agent NEVER deletes or renames Functional Packages
- The agent only READS them as input for the feature flow
