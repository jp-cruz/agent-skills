# Architecture & Design Decisions

## Overview

This document explains *why* the system is designed this way, not just *what* it does. It's for:
- Future developers maintaining this skill
- Users customizing the setup for their team
- AI agents implementing similar systems
- Anyone wanting to understand the tradeoffs

---

## The Three-Layer Model

### Why Three Layers, Not One?

**Naive approach:** Load entire vault into every session.

**Problem:**
- 50MB vault → 100KB of noise in context for a simple task
- Slow startup (parse entire vault every session)
- Confusing (Claude sees projects you're not working on)
- Breaks on token limits (context window exhausted by metadata)

**Three-layer solution:**

```
Layer 0: Auto-loaded at session start
├─ Tiny (5–10KB): only current work + rules
└─ Fresh: loaded every session

Layer 1: Available on-demand via MCP
├─ Medium (20–50KB): project state, notes
└─ Fetched: only when agent asks for it

Layer 2: Selective by domain
├─ Varies (10–100KB per domain)
└─ Loaded: only if project tags match
```

**Benefit:** Context stays small while information stays available.

### Layer 0: Automatic Context

**What:** Always loaded at session start

**Contents:**
- `!startup.md` — What were you last working on? What's next?
- `vault-directives.md` — Rules all AI providers must follow
- `user-profile.md` — Who is this person? Their setup, skills, preferences
- `claude-global.md` (optional) — Claude-specific rules

**Why this set?**
- `!startup.md` answers "what's my context right now?" (critical for session orientation)
- `vault-directives.md` ensures any AI provider understands your rules (provider independence)
- `user-profile.md` tells Claude about you (skills, role, preferences)

**Why auto-loaded?**
- Can't rely on the agent to ask for context manually
- Humans forget to paste context, agents sometimes ignore instructions to fetch
- Every session deserves this baseline

**Overhead:** ~50–100ms injection + file reads. Negligible.

### Layer 1: On-Demand State

**What:** Available via MCP, fetched when agent requests

**Contents:**
- `!checkpoint.md` — State of all projects (tests passing? blockers?)
- `<project>-quickref.md` — This specific project's status
- Project notes, architecture decisions
- Any large reference material

**Why on-demand?**
- Don't need project X state when working on project Y
- Can be updated continuously (checkpoint during work)
- Agent fetches only what it needs
- Scales to many projects without bloat

**How it works:**
1. Claude reads Layer 0 (`!checkpoint.md` exists, but might be old)
2. Claude asks: "What's the current status of ProjectX?"
3. MCP fetches from vault and returns fresh data
4. Claude uses that data for decisions

**Why MCP?**
- Standard protocol (works with any AI provider that supports MCP)
- Real-time (fetch always gets latest vault state)
- Optional graceful degradation (if MCP down, Layer 0 still sufficient)

### Layer 2: Selective Lessons

**What:** Lessons loaded based on project domain tags

**Contents:**
- `lessons-<domain>.md` — Best practices for that domain
- `lessons-rust.md`, `lessons-python.md`, `lessons-async.md`, etc.

**Selection mechanism:**
1. Project's `!checkpoint.md` declares domains: `domains: [rust, async]`
2. Agent loads `lessons-index.md` asking "what lessons apply?"
3. Answer: "load lessons-rust.md and lessons-async.md"
4. Agent loads only those files

**Why selective?**
- Rust lessons meaningless for Python work (waste of context)
- Web dev lessons don't apply to firmware projects
- Scales to 100+ lessons without ever loading them all

**Why lessons at all?**
- Captures institutional knowledge ("we learned X the hard way")
- Prevents repeating mistakes (learned = cached)
- Better than GitHub README (structured, searchable, domain-indexed)

---

## Checkpoint Strategy

### The Problem with "Checkpoint at Session End"

Sessions die. They crash, time out, get killed by system shutdown. A "write at end of session" strategy doesn't survive.

**Bad:** "I'll write a checkpoint when I'm done"
- Session crashes at 95% → checkpoint never written
- Context lost, next session starts cold

### Solution: "Checkpoint on Completion"

**Rule:** Checkpoint immediately when any meaningful state changes:
- ✅ Test passes/fails → update test status in quickref
- ✅ Bug fixed → update !startup.md with "fixed X"
- ✅ Feature complete → update !checkpoint.md
- ✅ Design decision made → write it to project-notes.md

**Why this survives crashes:**
- Last checkpoint written 5 minutes ago? Safe.
- Crash happens now? Last checkpoint still there.
- Next session reads checkpoint and continues from there.

**In practice:**
```
9:00 AM  — Start session, read Layer 0 (checkpoint from yesterday)
9:15 AM  — Fix bug #42. Write checkpoint immediately: "bug #42 fixed"
9:30 AM  — Tests pass. Write checkpoint: "tests 12/15 passing"
9:45 AM  — System crashes
10:00 AM — Start new session, read Layer 0
          → Sees: "bug #42 fixed, tests 12/15 passing"
          → Continues from correct context
```

**No data lost because checkpoints are written continuously, not at the end.**

---

## Provider Independence

### The Real Problem

Claude outages happen. Ollama sometimes better for local work. You might switch providers mid-project.

If your vault is Claude-specific (`!startup.md` says "use Claude API for embeddings"), then:
- Can't use Ollama when Claude is down
- Can't use ChatGPT for a task (reads "this is Claude-only")
- Locked in to one provider

### Solution: Vault is Provider-Agnostic

**Rule:** `vault-directives.md` must be readable and actionable by ANY provider.

**Do:**
- "Archive, never delete"
- "Test locally with qwen2.5 before shipping"
- "Always checkpoint on test pass"
- "Domains: rust, async, systems"

**Don't:**
- "Use Claude's function calling" (Claude-specific)
- "Fetch from Claude API" (Anthropic-specific)
- "Run with GPT-4" (OpenAI-specific)

**Consequence:**
- Same vault works with Claude, Ollama, ChatGPT, local models
- Can switch providers without vault changes
- Reduces vendor lock-in

**For Claude-only rules:** Put them in `~/.claude/CLAUDE.md` (Claude-only config), not vault.

---

## Cross-Platform Design

### Challenge

Paths, shells, environment variables differ:
- macOS: `/Users/jp/...`, `~/.zshrc`
- Linux: `/home/jp/...`, `~/.bashrc`
- Windows: `C:\Users\jp\...`, PowerShell profile

### Solution

**Vault paths:** Use `$OBSIDIAN_VAULT_PATH` environment variable.
- Set once per OS, works everywhere after that
- Handles Obsidian Sync changing vault name (just update env var)

**Shell profiles:** Scripts detect which shell and update the right file.

**Config paths:** `~/.claude/` works on all three (Unix-like convention on Windows too).

**File operations:** Python for portability (no bash-only features).

**MCP servers:** HTTP-based (localhost:22360), works same on all platforms.

---

## Design Tradeoffs

### Tradeoff 1: Many Files vs. Monolithic File

**Choice:** Many small files (`!startup.md`, `!checkpoint.md`, `lessons-rust.md`)

**Why?**
- ✅ Can update one without rewriting entire vault
- ✅ Selective loading (just read needed files)
- ✅ Easier merging if synced across machines
- ✅ Natural organization (Rails app state separate from Python lessons)

**Cost:**
- ❌ More files to manage
- ❌ Slightly slower startup (read multiple files vs. one)

**Verdict:** Trade slight overhead for huge flexibility gain.

### Tradeoff 2: Hooks vs. Manual Context Pasting

**Choice:** Hooks (SessionStart, UserPromptSubmit)

**Why?**
- ✅ Automatic (users don't forget)
- ✅ Consistent (same context every session)
- ✅ Testable (hooks can be verified to execute)

**Cost:**
- ❌ Requires Claude Code hook support
- ❌ Fails silently if hook misconfigured
- ❌ One less thing in user's direct control

**Verdict:** Automation > manual work, even with risk of silent failures.

### Tradeoff 3: Environment Variable vs. Auto-Detection

**Choice:** User sets `OBSIDIAN_VAULT_PATH` environment variable

**Why?**
- ✅ Explicit (no magic, user controls)
- ✅ Works on all platforms (same mechanism)
- ✅ Survives moving vault (just update env var)

**Cost:**
- ❌ Extra setup step
- ❌ Can be forgotten (breaks silently)

**Alternative:** Scan `~/Documents/` for `.obsidian/` directories
- ✓ Simpler for users
- ✗ Fails if multiple vaults
- ✗ Fails if vault on external drive
- ✗ Doesn't work after Obsidian Sync renames vault

**Verdict:** Explicit > magic, even if one more setup step.

### Tradeoff 4: MCP Optional vs. Required

**Choice:** MCP is optional (Layer 0 sufficient without it)

**Why?**
- ✅ Works offline (no server needed)
- ✅ Works if MCP breaks (doesn't block)
- ✅ Supports environments without Node/npm

**Cost:**
- ❌ Layer 1 unavailable (must fetch manually or wait for next session)
- ❌ Slightly less seamless experience

**Verdict:** Robustness > perfect experience.

---

## Implementation Notes

### Why Python for Setup, Not Shell?

- Portable (works on Windows, macOS, Linux without WSL)
- Readable (imperative, not cryptic bash)
- Auditable (easier to review security, no pipe chains)
- JSON/file manipulation (built-in libraries)

### Why Hook Scripts in Both Python and Bash?

- `session-startup.sh` (bash) — needs to be shell-independent, fast
- `inject-layer0.py` (Python) — complex JSON/file operations
- Hybrid approach: bash calls Python, Python handles complexity

### Why No Database?

- Git-friendly (diffs are readable)
- Sync-friendly (Obsidian Sync, iCloud, Google Drive)
- Mergeable (plain-text files conflict cleanly)
- Portable (no SQLite dependency)
- Auditable (see history in git blame)

---

## Future Improvements

### 1. Dependency Declaration (Not Yet Implemented)

**Idea:** Each project declares which lesson domains it needs

```markdown
# my-project

domains:
  - rust
  - async-programming
  - systems
  - performance
```

**Mechanism:**
- Agent reads `domains:` field
- Automatically loads matching `lessons-<domain>.md`
- No manual selection needed

**Why not done:**
- Requires agent to understand domain matching
- Not essential (manual selection works fine)
- Can add later without breaking existing setups

### 2. Checkpoint Automation (Not Yet Implemented)

**Idea:** Auto-checkpoint on git commit, test completion, etc.

**Mechanism:**
- Git hook: `post-commit` → auto-update checkpoint with commit message
- Test hook: `post-test` → update test status
- Timer: Checkpoint every 30 minutes if any files changed

**Why not done:**
- Risk of noisy updates (checkpoint should be human-decided)
- Requires robust change detection
- Current manual approach is actually good (forces review)

### 3. Hierarchical Rules (Not Yet Implemented)

**Idea:** Project rules inherit from/override vault rules

```
vault-directives.md (global)
  ↓
project/CLAUDE.md (project-specific)
  ↓ (merged)
Effective rules for this project
```

**Why not done:**
- Currently simple (one set of rules)
- Multi-project teams would benefit, but niche use case
- Can add without breaking existing setups

### 4. Lessons Decay (Not Yet Implemented)

**Idea:** Mark lessons with "valid until 2026-06-01", auto-archive after

```markdown
# Lesson — Fix for Postgres Bug #12345

Valid until: 2026-06-01 (after we upgrade to 15.1)
Status: Will be obsolete once upgraded
```

**Why not done:**
- Rarely needed (lessons are usually permanent)
- Can use tags/archives instead
- Added complexity for niche use

### 5. Team Vaults (Not Yet Implemented)

**Idea:** Multiple users/agents sharing same vault with per-user sessions

```
Library/AI/Sessions/
├── session-2026-05-15-alice.md
├── session-2026-05-15-bob.md
└── session-2026-05-15-claude.md
```

**Why not done:**
- Currently single-user focused
- Teams would need consensus on rules
- Git merging team sessions would be messy
- Can add after proven in single-user context

---

## Security Considerations

### What's Safe

✅ Architecture decisions (public, not sensitive)
✅ Lessons learned (public knowledge)
✅ Test status, blockers (internal, but not credentials)
✅ Project names, domain tags (organizational metadata)

### What's Not Safe

❌ API keys, tokens, passwords (ever)
❌ SSH key paths, private URLs (infrastructure details)
❌ Internal IP addresses, hostnames (network topology)
❌ Proprietary data, PII, PHI, financial info (regulated)

### Pre-Commit Hook (Optional)

Prevent accidental commits of secrets:

```bash
git diff --staged | grep -E "api_key|secret|token|password" && {
  echo "Detected potential secret. Aborting commit."
  exit 1
}
```

---

## Testing Strategy

### Automated Tests (Setup Script)

1. **Environment:** OBSIDIAN_VAULT_PATH is set
2. **Structure:** Required directories exist
3. **Files:** Memory files readable and valid (markdown/JSON)
4. **Configs:** settings.json is valid JSON
5. **Hooks:** Scripts are executable
6. **Connectivity:** MCP server responds (if configured)

### Manual Verification (Walk-Through)

1. Start Claude Code session
2. Verify `[startup-guard] First prompt` appears
3. Ask Claude to summarize `!startup.md` (tests Layer 0 injection)
4. Ask Claude to summarize `!checkpoint.md` (tests Layer 1/MCP)
5. Create test project quickref, ask Claude about it (tests MCP access)

### Regression Test (After Changes)

- Modify `!startup.md`
- Restart Claude Code
- Verify new content is loaded (not cached)

---

## Metrics & Observability

### What We Don't Track

- No telemetry
- No phone-home
- No analytics

### How to Debug

- Check log of hook execution: `bash ~/.claude/hooks/session-startup.sh`
- Check environment: `echo $OBSIDIAN_VAULT_PATH`
- Check configs: `cat ~/.claude/settings.json`
- Run doctor: `python3 scripts/recovery.py`

---

## Conclusion

This system trades **simplicity for robustness**:
- Simple parts: vault structure (just markdown files)
- Robust parts: hook execution, error handling, recovery

It prioritizes:
1. **Provider independence** (works with any AI engine)
2. **Crash safety** (survives session failures)
3. **Scalability** (works with 1 project or 100)
4. **Auditability** (everything is plain text, git-tracked)

Result: A setup that just works, and keeps working even when things break.
