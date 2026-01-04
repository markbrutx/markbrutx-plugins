# markbrutx-plugins

Personal Claude Code plugin marketplace with Windows-compatible forks and custom plugins.

## 🚀 Installation

```bash
# Add the marketplace
/plugin marketplace add markbrutx/markbrutx-plugins

# Install plugins
/plugin install ralph-win@markbrutx-plugins
```

## 📦 Available Plugins

### ralph-win
Windows-compatible fork of [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum).

**Fixes:**
- ✅ `jq: command not found` — adds `$HOME/bin` to PATH
- ✅ Git Bash compatibility
- ✅ Proper Windows path handling
- ✅ Clear dependency documentation

**Commands:**
- `/ralph-win:ralph-loop` — Start autonomous iteration loop
- `/ralph-win:cancel-ralph` — Cancel running loop

**Usage:**
```bash
/ralph-win:ralph-loop "Build feature X" --max-iterations 20
```

## 📋 Requirements

### jq (for ralph-win)

**Git Bash (Windows):**
```bash
mkdir -p ~/bin
curl -L -o ~/bin/jq.exe "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe"
chmod +x ~/bin/jq.exe
```

**Or:** `choco install jq` / `scoop install jq`

## 🔄 Updates

```bash
/plugin marketplace update markbrutx-plugins
```

## 📄 License

MIT
