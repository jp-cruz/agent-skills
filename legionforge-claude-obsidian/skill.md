---
name: legionforge-claude-obsidian
description: |
  Complete session context initialization system for Claude Code and Claude Desktop.
  Integrates Obsidian vault with Claude via hooks and MCP servers, providing three-layer
  context loading (Layer 0: automatic, Layer 1: on-demand via MCP, Layer 2: lessons).
  Supports setup, verification, and recovery across macOS, Linux, and Windows.
license: MIT
metadata:
  author: jp-cruz
  version: "1.0.0"
  status: "production"
  platforms:
    - macos
    - linux
    - windows
  requirements:
    - obsidian (optional, but recommended)
    - git (recommended)
    - node (for MCP servers)
    - python3 (for hooks)
    - bash or powershell
  compatibility:
    - claude-code
    - claude-desktop
    - claude-chat
    - claude-dispatch
    - claude-cowork
---

# LegionForge Claude + Obsidian Setup

You are a setup wizard helping users establish a provider-independent session context system for AI-assisted development. Your goal is to get the user from "nothing" to "fully working three-layer context loading" in 20–30 minutes, with clear diagnostics if anything fails.

---

## Overview

This is not just an Obsidian sync setup. This is a **crash-safe, provider-independent knowledge management system** where:

