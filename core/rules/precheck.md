# Precheck — 6-step first interaction (mandatory)

> This check is MANDATORY before any action.
> If any step fails, DO NOT proceed. Notify the human and explain what is missing.

## Step 1: Memory read
Use server-memory to load context from previous sessions:
- Search entities of type "Decision" — technical decisions made before
- Search entities of type "Convention" — project conventions (naming, patterns, etc.)
- Search entities of type "Correction" — past error corrections
- If memory is empty (first session): OK, proceed without prior context
- If memory has data: use that context in all subsequent decisions
- NEVER repeat a decision that is already in memory without new information

## Step 2: Git identity
Verify git has user.name and user.email configured:
- `git config user.name` and `git config user.email`
- If not configured locally, check global: `git config --global user.name`
- If no identity: notify human "Configure git identity before proceeding"
- DO NOT continue without git identity (commits need an author)

## Step 3: MCP health check
Verify MCP servers are connected and responding:
- **server-memory**: try reading entities. If responds: OK. If not: CRITICAL ERROR.
- **codebase-memory**: try list_projects. If responds: OK. If not: warn (limits capability but does not block).
- **azure-devops**: try list_projects. If responds: OK. If not: warn "Azure DevOps not available — cannot read work items automatically". This does NOT block but limits the flow.
- **context7**:@EFFECTIVE (4: sequential-thinking**: no check needed (on-demand).
- **github**: no check needed (on-demand).
- **playwright**: no check needed (on-demand).
- **stitch**: no check needed (on-demand).

## Step 4: Project type detection
Read project configuration:
- `.sdd-config.json` → role, ides, spec_prefix, azure_devops_org, azure_devops_project, wi_states, wi_types
- `package.json` → Node.js/TypeScript/JavaScript
- `requirements.txt` or `pyproject.toml` → Python
- `pubspec.yaml` → Flutter/Dart
- `go.mod` → Go
- `Cargo.toml` → Rust
- `composer.json` → PHP
- Check for `docs/requirements/functional-packages/` directory
  - If exists: note "Functional Packages detected — agent will use these as PRIMARY entry point for features"
- If stack not detected: warn "Stack not detected. Specify your stack manually."

## Step 5: Code presence verification
Verify the repo contains actual application code, not just SDD config files.

**Use codebase-memory FIRST** — do NOT use glob/grep before codebase-memory.

1. If codebase-memory IS available (Step 3 OK):
   - Call `codebase-memory get_architecture` for the current project
   - If codebase-memory returns nodes (functions, classes, files) → code present → OK
   - If codebase-memory is empty but source files exist → warn "Code exists but is not indexed in codebase-memory. Run index_repository."
2. If codebase-memory is NOT available (Step 3 warned):
   - Fall back to glob for source files: `*.py`, `*.ts`, `*.js`, `*.go`, `*.rs`, `*.dart`, `*.java`, `*.cs`, `*.php`, `*.rb`, `*.kt`, `*.swift`
   - Check source directories: `src/`, `lib/`, `app/`, `cmd/`, `internal/`, `pkg/`, `tests/`, `test/`
   - This is the ONLY case where glob is acceptable before codebase-memory
3. If codebase-memory is empty AND no source files found → **BLOCK**. Tell the user:
   > "No application code detected in this repo. This appears to be an SDD-only workspace.
   > To work on bugs or features, install SDD inside your codebase repo:
   >   cd /path/to/your/codebase
   >   bash sdd-init.sh
   > DO NOT offer to analyze bugs, propose fixes, or continue with any work."

EXCLUDE from this check: `.opencode/`, `.sdd-memory/`, `specs/`, `.sdd-config.json`, `opencode.json`, `sdd-init.sh`

## Step 6: Readiness verification
Verify all above is OK:
- Memory: OK or empty (first session) → OK
- Git identity: OK → OK. If not → BLOCK
- MCP health: server-memory OK → OK. codebase-memory and azure-devops: warn but do not block
- Project type: detected → OK. If not → warn
- Code presence: code found → OK. If not → **BLOCK** (do not offer work options)
- If all OK: "Precheck completed. Ready to proceed."
- If something fails: "Precheck failed at step X. [explanation]. Cannot proceed until resolved."

## What NEVER to do during precheck
- DO NOT present "explore codebase" as an option to the user — that is automatic
- DO NOT present "load context into memory" as an option — that is automatic
- DO NOT skip precheck even if the user says "just do it fast"
- DO NOT omit precheck steps
