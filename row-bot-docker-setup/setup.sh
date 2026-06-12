#!/bin/bash

# Row-Bot Docker Secure Setup
# Two pathways: Quick/Easy or Advanced
# Security-first framing with smart defaults

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"
DOCKERFILE="$SCRIPT_DIR/docker/Dockerfile"

# Script & Row-Bot versions
SCRIPT_VERSION="0.5.0"

# Extract Row-Bot version from Dockerfile
ROWBOT_VERSION=$(grep -oP 'git checkout \K[^ ]+' "$DOCKERFILE" 2>/dev/null || echo "unknown")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# WELCOME & VERSION CHECK
# ============================================================================

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                 Row-Bot Docker Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Setting up Row-Bot in Docker for safe, isolated AI agent deployment."
echo ""

# ============================================================================
# CHECK 1: DOCKER OR RANCHER INSTALLED (GATING)
# ============================================================================

DOCKER_AVAILABLE=false
DOCKER_PRODUCT="unknown"

if command -v docker &> /dev/null; then
    if docker info > /dev/null 2>&1; then
        DOCKER_AVAILABLE=true
        DOCKER_PRODUCT="Docker Desktop or Docker Engine"
    fi
fi

if [ "$DOCKER_AVAILABLE" = false ]; then
    echo -e "${RED}✗ Docker is not installed or not running${NC}"
    echo ""
    echo "Before continuing, you need to install Docker (or Rancher Desktop as an alternative)."
    echo ""
    echo "Options:"
    echo "  1. Install Docker Desktop (recommended)"
    echo "  2. Install Rancher Desktop (lighter weight)"
    echo "  3. Already installed? Then start Docker and run this script again"
    echo ""
    echo "Full installation guide available in: DOCKER_GUIDE_FOR_BEGINNERS.md"
    echo ""
    echo "Quick links:"
    echo "  • Docker Desktop: https://www.docker.com/products/docker-desktop"
    echo "  • Rancher Desktop: https://rancherdesktop.io"
    echo ""
    exit 1
fi

# ============================================================================
# SYSTEM SCANNING
# ============================================================================

echo -e "${YELLOW}Scanning your system...${NC}"
echo ""

# Detect RAM
RAM_GB=$(free -g 2>/dev/null | awk 'NR==2 {print $2}' || \
         vm_stat 2>/dev/null | grep "Pages free:" | awk '{print int($3/256000)}' || \
         echo "unknown")

# Detect GPU
GPU_TYPE="none"
if command -v nvidia-smi &> /dev/null; then
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    if [ ! -z "$GPU_VRAM" ]; then
        GPU_TYPE="nvidia"
        GPU_VRAM_GB=$((GPU_VRAM / 1024))
    fi
elif system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Metal"; then
    GPU_TYPE="apple-metal"
fi

# Detect Ollama
OLLAMA_RUNNING=false
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1 || \
   curl -s http://host.docker.internal:11434/api/tags > /dev/null 2>&1; then
    OLLAMA_RUNNING=true
fi

# Check port availability
PORT_8080_AVAILABLE=true
if lsof -i :8080 > /dev/null 2>&1 || \
   netstat -tln 2>/dev/null | grep -q ":8080 "; then
    PORT_8080_AVAILABLE=false
fi

# Print scan results
echo -e "${GREEN}✓ System Scan Results${NC}"
echo "  RAM: $([[ "$RAM_GB" != "unknown" ]] && echo "${RAM_GB}GB" || echo "Unable to detect")"
if [[ "$GPU_TYPE" == "nvidia" ]]; then
    echo "  GPU: NVIDIA (${GPU_VRAM_GB}GB VRAM) — vLLM or accelerated Ollama recommended ✓"
elif [[ "$GPU_TYPE" == "apple-metal" ]]; then
    echo "  GPU: Apple Metal — oMLX or Ollama recommended ✓"
else
    echo "  GPU: None detected (will use CPU or cloud LLM)"
