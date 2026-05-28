#!/bin/bash
# Comprehensive Pre-flight Environment Assessment
# Detects OS, installed LLM backends, Python environment, secrets management, etc.
# Generates recommendations for .env configuration

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         THOTH DOCKER SETUP — ENVIRONMENT ASSESSMENT                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"

# ============================================================================
# SECTION 1: OS DETECTION
# ============================================================================

echo -e "\n${GREEN}[1/5] DETECTING OPERATING SYSTEM${NC}"

OS="unknown"
ARCH="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    if [[ $(uname -m) == "arm64" ]]; then
        ARCH="apple-silicon"
    else
        ARCH="intel"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    ARCH=$(uname -m)
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    ARCH="x86_64"
fi

echo "  OS: $OS"
echo "  Architecture: $ARCH"
echo "  Shell: $SHELL"

# ============================================================================
# SECTION 1.5: WINDOWS WSL2 PREREQUISITE CHECK (Windows only)
# ============================================================================

if [[ "$OS" == "windows" ]]; then
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      WINDOWS PREREQUISITE: WSL2                           ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"

    echo ""
    echo "  Docker Desktop on Windows requires WSL2 (Windows Subsystem"
    echo "  for Linux v2). Without it, containers are slow, unstable, or"
    echo "  fail entirely. This is Microsoft and Docker's official recommendation."
    echo ""

    # --- Sub-check A: Is WSL installed at all? ---
    WSL_INSTALLED=0
    WSL_HAS_V2=0

    if wsl --list --verbose > /dev/null 2>&1; then
        WSL_INSTALLED=1
        # wsl output has UTF-16 BOM + CRLF; try iconv first, fall back to tr
        WSL_OUTPUT=$(wsl --list --verbose 2>&1 | iconv -f utf-16 -t utf-8 2>/dev/null || wsl --list --verbose 2>&1)

        if echo "$WSL_OUTPUT" | grep -q " 2 "; then
            WSL_HAS_V2=1
        fi
    fi

    # --- Sub-check B: Is Docker Desktop using WSL2 backend? ---
    DOCKER_USES_WSL2=0
    DOCKER_SETTINGS_PATH="${USERPROFILE}/AppData/Roaming/Docker/settings.json"
    # Translate Windows path to Git Bash path
    DOCKER_SETTINGS_BASH=$(echo "$DOCKER_SETTINGS_PATH" | sed 's|\\|/|g' | sed 's|C:|/c|')

    if [[ -f "$DOCKER_SETTINGS_BASH" ]]; then
        if grep -q '"wslEngineEnabled":true' "$DOCKER_SETTINGS_BASH" 2>/dev/null || \
           grep -q '"wslEngineEnabled": true' "$DOCKER_SETTINGS_BASH" 2>/dev/null; then
            DOCKER_USES_WSL2=1
        fi
    fi

    # --- Report and act ---

    if [[ $WSL_INSTALLED -eq 0 ]]; then
        echo -e "  ${RED}✗ WSL is NOT installed${NC}"
        echo ""
        echo -e "  ${YELLOW}Why WSL2 matters:${NC}"
        echo "    • Docker Desktop uses WSL2 as its Linux kernel on Windows"
        echo "    • Without it: containers start 10–30x slower"
        echo "    • Many Thoth features require a real Linux process"
        echo "    • Microsoft ships WSL2 free with all Windows 10/11 versions"
        echo ""
        echo -e "  ${YELLOW}To install WSL2:${NC}"
        echo "    Run this in PowerShell (as Administrator):"
        echo "      wsl --install"
        echo "    Then restart your computer."
        echo ""
        echo -e "  ${YELLOW}Or let this script open PowerShell for you:${NC}"
        read -p "  Open PowerShell as Administrator to install WSL2? [y/N] " INSTALL_WSL
        if [[ "$INSTALL_WSL" == "y" || "$INSTALL_WSL" == "Y" ]]; then
            powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command wsl --install'"
            echo ""
            echo -e "  ${YELLOW}→ PowerShell launched. Run setup again after restart.${NC}"
            exit 0
        fi

    elif [[ $WSL_HAS_V2 -eq 0 ]]; then
        echo -e "  ${YELLOW}⚠ WSL is installed but only WSL1 found${NC}"
        echo ""
        echo "  WSL1 uses a compatibility layer — it's too slow for Docker"
        echo "  and many Thoth operations will fail or timeout."
        echo ""
        echo -e "  ${YELLOW}Upgrade to WSL2:${NC}"
        echo "    1. Open PowerShell as Administrator"
        echo "    2. Run: wsl --set-default-version 2"
        echo "    3. Upgrade your distro:"
        echo "       wsl --set-version <DistroName> 2"
        echo "    (Run 'wsl -l' to see your distro name)"
        echo ""
        read -p "  Open PowerShell as Administrator to upgrade WSL2? [y/N] " UPGRADE_WSL
        if [[ "$UPGRADE_WSL" == "y" || "$UPGRADE_WSL" == "Y" ]]; then
            powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command wsl --set-default-version 2'"
            echo -e "  ${YELLOW}→ PowerShell launched. Confirm upgrade, then re-run setup.${NC}"
        fi

    else
        echo -e "  ${GREEN}✓ WSL2 is installed${NC}"
    fi

    # Docker Desktop backend check
    if [[ $WSL_HAS_V2 -eq 1 ]]; then
        if [[ $DOCKER_USES_WSL2 -eq 1 ]]; then
            echo -e "  ${GREEN}✓ Docker Desktop is using WSL2 backend${NC}"
        else
            echo -e "  ${YELLOW}⚠ Docker Desktop may not be using WSL2 backend${NC}"
            echo ""
            echo "  To verify and fix:"
            echo "    1. Open Docker Desktop"
            echo "    2. Go to: Settings → General"
            echo "    3. Enable: 'Use the WSL 2 based engine'"
            echo "    4. Click 'Apply & Restart'"
            echo ""
            echo "  Why this matters:"
            echo "    • WSL2 backend: fast, stable, full Linux kernel"
            echo "    • Hyper-V backend: slower, more memory, less compatible"
        fi
    fi

    echo ""
