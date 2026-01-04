# Cancel Ralph Loop

Stop the currently running ralph loop.

## Usage

```
/ralph-win:cancel-ralph
```

## What It Does

Removes the ralph loop state file (`.claude/ralph-loop.local.md`), which:
- Stops the stop hook from blocking exit
- Allows Claude to exit normally
- Ends the iteration loop

## When to Use

- Loop is taking too long
- You want to change the prompt
- Claude is stuck in an unproductive pattern
- You need to work on something else

---

```! rm -f .claude/ralph-loop.local.md && echo "Ralph loop cancelled. Claude will exit normally now."
```