fi
echo "  Docker: $DOCKER_PRODUCT ✓"
[[ "$OLLAMA_RUNNING" == "true" ]] && echo "  Ollama: Running ✓" || echo "  Ollama: Not running (will use cloud LLM)"
[[ "$PORT_8080_AVAILABLE" == "true" ]] && echo "  Port 8080: Available ✓" || echo "  Port 8080: In use (⚠️ may need to configure different port)"
echo ""

# ============================================================================
# PATHWAY SELECTION
# ============================================================================

echo -e "${BLUE}Which setup path works best for you?${NC}"
echo ""
echo "  ${GREEN}a) Quick Setup${NC} (5 minutes)"
echo "     • System-intelligent defaults"
echo "     • One approval button"
echo "     • Operationally safe out of the box"
echo ""
echo "  ${GREEN}b) Advanced Setup${NC} (10 minutes) [DEFAULT]"
echo "     • Same smart defaults"
echo "     • Detailed customization options"
echo "     • CTAs for power users"
echo ""
read -p "Choose [a/b]: " pathway_choice
pathway_choice=${pathway_choice:-b}

echo ""

# ============================================================================
# CHECK IF .env EXISTS
# ============================================================================

if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}✓${NC} .env already exists"
    read -p "Do you want to reconfigure? [y/n]: " reconfigure
    if [[ "$reconfigure" != "y" && "$reconfigure" != "Y" ]]; then
        echo "Skipping configuration. To reconfigure, delete .env and run setup.sh again."
        exit 0
    fi
fi

# ============================================================================
# QUICK SETUP PATHWAY
# ============================================================================