- **Layer 0** (critical): Automatically loads at session start (what you're working on, your rules)
- **Layer 1** (on-demand): Available via MCP when the agent needs project state
- **Layer 2** (selective): Lessons and reference materials loaded based on project domain

The system survives Claude outages, cross-platform switches, and session crashes via checkpoint discipline.

---

## When to Use This Skill

Use this skill when:
- Setting up Claude Code for the first time and want integrated Obsidian context
- Moving Claude projects to a new machine
- Diagnosing why Layer 0 isn't loading (recovery/doctor mode)
- Verifying MCP servers and hooks are working
- Creating a vault for another team member or AI user

---

## The Setup Process

### Phase 1: Gather Information (2 min)

Ask the user these questions (provide defaults):

```
1. Where should your vault live?
   Default: ~/Documents/
   Answer: <VAULT_PATH>

2. What is your username on this machine?
   Default: (auto-detect from whoami)
   Answer: <USERNAME>

3. What are your absolute rules for this vault?
   Examples:
   - "Archive, never delete"
   - "Always checkpoint on test pass/fail"
   - "New memory = save immediately"
   Answer: <RULES>

4. What domains will you work in?
   Examples: rust, python, javascript, devops, ml
   Answer: <DOMAIN1>, <DOMAIN2>, ...

5. What Claude products do you use?
   □ Claude Code
   □ Claude Desktop
   □ Claude Dispatch
   □ Claude Cowork
   □ All of the above
   Answer: <SELECTION>

6. Initialize this as a git repo?
   □ Yes, new local repo
   □ Yes, push to GitHub (provide URL)
   □ No, local only
   Answer: <CHOICE>
```

### Phase 2: Create Vault Structure (3 min)

Based on answers, create:

```
<VAULT_PATH>/
├── .obsidian/
├── Library/AI/
│   ├── memory/
│   │   ├── !startup.md
│   │   ├── !checkpoint.md
│   │   ├── vault-directives.md
│   │   ├── user-profile.md
│   │   ├── MEMORY.md
│   │   └── lessons/
│   │       ├── lessons-index.md
│   │       └── lessons-<domain>.md (for each domain)
│   ├── projects/
│   │   └── .gitkeep
│   └── Sessions/
│       └── .gitkeep
```

### Phase 3: Configure Claude (5 min)

Update or create:
- `~/.claude/settings.json` (Claude Code)
- `~/Library/Application Support/Claude/claude_desktop_config.json` (Claude Desktop)

Configure:
- Hooks (SessionStart, UserPromptSubmit)
- MCP servers (obsidian, optional ob1)
- Permissions

### Phase 4: Install Hooks (2 min)

Create scripts in `~/.claude/hooks/`:
- `session-startup.sh`
- `inject-layer0.py`
- `user-prompt-startup-guard.py`

### Phase 5: Verify Setup (5 min)

Run tests:
- Check environment variables
- Verify vault structure
- Test hook execution
- Validate JSON configs
- Test MCP connectivity
- Interactive walkthrough

### Phase 6: Create Installation Record (1 min)

Write to vault (timestamp, version, location):
```markdown
# Installation Record

**Date:** 2026-05-15 12:30:45
**Installer:** legionforge-claude-obsidian v1.0.0
**Vault:** ~/Documents/my-vault/
**GitHub:** https://github.com/jp-cruz/agent-skills
**Status:** ✓ All checks passed
```

---

## Usage Examples

### First-Time Setup

```
User: "I want to set up Claude Code with Obsidian"

Skill: [Runs Phase 1–6 above, asks questions, creates files, verifies]

Result: User has fully functional three-layer context loading
```

### Repair / Doctor Mode

```
User: "Layer 0 isn't loading"

Skill: [Detects problem]
- OBSIDIAN_VAULT_PATH not set? → Guide user to set it
- Hooks missing? → Reinstall them
- vault-directives.md not in vault? → Recreate it
- MCP not running? → Note it's optional, suggest fallback
- !startup.md out of date? → Show what's stale

Result: User understands the problem and can fix it
```

### Cross-Platform Setup

```
User: "I work on macOS, Windows, and Linux"

Skill: [Offers platform-specific guidance for each]
- macOS: launchd service manager
- Linux: systemd service manager
- Windows: PowerShell execution policy, environment variables

Result: User can set up identically on all three OS
```

---

## Technical Details

### Environment Variables

The system relies on one key variable:

```bash
export OBSIDIAN_VAULT_PATH="/Users/<USERNAME>/Documents/my-vault"
```

Set this in:
- `~/.zshrc` or `~/.bashrc` (macOS/Linux)
- PowerShell `$PROFILE` (Windows)

### Hook Execution Flow

```
Session Start
  ├─ SessionStart hook
  │  └─ Calls: bash ~/.claude/hooks/session-startup.sh
  │     └─ Calls: python3 ~/.claude/hooks/inject-layer0.py
  │        └─ Loads vault-directives.md, !startup.md, user-profile.md
  │           └─ Injects into system message (Layer 0)
  │
  └─ User's first prompt
     └─ UserPromptSubmit hook
        └─ Calls: python3 ~/.claude/hooks/user-prompt-startup-guard.py
           └─ Sends brief notice: "Layer 0 injected. Layer 1 via MCP."
```

### MCP Server Configuration

Both Claude Code and Claude Desktop can connect to Obsidian MCP:

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote@^0.1.16",
        "http://localhost:22360/sse"
      ]
    }
  }
}
```

This requires the Obsidian MCP server running on localhost:22360. It's optional—the vault still works without it (just slower when fetching Layer 1).

---

## Verification & Diagnostics

### Automated Checks

The skill runs these checks and reports which passed/failed:

1. **Environment**
   - [ ] OBSIDIAN_VAULT_PATH is set
   - [ ] Vault directory exists
   - [ ] vault-directives.md is present

2. **Claude Code Config**
   - [ ] ~/.claude/settings.json exists and is valid JSON
   - [ ] SessionStart hook is configured
   - [ ] UserPromptSubmit hook is configured

3. **Claude Desktop Config**
   - [ ] claude_desktop_config.json exists (macOS/Linux)
   - [ ] MCP servers configured
   - [ ] Trusted folders include vault path

4. **Hooks & Scripts**
   - [ ] ~/.claude/hooks/ directory exists
   - [ ] session-startup.sh is executable
   - [ ] inject-layer0.py is executable
   - [ ] user-prompt-startup-guard.py is executable

5. **Vault Structure**
   - [ ] Library/AI/memory/ exists
   - [ ] Library/AI/projects/ exists
   - [ ] Library/AI/Sessions/ exists
   - [ ] !startup.md exists
   - [ ] !checkpoint.md exists
   - [ ] vault-directives.md exists

6. **Connectivity**
   - [ ] MCP server responding (if configured)
   - [ ] Git initialized (if requested)

### Interactive Walkthrough

After checks, the skill walks the user through:

1. **Start a Claude Code session**
   - "Do you have Claude Code open now? If not, start it."

2. **Check Layer 0 loaded**
   - "Send any message. Do you see '[startup-guard] First prompt' in the context?"
   - If no → troubleshoot hook execution

3. **Fetch Layer 1 via MCP**
   - "Ask Claude: 'What does !checkpoint.md say?'"
   - If works → MCP is running, all good
   - If not → MCP optional, Layer 0 sufficient

4. **Verify project quickref**
   - "Create a test project file: `Library/AI/projects/test-quickref.md`"
   - "Ask Claude: 'What's in test-quickref.md?'"
   - If works → you can now fetch project state

5. **Test checkpoint workflow**
   - "Now, go make a small edit to !startup.md"
   - "Start a new Claude Code session"
   - "Check if your edit was loaded automatically"
   - If works → checkpoint system is live

---

## Recovery & Troubleshooting

### Common Issues & Fixes

**Issue: "OBSIDIAN_VAULT_PATH is not set"**
```bash
# Check if it's set
echo $OBSIDIAN_VAULT_PATH