fi

# ============================================================================
# SECTION 2: DETECT LLM BACKENDS
# ============================================================================

echo -e "\n${GREEN}[2/5] DETECTING AVAILABLE LLM BACKENDS${NC}"

LLM_BACKEND=""
LLM_BACKENDS_FOUND=()
LLM_DETAILS=""

# Check Ollama
if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "unknown")
    echo -e "  ✓ ${YELLOW}Ollama${NC} — Running"
    echo "    Version: $OLLAMA_VERSION"
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        MODELS=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | wc -l)
        echo "    Models available: $MODELS"
        LLM_BACKENDS_FOUND+=("ollama")
        LLM_BACKEND="ollama"
    else
        echo -e "    ${YELLOW}⚠ Installed but not running${NC}"
    fi
else
    echo -e "  ✗ Ollama — Not installed"
fi

# Check LM Studio
if command -v lm-studio &> /dev/null; then
    echo -e "  ✓ ${YELLOW}LM Studio${NC} — Installed"
    LLM_BACKENDS_FOUND+=("lmstudio")
    if [[ -z "$LLM_BACKEND" ]]; then
        LLM_BACKEND="lmstudio"
    fi
elif [[ -d "$HOME/LM Studio" ]] || [[ -d "/Applications/LM Studio.app" ]]; then
    echo -e "  ✓ ${YELLOW}LM Studio${NC} — Found (may not be in PATH)"
    LLM_BACKENDS_FOUND+=("lmstudio")
    if [[ -z "$LLM_BACKEND" ]]; then
        LLM_BACKEND="lmstudio"
    fi
else
    echo -e "  ✗ LM Studio — Not installed"
fi

# Check vLLM
if command -v vllm &> /dev/null; then
    echo -e "  ✓ ${YELLOW}vLLM${NC} — Installed (Python)"
    LLM_BACKENDS_FOUND+=("vllm")
    if [[ -z "$LLM_BACKEND" ]]; then
        LLM_BACKEND="vllm"
    fi
else
    echo -e "  ✗ vLLM — Not installed"
fi

# Check Llama.cpp
if command -v llama-cpp-python &> /dev/null; then
    echo -e "  ✓ ${YELLOW}llama.cpp${NC} — Installed"
    LLM_BACKENDS_FOUND+=("llama-cpp")
    if [[ -z "$LLM_BACKEND" ]]; then
        LLM_BACKEND="llama-cpp"
    fi
