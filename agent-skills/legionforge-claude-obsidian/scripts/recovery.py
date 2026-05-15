#!/usr/bin/env python3
"""
recovery.py — Doctor mode / Auto-recovery
Diagnoses issues and suggests fixes
"""

import os
import sys
import json
import subprocess
from pathlib import Path

class Doctor:
    def __init__(self):
        self.username = os.getenv("USER", os.getenv("USERNAME", "user"))
        self.home = str(Path.home())
        self.vault = os.environ.get("OBSIDIAN_VAULT_PATH")
        self.issues = []
        self.fixes = []

    def print_header(self, text):
        print(f"\n{'='*60}")
        print(f"  {text}")
        print(f"{'='*60}\n")

    def diagnose(self):
        """Run all diagnostic checks."""
        self.print_header("Diagnosing Setup")

        # Check 1: OBSIDIAN_VAULT_PATH
        if not self.vault:
            self.issues.append({
                "name": "OBSIDIAN_VAULT_PATH not set",
                "severity": "critical",
                "fix": self._fix_env_var
            })
            return  # Can't continue without this

        # Check 2: Vault exists
        if not Path(self.vault).exists():
            self.issues.append({
                "name": f"Vault not found at {self.vault}",
                "severity": "critical",
                "fix": lambda: self._fix_vault_path()
            })
            return

        # Check 3: Memory files
        vault_path = Path(self.vault)
        memory_files = [
            "Library/AI/memory/vault-directives.md",
            "Library/AI/memory/!startup.md",
            "Library/AI/memory/!checkpoint.md",
        ]
        for f in memory_files:
            full_path = vault_path / f
            if not full_path.exists():
                self.issues.append({
                    "name": f"Missing: {f}",
                    "severity": "major",
                    "fix": lambda fp=f: self._fix_missing_file(fp)
                })

        # Check 4: Hooks
        hooks_dir = Path(self.home) / ".claude/hooks"
        hook_files = [
            "session-startup.sh",
            "inject-layer0.py",
            "user-prompt-startup-guard.py"
        ]
        for hook in hook_files:
            hook_path = hooks_dir / hook
            if not hook_path.exists():
                self.issues.append({
                    "name": f"Missing hook: {hook}",
                    "severity": "major",
                    "fix": lambda h=hook: print(f"  ⚠ Need to reinstall {h}")
                })
            elif not os.access(hook_path, os.X_OK):
                self.issues.append({
                    "name": f"Hook not executable: {hook}",
                    "severity": "major",
                    "fix": lambda h=hook_path: os.chmod(h, 0o755)
                })

        # Check 5: settings.json
        settings_path = Path(self.home) / ".claude/settings.json"
        if not settings_path.exists():
            self.issues.append({
                "name": "~/.claude/settings.json not found",
                "severity": "critical",
                "fix": lambda: print("  Run setup.py to recreate")
            })
        else:
            try:
                json.loads(settings_path.read_text())
            except:
                self.issues.append({
                    "name": "settings.json is invalid JSON",
                    "severity": "critical",
                    "fix": lambda: print("  ⚠ Please fix JSON syntax in settings.json")
                })

        # Print findings
        if not self.issues:
            print("✓ No issues found. Your setup looks good!")
            return

        print(f"Found {len(self.issues)} issue(s):\n")
        for i, issue in enumerate(self.issues, 1):
            severity_color = {
                "critical": "\033[91m",
                "major": "\033[93m",
                "minor": "\033[94m"
            }.get(issue["severity"], "")
            reset = "\033[0m"
            print(f"{i}. {severity_color}[{issue['severity'].upper()}]{reset} {issue['name']}")

    def fix(self):
        """Offer to fix issues."""
        if not self.issues:
            return

        print("\nWould you like me to fix these issues? [y/n]: ", end="")
        if input().strip().lower() != 'y':
            print("Skipped. Manual fixes needed.")
            return

        for issue in self.issues:
            print(f"\nFixing: {issue['name']}")
            try:
                issue['fix']()
                print("  ✓ Fixed")
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def _fix_env_var(self):
        """Guide user to set OBSIDIAN_VAULT_PATH."""
        shell_profile = Path(self.home) / ".zshrc"
        if not shell_profile.exists():
            shell_profile = Path(self.home) / ".bashrc"

        vault_path = input("Enter vault path (or press Enter to cancel): ").strip()
        if not vault_path:
            return

        env_line = f'export OBSIDIAN_VAULT_PATH="{vault_path}"\n'
        with open(shell_profile, 'a') as f:
            f.write(env_line)
        print(f"  ✓ Added to {shell_profile.name}")
        print(f"  Now run: source {shell_profile}")

    def _fix_vault_path(self):
        """Help user find correct vault path."""
        print("  Vault not found. Where should it be?")
        new_path = input("  Enter path: ").strip()
        if new_path:
            os.environ['OBSIDIAN_VAULT_PATH'] = new_path
            self.vault = new_path
            print(f"  Updated to {new_path}")

    def _fix_missing_file(self, filename):
        """Offer to recreate missing file."""
        print(f"  Would you like to recreate {filename}? [y/n]: ", end="")
        if input().strip().lower() == 'y':
            print(f"  Run: python3 scripts/setup.py (to recreate full vault)")

def main():
    doctor = Doctor()
    doctor.print_header("Claude + Obsidian Setup Doctor")
    doctor.diagnose()
    doctor.fix()
    print("\n✓ Done. Start a new Claude Code session to test.")

if __name__ == "__main__":
    main()
