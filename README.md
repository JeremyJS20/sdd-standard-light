# sdd-standard

Script generico que instala SDD Standard en cualquier proyecto para cualquier IDE.
Agente autonomo inspirado en SDD Standard. Rol: developer.
Principio fundamental: "AI proposes, human approves."

## Estructura

```
sdd-standard/
├── sdd-init.sh              # Script generico (--ide flag)
├── README.md                # Este archivo
├── .env.example             # Variables de entorno template
├── core/                    # Contenido independiente del IDE
│   ├── rules/               # 11 steering rules
│   ├── agents/              # 2 agent prompts (sdd-build, sdd-plan)
│   └── templates/           # 3 spec templates (requirements, design, tasks)
└── adapters/                # Adaptadores por IDE (extensible)
    └── opencode/            # Adapter para opencode
        └── adapter.sh       # Genera opencode.json
```

## Prerequisites

- Node.js 20+ (para npx de MCPs)
- Git
- Azure DevOps PAT (con acceso a Work Items, Repos, Pipelines)

## Uso

### Interactivo (default)

```bash
bash sdd-init.sh
```

Te preguntara:
1. Que IDE usas (opencode, kiro, claude, antigravity)
2. Organizacion Azure DevOps
3. Proyecto en ADO

### No-interactivo (CI)

```bash
bash sdd-init.sh --ide opencode --org mi-org --project mi-proyecto --non-interactive
```

### Sobrescribir

```bash
bash sdd-init.sh --force
```

## MCPs configurados (7 locales)

| MCP | Command | Para que |
|-----|---------|----------|
| azure-devops | npx -y @azure-devops/mcp {org} --authentication pat | Tasks, bugs, sprints, PRs, pipelines |
| sequential-thinking | npx -y @modelcontextprotocol/server-sequential-thinking | Razonamiento paso a paso |
| context7 | npx -y @upstash/context7-mcp@latest | Docs de librerias |
| github | npx -y @modelcontextprotocol/server-github | PRs, Actions (dual CI/CD) |
| server-memory | npx -y @modelcontextprotocol/server-memory | Memoria cross-session |
| playwright | npx -y @playwright/mcp@latest | E2E, browser automation |
| stitch | npx -y @google/stitch-sdk | Generacion de UI/design |

## codebase-memory (global, fuera del script)

```bash
npm i -g codebase-memory-mcp
codebase-memory-mcp install
codebase-memory-mcp config set auto_index true
```

## Agentes

| Agente | Color | Funcion |
|--------|-------|---------|
| sdd-build | green | Implementacion con aprobacion humana |
| sdd-plan | blue | Analisis read-only7 steering rules

1. precheck.md — 5-step first interaction
2. protected-files.md — archivos inmutables
3. token-optimization.md — memory-first, verbosidad
4. tool-protocol.md — CUANDO usar cada MCP
5. azure-devops-workflow.md — CMMI, WI hierarchy, flujos feature vs bug
6. git-conventions.md — branch naming, conventional commits
7. workflow-router.md — HARD GATES, lifecycle detection, routing
8. spec-integration.md — templates obligatorios, gates
9. artifact-storage.md — que se commitea, que no, que vive en ADO
10. change-propagation.md — matrix upstream→downstream, anti-flip-flop
11. spec-structure-gate.md — bloqueos automaticos

## HARD GATES (non-negotiable)

1. AI proposes, human approves
2. One spec at a time
3B3. No auto-deploy prod
4. No auto-merge PRs
5. Templates obligatorios
6. AB# en todo commit
7. Memory-first
8. No editar protected files
9. Bug != Feature
10. Requirements vienen de ADO

## Flujo autonomo

El usuario no ejecuta comandos explicitos. El agente:
1. Lee contexto (server-memory, Azure DevOps, codebase-memory)
2. Detecta tipo (feature vs bug)
3. Propone cada accion
4. Espera aprobacion humana
5. Ejecuta
6. Repite

### Feature: requirement → design → tasks → impl → test → PR
### Bug: bug → analizar → fix → test → PR