# If empty, add to shell profile
echo 'export OBSIDIAN_VAULT_PATH="/Users/<USERNAME>/Documents/my-vault"' >> ~/.zshrc
source ~/.zshrc
```

**Issue: "vault-directives.md not found"**
```bash
# The file should exist at: $OBSIDIAN_VAULT_PATH/Library/AI/memory/vault-directives.md
ls -la "$OBSIDIAN_VAULT_PATH/Library/AI/memory/vault-directives.md"

# If missing, reinstall (see Phase 2 above)
```

**Issue: "Layer 0 not loading"**
```bash
# Check if hook is executing
bash ~/.claude/hooks/session-startup.sh

# Check for error messages
python3 ~/.claude/hooks/inject-layer0.py

# If stuck, trace manually:
ls -la ~/.claude/hooks/
cat ~/.claude/settings.json | grep -A5 "SessionStart"
```

**Issue: "MCP server not responding"**
```bash
# Check if Obsidian MCP is running (depends on your setup)
# This is expected to fail if not configured—Layer 0 still works

# Verify MCP server manually:
curl -s http://localhost:22360/sse | head -1
# If no response, MCP server isn't running (that's OK)
```

**Issue: "Hooks missing or not executable"**
```bash
# Check permissions
ls -l ~/.claude/hooks/

