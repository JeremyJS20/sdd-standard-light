# SDD Standard (Spec-Driven Development)

Estándar y framework de desarrollo autónomo guiado por especificaciones (**Spec-Driven Development**) para agentes de inteligencia artificial y desarrolladores.

> **Principio Fundamental:** *"AI proposes, human approves."*  
> El agente de IA propone arquitectura, diseño, tareas y código; el desarrollador humano mantiene el control y la aprobación explícita de cada compuerta (Hard Gate).

---

## 📌 Tabla de Contenidos

1. [Características Principales](#-características-principales)
2. [Estructura del Proyecto y Aislamiento](#-estructura-del-proyecto-y-aislamiento)
3. [Instalación e Inicialización](#-instalación-e-inicialización)
4. [Ciclos de Vida: Greenfield vs Brownfield](#-ciclos-de-vida-greenfield-vs-brownfield)
5. [Generación de Especificaciones (3 Modos)](#-generación-de-especificaciones-3-modos)
6. [Protocolo de Corrección de Bugs (8 Fases)](#-protocolo-de-corrección-de-bugs-8-fases)
7. [Ciclos de QA Corte y Releases](#-ciclos-de-qa-corte-y-releases)
8. [Ecosistema de MCPs (Memory-First)](#-ecosistema-de-mcps-memory-first)
9. [Catálogo de las 14 Reglas de Gobierno](#-catálogo-de-las-14-reglas-de-gobierno)
10. [Los 10 Hard Gates Innegociables](#-los-10-hard-gates-innegociables)

---

## 🚀 Características Principales

* **Agnóstico de IDE:** Compatible de fábrica con **OpenCode**, **Antigravity (Gemini CLI)**, **Kiro** y **Claude Code**.
* **Agnóstico de Stack:** Funciona con TypeScript/Node, Python, Go, Rust, Flutter/Dart, PHP, Java, C#, etc.
* **Gobierno y Trazabilidad:** Integración nativa con **Azure DevOps** (WIs, Epics, Features, PBIs, Bugs, PRs, Pipelines).
* **Memory-First:** Persistencia cross-sesión de decisiones técnicas, convenciones y aprendizajes con `server-memory` y navegación de código mediante grafo AST con `codebase-memory`.
* **Zero Fluff & Zero Regressions:** No se modifica código sin spec previa, no se declara un bug arreglado sin test de reproducción y smoke test local.

---

## 📁 Estructura del Proyecto y Aislamiento

SDD separa estrictamente el **gobierno del proyecto** (en la raíz) del **código fuente de la aplicación** (en una subcarpeta aislada):

```text
mi-proyecto/                          # 📁 RAÍZ DEL REPOSITORIO (Gobierno y Orquestación)
├── .agents/ o .opencode/             # Reglas, agentes y configuración del IDE
├── .sdd-memory/                      # Memoria cross-session (server-memory) [GITIGNORED]
├── .sdd-config.json                  # Configuración del proyecto ("app_dir": "app")
├── .sdd-credentials.json             # PATs y llaves de acceso locales [GITIGNORED]
├── specs/                            # Especificaciones funcionales y técnicas
│   ├── _templates/                   # requirements, design y tasks templates
│   └── {AB#id-feature}/              # Especificación por Feature/PBI
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
├── docs/                             # PRDs, briefs o Functional Packages
├── .gitignore                        # Gitignore raíz (protege credenciales de MCPs)
├── README.md
│
└── app/                              # 🚀 SUBCARPETAS DE LA APLICACIÓN ("app_dir")
    ├── package.json (o go.mod, etc.) # Manifiesto y dependencias de la aplicación
    ├── src/                          # Código fuente puro de la app
    ├── tests/                        # Tests unitarios y de integración
    └── ...
```

---

## 🛠️ Instalación e Inicialización

### Prerrequisitos
* Node.js 20+ (para servidores MCP vía `npx`)
* Git
* Personal Access Token (PAT) de Azure DevOps (con permisos en Work Items, Repos y Pipelines)

### Modo Interactivo (Recomendado)
Ejecuta el inicializador en la raíz de cualquier repositorio (vacío o existente):

```bash
bash sdd-init.sh
```

El asistente te solicitará:
1. El IDE a configurar (`opencode`, `antigravity`, `kiro`, `claude`).
2. Organización y Proyecto de Azure DevOps.
3. Tus tokens de acceso (PAT de ADO, GitHub opcional, Stitch UI opcional).

### Modo No Interactivo (CI / Automatización)
```bash
bash sdd-init.sh --ide antigravity --org mi-org --project MiProyecto --non-interactive
```

---

## 🌱 Ciclos de Vida: Greenfield vs Brownfield

El **Precheck** automático (Paso 5) detecta en qué fase de vida se encuentra el repositorio:

### 1. 🌱 Modo Greenfield (Proyectos desde Cero)
Cuando el repositorio no tiene código fuente previo, SDD no bloquea al desarrollador; activa el **Project Inception Flow**:

* **Paso 1: Inception & Levantamiento:**
  El agente recopila los requerimientos a través de uno de tres canales:
  * **Canal A (Archivo local/PRD):** Lee un brief o especificación en `docs/brief.md` o ruta indicada.
  * **Canal B (Entrevista de Descubrimiento):** Conduce una entrevista interactiva estructurada en 5 dimensiones (Propósito, Actores/RBAC, Entidades/Estados, Reglas de Negocio Críticas, Integraciones/NFRs).
  * **Canal C (Azure DevOps):** Lee el Epic o Feature inicial en el backlog.
  * **Decisión de Stack:** Propone y justifica el stack técnico y lo persiste como `Decision` en `server-memory`.
* **Paso 2: Especificación MVP Inicial (Forward Spec):**
  Redacta `requirements.md`, `design.md` y `tasks.md` dividido en olas.
* **Paso 3: Scaffolding (Wave 0):**
  Ejecuta la inicialización del framework dentro de la subcarpeta `app/` (ej. `npx create-next-app@latest app`), protegiendo las reglas de la raíz.
* **Paso 4: Indexación Inmediata:**
  Ejecuta `codebase-memory index_repository` en cuanto el scaffolding concluye.

### 2. 🏢 Modo Brownfield (Código Existente)
Detecta código en la raíz o subcarpeta (`app/`, `src/`) y habilita el flujo de desarrollo continuo:
* Detección de stack automático (`package.json`, `go.mod`, etc.).
* Carga de memoria de bugs resueltos y decisiones previas.
* Verificación de frescura del grafo en `codebase-memory`.

---

## 📑 Generación de Especificaciones (3 Modos)

Ninguna feature se programa sin antes aprobar sus 3 artefactos en `specs/{id}/`:

```
Requerimiento / WI ──► requirements.md ──► design.md ──► tasks.md ──► sdd-build
```

| Modo | Situación | Proceso |
| :--- | :--- | :--- |
| **1. Forward Spec** | Nueva funcionalidad (Greenfield o nueva HU) | Archivo / Entrevista / ADO ➔ `requirements.md` (notación EARS) ➔ `design.md` (Mermaid) ➔ `tasks.md` (<4h por tarea, agrupadas en waves). |
| **2. Reverse Spec (As-Built)** | Código heredado o no documentado | Minería con `codebase-memory` (`search_graph`, `trace_path`) + **Arqueología de Git** (`git log`, `git blame`, commits `AB#`) para documentar el raciocinio de negocio real detrás del código existente. |
| **3. Hybrid Spec (Extensión)** | Sub-feature agregada a módulo existente | Mapea la base técnica existente como dependencia y genera Forward Spec exclusivo para la nueva capacidad. |

---

## 🐛 Protocolo de Corrección de Bugs (8 Fases)

Un bug **NO** está resuelto hasta que exista evidencia ejecutable. Se prohíbe parchar código por simple deducción.

1. **Investigar (Fase 1):** Consulta en ADO el bug, sus pasos de reproducción y bugs similares en el módulo; busca correcciones previas en `server-memory`; localiza el código con `codebase-memory` e inspecciona `git blame`.
2. **Reproducir (Fase 2):** Escribe una prueba automatizada (unitaria o Playwright UI) que **falle** exactamente con el síntoma reportado.
3. **Impacto (Fase 3):** Traza llamadores con `codebase-memory trace_path(direction="inbound")` y clasifica el riesgo (BAJO / MEDIO / ALTO) antes de tocar el código.
4. **Fix Quirúrgico (Fase 4):** Propone el diff mínimo de causa raíz sin refactorizaciones colaterales.
5. **Verificar (Fase 5):**
   * El test de reproducción ahora pasa.
   * La suite del módulo pasa sin regresiones.
   * **Smoke Test Local (Fase 5.1):** Prueba E2E Playwright contra la aplicación corriendo en local (`environments.local.url`).
6. **Reporte de Evidencia (Fase 6):** Inserta en el Pull Request la traza completa de causa raíz, test y verificación.
7. **Verificación de Despliegue (Fase 7):** Auditoría en DEV tras merge a `develop` y en QA tras merge del corte a `qa`.
8. **Aprender (Fase 8):** Guarda la entidad `BugFix` (y `Correction` si fue una reapertura) en `server-memory`.

---

## 🚦 Ciclos de QA Corte y Releases

* **Detección Automática:** Detecta cortes activos en Azure DevOps (PBIs con *"corte al"* en el título en estado `Acceptance`).
* **Prioridad Absoluta:** Los bugs del corte tienen prioridad sobre cualquier desarrollo nuevo.
* **Estrategia de Release Quirúrgica:**
  * **Prohibido** hacer merge directo `develop ➔ qa`.
  * Se audita commit por commit y se genera una rama `release/corte-DD-MM-YYYY` desde `origin/qa` conteniendo únicamente los fixes certificados.
  * Para producción, se crea `release/prod-DD-MM-YYYY` desde `origin/main` y se aplica Versionamiento Semántico (SemVer) con tag `vX.Y.Z` tras la aprobación humana.

---

## 🧠 Ecosistema de MCPs (Memory-First)

| Servidor MCP | Comando | Propósito en SDD |
| :--- | :--- | :--- |
| **`server-memory`** | `@modelcontextprotocol/server-memory` | Memoria persistente en `.sdd-memory/memory.jsonl` (Decisions, Conventions, BugFixes, Corrections). |
| **`codebase-memory`** | `codebase-memory-mcp` | Grafo de conocimiento AST. Búsqueda semántica (`search_graph`), trazabilidad de llamadores (`trace_path`) y lectura precisa (`get_code_snippet`) **antes de cualquier grep**. |
| **`azure-devops`** | `@azure-devops/mcp` | Gestión de Work Items, transiciones de estado, vinculación de PRs y lectura de criterios de aceptación. |
| **`playwright`** | `@playwright/mcp` | Smoke tests locales, reproducción de bugs en UI y pruebas E2E. |
| **`stitch`** | `@google/stitch-sdk` | Generación y revisión de interfaces visuales y componentes UI. |
| **`context7`** | `@upstash/context7-mcp` | Documentación técnica oficial y actualizada de frameworks y librerías. |
| **`sequential-thinking`** | `server-sequential-thinking` | Desglose dinámico para análisis de causa raíz y problemas de alta complejidad. |

---

## 📜 Catálogo de las 14 Reglas de Gobierno

Ubicadas en [`core/rules/`](file:///C:/Users/jsjer/OneDrive/Bureaublad/projects/smart_testing/sdd-standard/core/rules/):

1. **`tool-protocol.md`**: Checkpoints MCP obligatorios; orden estricto de herramientas (memoria antes de archivos, grafo antes de grep).
2. **`precheck.md`**: Protocolo de arranque en 6 pasos; detección de identidad git, salud de MCPs y modo Greenfield vs Brownfield.
3. **`workflow-router.md`**: Enrutador de flujo de trabajo, ciclo Greenfield (Inception, Wave 0) y compuertas de ciclo de vida.
4. **`spec-generation-protocol.md`**: Regla #14 para creación de especificaciones en Modos Forward, Reverse (con Arqueología Git) e Hybrid.
5. **`bug-fix-protocol.md`**: Protocolo de 8 fases para corrección de bugs basada en evidencia y smoke tests locales.
6. **`qa-corte-workflow.md`**: Flujo de estabilización de cortes de QA, congelamiento de ramas y releases quirúrgicos a QA y Producción.
7. **`artifact-storage.md`**: Matriz de artefactos del repositorio, aislamiento en subcarpeta `app/` y archivos protegidos `.gitignore`.
8. **`protected-files.md`**: Lista de archivos inmutables para el agente (configuraciones de MCPs, credenciales, memoria).
9. **`azure-devops-workflow.md`**: Jerarquía de Work Items (CMMI / Agile), reglas de transición de estados y contrato RQE vs Dev.
10. **`spec-integration.md`**: Integración de plantillas obligatorias (`requirements`, `design`, `tasks`).
11. **`spec-structure-gate.md`**: Validaciones automáticas de completitud de specs antes de autorizar el paso a código.
12. **`change-propagation.md`**: Matriz de impacto upstream ➔ downstream ante cambios en requerimientos para evitar estados inconsistentes.
13. **`git-conventions.md`**: Convenciones de nombres de ramas (`feat/AB#id`, `fix/AB#id`, `release/*`) y Conventional Commits.
14. **`token-optimization.md`**: Reglas de ahorro de contexto (lecturas quirúrgicas, resúmenes estructurados y antipatrones de tokens).

---

## ⛔ Los 10 Hard Gates Innegociables

1. **AI propone, humano aprueba:** Ninguna acción destructiva o modificación de código se ejecuta sin confirmación explícita.
2. **Una spec a la vez:** Prohibido mezclar múltiples features o bugs en el mismo contexto de trabajo.
3. **Prohibido el auto-deploy a Producción:** Los pases a producción exigen autorización y validación humana explícita.
4. **Prohibido el auto-merge de Pull Requests:** Todo PR requiere revisión de código por un desarrollador humano.
5. **Plantillas obligatorias:** Ninguna especificación se redacta fuera de `specs/_templates/`.
6. **AB# en cada commit:** Todo commit debe referenciar el Work Item correspondiente (`feat(AB#123): ...` o `fix(AB#123): ...`).
7. **Memory-First:** `server-memory` antes de leer archivos; `codebase-memory` antes de utilizar grep/glob.
8. **Archivos protegidos intocables:** El agente jamás edita archivos de configuración de MCPs ni almacenes de credenciales.
9. **Bug != Feature:** Los bugs no llevan `design.md` ni `tasks.md`; siguen el protocolo de 8 fases. Las features nunca se programan sin spec aprobada.
10. **Requerimientos desde el Origen:** Los requerimientos provienen del Functional Package o del Work Item de Azure DevOps; el desarrollador no inventa reglas funcionales.
