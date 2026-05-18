---
name: legionforge-claude-obsidian
description: |
  Complete session context initialization system for Claude Code and Claude Desktop.
  Integrates Obsidian vault with Claude via hooks and MCP servers, providing three-layer
  context loading (Layer 0: automatic, Layer 1: on-demand via MCP, Layer 2: lessons).
  Supports setup, verification, and recovery across macOS, Linux, and Windows.

  Also use this skill when the user is unsure whether they already have a memory or
  second-brain system set up, wants to audit existing knowledge infrastructure before
  adding more, or needs to assess whether installing this system would conflict with or
  duplicate something already in place. The skill will discover what's installed,
  assess safety and redundancy, and only proceed with user confirmation.
license: MIT
metadata:
  author: jp-cruz
  version: "1.1.0"
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

**Before doing anything else, always run Phase 0 and Phase 0.5. Never assume the user is starting from scratch.**

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
- **You are unsure whether you already have a memory or second-brain system installed**
- **You want to audit your existing knowledge infrastructure before adding more**
- **You need to know if this system would conflict with or duplicate something already in place**

---

## The Setup Process

### Phase 0: Discover Existing Infrastructure (2 min)

**Run this phase every time, before asking the user any setup questions.**

The goal is to build a complete picture of what knowledge infrastructure already exists on this machine. Do not assume the user is starting from scratch—even if they say so.

#### 0a. Ask the user directly

Ask these questions in a single message (keep it brief):

```
Before we set anything up, I want to check what's already in place.

1. Do you have any memory or second-brain system currently set up for Claude?
   (Examples: Obsidian vault with Claude hooks, mem0, ob1, MemGPT, a
   custom CLAUDE.md with session injection, another vault tool, etc.)

2. Do you have any MCP servers configured for memory or knowledge retrieval?

3. Have you run any version of this skill (legionforge-claude-obsidian) before?

Answer with whatever you know — I'll also check your machine directly.
```

#### 0b. Search the machine for known indicators

Run these checks silently while waiting for the user's answer (or immediately if they say "go ahead"):

**Environment variables:**
```bash
echo $OBSIDIAN_VAULT_PATH
echo $MEM0_API_KEY
echo $OB1_VAULT_PATH
```

**Existing hook infrastructure:**
```bash
ls -la ~/.claude/hooks/ 2>/dev/null
cat ~/.claude/settings.json 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -A3 -B1 "SessionStart\|UserPromptSubmit\|memory\|obsidian\|inject"
```

**Existing MCP servers (Claude Code):**
```bash
cat ~/.claude/settings.json 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -A5 "mcpServers"
```

**Existing MCP servers (Claude Desktop — macOS):**
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -A5 "mcpServers"
```

**Existing MCP servers (Claude Desktop — Linux):**
```bash
cat ~/.config/claude/claude_desktop_config.json 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -A5 "mcpServers"
```

**Existing vault directories:**
```bash
find ~/Documents ~/Desktop ~/Dropbox ~/iCloud\ Drive 2>/dev/null -name ".obsidian" -maxdepth 3 -type d
find ~ -name "!startup.md" -maxdepth 6 2>/dev/null
find ~ -name "vault-directives.md" -maxdepth 6 2>/dev/null
find ~ -name "MEMORY.md" -maxdepth 6 2>/dev/null
```

**Other memory systems:**
```bash
pip show mem0ai 2>/dev/null | head -3
pip3 show mem0ai 2>/dev/null | head -3
find ~ -name "memgpt" -maxdepth 5 2>/dev/null | head -5
find ~ -name ".ob1" -maxdepth 4 2>/dev/null
find ~ -name "ob1-config*" -maxdepth 5 2>/dev/null
```

**CLAUDE.md files (session injection via project context):**
```bash
find ~ -name "CLAUDE.md" -maxdepth 5 2>/dev/null | head -10
cat ~/.claude/CLAUDE.md 2>/dev/null | head -30
```

#### 0c. Compile findings

Produce a structured inventory before continuing:

```
## Infrastructure Found

