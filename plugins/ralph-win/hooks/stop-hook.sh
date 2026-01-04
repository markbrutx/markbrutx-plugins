#!/usr/bin/env bash
# Ralph-Win Stop Hook - Windows-compatible fork of ralph-wiggum
# Fixes: jq PATH, Windows path handling, Git Bash compatibility
# Original: https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum

set -euo pipefail

# ============================================================================
# WINDOWS FIX: Add common jq installation paths to PATH
# ============================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Check for required dependencies
check_dependencies() {
    local missing=()
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required dependencies: ${missing[*]}" >&2
        echo "" >&2
        echo "To install jq on Windows (Git Bash):" >&2
        echo "  mkdir -p ~/bin" >&2
        echo "  curl -L -o ~/bin/jq.exe 'https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe'" >&2
        echo "  chmod +x ~/bin/jq.exe" >&2
        echo "" >&2
        echo "Or via chocolatey: choco install jq" >&2
        echo "Or via scoop: scoop install jq" >&2
        exit 1
    fi
}

check_dependencies

# ============================================================================
# Configuration
# ============================================================================
RALPH_STATE_FILE=".claude/ralph-loop.local.md"

# ============================================================================
# Helper Functions
# ============================================================================

# Get the state file path (create .claude dir if needed)
get_state_file() {
    local dir
    dir=$(dirname "$RALPH_STATE_FILE")
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
    echo "$RALPH_STATE_FILE"
}

# Check if ralph loop is active
is_ralph_active() {
    local state_file
    state_file=$(get_state_file)
    [ -f "$state_file" ]
}

# Read ralph state from file
read_ralph_state() {
    local state_file
    state_file=$(get_state_file)
    if [ -f "$state_file" ]; then
        cat "$state_file"
    fi
}

# Parse field from ralph state (markdown format)
get_state_field() {
    local field="$1"
    local state
    state=$(read_ralph_state)
    echo "$state" | grep -E "^\*\*${field}:\*\*" | sed "s/^\*\*${field}:\*\* //" || true
}

# Increment iteration counter
increment_iteration() {
    local state_file
    state_file=$(get_state_file)
    local current
    current=$(get_state_field "Current Iteration")
    local new_iteration=$((current + 1))
    
    # Update the state file with new iteration count
    if [ -f "$state_file" ]; then
        # Use sed to replace the iteration line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^\*\*Current Iteration:\*\* [0-9]*$/\*\*Current Iteration:\*\* $new_iteration/" "$state_file"
        else
            sed -i "s/^\*\*Current Iteration:\*\* [0-9]*$/\*\*Current Iteration:\*\* $new_iteration/" "$state_file"
        fi
    fi
    
    echo "$new_iteration"
}

# ============================================================================
# Main Stop Hook Logic
# ============================================================================

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)
    
    # Parse input with jq
    local transcript_path
    transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty')
    
    # Check if ralph loop is active
    if ! is_ralph_active; then
        # No ralph loop active, allow normal exit
        echo '{"decision": "approve", "reason": "No ralph loop active"}'
        exit 0
    fi
    
    # Get ralph state
    local prompt
    prompt=$(get_state_field "Prompt")
    local completion_promise
    completion_promise=$(get_state_field "Completion Promise")
    local max_iterations
    max_iterations=$(get_state_field "Max Iterations")
    local current_iteration
    current_iteration=$(get_state_field "Current Iteration")
    
    # Check if we should stop due to max iterations
    if [ -n "$max_iterations" ] && [ "$current_iteration" -ge "$max_iterations" ]; then
        # Remove state file to end the loop
        rm -f "$(get_state_file)"
        echo '{"decision": "approve", "reason": "Max iterations reached ('$max_iterations')"}'
        exit 0
    fi
    
    # Check transcript for completion promise if provided
    if [ -n "$completion_promise" ] && [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        # Read transcript and check for completion promise in last assistant message
        local last_message
        last_message=$(jq -r '.messages | map(select(.role == "assistant")) | last | .content // empty' "$transcript_path" 2>/dev/null || true)
        
        if [ -n "$last_message" ]; then
            # Check for promise pattern: <promise>COMPLETION_TEXT</promise>
            if echo "$last_message" | grep -q "<promise>.*${completion_promise}.*</promise>"; then
                # Completion promise found, end the loop
                rm -f "$(get_state_file)"
                echo '{"decision": "approve", "reason": "Completion promise found: '"$completion_promise"'"}'
                exit 0
            fi
        fi
    fi
    
    # Increment iteration
    local new_iteration
    new_iteration=$(increment_iteration)
    
    # Block exit and re-inject the prompt
    local response
    response=$(jq -n \
        --arg reason "Ralph loop iteration $new_iteration/$max_iterations" \
        --arg prompt "$prompt" \
        '{
            "decision": "block",
            "reason": $reason,
            "stopReason": ("Ralph loop continuing (iteration " + ($prompt | @json) + ")"),
            "hookSpecificOutput": {
                "hookEventName": "Stop",
                "additionalContext": ("Continue working on the task. This is iteration " + ($prompt | tostring) + ". Original prompt: " + $prompt)
            }
        }'
    )
    
    # Simplified response for re-injection
    echo "{\"decision\": \"block\", \"reason\": \"Ralph loop iteration $new_iteration${max_iterations:+/$max_iterations}\", \"systemMessage\": \"[RALPH LOOP - Iteration $new_iteration${max_iterations:+/$max_iterations}] Continue working on the task. Original prompt: $prompt\"}"
    exit 2
}

main "$@"