if [[ "$pathway_choice" == "a" || "$pathway_choice" == "A" ]]; then
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                      QUICK SETUP${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Determine recommended defaults
    ROWBOT_BIND="127.0.0.1"  # Always localhost-only by default (most secure)

    if [[ "$RAM_GB" != "unknown" && "$RAM_GB" -lt 8 ]]; then
        RECOMMENDED_LLM="openrouter"
        RECOMMENDED_LLM_MSG="Cloud LLM (your hardware is <8GB RAM)"
    elif [[ "$GPU_TYPE" == "nvidia" && "$GPU_VRAM_GB" -ge 8 ]]; then
        RECOMMENDED_LLM="ollama"
        RECOMMENDED_LLM_MSG="Local Ollama with GPU acceleration (NVIDIA ${GPU_VRAM_GB}GB)"
    elif [[ "$GPU_TYPE" == "apple-metal" ]]; then
        RECOMMENDED_LLM="ollama"
        RECOMMENDED_LLM_MSG="Local Ollama (Apple Metal optimized)"
    elif [[ "$OLLAMA_RUNNING" == "true" ]]; then
        RECOMMENDED_LLM="ollama"
        RECOMMENDED_LLM_MSG="Local Ollama (detected on your machine)"
    elif [[ "$RAM_GB" != "unknown" && "$RAM_GB" -ge 8 ]]; then
        RECOMMENDED_LLM="ollama"
        RECOMMENDED_LLM_MSG="Local Ollama (your hardware supports it)"
    else
        RECOMMENDED_LLM="openrouter"
        RECOMMENDED_LLM_MSG="Cloud LLM (fallback)"
    fi

    echo -e "${GREEN}Recommended Configuration (Based on Your System)${NC}"
    echo ""
    echo "  Network Access: Localhost only (this computer)"
    echo "    → Access Row-Bot at: http://localhost:8080"
    echo "    → Security: Maximum (not accessible from other machines)"
    echo ""
    echo "  LLM Provider: $RECOMMENDED_LLM_MSG"
    if [[ "$RECOMMENDED_LLM" == "ollama" ]]; then
        echo "    → Your data stays on your computer (private)"
        echo "    → Cost: Free (uses your hardware)"
    else
        echo "    → Cloud-based (requires API key)"
        echo "    → Cost: ~$5-20/month depending on usage"
    fi
    echo ""

    read -p "Accept these settings? [y/n]: " accept_defaults

    if [[ "$accept_defaults" != "y" && "$accept_defaults" != "Y" ]]; then
        echo "Switching to Advanced Setup for customization..."
        pathway_choice="b"
    else
        echo ""
        echo -e "${YELLOW}Creating .env with your recommended settings...${NC}"
        cp "$ENV_EXAMPLE" "$ENV_FILE"

        # Apply defaults
        sed -i.bak "s/^ROWBOT_BIND=.*/ROWBOT_BIND=$ROWBOT_BIND/" "$ENV_FILE" || \
        sed -i '' "s/^ROWBOT_BIND=.*/ROWBOT_BIND=$ROWBOT_BIND/" "$ENV_FILE"

        # Setup LLM provider
        if [[ "$RECOMMENDED_LLM" == "ollama" ]]; then
            echo "✓ Configured for Ollama (local, private)"
            if ! grep -q "^OLLAMA_BASE_URL=" "$ENV_FILE"; then
                echo "OLLAMA_BASE_URL=http://host.docker.internal:11434" >> "$ENV_FILE"
            fi
        else
            echo "✓ Configured for OpenRouter (cloud)"
            echo ""
            echo "To complete setup, you'll need an OpenRouter API key:"
            echo "  1. Sign up at https://openrouter.ai"
            echo "  2. Add $5+ credit to your account"
            echo "  3. Copy your API key"
            echo ""
            read -sp "Enter your OpenRouter API key (sk-or-...): " api_key
            echo ""
            if [ ! -z "$api_key" ]; then
                sed -i.bak '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE" || \
                sed -i '' '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE"

                sed -i.bak "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE" || \
                sed -i '' "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE"

                sed -i.bak '/^# ROWBOT_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE" || \
                sed -i '' '/^# ROWBOT_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE"

                echo "✓ API key saved to .env (keep this secret!)"
            fi
        fi

        rm -f "$ENV_FILE.bak"
        pathway_choice="done"  # Skip Advanced setup
    fi
fi

# ============================================================================
# ADVANCED SETUP PATHWAY
# ============================================================================

if [[ "$pathway_choice" == "b" || "$pathway_choice" == "B" ]]; then
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                     ADVANCED SETUP${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Start with a fresh copy
    cp "$ENV_EXAMPLE" "$ENV_FILE"

    # ===== Q1: NETWORK ACCESS =====
    echo -e "${YELLOW}Q1: Who should access Row-Bot?${NC}"
    echo "  a) Just this computer [DEFAULT - most secure]"
    echo "  b) Devices on my Local Area Network (LAN)"
    echo "  c) From the internet (requires secure tunnel)"
    echo ""
    read -p "Choose [a/b/c]: " network_choice
    network_choice=${network_choice:-a}

    case "$network_choice" in
        b)
            ROWBOT_BIND="0.0.0.0"
            echo -e "✓ Local Area Network (LAN) access enabled"
            echo "  Accessible from devices on your LAN:"
            echo "  • WiFi devices on your network"
            echo "  • Wired (Ethernet) devices on your network"
            echo "  • Any device on same local network"
            echo ""
            echo "  Still protected by firewall (not internet-accessible)"
            echo ""
            echo "  For remote access from outside LAN, use:"
            echo "  • Discord bot (chat from Discord)"
            echo "  • SMS integration (text-based)"
            echo "  • Tailscale or Cloudflare Tunnel"
            echo "  See: REMOTE_ACCESS_GUIDE.md for setup"
            ;;
        c)
            echo -e "${RED}⚠️  IMPORTANT: Internet Access to Web UI${NC}"
            echo ""
            echo "  We recommend using Row-Bot's SAFER remote access methods:"
            echo "  • Discord bot — Full Row-Bot access via Discord (encrypted)"
            echo "  • SMS integration — Access via text message (no web needed)"
            echo "  • Signal bot — Private, secure messaging"
            echo "  • Messenger bot — Facebook Messenger integration"
            echo ""
            echo "  These are:"
            echo "  ✓ Authenticated (only you can use them)"
            echo "  ✓ Encrypted (no web exposure)"
            echo "  ✓ Better UX (designed for chat)"
            echo ""
            read -p "  Would you like to set up a Discord/SMS bot instead? [y/n]: " use_safer
            if [[ "$use_safer" == "y" || "$use_safer" == "Y" ]]; then
                echo "  ✓ Skip web UI internet access"
                echo "  See: REMOTE_ACCESS_GUIDE.md for bot setup instructions"
                ROWBOT_BIND="127.0.0.1"
            else
                echo ""
                echo -e "${YELLOW}You've chosen to expose the web UI to the internet.${NC}"
                echo "  This requires:"
                echo "  1. A secure tunnel (Cloudflare, Tailscale, etc.)"
                echo "  2. Authentication (password or OAuth)"
                echo "  3. HTTPS only (never HTTP)"
                echo ""
                read -p "  Do you understand and accept these requirements? [y/n]: " internet_accept
                if [[ "$internet_accept" == "y" || "$internet_accept" == "Y" ]]; then
                    echo ""
                    echo "  You MUST set up ONE of these before accessing from internet:"
                    echo "  • Cloudflare Tunnel (recommended, free)"
                    echo "  • Tailscale (private VPN)"
                    echo "  • Reverse proxy + HTTPS (advanced)"
                    echo ""
                    read -p "  Which will you use? [cloudflare/tailscale/other]: " tunnel_choice
                    if [[ "$tunnel_choice" == "cloudflare" ]]; then
                        ROWBOT_BIND="127.0.0.1"
                        echo "  ✓ Remember: Cloudflare Tunnel proxies all traffic"
                        echo "    Configure tunnel to: http://127.0.0.1:8080"
                        echo "    Setup guide: NETWORK_SETUP.md"
                    elif [[ "$tunnel_choice" == "tailscale" ]]; then
                        ROWBOT_BIND="127.0.0.1"
                        echo "  ✓ Remember: Connect devices to Tailscale VPN first"
                        echo "    Then access Thoth via private network"
                    else
                        ROWBOT_BIND="127.0.0.1"
                        echo "  ⚠️  Set up your chosen solution before accessing Thoth"
                        echo "    See: NETWORK_SETUP.md for detailed guides"
                    fi
                else
                    echo "  ✓ Reverting to localhost-only (most secure)"
                    ROWBOT_BIND="127.0.0.1"
                fi
            fi
            ;;
        *)
            ROWBOT_BIND="127.0.0.1"
            echo "✓ Localhost only (most secure)"
            ;;
    esac
    echo ""

    # ===== Q2: LLM PROVIDER =====
    echo -e "${YELLOW}Q2: How do you want to run the AI model?${NC}"
    echo "  a) Local (private, on your computer)"
    echo "  b) Cloud (faster, needs API key)"
    echo ""
    read -p "Choose [a/b]: " llm_quick_choice

    if [[ "$llm_quick_choice" == "a" ]]; then
        USE_OLLAMA=true
        LLM_PROVIDER="ollama"
        echo "✓ Local Ollama (your data stays on your computer)"
        echo "  See LOCAL_LLM_OPTIONS.md for model options"
    else
        echo "Which cloud provider?"
        echo "  1) OpenRouter (cheapest, \$0.10-1/month)"
        echo "  2) OpenAI (GPT-4, \$3-20/month)"
        echo "  3) Anthropic (Claude, \$3-40/month)"
        echo ""
        read -p "Choose [1/2/3]: " cloud_choice

        case "$cloud_choice" in
            2) LLM_PROVIDER="openai" ;;
            3) LLM_PROVIDER="anthropic" ;;
            *) LLM_PROVIDER="openrouter" ;;
        esac

        USE_OLLAMA=false
        echo "✓ Using $LLM_PROVIDER"
        echo "  See estimate-costs.sh to plan monthly budget"
    fi
    echo ""

    # ===== Q3: POWER USER CTAs =====
    echo -e "${YELLOW}Q3: Interested in advanced options?${NC}"
    echo ""
    echo "Check any that interest you (or press Enter to skip):"
    echo ""
    echo "  1. Custom models (vLLM, llama.cpp, oMLX)"
    echo "  2. GPU acceleration"
    echo "  3. Reverse proxy setup (Nginx, Caddy)"
    echo "  4. Kubernetes deployment"
    echo ""
    echo "We'll show you relevant guides at the end"
    echo ""
    read -p "Enter numbers [1/2/3/4] or press Enter to skip: " power_user_choice

    if [[ ! -z "$power_user_choice" ]]; then
        echo ""
        if [[ "$power_user_choice" == *"1"* ]]; then
            echo -e "${GREEN}📖 Custom Models Guide:${NC} See LOCAL_LLM_OPTIONS.md"
        fi
        if [[ "$power_user_choice" == *"2"* ]]; then
            echo -e "${GREEN}📖 GPU Setup Guide:${NC} https://docs.docker.com/config/containers/resource_constraints/"
        fi
        if [[ "$power_user_choice" == *"3"* ]]; then
            echo -e "${GREEN}📖 Reverse Proxy Guide:${NC} See references/NETWORK_SETUP.md"
        fi
        if [[ "$power_user_choice" == *"4"* ]]; then
            echo -e "${GREEN}📖 Kubernetes:${NC} Coming in v2.0 (check GitHub for community examples)"
        fi
        echo ""
    fi

    # ===== APPLY NETWORK SETTINGS =====
    sed -i.bak "s/^ROWBOT_BIND=.*/ROWBOT_BIND=$ROWBOT_BIND/" "$ENV_FILE" || \
    sed -i '' "s/^ROWBOT_BIND=.*/ROWBOT_BIND=$ROWBOT_BIND/" "$ENV_FILE"

    # ===== APPLY LLM SETTINGS =====
    if [[ "$USE_OLLAMA" == "true" ]]; then
        echo -e "${GREEN}✓${NC} Configured for Ollama (local, private LLM)"
        if ! grep -q "^OLLAMA_BASE_URL=" "$ENV_FILE"; then
            echo "OLLAMA_BASE_URL=http://host.docker.internal:11434" >> "$ENV_FILE"
        fi
    else
        echo -e "${GREEN}✓${NC} Configured for $LLM_PROVIDER"
        echo ""
        echo "To complete setup, you'll need an API key:"

        case "$LLM_PROVIDER" in
            openrouter)
                echo "  Sign up: https://openrouter.ai (free, need \$5+ credits)"
                echo ""
                read -sp "Enter your OpenRouter API key (sk-or-...): " api_key
                echo ""
                if [ ! -z "$api_key" ]; then
                    sed -i.bak '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE"

                    sed -i.bak "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE" || \
                    sed -i '' "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE"

                    sed -i.bak '/^# ROWBOT_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# ROWBOT_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE"

                    echo "✓ API key saved"
                fi
                ;;
            openai)
                echo "  Sign up: https://openai.com (requires credit card)"
                echo ""
                read -sp "Enter your OpenAI API key (sk-...): " api_key
                echo ""
                if [ ! -z "$api_key" ]; then
                    sed -i.bak '/^# OPENAI_API_KEY/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# OPENAI_API_KEY/s/^# //' "$ENV_FILE"

                    sed -i.bak "s|sk-your-openai-key-here|$api_key|" "$ENV_FILE" || \
                    sed -i '' "s|sk-your-openai-key-here|$api_key|" "$ENV_FILE"

                    sed -i.bak '/^# ROWBOT_LLM_PROVIDER=openai/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# ROWBOT_LLM_PROVIDER=openai/s/^# //' "$ENV_FILE"

                    echo "✓ API key saved"
                fi
                ;;
            anthropic)
                echo "  Sign up: https://anthropic.com (requires credit card)"
                echo ""
                read -sp "Enter your Anthropic API key (sk-ant-...): " api_key
                echo ""
                if [ ! -z "$api_key" ]; then
                    sed -i.bak '/^# ANTHROPIC_API_KEY/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# ANTHROPIC_API_KEY/s/^# //' "$ENV_FILE"

                    sed -i.bak "s|sk-ant-your-key-here|$api_key|" "$ENV_FILE" || \
                    sed -i '' "s|sk-ant-your-key-here|$api_key|" "$ENV_FILE"

                    sed -i.bak '/^# ROWBOT_LLM_PROVIDER=anthropic/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# ROWBOT_LLM_PROVIDER=anthropic/s/^# //' "$ENV_FILE"

                    echo "✓ API key saved"
                fi
                ;;
        esac
        echo ""
    fi

    rm -f "$ENV_FILE.bak"
