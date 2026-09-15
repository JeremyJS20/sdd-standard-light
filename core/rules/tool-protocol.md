# Tool Protocol — WHEN to use each MCP (automatic, without user asking)

> The agent knows when to use each tool WITHOUT the user telling it.
> The user NEVER says "use context7" or "use playwright". The agent knows by context.

## MCPs and when to use them automatically

### server-memory → ALWAYS FIRST
- **When**: at the start of any session, before reading files
- **What to load**: Decisions (technical decisions), Conventions (naming, patterns), Corrections (past errors)
- **When to save**: after each technical decision, after discovering a convention, after correcting an error
- **What NOT to do**: DO NOT read files if the info is already in memory. DO NOT repeat decisions from memory.

### codebase-memory → BEFORE grep/glob (MANDATORY)
- **When**: searching for code, finding callers of a function, tracing dependencies, understanding architecture, verifying code presence in precheck
- **What to do**: search_graph (find functions/classes), trace_path (callers/callees), get_code_snippet (read source), query_graph (complex patterns), get_architecture (project overview)
- **What NOT to do**: DO NOT use grep if codebase-memory can find it. DO NOT use glob if codebase-memory knows the structure. DO NOT use glob/grep to verify code presence in precheck — use get_architecture FIRST.
- **If codebase-memory does not have the project indexed**: warn and use grep as fallback
- **This is MANDATORY**: even in precheck, codebase-memory is used BEFORE any glob/grep call

### context7 → library/framework docs
- **When**: need documentation for a library (React, Next.js, Prisma, Express, Tailwind, etc.)
- **How**: first resolve-library-id (get the ID), then query-docs (search specific docs)
- **What NOT to do**: DO NOT use context7 to search project code. DO NOT use context7 for things you already know.
- **Example**: user asks "implement JWT auth in Express" → context7 for express-jwt docs

### sequential-thinking → complex problems
- **When**: architecture, complex debugging, planning large features, dependency analysis
- **What NOT to do**: DO NOT use for simple things (change a string, add a field). DO NOT use if the solution is obvious.
-/E: user asks "design architecture for a settlement system" → sequential-thinking step by step

### azure-devops → tasks, bugs, sprints, PRs, pipelines
- **When**: at session start (see assigned items), read work item, create branch, update WI, create PR, trigger pipeline
- **Automatic at start**: read assigned items from current sprint and show them
- **What NOT to do**: DO NOT create work items (developer receives, does not report). DO NOT close WIs without approval.
- **Flow**: read WI → create branch → implement → create PR → update WI (all with approval)

### github → PRs, Actions on GitHub (dual CI/CD)
- **When**: if project has dual CI/CD (Azure DevOps + GitHub), create PR on GitHub, view Actions
- **What>### playwright → E2E, browser automation, screenshots
- **When**: after implementing (smoke tests), E2E testing, visual regression, UI screenshots
- **Automatic**: after deploy to dev, run smoke tests with playwright
- **What NOT to do**: DO NOT use for unit tests. DO NOT use for API tests (use postman or curl).

### stitch → generate UI/design from text
- **When**: designing new UI screens, generating design system, creating screen variants
- **What NOT to do**: DO NOT use for backend. DO NOT use for non-UI things. DO NOT use if user does not want UI generation.

## Priority order for finding information

1. **server-memory** — decisions, conventions, corrections (fastest, already in context)
2. **code3. **Read project files** — when memory and codebase-memory do not have the answer
4. **context7** — external library docs (when you need docs for something external)
5. **azure-devops** — work items, specs, wiki (when you need info from the requirement)

## Tool discipline rules
- NEVER use 3 MCPs for the same task if 1 suffices
- NEVER call context7 if you already know the answer
- NEVER call playwright if there is no UI to test
- NEVER call azure-devops if there is no AB# in context
- ALWAYS use server-memory first before any other tool
