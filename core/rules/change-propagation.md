# Change Propagation

> When upstream artifacts change, downstream artifacts must be reviewed.
> Anti-flip-flop: never revert a decision without new information.

## Propagation matrix

| If this changes... | ...then mark these as REQUIRES REVIEW |
|---------------------|----------------------------------------|
| requirements.md | design.md, tasks.md |
| design.md | tasks.md, implementation code |
| tasks.md | implementation code |
| .sdd-config.json | all specs (role/org may have changed) |

## How to mark REQUIRES REVIEW
Add at the top of the affected file:
```markdown
> ⚠️ REQUIRES REVIEW — upstream changed: [file] on [date]
```

## Anti-flip-flop rule
- NEVER revert a technical decision without new information that justifies the revert
- If a decision was made and recorded in server-memory, it stands unless:
  - New requirements make it obsolete
  - New technical constraints require a different approach
  - The human explicitly provides new information
- If reverting: document WHY in server-memory as a new Decision

## When to trigger propagation
- When requirements.md is modified → mark design.md and tasks.md
- When design.md is modified → mark tasks.md
- When tasks.md is modified → warn that implementation may need updates
- Propagation is automatic — the agent detects changes and marks downstream

## What NEVER to do
- DO NOT silently change an upstream artifact without marking downstream
- DO NOT revert a decision without documenting the reason
- DO NOT ignore REQUIRES REVIEW markers — they must be addressed before proceeding