fi

# ============================================================================
# SETUP COMPLETE - COMMON FOR BOTH PATHWAYS
# ============================================================================

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    SETUP COMPLETE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# Version check (informational only, after setup completes)
if [[ "$ROWBOT_VERSION" != "unknown" && ! "$ROWBOT_VERSION" =~ ^v[0-9] ]]; then
    echo -e "${YELLOW}ℹ️  Note: Dockerfile uses Row-Bot commit $ROWBOT_VERSION${NC}"
    echo "    This script was tested with Row-Bot main branch"
    echo ""
elif [[ "$SCRIPT_VERSION" < "$ROWBOT_VERSION" ]]; then
    echo -e "${YELLOW}ℹ️  Note: You may have a newer Row-Bot version${NC}"
    echo "    This script v$SCRIPT_VERSION was tested with Row-Bot $ROWBOT_VERSION"
    echo ""
fi

# Source the .env file for checking
set -a
source "$ENV_FILE"
set +a

# Final summary
echo -e "${GREEN}Your Configuration:${NC}"
echo ""
if [[ "$ROWBOT_BIND" == "127.0.0.1" ]]; then
    echo "  Network: Localhost only (most secure) ✓"
    echo "  Access:  http://localhost:8080"
elif [[ "$ROWBOT_BIND" == "0.0.0.0" ]]; then
    echo "  Network: Home network accessible"
    echo "  Access:  http://<your-ip>:8080"
