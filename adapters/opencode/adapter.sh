#!/usr/bin/env bash
# adapter.sh - Adapter for opencode
# Generates opencode.json with MCPs, agents and permissions
#
# Called by sdd-init.sh with:
#   bash adapter.sh --org $ORG --project $PROJECT --ide-dir .opencode --script-dir $SCRIPT_DIR --pat64 $PAT64 --github-pat $GITHUB_PAT --stitch-key $STITCH_KEY

set -e

# --- Parse args ---
ORG=""
PROJECT=""
IDE_DIR=""
SCRIPT_DIR=""
PAT64=""
GITHUB_PAT=""
STITCH_KEY=""
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --org)        ORG="$2"; shift 2 ;;
    --project)    PROJECT="$2"; shift 2 ;;
    --ide-dir)    IDE_DIR="$2"; shift 2 ;;
    --script-dir) SCRIPT_DIR="$2"; shift 2 ;;
    --pat64)      PAT64="$2"; shift 2 ;;
    --github-pat) GITHUB_PAT="$2"; shift 2 ;;
    --stitch-key) STITCH_KEY="$2"; shift 2 ;;
    --force)      FORCE=true; shift ;;
    *) shift ;;
  esac
done

# --- Generate opencode.json ---
echo "   Generating opencode.json..."

PROJECT_ROOT="$(pwd)"

# Build azure-devops environment
ADO_ENV=""
if [ -n "$PAT64" ]; then
  ADO_ENV="\"PERSONAL_ACCESS_TOKEN\": \"$PAT64\","
fi

# Build github environment
GH_ENV=""
if [ -n "$GITHUB_PAT" ]; then
  GH_ENV="\"GITHUB_PERSONAL_ACCESS_TOKEN\": \"$GITHUB_PAT\","
fi

# Build stitch environment
STITCH_ENV=""
if [ -n "$STITCH_KEY" ]; then
  STITCH_ENV="\"STITCH_API_KEY\": \"$STITCH_KEY\","
fi

cat > opencode.json << OPENCODE_EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".opencode/rules/precheck.md",
    ".opencode/rules/tool-protocol.md",
    ".opencode/rules/protected-files.md",
    ".opencode/rules/token-optimization.md",
    ".opencode/rules/azure-devops-workflow.md",
    ".opencode/rules/git-conventions.md",
    ".opencode/rules/workflow-router.md",
    ".opencode/rules/spec-integration.md",
    ".opencode/rules/artifact-storage.md",
    ".opencode/rules/change-propagation.md",
    ".opencode/rules/spec-structure-gate.md"
  ],
  "skills": {
    "paths": [".opencode/skills"]
  },
  "mcp": {
    "azure-devops": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@azure-devops/mcp",
        "$ORG",
        "--authentication", "pat"
      ],
      "environment": {
        ${ADO_ENV}
        "AZURE_DEVOPS_DEFAULT_PROJECT": "$PROJECT"
      }
    },
    "sequential-thinking": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "context7": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@upstash/context7-mcp@latest"
      ]
    },
    "github": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@modelcontextprotocol/server-github"
      ],
      "environment": {
        ${GH_ENV}
        "_placeholder": ""
      }
    },
    "server-memory": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@modelcontextprotocol/server-memory"
      ],
      "environment": {
        "MEMORY_FILE_PATH": "$PROJECT_ROOT/.sdd-memory/memory.jsonl"
      }
    },
    "playwright": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@playwright/mcp@latest"
      ]
    },
    "stitch": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx", "-y", "@google/stitch-sdk"
      ],
      "environment": {
        ${STITCH_ENV}
        "_placeholder": ""
      }
    }
  },
  "agent": {
    "sdd-build": {
      "description": "SDD build - implementation with lifecycle gates and human approval",
      "mode": "primary",
      "prompt": "{file:.opencode/agents/sdd-build.md}",
      "permission": {
        "bash": {
          "git push": "ask",
          "*": "allow"
        }
      }
    },
    "sdd-plan": {
      "description": "SDD plan - read-only analysis, lifecycle, gate checking, next-step planning",
      "mode": "primary",
      "prompt": "{file:.opencode/agents/sdd-plan.md}",
      "permission": {
        "read": "allow",
        "glob": "allow",
        "grep": "allow",
        "bash": {
          "git status": "allow",
          "git log *": "allow",
          "git diff *": "allow",
          "git branch *": "allow",
          "git config *": "allow",
          "git remote *": "allow",
          "git show *": "allow",
          "*": "deny"
        },
        "edit": "deny"
      }
    }
  }
}
OPENCODE_EOF

# Clean up empty _placeholder entries
sed -i '/"_placeholder": ""/d' opencode.json 2>/dev/null || true
# Clean up trailing commas in environment objects
sed -i 's/,\s*}/}/g' opencode.json 2>/dev/null || true

echo "   OK opencode.json generated (7 MCPs + 2 agents)"
