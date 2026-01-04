#!/usr/bin/env bash
# Ralph-Win Setup Script - Windows-compatible fork
# Sets up the ralph loop state file with configuration

set -euo pipefail

# ============================================================================
# WINDOWS FIX: Add common jq installation paths to PATH
# ============================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# ============================================================================
# Configuration
# ============================================================================
RALPH_STATE_FILE=".claude/ralph-loop.local.md"

# ============================================================================
# Usage
# ============================================================================
usage() {
    cat << EOF
Usage: $(basename "$0") <prompt> [options]

Start a Ralph loop with the given prompt.

Options:
    --completion-promise <text>   Text pattern that signals completion (inside <promise></promise> tags)
    --max-iterations <n>          Maximum number of iterations (default: unlimited)
    -h, --help                    Show this help message

Examples:
    $(basename "$0") "Implement feature X" --max-iterations 20
    $(basename "$0") "Build API" --completion-promise "DONE" --max-iterations 50

Note: The completion promise uses exact string matching within <promise></promise> tags.
Always set --max-iterations as a safety net.
EOF
    exit 1
}

# ============================================================================
# Parse Arguments
# ============================================================================
PROMPT=""
COMPLETION_PROMISE=""
MAX_ITERATIONS=""

# Parse positional and optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --completion-promise)
            if [[ $# -lt 2 ]]; then
                echo "Error: --completion-promise requires a value" >&2
                exit 1
            fi
            COMPLETION_PROMISE="$2"
            shift 2
            ;;
        --max-iterations)
            if [[ $# -lt 2 ]]; then
                echo "Error: --max-iterations requires a value" >&2
                exit 1
            fi
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            usage
            ;;
        *)
            if [ -z "$PROMPT" ]; then
                PROMPT="$1"
            else
                # Append to prompt (handles multi-word prompts)
                PROMPT="$PROMPT $1"
            fi
            shift
            ;;
    esac
done

# Validate prompt
if [ -z "$PROMPT" ]; then
    echo "Error: Prompt is required" >&2
    usage
fi

# ============================================================================
# Create State File
# ============================================================================
create_state_file() {
    local dir
    dir=$(dirname "$RALPH_STATE_FILE")
    
    # Create directory if needed
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
    
    # Generate state file content
    cat > "$RALPH_STATE_FILE" << EOF
# Ralph Loop State

**Status:** Active
**Started:** $(date -Iseconds 2>/dev/null || date)
**Prompt:** $PROMPT
**Completion Promise:** ${COMPLETION_PROMISE:-none}
**Max Iterations:** ${MAX_ITERATIONS:-unlimited}
**Current Iteration:** 0

---

## Configuration

This file tracks the ralph loop state. Delete this file to stop the loop.

- The stop hook checks for this file to determine if a loop is active
- Each iteration increments the counter
- Loop ends when:
  - Max iterations reached
  - Completion promise found in Claude's response
  - This file is deleted (via /cancel-ralph or manually)
EOF

    echo "Ralph loop initialized!"
    echo ""
    echo "Configuration:"
    echo "  Prompt: $PROMPT"
    echo "  Completion Promise: ${COMPLETION_PROMISE:-none}"
    echo "  Max Iterations: ${MAX_ITERATIONS:-unlimited}"
    echo ""
    echo "To cancel the loop, run: /ralph-win:cancel-ralph"
    echo "Or delete: $RALPH_STATE_FILE"
}

# ============================================================================
# Main
# ============================================================================

# Check if loop already active
if [ -f "$RALPH_STATE_FILE" ]; then
    echo "Warning: A ralph loop is already active!" >&2
    echo "Current state file: $RALPH_STATE_FILE" >&2
    echo "" >&2
    echo "To start a new loop, first cancel the existing one:" >&2
    echo "  /ralph-win:cancel-ralph" >&2
    echo "" >&2
    echo "Or delete the state file manually:" >&2
    echo "  rm $RALPH_STATE_FILE" >&2
    exit 1
fi

create_state_file
