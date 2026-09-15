# Spec Integration

> Specs live in the repo under specs/{AB#id-feature-name}/
> Templates are MANDATORY. The agent NEVER invents spec structure.

## Directory structure
```
specs/
├── _templates/                    # Templates (do not modify, reference only)
│   ├── requirements-template.md
│   ├── design-template.md
│   └── tasks-template.md
└── AB#5678-export-excel/          # Feature folder (named after WI)
    ├── requirements.md            # Brought from ADO, based on template
    ├── design.md                  # Created by developer, based on template
    └── tasks.md                   # Created by developer, based on template
```

## Template usage (MANDATORY)
Every spec file MUST be based on the corresponding template:

| File | Template | Who creates |
|------|----------|-------------|
| requirements.md | requirements-template.md | Agent (brings from ADO) |
| design.md | design-template.md | Developer (with approval) |
| tasks.md | tasks-template.md | Developer (with approval) |

Rules:
- NEVER create a spec without using the template
- NEVER invent sections not in the template
- Respect ALWAYS marks (always include these sections)
- Respect CONDITIONAL marks (include only if applicable)
- Fill all placeholders [in brackets] with real data
- DO NOT leave template placeholders unfilled

## Gates between phases

| Gate | Requirement | Block |
|------|-------------|-------|
| requirements → design | requirements.md exists and is approved | BLOCK if missing |
| design → tasks | design.md exists and is approved | BLOCK if missing |
| tasks → impl | tasks.md exists and has assigned tasks | BLOCK if missing |
| impl → test | code review + lint + unit tests passing | BLOCK if failing |
| test → PR | all tests pass, QA sign-off | BLOCK if failing |

## What NEVER to do
- DO NOT create design.md without requirements.md
- DO NOT create tasks.md without design.md
- DO NOT implement without tasks.md
- DO NOT create specs outside the specs/ directory
- DO NOT create spec files without using templates
- DO NOT modify templates (they are reference only)