### This skill (legionforge-claude-obsidian)
- Vault: [path or "not found"]
- OBSIDIAN_VAULT_PATH: [value or "not set"]
- Hooks installed: [yes / partial / no]
  - session-startup.sh: [present / missing]
  - inject-layer0.py: [present / missing]
  - user-prompt-startup-guard.py: [present / missing]
- SessionStart hook configured: [yes / no]
- !startup.md / vault-directives.md: [present / missing]

### Other memory/second-brain systems
- MCP servers in config: [list names, e.g. "obsidian, ob1, mem0" or "none"]
- CLAUDE.md files: [paths or "none"]
- mem0 / MemGPT / ob1 / other: [found / not found + details]
- Other vault directories (not this skill): [list or "none"]

### Hooks (generic, not this skill)
- Existing SessionStart hooks: [list commands or "none"]
- Existing UserPromptSubmit hooks: [list commands or "none"]
```

---

### Phase 0.5: Safety and Redundancy Assessment (1 min)

**After compiling the inventory, assess the situation and present it to the user before proceeding. Let the user decide.**

#### Assessment categories

**Case A — Clean slate**
Nothing found. Safe to proceed with full setup.

```
✅ No existing memory infrastructure detected.
This machine appears to be a clean slate for knowledge tooling.
Safe to proceed with full setup.

Shall I continue? (yes / no)
```

**Case B — Partial install of this skill**
Some components of legionforge-claude-obsidian are present but incomplete or broken.

```
⚠️  Partial install detected.
Found: [list what was found]
Missing: [list what was missing]

This looks like a previous setup that may have been interrupted or partially uninstalled.

Options:
  1. Repair — reinstall missing components, keep existing vault and files
  2. Reset — back up existing files, reinstall everything fresh
  3. Doctor — diagnose and surface what's broken without changing anything

Which would you prefer? (repair / reset / doctor)
```

**Case C — Full install of this skill already present**
Everything appears to be installed and functional.

```
✅ legionforge-claude-obsidian appears to be fully installed.
Vault: [path]
Layer 0 files: present
Hooks: installed and configured
MCP servers: [status]

You likely don't need to run setup again.

Options:
  1. Verify — run the full verification protocol (Phase 5) to confirm everything works
  2. Doctor — diagnose if something stopped working
  3. Reinstall — back up and start fresh anyway (use this if things feel broken)

Which would you prefer? (verify / doctor / reinstall)
```

**Case D — Competing or overlapping system detected**
Another memory/second-brain system is present. This is the most important case to handle carefully.

```
⚠️  Existing knowledge infrastructure detected.