else
    echo -e "  ✗ llama.cpp — Not installed"
fi

# Check GPT4All
if command -v gpt4all &> /dev/null; then
    echo -e "  ✓ ${YELLOW}GPT4All${NC} — Installed"
    LLM_BACKENDS_FOUND+=("gpt4all")
    if [[ -z "$LLM_BACKEND" ]]; then
        LLM_BACKEND="gpt4all"
    fi
else
    echo -e "  ✗ GPT4All — Not installed"
fi

if [[ ${#LLM_BACKENDS_FOUND[@]} -eq 0 ]]; then
    echo -e "  ${RED}⚠ No local LLM backend detected${NC}"
    echo -e "    ${YELLOW}→ Option 1: Install Ollama (free, private) from https://ollama.ai${NC}"
    echo -e "    ${YELLOW}→ Option 2: Use OpenRouter (cloud-based) — see below${NC}"
else
    echo -e "  ${GREEN}→ Using: $LLM_BACKEND${NC}"
fi

# ============================================================================
# SECTION 3: PYTHON ENVIRONMENT & DEPENDENCIES
# ============================================================================

echo -e "\n${GREEN}[3/5] CHECKING PYTHON ENVIRONMENT & DEPENDENCIES${NC}"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "  ✓ Python3: $PYTHON_VERSION"

    # Check for keyring
    if python3 -c "import keyring" 2>/dev/null; then
        echo -e "  ✓ ${YELLOW}keyring${NC} — Installed (Python)"
    else
        echo -e "  ✗ ${RED}keyring — Not installed${NC}"
        echo -e "    ${YELLOW}→ Install with: pip install keyring${NC}"
    fi

    # Check for keyrings.alt (Windows compatibility)
    if python3 -c "import keyrings.alt" 2>/dev/null; then
        echo -e "  ✓ ${YELLOW}keyrings.alt${NC} — Installed (Windows support)"
    else
        if [[ "$OS" == "windows" ]]; then
            echo -e "  ✗ ${RED}keyrings.alt — Not installed (Windows needs this!)${NC}"
            echo -e "    ${YELLOW}→ Install with: pip install keyrings.alt${NC}"
        else
            echo -e "  ⊘ keyrings.alt — Not installed (only needed on Windows)"
        fi
    fi

else
    echo -e "  ✗ ${RED}Python3 not found${NC}"
fi

# ============================================================================
# SECTION 4: SECRETS MANAGEMENT
# ============================================================================

echo -e "\n${GREEN}[4/5] CHECKING SECRETS MANAGEMENT${NC}"

# macOS Keychain
if [[ "$OS" == "macos" ]]; then
    if security show-keychain-info -l >/dev/null 2>&1; then
        echo -e "  ✓ ${YELLOW}macOS Keychain${NC} — Available"
    else
        echo -e "  ⚠ macOS Keychain — Not accessible"
    fi
fi

# Linux Secret Service
if [[ "$OS" == "linux" ]]; then
    if command -v secret-tool &> /dev/null; then
        echo -e "  ✓ ${YELLOW}Secret Service (DBus)${NC} — Available"
    else
        echo -e "  ⚠ Secret Service — Not available"
        echo -e "    ${YELLOW}→ Install: sudo apt install libsecret-1-dev${NC}"
    fi
fi

# Windows Credential Manager
if [[ "$OS" == "windows" ]]; then
    echo -e "  ✓ ${YELLOW}Windows Credential Manager${NC} — Available (via keyrings.alt)"
fi

# Environment variables check
if [[ -n "$THOTH_SECRETS_BACKEND" ]]; then
    echo -e "  ℹ THOTH_SECRETS_BACKEND set to: $THOTH_SECRETS_BACKEND"
else
    echo -e "  ℹ THOTH_SECRETS_BACKEND not set (will auto-detect)"
fi

# ============================================================================
# SECTION 5: OTHER TOOLS & UTILITIES
# ============================================================================

echo -e "\n${GREEN}[5/5] CHECKING UTILITIES & TOOLS${NC}"

# Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "  ✓ Docker: $DOCKER_VERSION"
else
    echo -e "  ✗ ${RED}Docker not found${NC}"
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(docker-compose --version)
    echo -e "  ✓ Docker Compose: $DOCKER_COMPOSE_VERSION"
else
    echo -e "  ✗ ${RED}Docker Compose not found${NC}"
fi

# Git
if command -v git &> /dev/null; then
    echo -e "  ✓ Git: $(git --version)"
else
    echo -e "  ✗ Git not found"
fi

# nano (mentioned in Dockerfile now)
if command -v nano &> /dev/null; then
    echo -e "  ✓ nano: $(nano --version 2>&1 | head -1)"
else
    echo -e "  ⊘ nano — Not on host (will be in Docker container)"
fi

# curl
if command -v curl &> /dev/null; then
    echo -e "  ✓ curl: $(curl --version | head -1)"
else
    echo -e "  ✗ ${RED}curl not found${NC}"
fi

# jq
if command -v jq &> /dev/null; then
    echo -e "  ✓ jq: $(jq --version)"
else
    echo -e "  ⊘ jq — Not on host (will be in Docker container)"
fi

# ============================================================================
# SECTION 6: ENVIRONMENT VARIABLES
# ============================================================================

echo -e "\n${GREEN}ENVIRONMENT VARIABLES${NC}"

# Check for relevant env vars
RELEVANT_VARS=("OLLAMA_HOST" "OLLAMA_BASE_URL" "THOTH_PORT" "THOTH_DATA_DIR" "THOTH_WORKSPACE_DIR" "THOTH_SECRETS_BACKEND" "PYTHONPATH" "PYTHON_KEYRING_BACKEND")

for var in "${RELEVANT_VARS[@]}"; do
    if [[ -n "${!var}" ]]; then
        echo "  ℹ $var = ${!var}"
    fi
done

# ============================================================================
# SECTION 7: RECOMMENDATIONS
# ============================================================================

echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      RECOMMENDATIONS                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"

# Generate .env recommendations
echo -e "\n${GREEN}Suggested .env Configuration:${NC}\n"

echo "# ============================================"
echo "# RECOMMENDED .env (based on your system)"
echo "# ============================================"
echo ""

# Port
echo "# Port for Thoth"
echo "THOTH_PORT=8080"
echo ""

# LLM Backend
echo "# LLM Backend Configuration"
if [[ "$LLM_BACKEND" == "ollama" ]]; then
    if [[ "$OS" == "linux" ]]; then
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "# Using Ollama (detected on host)"
        echo "OLLAMA_BASE_URL=http://$LOCAL_IP:11434"
    else
        echo "# Using Ollama (Docker Desktop)"
        echo "OLLAMA_BASE_URL=http://host.docker.internal:11434"
    fi
elif [[ "$LLM_BACKEND" == "lmstudio" ]]; then
    echo "# Using LM Studio (detected on host)"
    if [[ "$OS" == "linux" ]]; then
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "OLLAMA_BASE_URL=http://$LOCAL_IP:1234/v1"
    else
        echo "OLLAMA_BASE_URL=http://host.docker.internal:1234/v1"
    fi
elif [[ "$LLM_BACKEND" == "vllm" ]]; then
    echo "# Using vLLM (detected on host)"
    if [[ "$OS" == "linux" ]]; then
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "OLLAMA_BASE_URL=http://$LOCAL_IP:8000/v1"
    else
        echo "OLLAMA_BASE_URL=http://host.docker.internal:8000/v1"
    fi
else
    echo "# No LLM backend detected, using Ollama default"
    if [[ "$OS" == "linux" ]]; then
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "OLLAMA_BASE_URL=http://$LOCAL_IP:11434"
    else
        echo "OLLAMA_BASE_URL=http://host.docker.internal:11434"
    fi
fi
echo ""

# Data directories
echo "# Data Persistence Paths"
if [[ "$OS" == "macos" ]]; then
    echo "THOTH_DATA_DIR=/Users/$(whoami)/thoth-data"
    echo "THOTH_WORKSPACE_DIR=/Users/$(whoami)/thoth-workspace"
elif [[ "$OS" == "linux" ]]; then
    echo "THOTH_DATA_DIR=/home/$(whoami)/thoth-data"
    echo "THOTH_WORKSPACE_DIR=/home/$(whoami)/thoth-workspace"
elif [[ "$OS" == "windows" ]]; then
    echo "THOTH_DATA_DIR=C:\\Users\\$(whoami)\\thoth-data"
    echo "THOTH_WORKSPACE_DIR=C:\\Users\\$(whoami)\\thoth-workspace"
fi
echo ""

# Restart policy
echo "# Container Restart Policy"
echo "RESTART_POLICY=unless-stopped"
echo ""

# Secrets backend
echo "# Secrets Management"
if [[ "$OS" == "macos" ]]; then
    echo "PYTHON_KEYRING_BACKEND=keyring.backends.macOS.Keyring"
elif [[ "$OS" == "linux" ]]; then
    echo "PYTHON_KEYRING_BACKEND=keyring.backends.secretservice.SecretServiceBackend"
elif [[ "$OS" == "windows" ]]; then
    echo "PYTHON_KEYRING_BACKEND=keyrings.alt.windows.CredentialVaultKeyring"
fi
echo "THOTH_SECRETS_BACKEND=keyring"
echo ""

# ============================================================================
# SECTION 8: NEXT STEPS
# ============================================================================

echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         NEXT STEPS                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${GREEN}1. Copy recommended config above to .env${NC}"
echo "   cp .env.example .env"
echo "   # Edit with your preferred editor"
echo ""

if [[ -z "$LLM_BACKEND" ]]; then
    echo -e "${YELLOW}2. Choose an LLM provider:${NC}"
    echo ""
    echo -e "   ${GREEN}Option A: Local LLM (Free, Private)${NC}"
    echo "   → Install Ollama: https://ollama.ai"
    echo "   → Download a model: ollama pull llama2"
    echo "   → Restart Thoth with local backend"
    echo ""
    echo -e "   ${GREEN}Option B: OpenRouter (Cloud, Paid, Fast)${NC}"
    echo "   → Sign up: https://openrouter.ai"
    echo "   → Buy \$5 credit (recommended)"
    echo "   → See: OPENROUTER_SETUP.md for detailed guide"
    echo "   → Privacy note: Free models may log data for training"
    echo ""
fi

echo -e "${GREEN}3. Verify prerequisites${NC}"
echo "   docker --version"
echo "   docker-compose --version"
echo ""

echo -e "${GREEN}4. Start Thoth${NC}"
echo "   docker-compose up -d"
echo ""

echo -e "${GREEN}5. Access Thoth${NC}"
if [[ "$OS" == "windows" ]]; then
    echo "   start http://localhost:8080"
else
    echo "   open http://localhost:8080  # macOS"
    echo "   xdg-open http://localhost:8080  # Linux"
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "\n${BLUE}SUMMARY${NC}"
echo "  OS: $OS ($ARCH)"
echo "  LLM Backend: ${LLM_BACKEND:-Not detected}"
if [[ ${#LLM_BACKENDS_FOUND[@]} -gt 0 ]]; then
    echo "  Available: ${LLM_BACKENDS_FOUND[@]}"
fi
echo "  Python: $(python3 --version 2>&1)"
echo "  Docker: $(docker --version 2>/dev/null || echo 'Not found')"
echo ""

# ============================================================================
# OPENROUTER GUIDANCE (if no local LLM detected)
# ============================================================================

if [[ -z "$LLM_BACKEND" ]]; then
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                    NO LOCAL LLM DETECTED                              ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Quick Setup with OpenRouter (5 minutes):${NC}"
    echo ""
    echo "  1. Sign up: https://openrouter.ai"
    echo "  2. Add payment: \$5 USD credit"
    echo "  3. Create API key in settings"
    echo "  4. In .env, set:"
    echo "     OPENROUTER_API_KEY=sk-or-your-key-here"
    echo "  5. In Thoth UI, set provider to OpenAI with:"
    echo "     Base URL: https://openrouter.ai/api/v1"
    echo "     Model: anthropic/claude-3-haiku"
    echo ""
    echo -e "${YELLOW}⚠️  Privacy Notice:${NC}"
    echo "   • Free models: May log/train on your data"
    echo "   • Paid models: Better privacy (Claude 3 Haiku recommended)"
    echo "   • Cost: \$0.0015 per 1K tokens (very cheap)"
    echo ""
    echo -e "${YELLOW}For detailed setup guide:${NC}"
    echo "   See: OPENROUTER_SETUP.md"
    echo ""
fi

echo -e "${GREEN}✓ Assessment complete. You're ready to proceed!${NC}\n"
