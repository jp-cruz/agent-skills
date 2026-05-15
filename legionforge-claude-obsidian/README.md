# LegionForge Claude + Obsidian

**Complete session context initialization system for Claude Code and Claude Desktop.**

Integrates your Obsidian vault with Claude via hooks and MCP servers, providing three-layer context loading (Layer 0: automatic, Layer 1: on-demand via MCP, Layer 2: lessons). Supports setup, verification, and recovery across macOS, Linux, and Windows.

---

## What This Does

When you use Claude Code, your vault context is automatically loaded at session start:

1. **Layer 0** (automatic): What you're working on, your rules, your profile
2. **Layer 1** (on-demand): Project state, checkpoints, detailed notes (via MCP)
3. **Layer 2** (selective): Domain-specific lessons loaded based on your project

This means Claude understands your context immediately—no manual "here's my situation" every session.

---

## Quick Start

### Installation

```bash
# Option 1: Using npx (recommended)
npx skills@latest add jp-cruz/agent-skills/legionforge-claude-obsidian

# Option 2: Manual
git clone https://github.com/jp-cruz/agent-skills.git
cd agent-skills/agent-skills/legionforge-claude-obsidian
python3 scripts/setup.py
```

### Run Setup

```bash
python3 scripts/setup.py
```

The setup wizard will:
1. Ask you questions (where's your vault? what domains do you work in?)
2. Create vault structure
3. Configure Claude Code and Desktop
4. Install hook scripts
5. Run verification tests
6. Create an installation record

**Time: ~10 minutes** (mostly automated)

### Verify It Works

```bash
bash scripts/verify.sh
```

Then:
1. Start Claude Code (new session)
2. Send any message
3. Look for `[startup-guard] First prompt` in the context
4. Your vault is now integrated!

---

## Architecture

### Folder Structure

```
<vault>/
├── .obsidian/
├── Library/AI/
│   ├── memory/
│   │   ├── !startup.md              ← What you're working on now
│   │   ├── !checkpoint.md           ← Project state snapshot
│   │   ├── vault-directives.md      ← Your rules
│   │   ├── user-profile.md          ← About you
│   │   ├── MEMORY.md                ← Index
│   │   └── lessons/
│   │       ├── lessons-index.md     ← Which lessons apply
│   │       └── lessons-<domain>.md  ← e.g., lessons-rust
│   ├── projects/
│   │   └── <project>-quickref.md   ← Per-project state
│   └── Sessions/
│       └── session-<date>.md        ← What happened today
```

### Boot Sequence

```
Claude Code starts
  ↓
SessionStart hook executes
  ├─ Reads OBSIDIAN_VAULT_PATH
  ├─ Calls inject-layer0.py
  └─ Loads vault-directives.md, !startup.md, user-profile.md
     → Injects into system message (Layer 0)
  ↓
User sends first message
  ↓
UserPromptSubmit hook executes
  └─ Sends notice: "Layer 0 injected. Layer 1 available via MCP."
     → Claude now knows it can ask for detailed state
```

### Three-Layer Context Model

| Layer | What | Loaded When | Example |
|-------|------|------------|---------|
| **0** | Critical: what you're doing, rules | Session start (automatic) | `!startup.md`: "working on Rust API, deadline Friday" |
| **1** | On-demand: project state, notes | When agent requests via MCP | `!checkpoint.md`: test status, blockers, commit history |
| **2** | Selective: lessons by domain | Matched to project tags | `lessons-rust.md`: async patterns, error handling |

Why three layers?
- **Layer 0** prevents context bloat (always loaded, always fresh)
- **Layer 1** available instantly when needed (no delay waiting for full vault)
- **Layer 2** prevents irrelevant info (Rust lessons won't load for Python projects)

---

## Usage

### First Session

```bash
# 1. Run setup
python3 scripts/setup.py

# 2. Source your shell profile
source ~/.zshrc

# 3. Start Claude Code
# New session will automatically load Layer 0
```

### Using Your Vault

**Update !startup.md** when you start new work:
```markdown
**Status:** Working on Rust async API refactor
**Next:** Finish handler tests, then benchmark
**Blocker:** MCP server timeout on Windows (investigating)
```

**Create project quickref**:
```markdown
# my-project

**Domains:** rust, async
**Status:** In progress
**Test Status:** 12/15 passing
**Blockers:** Memory leak in cache layer
```

**Write lessons** for future reference:
```markdown
# Lessons — Rust

**Learned:** Always use `tokio::spawn` for CPU-bound tasks in web handler
**Why:** Prevents blocking event loop
**Lesson ID:** rust-spawn-cpu-tasks
```

### Recovery / Doctor Mode

If something breaks:

```bash
python3 scripts/recovery.py
```

The doctor will:
1. Diagnose what's wrong
2. Suggest fixes
3. Offer to apply them automatically

---

## Features

### ✅ Provider Independent

Works with any AI provider (Claude, Ollama, ChatGPT, etc.). The vault follows open standards, not Claude-specific syntax.

### ✅ Cross-Platform

Supports macOS, Linux, and Windows. Platform-specific paths and shell profiles handled automatically.

### ✅ Crash-Safe

Sessions die. Vaults survive. By checkpointing on completion (not at session end), your context survives unexpected shutdowns.

### ✅ Selective Loading

Only load what you need. Rust lessons won't load for Python projects. Database notes won't appear in frontend work.

### ✅ MCP Integration

Optional Obsidian MCP server for real-time access to vault (fetch notes while Claude is working). Gracefully degrades if MCP unavailable.

### ✅ Git-Ready

Vault can be synced via git, iCloud, or Obsidian Sync. Works across multiple machines.

---

## Configuration

### Environment Variables

```bash
export OBSIDIAN_VAULT_PATH="/Users/<username>/Documents/my-vault"
```

Add to `~/.zshrc`, `~/.bashrc`, or PowerShell `$PROFILE`.

### Claude Code Settings

Located at: `~/.claude/settings.json`

The setup wizard configures:
- Session start hooks
- MCP servers
- File permissions
- Model preferences

### Hook Scripts

Located at: `~/.claude/hooks/`

Three scripts:
1. `session-startup.sh` — Runs at session start
2. `inject-layer0.py` — Loads vault files into context
3. `user-prompt-startup-guard.py` — Notifies on first prompt

---

## Troubleshooting

### Layer 0 Not Loading

```bash
# Check environment variable
echo $OBSIDIAN_VAULT_PATH

# Check hooks are set up
ls -la ~/.claude/hooks/

# Manually test
bash ~/.claude/hooks/session-startup.sh
```

### MCP Server Not Connecting

This is **optional**. Layer 0 still works without it. If you want MCP:
- Ensure Obsidian MCP server running on localhost:22360
- Check `~/.claude/settings.json` for MCP configuration

### Vault Files Missing

```bash
# Reinstall
python3 scripts/recovery.py
```

---

## Performance Notes

- **Layer 0** injection adds ~50–100ms to session startup
- **Layer 1** MCP calls are on-demand (no delay unless you ask Claude to fetch)
- **Layer 2** lessons are selective (minimal overhead)

Total impact: **negligible** for typical workflows.

---

## Security

⚠️ **Do not store in vault:**
- API keys, tokens, passwords
- SSH keys or private paths
- PII or proprietary data

✅ **Safe to store:**
- Architecture decisions
- Lessons learned
- Session notes
- Project status and blockers

Pre-commit check:
```bash
git diff --staged | grep -E "api_key|token|secret|password" && echo "⚠️ Secrets detected!"
```

---

## Next Steps

1. **Run setup**: `python3 scripts/setup.py`
2. **Source shell**: `source ~/.zshrc`
3. **Create first project**: `Library/AI/projects/my-project-quickref.md`
4. **Write first lesson**: `Library/AI/memory/lessons/lessons-python.md`
5. **Commit to git**: `git add -A && git commit -m "Initial vault setup"`
6. **Start using Claude**: New session loads context automatically

---

## Architecture & Design Decisions

See [ARCHITECTURE.md](./ARCHITECTURE.md) for deep dives on:
- Why three layers instead of one monolithic context
- Checkpoint strategy (why "on completion" not "on end")
- Provider independence design
- Multi-machine sync considerations

---

## Support

- **Setup questions?** Run: `python3 scripts/setup.py`
- **Something broken?** Run: `python3 scripts/recovery.py`
- **Want to verify?** Run: `bash scripts/verify.sh`
- **Need help?** See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed guides

---

## License

MIT — see LICENSE file

## Author

JP Cruz (@jp-cruz) — LegionForge GitHub organization

---

## Feedback & Contributions

This is a curated skill. I don't accept pull requests, but issues and suggestions are welcome:
https://github.com/jp-cruz/agent-skills/issues

---

**Ready to get started? Run:**
```bash
python3 scripts/setup.py
```
