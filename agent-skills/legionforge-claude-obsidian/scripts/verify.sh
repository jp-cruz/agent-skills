#!/usr/bin/env bash
# verify.sh — Verification and testing protocol
# Cross-platform testing (bash version for macOS/Linux)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${OBSIDIAN_VAULT_PATH:?Error: OBSIDIAN_VAULT_PATH not set}"
HOME_DIR="$HOME"
CLAUDE_DIR="$HOME_DIR/.claude"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
PASSED=0
FAILED=0

print_header() {
    echo -e "\n${GREEN}======================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}======================================${NC}\n"
}

test_check() {
    local name=$1
    local cmd=$2

    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        ((FAILED++))
    fi
}

test_file() {
    local name=$1
    local path=$2

    if [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name (not found: $path)"
        ((FAILED++))
    fi
}

test_dir() {
    local name=$1
    local path=$2

    if [ -d "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name (not found: $path)"
        ((FAILED++))
    fi
}

print_header "LegionForge Claude + Obsidian Verification"

# 1. Environment
echo "1. Environment Variables"
test_check "OBSIDIAN_VAULT_PATH is set" "[ -n '$VAULT' ]"
test_dir "Vault directory exists" "$VAULT"

# 2. Vault structure
echo -e "\n2. Vault Structure"
test_dir "Library/AI/memory" "$VAULT/Library/AI/memory"
test_dir "Library/AI/projects" "$VAULT/Library/AI/projects"
test_dir "Library/AI/Sessions" "$VAULT/Library/AI/Sessions"

# 3. Memory files
echo -e "\n3. Memory Files"
test_file "vault-directives.md" "$VAULT/Library/AI/memory/vault-directives.md"
test_file "!startup.md" "$VAULT/Library/AI/memory/!startup.md"
test_file "!checkpoint.md" "$VAULT/Library/AI/memory/!checkpoint.md"
test_file "user-profile.md" "$VAULT/Library/AI/memory/user-profile.md"
test_file "lessons-index.md" "$VAULT/Library/AI/memory/lessons/lessons-index.md"

# 4. Claude Code config
echo -e "\n4. Claude Code Configuration"
test_file "~/.claude/settings.json" "$CLAUDE_DIR/settings.json"
test_check "settings.json is valid JSON" "python3 -m json.tool '$CLAUDE_DIR/settings.json' > /dev/null"

# 5. Hooks
echo -e "\n5. Hook Scripts"
test_file "session-startup.sh" "$CLAUDE_DIR/hooks/session-startup.sh"
test_file "inject-layer0.py" "$CLAUDE_DIR/hooks/inject-layer0.py"
test_file "user-prompt-startup-guard.py" "$CLAUDE_DIR/hooks/user-prompt-startup-guard.py"
test_check "session-startup.sh is executable" "[ -x '$CLAUDE_DIR/hooks/session-startup.sh' ]"
test_check "inject-layer0.py is executable" "[ -x '$CLAUDE_DIR/hooks/inject-layer0.py' ]"
test_check "user-prompt-startup-guard.py is executable" "[ -x '$CLAUDE_DIR/hooks/user-prompt-startup-guard.py' ]"

# 6. Claude Desktop config (macOS/Linux)
if [ "$OS_TYPE" != "Windows" ]; then
    echo -e "\n6. Claude Desktop Configuration"
    DESKTOP_CONFIG="$HOME_DIR/Library/Application Support/Claude/claude_desktop_config.json"
    if [ -f "$DESKTOP_CONFIG" ]; then
        test_check "claude_desktop_config.json is valid JSON" "python3 -m json.tool '$DESKTOP_CONFIG' > /dev/null"
    else
        echo -e "${YELLOW}ℹ${NC} Claude Desktop config not found (optional)"
    fi
fi

# 7. Git
echo -e "\n7. Git Status"
if [ -d "$VAULT/.git" ]; then
    test_check "Git repo initialized" "git -C '$VAULT' rev-parse --git-dir > /dev/null"
else
    echo -e "${YELLOW}ℹ${NC} Git not initialized (optional)"
fi

# 8. MCP Server check (if available)
echo -e "\n8. MCP Server (Optional)"
if timeout 2 nc -zv localhost 22360 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Obsidian MCP server responding (localhost:22360)"
    ((PASSED++))
else
    echo -e "${YELLOW}ℹ${NC} Obsidian MCP server not responding (optional)"
fi

# Summary
echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}  Verification Summary${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All checks passed!${NC}"
    echo -e "\nNext steps:"
    echo "1. Start a new Claude Code session"
    echo "2. Send a message and look for '[startup-guard] First prompt'"
    echo "3. Your vault context should be loaded automatically"
    exit 0
else
    echo -e "\n${RED}✗ Some checks failed.${NC}"
    echo -e "\nTroubleshooting:"
    echo "- Check OBSIDIAN_VAULT_PATH is set: echo \$OBSIDIAN_VAULT_PATH"
    echo "- Verify hooks are executable: ls -l ~/.claude/hooks/"
    echo "- Check settings.json: cat ~/.claude/settings.json"
    echo "- For advanced help, run: python3 scripts/recovery.py"
    exit 1
fi
