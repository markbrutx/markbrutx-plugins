# Ralph-Win

🪟 **Windows-compatible fork of [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)**

Interactive self-referential AI loops for iterative development. Claude works on the same task repeatedly, seeing its previous work, until completion.

## Why This Fork?

The original `ralph-wiggum` plugin has [known issues on Windows](https://github.com/anthropics/claude-code/issues/14817):

| Issue | Original | Ralph-Win Fix |
|-------|----------|---------------|
| `jq: command not found` | jq not in PATH | Adds `$HOME/bin` and common paths to PATH |
| Git Bash vs WSL conflict | `/bin/bash` may resolve to WSL | Uses portable `#!/usr/bin/env bash` |
| Path handling | Windows paths fail | Handles both Unix and Windows paths |
| Missing dependency docs | No jq requirement listed | Clear error messages with install instructions |

## Requirements

### jq (JSON processor)

The plugin requires `jq`. Install it:

**Option 1: Manual (recommended for Git Bash)**
```bash
mkdir -p ~/bin
curl -L -o ~/bin/jq.exe "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe"
chmod +x ~/bin/jq.exe
```

**Option 2: Chocolatey**
```powershell
choco install jq
```

**Option 3: Scoop**
```powershell
scoop install jq
```

**Option 4: WSL**
```bash
sudo apt install jq
```

## Installation

### Option 1: Local Installation (for testing)

1. Clone or download this plugin to a local directory
2. In Claude Code, run:
```
/plugin install --plugin-dir /path/to/ralph-win
```

### Option 2: From Your Own Marketplace

1. Fork this repo or create your own marketplace
2. Add to `.claude-plugin/marketplace.json`:
```json
{
  "plugins": [
    {
      "name": "ralph-win",
      "description": "Windows-compatible ralph loops",
      "version": "1.0.0",
      "source": "./ralph-win"
    }
  ]
}
```
3. Add marketplace: `/plugin marketplace add your-username/your-repo`
4. Install: `/plugin install ralph-win@your-marketplace`

## Usage

### Start a Loop

```
/ralph-win:ralph-loop "Your task description" --max-iterations 20
```

### With Completion Promise

```
/ralph-win:ralph-loop "Build feature X. Output <promise>DONE</promise> when complete." --completion-promise "DONE" --max-iterations 30
```

### Cancel a Loop

```
/ralph-win:cancel-ralph
```

## How It Works

```
┌─────────────────────────────────────────────────────┐
│  You run ONCE:                                      │
│  /ralph-win:ralph-loop "Task" --max-iterations 20   │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  Claude works on the task                           │
│  - Writes code                                      │
│  - Runs tests                                       │
│  - Fixes bugs                                       │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  Claude tries to exit                               │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  Stop hook intercepts:                              │
│  - Checks for completion promise                    │
│  - Checks iteration count                           │
│  - If not done: blocks exit, re-injects prompt      │
└─────────────────────────────────────────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
    ┌─────────────────┐   ┌─────────────────┐
    │ Continue loop   │   │ Allow exit      │
    │ (go back to     │   │ (task complete  │
    │  Claude works)  │   │  or max iters)  │
    └─────────────────┘   └─────────────────┘
```

## Best Practices

1. **Always set `--max-iterations`** - Prevents infinite loops and runaway costs
2. **Be specific** - Clear success criteria help Claude converge faster
3. **Include stuck handling** in your prompt:
   ```
   After 15 iterations, if not complete:
   - Document what's blocking progress
   - List what was attempted
   - Suggest alternative approaches
   ```
4. **Use completion promises** for precise endpoints

## Files

```
ralph-win/
├── .claude-plugin/
│   └── plugin.json        # Plugin metadata
├── commands/
│   ├── ralph-loop.md      # /ralph-win:ralph-loop command
│   └── cancel-ralph.md    # /ralph-win:cancel-ralph command
├── hooks/
│   ├── hooks.json         # Hook configuration
│   └── stop-hook.sh       # Stop hook (with Windows fixes)
├── scripts/
│   └── setup-ralph-loop.sh # Loop setup script
└── README.md
```

## Troubleshooting

### "jq: command not found"

Install jq (see Requirements above) and ensure it's in your PATH:
```bash
# Add to ~/.bashrc or ~/.bash_profile
export PATH="$HOME/bin:$PATH"
```

### Loop not stopping

1. Check `.claude/ralph-loop.local.md` exists
2. Run `/ralph-win:cancel-ralph`
3. Or manually: `rm .claude/ralph-loop.local.md`

### Hook not triggering

1. Restart Claude Code after installing the plugin
2. Check `/plugin list` shows ralph-win as enabled
3. Verify hooks/hooks.json syntax

## Credits

- Original technique: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Original plugin: [Anthropic](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- Windows fixes: Based on [Issue #14817](https://github.com/anthropics/claude-code/issues/14817)

## License

MIT - Same as original ralph-wiggum
