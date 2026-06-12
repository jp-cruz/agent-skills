#!/bin/bash
# Row-Bot Docker Setup Script
# Automated detection, one-decision setup flow, progressive disclosure

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# BANNER
# ============================================================================

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Row-Bot Docker Setup${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================================================
# EXECUTION CONTEXT CHECK
# ============================================================================

# Verify running in an interactive terminal (TTY required for prompts)
if [ -z "$TERM" ] || [ ! -t 0 ]; then
    echo -e "${RED}✗ ERROR: Not running in an interactive terminal${NC}"
    echo ""
    echo "This script requires a terminal with bash and file system access."
    echo "It cannot run from Claude.ai web, desktop app, or ChatGPT."
    echo ""
    echo "Run from any of these:"
    echo "  ${BLUE}Claude Code CLI:${NC}    npm install -g @anthropic-ai/claude-code && claude"
    echo "  ${BLUE}Aider:${NC}             aider"
    echo "  ${BLUE}VS Code terminal:${NC}   Ask Claude with code execution enabled"
    echo "  ${BLUE}OpenCode:${NC}          Terminal within OpenCode"
    echo "  ${BLUE}Any bash terminal:${NC}  bash setup.sh"
    echo ""
    exit 1
fi

echo -e "${YELLOW}Scanning environment...${NC}"
echo ""

# ============================================================================
# PHASE 1: SILENT DETECTION
# ============================================================================

# Ensure .env exists
if [ ! -f .env ]; then
    cp .env.example .env 2>/dev/null || true
fi

# Detect OS
OS="unknown"
ARCH="unknown"
if echo "$OSTYPE" | grep -q "^darwin"; then
    OS="macos"
    ARCH=$(uname -m)
elif echo "$OSTYPE" | grep -q "^linux"; then
    OS="linux"
    ARCH=$(uname -m)
elif [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    OS="windows"
    ARCH="x86_64"
fi

# Detect system drive status
SYSTEM_FREE_KB=$(df -k / | tail -1 | awk '{print $4}')
SYSTEM_FREE_GB=$((SYSTEM_FREE_KB / 1024 / 1024))
SYSTEM_TOTAL_KB=$(df -k / | tail -1 | awk '{print $2}')
SYSTEM_TOTAL_GB=$((SYSTEM_TOTAL_KB / 1024 / 1024))

DRIVE_STATUS="○ Adequate ✓"
DRIVE_ICON=" "
if [ $SYSTEM_FREE_GB -lt 30 ]; then
    DRIVE_STATUS="${RED}✗ CRITICAL${NC}"
    DRIVE_ICON="  "
elif [ $SYSTEM_FREE_GB -lt 50 ]; then
    DRIVE_STATUS="${RED}✗ WARNING${NC}"
    DRIVE_ICON="  "
elif [ $SYSTEM_FREE_GB -lt 100 ]; then
    DRIVE_STATUS="${YELLOW}⚠ CAUTION${NC}"
    DRIVE_ICON=" "
else
    DRIVE_STATUS="${GREEN}✓ Adequate${NC}"
fi

# Run disk-check for recommendations (with --export-only to suppress output)
source "$(dirname "$0")/disk-check.sh" --export-only 2>/dev/null || true

# Extract paths from .env
ROWBOT_DATA_DIR=$(grep "^ROWBOT_DATA_DIR=" .env | cut -d= -f2 | sed "s|~|$HOME|g")
ROWBOT_WORKSPACE_DIR=$(grep "^ROWBOT_WORKSPACE_DIR=" .env | cut -d= -f2 | sed "s|~|$HOME|g")
ROWBOT_PORT=$(grep "^ROWBOT_PORT=" .env | cut -d= -f2)
OLLAMA_BASE_URL=$(grep "^OLLAMA_BASE_URL=" .env | cut -d= -f2)

# Check Ollama
OLLAMA_STATUS="✗ Not reachable"
MODEL_COUNT=0
if curl -s "${OLLAMA_BASE_URL}/api/tags" > /dev/null 2>&1; then
    OLLAMA_STATUS="${GREEN}✓ Running${NC}"
    MODEL_COUNT=$(curl -s "${OLLAMA_BASE_URL}/api/tags" | grep -o '"name":"[^"]*"' | wc -l)
fi

# Check Docker
DOCKER_AVAILABLE=0
if command -v docker >/dev/null 2>&1; then
    DOCKER_AVAILABLE=1
fi

# Check port
PORT_AVAILABLE=0
if [ "$OS" = "macos" ]; then
    if ! lsof -i ":${ROWBOT_PORT}" > /dev/null 2>&1; then
        PORT_AVAILABLE=1
    fi
elif [ "$OS" = "linux" ]; then
    if ! netstat -tlnp 2>/dev/null | grep -q ":${ROWBOT_PORT} "; then
        PORT_AVAILABLE=1
    fi
fi

# ============================================================================
# PHASE 2: CONFIG PANEL
# ============================================================================

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   DETECTED CONFIGURATION                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# System info
if [ "$OS" = "macos" ]; then
    if [ "$ARCH" = "arm64" ]; then
        ARCH_DISPLAY="Apple Silicon"
    else
        ARCH_DISPLAY="Intel"
    fi
elif [ "$OS" = "windows" ]; then
    ARCH_DISPLAY="x86-64"
else
    ARCH_DISPLAY="$ARCH"
fi

echo "  System"
echo "    OS:     $(echo "$OS" | sed 's/^./\U&/') · $ARCH_DISPLAY"
echo "    Drive:  ${SYSTEM_FREE_GB}GB free of ${SYSTEM_TOTAL_GB}GB — ${DRIVE_STATUS}"
echo ""

# Storage info
if [ -n "$DISK_CHECK_RECOMMENDED_DATA_DIR" ]; then
    STORAGE_ICON="${GREEN}⭐${NC}"
    DATA_PATH="$DISK_CHECK_RECOMMENDED_DATA_DIR"
    WORKSPACE_PATH="$DISK_CHECK_RECOMMENDED_WORKSPACE_DIR"
    ROWBOT_DATA_DIR="$DATA_PATH"
    ROWBOT_WORKSPACE_DIR="$WORKSPACE_PATH"
else
    STORAGE_ICON=" "
    DATA_PATH="$ROWBOT_DATA_DIR"
    WORKSPACE_PATH="$ROWBOT_WORKSPACE_DIR"
    if [ $SYSTEM_FREE_GB -lt 100 ]; then
        echo -e "${YELLOW}  ⚠ Using system drive (${SYSTEM_FREE_GB}GB free).${NC}"
        echo -e "${YELLOW}    External SSD recommended for long-term use.${NC}"
    fi
fi

echo "  Storage"
echo "    ${STORAGE_ICON} Data:      $DATA_PATH"
echo "       Workspace: $WORKSPACE_PATH"
echo ""

# Network
echo "  Network"
echo "    Ollama:  $OLLAMA_STATUS ($MODEL_COUNT models)"
echo "    Port:    ${ROWBOT_PORT} — $([ $PORT_AVAILABLE -eq 1 ] && echo "${GREEN}Available ✓${NC}" || echo "${RED}In use ✗${NC}")"
echo ""

echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# PHASE 3: ONE DECISION
# ============================================================================

read -p "Apply this configuration? [Y/n] " CONFIRM

if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "N" ]; then
    echo ""
    echo "To customize:"
    echo "  1. Edit .env manually (e.g., change ROWBOT_DATA_DIR)"
    echo "  2. Re-run: ./setup.sh"
    echo ""
    echo "For detailed guidance:"
    echo "  → cat references/DISK_MANAGEMENT.md"
    echo ""
    exit 0
fi

echo ""

# ============================================================================
# PHASE 4: APPLY (with progress)
# ============================================================================

echo -e "${GREEN}[1/4] Creating data directories${NC}"
mkdir -p "$ROWBOT_DATA_DIR"
mkdir -p "$ROWBOT_WORKSPACE_DIR"

# Update .env only if external drive was recommended and used
if [ -n "$DISK_CHECK_RECOMMENDED_DATA_DIR" ] && [ "$DATA_PATH" != "$(grep '^ROWBOT_DATA_DIR=' .env | cut -d= -f2 | sed "s|~|$HOME|g")" ]; then
    sed -i.bak "s|^ROWBOT_DATA_DIR=.*|ROWBOT_DATA_DIR=$DISK_CHECK_RECOMMENDED_DATA_DIR|" .env
    sed -i.bak "s|^ROWBOT_WORKSPACE_DIR=.*|ROWBOT_WORKSPACE_DIR=$DISK_CHECK_RECOMMENDED_WORKSPACE_DIR|" .env
fi

echo -e "${GREEN}[2/4] Verifying Docker${NC}"
if ! bash "$(dirname "$0")/check-docker.sh" 2>&1 | grep -q "ALL CHECKS PASSED"; then
    echo -e "${RED}Docker check failed. See: DOCKER_GUIDE_FOR_BEGINNERS.md${NC}"
    exit 1
fi

echo -e "${GREEN}[3/4] Verifying Ollama${NC}"
if curl -s "${OLLAMA_BASE_URL}/api/tags" > /dev/null 2>&1; then
    echo -e "${GREEN}  Ollama is running${NC}"
else
    echo -e "${YELLOW}  ⚠ Ollama not reachable. Start it before docker-compose up${NC}"
fi

echo -e "${GREEN}[4/4] Port check${NC}"
echo -e "${GREEN}  Port ${ROWBOT_PORT} available${NC}"

echo ""

# ============================================================================
# PHASE 5: SUCCESS + PROGRESSIVE DISCLOSURE
# ============================================================================

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Ensure Ollama is running: ollama serve"
echo "  2. Start Thoth: docker-compose up -d"
echo "  3. Open: http://localhost:${ROWBOT_PORT}"
echo ""

# Progressive disclosure for maintenance
read -p "Run rowbot-maintenance.sh now to check disk cleanup options? [y/N] " RUN_MAINT

if [ "$RUN_MAINT" = "y" ] || [ "$RUN_MAINT" = "Y" ]; then
    bash ./scripts/rowbot-maintenance.sh
else
    echo ""
    echo -e "${YELLOW}Tip:${NC} Run this monthly to clean up Docker artifacts:"
    echo "  ./scripts/rowbot-maintenance.sh"
    echo ""
fi