fi

if grep -q "^ROWBOT_LLM_PROVIDER=ollama" "$ENV_FILE"; then
    echo "  LLM:     Ollama (local, private) ✓"
elif grep -q "^ROWBOT_LLM_PROVIDER=openrouter" "$ENV_FILE"; then
    echo "  LLM:     OpenRouter (cloud)"
elif grep -q "^ROWBOT_LLM_PROVIDER=openai" "$ENV_FILE"; then
    echo "  LLM:     OpenAI (cloud)"
elif grep -q "^ROWBOT_LLM_PROVIDER=anthropic" "$ENV_FILE"; then
    echo "  LLM:     Anthropic (cloud)"
else
    echo "  LLM:     Ollama (default)"
fi
echo ""

# Check Ollama if configured
if grep -q "OLLAMA_BASE_URL" "$ENV_FILE"; then
    echo -e "${YELLOW}Checking Ollama connectivity...${NC}"
    OLLAMA_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"

    if curl -s "$OLLAMA_URL/api/tags" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Ollama is reachable"
    else
        echo -e "${YELLOW}⚠️${NC} Ollama is not reachable at $OLLAMA_URL"
        echo "  Start Ollama before starting Thoth, or use a cloud provider"
        echo "  See TROUBLESHOOTING.md for Ollama setup help"
    fi
    echo ""
fi

# Next steps
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "1. Start Thoth:"
echo "   docker-compose up -d"
echo ""
echo "2. Verify everything works:"
echo "   ./health-check.sh"
echo ""
echo "3. Access Row-Bot:"
if [[ "$ROWBOT_BIND" == "127.0.0.1" ]]; then
    echo "   http://localhost:8080"
else
    echo "   http://<your-ip>:${THOTH_PORT:-8080}"
fi
echo ""

# Contextual learning links (optional)
echo -e "${YELLOW}Want to understand more?${NC}"
echo "  • Why Docker isolates Thoth:    See DOCKER_WHY.md"
echo "  • LLM options & tradeoffs:      See LOCAL_LLM_OPTIONS.md"
echo "  • First steps with Thoth:       See GETTING_STARTED.md"
echo "  • Network access & security:    See references/NETWORK_SETUP.md"
echo "  • Estimate monthly costs:       Run ./estimate-costs.sh"
echo ""

# .env security note (subtle, at end)
echo -e "${BLUE}⚠️  Keep .env safe:${NC}"
echo "  Don't commit it to Git (already in .gitignore)"
echo "  Don't share it with others"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