# Make executable
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/hooks/*.py
```

**Issue: "git remote not set up"**
```bash
# If you want to sync to GitHub later:
cd "$OBSIDIAN_VAULT_PATH"
git remote add origin https://github.com/<USERNAME>/<REPO>.git
git branch -M main
git push -u origin main
```

### Doctor Mode (Auto-Recovery)

If the user says "Something's broken, fix it," the skill enters doctor mode:

1. **Diagnose**: Run all checks (see "Automated Checks" above)
2. **Identify**: Report which checks failed
3. **Suggest**: Offer specific fixes for each failure
4. **Backup**: Before making changes, ask user to keep or overwrite backups
5. **Repair**: Execute fixes (reinstall hooks, update configs, etc.)
6. **Re-verify**: Run checks again

Example:
```
User: "Layer 0 isn't loading"

Skill: 
  ✗ Failed: OBSIDIAN_VAULT_PATH not set
  ✗ Failed: vault-directives.md not found
  ✓ Passed: ~/.claude/settings.json valid

Suggestions:
  1. Set OBSIDIAN_VAULT_PATH in ~/.zshrc (or ~/.bashrc)
  2. Reinstall vault structure
  3. Restart Claude Code

Do you want me to do this?
```

---

## Advanced Features

### Integration with Existing Vaults

If the user already has an Obsidian vault:

1. Ask: "Do you want to integrate Claude into your existing vault, or create a new one?"
2. If existing:
   - Backup first (git commit)
   - Add `Library/AI/` structure to existing vault
   - Migrate existing session files if present
   - Verify no conflicts

### Multiple Machines

If the user has multiple machines and wants to sync via Obsidian Sync or iCloud:

1. Set up vault on Machine A (this skill)
2. Set up Obsidian Sync
3. On Machine B:
   - Install Obsidian and sync the vault
   - Run this skill again with same OBSIDIAN_VAULT_PATH
   - Configs are per-machine (~/.claude/), but vault is shared

### Team Vaults

If multiple users/agents share a vault:

1. Use vault-directives.md for shared rules
2. Each person gets their own `<USERNAME>-profile.md`
3. Use `Library/AI/Sessions/session-<YYYY-MM-DD>-<USERNAME>.md` for per-user sessions

---

## Security & Best Practices

### What NOT to Store in Vault

- ❌ API keys, tokens, passwords
- ❌ SSH keys or key paths
- ❌ Proprietary or confidential data
- ❌ PII (personally identifiable information)

### Pre-Commit Checks

Before committing vault to git:

```bash
cd "$OBSIDIAN_VAULT_PATH"
git diff --staged | grep -E "api[_-]?key|token|secret|password" && {
  echo "⚠️  Found potential secrets in diff!"
  git reset
} || echo "✓ No secrets detected"
```

### Permissions

Set appropriate permissions:

```bash
# User-only access
chmod 700 "$OBSIDIAN_VAULT_PATH"

# If on shared machine, be selective about what's world-readable
chmod 600 "$OBSIDIAN_VAULT_PATH/Library/AI/memory"/*
```

---

## Implementation Notes for AI Agents

### Entry Points

This skill can be invoked as:

```
/legionforge-claude-obsidian setup
/legionforge-claude-obsidian verify
/legionforge-claude-obsidian doctor
/legionforge-claude-obsidian help
```

### Required Tools

- Read/Write file system (to create vault and configs)
- Execute shell (bash/zsh/powershell to run setup scripts)
- Optionally: run Python scripts
- Optional: git operations

### Decision Tree

```
User: "I want to set up Claude + Obsidian"
  ↓
Skill: Are you setting up for the first time, or fixing an existing setup?
  ├─ First time → Run Phase 1–6 (full setup)
  ├─ Fixing → Run Phase 5–6 (doctor mode)
  └─ Verify only → Run Phase 5 (checks)
```

### Testing the Implementation

To verify the skill works:

1. Create a test vault at `~/test-vault/`
2. Run setup with minimal answers
3. Verify all files are created
4. Check that configs are valid JSON
5. Manually verify hooks execute without error
6. Confirm Layer 0 files are readable

---

## Next Steps

After setup, guide the user to:

1. **Create their first project**: `Library/AI/projects/my-project-quickref.md`
2. **Update !checkpoint.md**: Add the project to the checkpoint
3. **Write first lesson**: `Library/AI/memory/lessons/lessons-<domain>.md`
4. **Commit to git** (if initialized): `git add -A && git commit -m "Initial vault setup"`
5. **Start using Claude Code**: New session should load Layer 0 automatically

---

## Support

If the user hits a wall:

- Check **Troubleshooting** section above
- Run **Doctor Mode** to auto-diagnose
- Provide **Installation Record** (when did this break? what changed?)
- Offer to **back up and reset** if needed

Remember: This system is designed to be resilient. If something breaks, there's always a safe way to recover without losing data.
