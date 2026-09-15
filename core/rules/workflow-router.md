# Workflow Router — lifecycle detection, hard gates and routing (automatic)

## HARD GATES (NEVER violate, non-negotiable)

### Gate 1: AI proposes, human approves
The agent NEVER executes without explicit human approval.
- Propose what you will do and why
- Wait for human to say "go", "proceed", "yes", etc.
- Execute ONE single step
- Propose the next step
- Repeat
- NEVER execute multiple steps without intermediate approval

### Gate 2: One spec at a time
Do not mix features/bugs in the same context.
- If there is an active AB#, finish before starting another
- DO NOT work on AB#5678 and AB#1234 at the same time
- If user asks to switch AB#: warn "You have AB#5678 in progress. Finish first?"

### Gate 3: No auto-deploy prod
Production deploy requires explicit human approval.
- NEVER deploy to prod without human saying "deploy to prod"
- dev: auto-deploy OK (with step approval)
- cert: manual approval OK
- prod: TRIPLE sign-off mandatory

### Gate 4: No auto-merge PRs
Every PR requires human review.
- The agent CREATES the PR (with approval)
- The agent NEVER merges the PR
- The agent NEVER auto-approves the PR

### Gate 5: Templates mandatory
NEVER create specs without using templates from specs/_templates/.
- requirements.md → based on requirements-template.md
- design.md → based on design-template.md
- tasks.md → based on tasks-template.md
- NEVER invent sections not in the template
- Respect ALWAYS marks (always include) and CONDITIONAL (include if applicable)

### Gate 6: AB# in every commit
Every commit must reference the work item.
- feat(AB#5678): add export endpoint
- fix(AB#1234): resolve login google oauth
- NEVER commit without AB#

### Gate 7: Memory-first
server-memory before reading files. codebase-memory before grep.
- Always load memory at start
- Always search codebase-memory before grep
- NEVER read a file if info is already in memory

### Gate 8: No editing protected files
Do not edit: opencode.json, .sdd-config.json, .sdd-credentials.json, VERSION, .kiro/settings/mcp.json, .mcp.json
- If changes needed: request explicit human approval
- If agent tries to edit them: STOP and notify

### Gate 9: Bug != Feature
Bug and Feature have different flows. DO NOT mix.
- **Feature**: receive requirement → bring from ADO → create design.md → create tasks.md → implement task by task
- **Bug**: receive bug directly → analyze → fix → test → PR (no design or tasks)
- NEVER create design.md for a bug
- NEVER skip design.md for a feature

### Gate 10: Requirements come from ADO or Functional Package
The analyst does NOT touch the repo. Only creates WIs in ADO and Functional Packages in docs/requirements/functional-packages/.
- Entry point priority:
  1. **Functional Package** (PRIMARY): if `docs/requirements/functional-packages/Functional-Package-HU-{id}-*.md` exists, use it as the authoritative source
  2. **Azure DevOps WI** (FALLBACK): if no Functional Package, read the WI from ADO via MCP
- The agent brings requirements into the repo as `specs/AB#id/requirements.md`
- If using a Functional Package: `specs/AB#id/requirements.md` REFERENCES the package (link, not copy)
- If using ADO WI: `specs/AB#id/requirements.md` copies the WI content into the template
- NEVER create requirements.md from scratch without reading Functional Package or ADO first

## Entry points

The agent detects the entry point automatically based on the AB#:

### 1. Functional Package (PRIMARY)
- Path: `docs/requirements/functional-packages/Functional-Package-HU-{id}-{title}.md`
- If exists: this is the authoritative functional baseline
- Contains: Business Rules, Data Dictionaries, E2E Context, Test Context, Implementation Contract, Traceability Map
- The Functional Package is READ-ONLY — the agent NEVER edits it
- The agent creates `specs/AB#id/requirements.md` that REFERENCES the package (link, not copy)
- The agent respects the Implementation Contract (what dev can/cannot do)
- If ambiguity/contradiction → STOP → Functional Escalation Protocol → wait for human decision

### 2. Azure DevOps WI (FALLBACK)
- If no Functional Package found: read the WI from ADO via MCP
- Get: title, description, acceptance criteria, linked WIs (Data Dictionary, Structure, Business Rule)
- The agent creates `specs/AB#id/requirements.md` from the WI content using template

## Automatic type detection

The agent automatically detects if it is a Feature or Bug:
1. Check for Functional Package: `docs/requirements/functional-packages/Functional-Package-HU-{id}-*.md`
2. If Functional Package exists → read it → type is in "Package Identity" section (usually User Story/Feature)
3. If no Functional Package → read WI from Azure DevOps (type: Task, User Story, Bug)
4. If type = Task/User Story/Feature → Feature flow
5. If type = Bug → Bug flow
6. If no type → ask human "Is this a feature or bug?"

## Automatic phase detection

The agent detects what phase of work it is in:
- No branch → need to start (create branch)
- Branch exists but no specs → need to create design + tasks (feature) or analyze (bug)
- Specs exist but no code → need to implement
- Code exists but no tests → need to test
- Tests pass → need to create PR
- PR created → need to update WI

## Routing

- Analysis/planning → sdd-plan agent (read-only, proposes)
- Implementation → sdd-build agent (edits with approval)
- Switch between agents: Tab

## What NEVER to present as an option to the user
- "Explore codebase" → do it automatically (codebase-memory)
- "Load context into memory" → do it automatically (server-memory)
- "View project status" → do it automatically (precheck)
- Only present WORK options: Feature or Bug
