# Ralph Loop Command

Start an autonomous iteration loop that continues until completion criteria are met.

## Usage

```
/ralph-win:ralph-loop "<prompt>" [--completion-promise "<text>"] [--max-iterations <n>]
```

## How It Works

1. You run this command ONCE with your task description
2. Claude works on the task
3. When Claude tries to exit, the Stop hook intercepts
4. The hook re-injects your original prompt
5. Claude continues working
6. Repeat until completion criteria met

## Arguments

- `<prompt>`: Your task description (required)
- `--completion-promise <text>`: Text pattern that signals completion. Must appear inside `<promise></promise>` tags in Claude's response
- `--max-iterations <n>`: Safety limit on iterations (highly recommended!)

## Examples

### Basic loop with iteration limit
```
/ralph-win:ralph-loop "Implement user authentication with tests" --max-iterations 20
```

### With completion promise
```
/ralph-win:ralph-loop "Build a REST API. Output <promise>COMPLETE</promise> when done." --completion-promise "COMPLETE" --max-iterations 30
```

### Multi-phase project
```
/ralph-win:ralph-loop "Phase 1: Setup database schema. Phase 2: Build API endpoints. Phase 3: Add tests. Output <promise>ALL_PHASES_DONE</promise> when complete." --completion-promise "ALL_PHASES_DONE" --max-iterations 50
```

## Best Practices

1. **Always set --max-iterations** - Prevents infinite loops
2. **Be specific in your prompt** - Clear success criteria help Claude converge
3. **Include stuck handling** - Add instructions like "After 10 iterations, if blocked, document what's wrong"
4. **Use completion promise for precise endpoints** - `<promise>DONE</promise>` is cleaner than relying on iteration count

## Stopping the Loop

- Use `/ralph-win:cancel-ralph` to stop
- Or delete `.claude/ralph-loop.local.md` manually

---

```! "${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" "$ARGUMENTS"
```