Found:
  [List each system found with brief description]
  Example:
  - ob1 MCP server configured (memory retrieval via ob1)
  - Custom CLAUDE.md at ~/.claude/CLAUDE.md with session injection
  - Another Obsidian vault at ~/Documents/MyVault/ (not this skill's vault)

Potential conflicts:
  [Describe specific risks, e.g.:]
  - Two SessionStart hooks that both inject memory could produce duplicate or conflicting context
  - A different Obsidian vault means you'd be managing two separate vaults for Claude
  - ob1 and this skill's Layer 1 MCP both provide memory retrieval — they overlap but don't conflict

My assessment:
  [One of:]
  - SAFE to add: These systems cover different concerns and won't interfere.
  - REDUNDANT: You already have [X] which does what this skill does. Installing this adds complexity without clear gain.
  - POTENTIALLY CONFLICTING: [Specific reason] — you should resolve this before proceeding.

Recommendation:
  [Concrete recommendation based on findings]

Do you want to proceed with setup, knowing this? Or would you prefer to:
  1. Proceed anyway (I've reviewed the risks and want this)
  2. Abort (don't change anything)
  3. Review what the conflict means in detail before deciding
```

**Case E — Unknown / ambiguous**
Evidence is mixed or unclear.

```
⚠️  I found some indicators but couldn't determine their status clearly.

Uncertain findings:
  [List what was found but couldn't be interpreted]

I recommend running doctor mode first to surface a clearer picture before making changes.

Options:
  1. Doctor mode — inspect without changing anything
  2. Proceed anyway — I know what I have
  3. Abort — don't touch anything
```

#### Assessment rules

- **Never proceed past Phase 0.5 without explicit user confirmation.**
- If the user says "just do it," treat that as Case A/B consent. Still surface what you found.
- If two SessionStart hooks both inject memory, flag this explicitly — it can cause doubled context or prompt bloat.
- ob1 and this skill's MCP are compatible but overlapping — note this but don't block.
- mem0 / MemGPT are architecturally different (cloud-backed, not file-based) — compatible, but note the design divergence.
- A `CLAUDE.md` doing simple session injection is compatible with Layer 0 hooks, but if it already injects vault content, that's redundant.

---

### Phase 1: Gather Information (2 min)

*Only run this after Phase 0 and Phase 0.5 are complete and the user has confirmed they want to proceed.*

Ask the user these questions (provide defaults, skip questions already answered by Phase 0 findings):

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

**If Phase 0.5 found existing hooks:** back up the existing hook configuration before modifying it. Offer to merge rather than overwrite.

### Phase 4: Install Hooks (2 min)

Create scripts in `~/.claude/hooks/`:
- `session-startup.sh`
- `inject-layer0.py`
- `user-prompt-startup-guard.py`

**Re-injection protection:** The startup guard must check whether Layer 0 has already been injected in this session before injecting again. This prevents duplicate context on subsequent prompts in the same session. The guard writes a session marker on first injection and reads it before each subsequent injection attempt — if the marker exists, it skips re-injection silently.

**If existing hooks were found in Phase 0:** back up the old scripts before replacing them. Store backups at `~/.claude/hooks/backup-<timestamp>/`.

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

**Date:** <timestamp>
**Installer:** legionforge-claude-obsidian v1.1.0
**Vault:** <vault_path>
**GitHub:** https://github.com/jp-cruz/agent-skills
**Status:** ✓ All checks passed
**Pre-existing infrastructure:** <summary from Phase 0 findings>
```

---

## Usage Examples

### First-Time Setup

```
User: "I want to set up Claude Code with Obsidian"

Skill: [Phase 0 — scans machine, finds nothing]
       [Phase 0.5 — Case A: clean slate, confirms with user]
       [Phases 1–6 — full setup]

Result: User has fully functional three-layer context loading
```

### Infrastructure Audit Before Setup

```
User: "I'm not sure if I already have a second brain set up"

Skill: [Phase 0 — scans machine, finds ob1 MCP and a CLAUDE.md]
       [Phase 0.5 — Case D: surfaces findings, assesses overlap, lets user decide]
       [User: "I'll keep ob1 but also want this"]
       [Phases 1–6 — proceeds with awareness of overlap]

Result: User understands what they have, makes an informed choice
```

### Partial Install / Repair

```
User: "Something seems half-set-up from before"

Skill: [Phase 0 — finds vault and OBSIDIAN_VAULT_PATH but hooks are missing]
       [Phase 0.5 — Case B: partial install, offers repair/reset/doctor]
       [User: "repair"]
       [Phases 4–6 — reinstalls missing hooks only]

Result: Existing vault preserved, gaps filled
```

### Repair / Doctor Mode

```
User: "Layer 0 isn't loading"

Skill: [Phase 0 — finds full install]
       [Phase 0.5 — Case C: full install, offers verify/doctor/reinstall]
       [User: "doctor"]
       [Detects problem]
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

Skill: [Phase 0 — scans each platform for existing infrastructure]
       [Phase 0.5 — assesses each platform independently]
       [Phases 1–6 — platform-specific guidance per OS]
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
           └─ Checks session marker — if already injected, skip
           └─ If first prompt: sends brief notice "Layer 0 injected. Layer 1 via MCP."
           └─ Writes session marker to prevent re-injection on subsequent prompts
```

**Re-injection protection detail:** The session marker is a lightweight flag (e.g., a temp file at `/tmp/.layer0-injected-<session-id>`) written after first injection. The guard reads this file before each injection attempt. If the file exists and belongs to the current session, injection is skipped. This prevents Layer 0 from being injected on every prompt — only on session start.

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
   - [ ] user-prompt-startup-guard.py contains re-injection guard logic

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

3. **Verify re-injection protection works**
   - "Send a second message in the same session."
   - "You should NOT see '[startup-guard] First prompt' again."
   - If you do see it again → the session marker is not being written or read correctly

4. **Fetch Layer 1 via MCP**
   - "Ask Claude: 'What does !checkpoint.md say?'"
   - If works → MCP is running, all good
   - If not → MCP optional, Layer 0 sufficient

5. **Verify project quickref**
   - "Create a test project file: `Library/AI/projects/test-quickref.md`"
   - "Ask Claude: 'What's in test-quickref.md?'"
   - If works → you can now fetch project state

6. **Test checkpoint workflow**
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

**Issue: "Layer 0 injecting on every prompt, not just session start"**
```bash
# The re-injection guard is not working. Check:
cat ~/.claude/hooks/user-prompt-startup-guard.py | grep -A5 "session"

# Look for the session marker file
ls /tmp/.layer0-injected-* 2>/dev/null

# If marker file is never written, the guard script needs to be reinstalled (Phase 4)
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

**Issue: "I already have another memory system and things feel doubled"**
```bash
# Re-run Phase 0 to get a fresh inventory
# Check: are two SessionStart hooks both injecting memory?
cat ~/.claude/settings.json | python3 -m json.tool | grep -A10 "SessionStart"
# If two hooks are running, you'll need to pick one or merge them
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

### Integration with Other Memory Systems

If Phase 0.5 found another memory system (ob1, mem0, MemGPT, CLAUDE.md injection, etc.):

- **ob1**: Compatible. ob1 and Layer 1 MCP overlap in function but do not conflict. The user can use both or choose one. Note that using both means Claude has two retrieval paths for memory — this is fine but slightly redundant for Layer 1 retrieval.
- **mem0 / MemGPT**: Compatible. These are cloud-backed; this skill is file-based. They serve different use cases. No hook conflicts unless mem0 also installs a SessionStart hook (check with Phase 0).
- **Existing CLAUDE.md with session injection**: Check what it injects. If it's already injecting vault content, merging it with Layer 0 hooks may create duplicate context. Best practice: move that injection into the Layer 0 hook system and simplify CLAUDE.md to references only.
- **Another Obsidian vault**: If the user has a separate Obsidian vault not managed by this skill, they'll need to decide whether to consolidate or maintain separate vaults. Dual vaults with separate `OBSIDIAN_VAULT_PATH` settings are technically possible but add cognitive overhead.

### Multiple Machines

If the user has multiple machines and wants to sync via Obsidian Sync or iCloud:

1. Set up vault on Machine A (this skill)
2. Set up Obsidian Sync
3. On Machine B:
   - Install Obsidian and sync the vault
   - Run this skill again with same OBSIDIAN_VAULT_PATH
   - **Run Phase 0 on Machine B** — it may have different existing infrastructure
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
/legionforge-claude-obsidian audit       ← NEW: run Phase 0 + 0.5 only, no changes
/legionforge-claude-obsidian help
```

### Required Tools

- Read/Write file system (to create vault and configs)
- Execute shell (bash/zsh/powershell to run setup scripts)
- Optionally: run Python scripts
- Optional: git operations

### Decision Tree

```
User triggers skill
  ↓
Phase 0: Scan machine for existing infrastructure
  ↓
Phase 0.5: Assess findings
  ├─ Case A (clean slate)       → Confirm → Phases 1–6 (full setup)
  ├─ Case B (partial install)   → Confirm mode → repair / reset / doctor
  ├─ Case C (full install)      → Confirm mode → verify / doctor / reinstall
  ├─ Case D (competing system)  → Surface risks → user decides → proceed or abort
  └─ Case E (ambiguous)         → Doctor mode recommended → user decides
```

### Testing the Implementation

To verify the skill works:

1. Create a test vault at `~/test-vault/`
2. Run setup with minimal answers
3. Verify all files are created
4. Check that configs are valid JSON
5. Manually verify hooks execute without error
6. Confirm Layer 0 files are readable
7. **Confirm re-injection guard works**: send two prompts in same session, verify Layer 0 only injects on first

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
