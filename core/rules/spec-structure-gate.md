# Spec Structure Gate

> Automatic blocks that prevent skipping lifecycle phases.
> If a gate is violated, STOP immediately and notify the human.

## Blocks

| # | Condition | Result |
|---|-----------|--------|
| 1 | Create design.md without requirements.md | BLOCK |
| 2 | Create tasks.md without design.md | BLOCK |
| 3 | Implement code without tasks.md | BLOCK |
| 4 | Create spec file outside specs/ directory | BLOCK |
| 5 | Create spec without using template | BLOCK |
| 6 | Create requirements.md without reading ADO first | BLOCK |
| 7 | Create design.md for a Bug (bugs don't need design) | BLOCK |
| 8 | Create tasks.md for a Bug (bugs don't need tasks) | BLOCK |

## What happens when a block is triggered
1. STOP immediately — do not proceed
2. Notify the human: "BLOCKED: [explanation of which gate was violated]"
3. Explain what is needed to unblock: "To proceed, you need to: [requirement]"
4. Wait for human to resolve or provide guidance

## How to unblock
- Gate 1: Create requirements.md first (bring from ADO using template)
- Gate 2: Create design.md first (using template)
- Gate 3: Create tasks.md first (using template)
- Gate 4: Move the file to specs/{AB#id-feature}/
- Gate 5: Use the corresponding template from specs/_templates/
- Gate 6: Read the WI from ADO via azure-devops MCP first
- Gate 7: Bugs don't need design.md — go directly to fix
- Gate 8: Bugs don't need tasks.md — go directly to fix

## What NEVER to do
- DO NOT bypass gates even if the user says "just do it"
- DO NOT create files that would violate a gate
- DO NOT ignore block warnings
