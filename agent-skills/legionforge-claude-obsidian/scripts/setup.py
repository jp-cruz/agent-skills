#!/usr/bin/env python3
"""
LegionForge Claude + Obsidian Setup Wizard
Comprehensive cross-platform installation for Claude Code + Obsidian integration.
Platforms: macOS, Linux, Windows
"""

import os
import sys
import json
import shutil
import subprocess
import platform
from pathlib import Path
from datetime import datetime

class SetupWizard:
    def __init__(self):
        self.username = os.getenv("USER", os.getenv("USERNAME", "user"))
        self.hostname = os.getenv("HOSTNAME", "machine")
        self.os_type = platform.system()  # Darwin, Linux, Windows
        self.home = str(Path.home())
        self.responses = {}

    def print_header(self, text):
        print(f"\n{'='*60}")
        print(f"  {text}")
        print(f"{'='*60}\n")

    def print_step(self, num, text):
        print(f"\n[{num}] {text}")
        print("-" * 50)

    def ask(self, question, default=None, options=None):
        """Interactive prompt with optional default and predefined options."""
        if default:
            prompt = f"{question}\n    Default: {default}\n    > "
        else:
            prompt = f"{question}\n    > "

        if options:
            print(f"Options: {', '.join(options)}")

        while True:
            response = input(prompt).strip()
            if not response and default:
                return default
            if response:
                return response
            print("    Please enter a value.")

    def confirm(self, question):
        """Yes/no confirmation."""
        while True:
            response = input(f"{question} [y/n]: ").strip().lower()
            if response in ['y', 'yes']:
                return True
            if response in ['n', 'no']:
                return False
            print("    Please answer 'y' or 'n'.")

    def phase_1_gather_info(self):
        """Phase 1: Gather user information."""
        self.print_step(1, "Gather Information")

        # Q1: Vault location
        default_vault = os.path.expanduser("~/Documents/my-claude-vault")
        self.responses['vault_path'] = self.ask(
            "Where should your vault live?",
            default=default_vault
        )
        self.responses['vault_path'] = os.path.expanduser(self.responses['vault_path'])

        # Q2: Username
        self.responses['username'] = self.ask(
            "What is your username on this machine?",
            default=self.username
        )

        # Q3: Rules
        default_rules = "Archive never delete, checkpoint on test pass/fail/fix, new memory saves immediately"
        self.responses['rules'] = self.ask(
            "What are your absolute rules for this vault?",
            default=default_rules
        )

        # Q4: Domains
        default_domains = "python,javascript,devops"
        domains_input = self.ask(
            "What domains will you work in? (comma-separated)",
            default=default_domains
        )
        self.responses['domains'] = [d.strip() for d in domains_input.split(',')]

        # Q5: Claude products
        print("\nWhich Claude products do you use?")
        products = []
        if self.confirm("  Claude Code"):
            products.append("code")
        if self.confirm("  Claude Desktop"):
            products.append("desktop")
        if self.confirm("  Claude Dispatch"):
            products.append("dispatch")
        if self.confirm("  Claude Cowork"):
            products.append("cowork")
        if not products:
            products = ["code", "desktop"]
        self.responses['products'] = products

        # Q6: Git
        print("\nInitialize as git repository?")
        choice = self.ask(
            "Setup options",
            default="local"
        )
        if choice.lower().startswith("github"):
            self.responses['git_url'] = self.ask("GitHub repo URL:")
            self.responses['git_mode'] = "push"
        elif choice.lower().startswith("y"):
            self.responses['git_mode'] = "init"
        else:
            self.responses['git_mode'] = "none"

    def phase_2_create_vault(self):
        """Phase 2: Create vault structure."""
        self.print_step(2, "Create Vault Structure")

        vault = Path(self.responses['vault_path'])

        # Backup if exists
        if vault.exists():
            if self.confirm(f"{vault} already exists. Backup and overwrite?"):
                backup_path = f"{vault}.backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
                shutil.move(str(vault), backup_path)
                print(f"  ✓ Backed up to {backup_path}")
            else:
                print("  ⚠ Keeping existing vault. Skipping creation.")
                return

        # Create structure
        dirs = [
            vault / ".obsidian",
            vault / "Library/AI/memory/lessons",
            vault / "Library/AI/projects",
            vault / "Library/AI/Sessions",
        ]
        for d in dirs:
            d.mkdir(parents=True, exist_ok=True)

        print(f"  ✓ Created vault structure at {vault}")

        # Create .gitignore
        gitignore = vault / ".gitignore"
        gitignore_content = """.obsidian/
.DS_Store
*.swp
*.tmp
"""
        gitignore.write_text(gitignore_content)
        print("  ✓ Created .gitignore")

    def phase_3_create_memory_files(self):
        """Phase 3: Create core memory files."""
        self.print_step(3, "Create Memory Files")

        vault = Path(self.responses['vault_path'])
        memory = vault / "Library/AI/memory"

        # Helper to replace variables in templates
        def render_template(content):
            return content.format(
                USERNAME=self.responses['username'],
                HOSTNAME=self.hostname,
                VAULT_PATH=str(vault),
                RULES=self.responses['rules'],
                DOMAINS=', '.join(self.responses['domains']),
                TIMESTAMP=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            )

        # vault-directives.md
        vault_directives = f"""# Vault Directives

> Version: 1.0.0-{datetime.now().strftime('%Y%m%d%H%M%S')}

## Provider Independence

This vault is the source of truth for all AI-assisted work. Any AI provider (Claude, Ollama, ChatGPT, etc.) can use this system.

**Load order at session start:**
1. `Library/AI/memory/!startup.md` — current work
2. `Library/AI/memory/!checkpoint.md` — project state
3. `Library/AI/projects/<project>-quickref.md` — project specifics
4. `Library/AI/memory/lessons/lessons-index.md` — domain lessons

## User's Absolute Rules

{self.responses['rules']}

## Versioned Files

Files with `Version:` headers must have the version updated on every edit.
Format: `Version: a.b.c-yyyymmddhhmmss`
- a = major (user controls)
- b = minor (user controls)
- c = revision (increment on every edit)
- timestamp = when last edited
"""
        (memory / "vault-directives.md").write_text(vault_directives)
        print("  ✓ Created vault-directives.md")

        # !startup.md
        startup = f"""# !startup.md

> Version: 1.0.0-{datetime.now().strftime('%Y%m%d%H%M%S')}

**Installed:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Status:** Setup complete, vault initialized

## What's Next

1. Set OBSIDIAN_VAULT_PATH environment variable
2. Restart Claude Code
3. Verify Layer 0 loads (check first prompt)
4. Create your first project quickref
5. Configure MCP servers (if desired)

## Setup Details

- Vault: {self.responses['vault_path']}
- User: {self.responses['username']}
- Domains: {', '.join(self.responses['domains'])}
"""
        (memory / "!startup.md").write_text(startup)
        print("  ✓ Created !startup.md")

        # !checkpoint.md
        checkpoint = f"""# !checkpoint.md

> Version: 1.0.0-{datetime.now().strftime('%Y%m%d%H%M%S')}

**Last Updated:** {datetime.now().strftime('%Y-%m-%d')}

## Active Projects

(None yet — create your first with `Library/AI/projects/<project>-quickref.md`)

## Installation Status

- [x] Vault structure created
- [x] Memory files initialized
- [ ] Environment variables set
- [ ] Claude configs updated
- [ ] Verification tests passed
"""
        (memory / "!checkpoint.md").write_text(checkpoint)
        print("  ✓ Created !checkpoint.md")

        # MEMORY.md (index)
        memory_index = """# MEMORY Index

## Files

- [!startup.md](./!startup.md) — What you're working on now
- [!checkpoint.md](./!checkpoint.md) — Project state snapshot
- [vault-directives.md](./vault-directives.md) — Rules for this vault
- [user-profile.md](./user-profile.md) — About you
- [MEMORY.md](./MEMORY.md) — This index
- [lessons/](./lessons/) — Domain-specific lessons
"""
        (memory / "MEMORY.md").write_text(memory_index)
        print("  ✓ Created MEMORY.md (index)")

        # user-profile.md
        user_profile = f"""# {self.responses['username']} — User Profile

**Name:** {self.responses['username']}
**Machine:** {self.hostname}
**OS:** {self.os_type}
**Setup Date:** {datetime.now().strftime('%Y-%m-%d')}

## Domains

{', '.join(self.responses['domains'])}

## Environment

```
Vault: {self.responses['vault_path']}
OBSIDIAN_VAULT_PATH: (set below)
```

### Shell Profile

Add to `~/.zshrc`, `~/.bashrc`, or PowerShell `$PROFILE`:

```bash
export OBSIDIAN_VAULT_PATH="{self.responses['vault_path']}"
```
"""
        (memory / "user-profile.md").write_text(user_profile)
        print("  ✓ Created user-profile.md")

        # lessons-index.md
        lessons_index = f"""# Lessons Index

> Version: 1.0.0-{datetime.now().strftime('%Y%m%d%H%M%S')}

## Your Domains

```yaml
domains:
{chr(10).join(f'  - {d}' for d in self.responses['domains'])}
```

## Lesson Files

Create lessons for each domain:
- `lessons-{self.responses['domains'][0] if self.responses['domains'] else 'python'}.md`
- (Add more as needed)
"""
        (memory / "lessons/lessons-index.md").write_text(lessons_index)
        print("  ✓ Created lessons-index.md")

    def phase_4_configure_claude(self):
        """Phase 4: Configure Claude Code and Desktop."""
        self.print_step(4, "Configure Claude Code")

        vault = self.responses['vault_path']
        claude_dir = Path(self.home) / ".claude"
        claude_dir.mkdir(exist_ok=True)

        # Set environment variable
        shell_profile = None
        if self.os_type in ['Darwin', 'Linux']:
            shell_profile = Path(self.home) / ".zshrc"
            if not shell_profile.exists():
                shell_profile = Path(self.home) / ".bashrc"

        if shell_profile:
            env_line = f'export OBSIDIAN_VAULT_PATH="{vault}"\n'
            content = shell_profile.read_text()
            if "OBSIDIAN_VAULT_PATH" not in content:
                with open(shell_profile, 'a') as f:
                    f.write(env_line)
                print(f"  ✓ Added OBSIDIAN_VAULT_PATH to {shell_profile.name}")
            else:
                print(f"  ℹ OBSIDIAN_VAULT_PATH already in {shell_profile.name}")

        # Configure settings.json
        settings_path = claude_dir / "settings.json"
        if settings_path.exists():
            settings = json.loads(settings_path.read_text())
        else:
            settings = {"permissions": {"defaultMode": "bypassPermissions", "allow": []}}

        # Add vault paths to permissions
        vault_patterns = [
            f"Bash({vault}/**)",
            f"Read({vault}/**)",
            f"Write({vault}/**)",
            f"Edit({vault}/**)",
        ]
        for pattern in vault_patterns:
            if pattern not in settings.get("permissions", {}).get("allow", []):
                settings["permissions"]["allow"].append(pattern)

        # Configure hooks
        if "hooks" not in settings:
            settings["hooks"] = {}

        settings["hooks"]["SessionStart"] = [{
            "hooks": [{
                "type": "command",
                "command": f"bash {self.home}/.claude/hooks/session-startup.sh",
                "statusMessage": "Initializing session context..."
            }]
        }]

        settings["hooks"]["UserPromptSubmit"] = [{
            "hooks": [{
                "type": "command",
                "command": f"python3 {self.home}/.claude/hooks/user-prompt-startup-guard.py"
            }]
        }]

        # Configure MCP servers
        if "mcpServers" not in settings:
            settings["mcpServers"] = {}

        settings["mcpServers"]["obsidian"] = {
            "command": "npx",
            "args": ["-y", "mcp-remote@^0.1.16", "http://localhost:22360/sse"]
        }

        settings_path.write_text(json.dumps(settings, indent=2))
        print(f"  ✓ Updated {settings_path}")

    def phase_5_install_hooks(self):
        """Phase 5: Install hook scripts."""
        self.print_step(5, "Install Hooks")

        hooks_dir = Path(self.home) / ".claude/hooks"
        hooks_dir.mkdir(parents=True, exist_ok=True)

        vault = self.responses['vault_path']

        # session-startup.sh
        startup_sh = f"""#!/usr/bin/env bash
# SessionStart hook — runs at beginning of every Claude Code session
if [ -n "$OBSIDIAN_VAULT_PATH" ]; then
    python3 "{{HOME}}/.claude/hooks/inject-layer0.py"
    CLAUDE_SRC="{{HOME}}/.claude/CLAUDE.md"
    CLAUDE_DST="$OBSIDIAN_VAULT_PATH/Library/AI/claude-global.md"
    if [ -f "$CLAUDE_SRC" ]; then
        cp "$CLAUDE_SRC" "$CLAUDE_DST"
    fi
fi
"""
        (hooks_dir / "session-startup.sh").write_text(startup_sh)
        (hooks_dir / "session-startup.sh").chmod(0o755)
        print("  ✓ Created session-startup.sh")

        # inject-layer0.py
        inject_py = """#!/usr/bin/env python3
import os
import json
vault = os.environ.get("OBSIDIAN_VAULT_PATH", "")
if not vault:
    exit(0)
layer0_files = [
    f"{vault}/Library/AI/memory/vault-directives.md",
    f"{vault}/Library/AI/memory/!startup.md",
    f"{vault}/Library/AI/memory/user-profile.md",
]
content = {}
for filepath in layer0_files:
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            filename = os.path.basename(filepath)
            content[filename] = f.read()
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "systemMessage": {"role": "user", "content": f"=== Vault Context (Layer 0) ===\\n\\n{json.dumps(content, indent=2)}"}
    }
}))
"""
        (hooks_dir / "inject-layer0.py").write_text(inject_py)
        (hooks_dir / "inject-layer0.py").chmod(0o755)
        print("  ✓ Created inject-layer0.py")

        # user-prompt-startup-guard.py
        guard_py = """#!/usr/bin/env python3
import json
import os
import sys
import tempfile
ppid = os.getppid()
flag_file = os.path.join(tempfile.gettempdir(), f".claude-session-guard-{ppid}")
if os.path.exists(flag_file):
    sys.exit(0)
try:
    with open(flag_file, "w") as f:
        f.write("1")
except Exception:
    pass
vault = os.environ.get("OBSIDIAN_VAULT_PATH", "")
if not vault:
    sys.exit(0)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": "[startup-guard] First prompt. Layer 0 injected at SessionStart. Layer 1 available via MCP: !checkpoint.md, memory quickref."
    }
}))
"""
        (hooks_dir / "user-prompt-startup-guard.py").write_text(guard_py)
        (hooks_dir / "user-prompt-startup-guard.py").chmod(0o755)
        print("  ✓ Created user-prompt-startup-guard.py")

    def phase_6_verify(self):
        """Phase 6: Run verification."""
        self.print_step(6, "Verify Setup")

        vault = Path(self.responses['vault_path'])
        checks = {
            "OBSIDIAN_VAULT_PATH set": os.environ.get("OBSIDIAN_VAULT_PATH") is not None,
            "Vault directory exists": vault.exists(),
            "vault-directives.md exists": (vault / "Library/AI/memory/vault-directives.md").exists(),
            "!startup.md exists": (vault / "Library/AI/memory/!startup.md").exists(),
            "!checkpoint.md exists": (vault / "Library/AI/memory/!checkpoint.md").exists(),
            "Hooks directory exists": (Path(self.home) / ".claude/hooks").exists(),
            "settings.json valid": self._check_json(Path(self.home) / ".claude/settings.json"),
        }

        for check, passed in checks.items():
            status = "✓" if passed else "✗"
            print(f"  {status} {check}")

        all_passed = all(checks.values())
        return all_passed

    def _check_json(self, path):
        try:
            if path.exists():
                json.loads(path.read_text())
                return True
        except:
            pass
        return False

    def phase_7_record(self):
        """Phase 7: Create installation record."""
        self.print_step(7, "Create Installation Record")

        vault = Path(self.responses['vault_path'])
        record = f"""# Installation Record

**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Installer:** legionforge-claude-obsidian v1.0.0
**Vault:** {vault}
**User:** {self.responses['username']}
**Platform:** {self.os_type}

## Configuration

- Domains: {', '.join(self.responses['domains'])}
- Claude Products: {', '.join(self.responses['products'])}
- Git Mode: {self.responses['git_mode']}

## Next Steps

1. Source your shell profile: `source ~/.zshrc` (or ~/.bashrc)
2. Start Claude Code (new session)
3. Send a message and verify Layer 0 loads
4. Check for "[startup-guard] First prompt" in context
"""

        record_path = vault / "Library/AI/memory/INSTALLATION.md"
        record_path.write_text(record)
        print(f"  ✓ Created installation record at {record_path}")

    def run(self):
        """Run the full setup wizard."""
        self.print_header("LegionForge Claude + Obsidian Setup Wizard")

        try:
            self.phase_1_gather_info()
            self.phase_2_create_vault()
            self.phase_3_create_memory_files()
            self.phase_4_configure_claude()
            self.phase_5_install_hooks()
            all_passed = self.phase_6_verify()
            self.phase_7_record()

            self.print_header("Setup Complete!" if all_passed else "Setup Complete (with some checks failed)")
            print("""
Next Steps:
1. Reload your shell profile: source ~/.zshrc (or ~/.bashrc / PowerShell profile)
2. Start Claude Code (new session)
3. Send any message to verify Layer 0 loaded
4. You should see "[startup-guard] First prompt" in the context

Vault location: {vault}
Configuration: ~/.claude/settings.json
Hooks: ~/.claude/hooks/

For help, run: python3 scripts/recovery.py (doctor mode)
""".format(vault=self.responses['vault_path']))

        except Exception as e:
            print(f"\n❌ Error: {e}", file=sys.stderr)
            sys.exit(1)

if __name__ == "__main__":
    wizard = SetupWizard()
    wizard.run()
