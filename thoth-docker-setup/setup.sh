#!/bin/bash

# Thoth Docker Secure Setup
# Two pathways: Quick/Easy or Advanced
# Security-first framing with smart defaults

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# WELCOME & SECURITY FRAMING
# ============================================================================

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           Thoth Docker: Secure AI Agent Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Why Docker?${NC}"
echo "Running agent software on bare metal exposes your entire computer to risk:"
echo "  • Malicious code could wipe your hard drive"
echo "  • Compromised agent could access your files and API keys"
echo "  • Security breaches affect your whole system"
echo ""
echo -e "${GREEN}Docker solution:${NC} Thoth runs in an isolated container. If something"
echo "goes wrong, your computer stays safe. Your data is protected."
echo ""
echo "Learn more: See DOCKER_WHY.md for detailed security explanation"
echo ""

# ============================================================================
# SYSTEM SCANNING
# ============================================================================

echo -e "${YELLOW}Scanning your system...${NC}"
echo ""

# Detect RAM
RAM_GB=$(free -g 2>/dev/null | awk 'NR==2 {print $2}' || \
         vm_stat 2>/dev/null | grep "Pages free:" | awk '{print int($3/256000)}' || \
         echo "unknown")

# Detect Ollama
OLLAMA_RUNNING=false
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1 || \
   curl -s http://host.docker.internal:11434/api/tags > /dev/null 2>&1; then
    OLLAMA_RUNNING=true
fi

# Detect Docker
DOCKER_OK=false
if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
    DOCKER_OK=true
    DOCKER_VERSION=$(docker --version | grep -o 'version [0-9.]*' | grep -o '[0-9.]*')
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
[[ "$DOCKER_OK" == "true" ]] && echo "  Docker: Installed (v${DOCKER_VERSION}) ✓" || echo "  Docker: Not installed ✗"
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
    THOTH_BIND="127.0.0.1"  # Always localhost-only by default (most secure)

    if [[ "$RAM_GB" != "unknown" && "$RAM_GB" -lt 8 ]]; then
        RECOMMENDED_LLM="openrouter"
        RECOMMENDED_LLM_MSG="Cloud LLM (your hardware is <8GB RAM)"
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
    echo "    → Access Thoth at: http://localhost:8080"
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
        sed -i.bak "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE" || \
        sed -i '' "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE"

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

                sed -i.bak '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE" || \
                sed -i '' '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE"

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
    echo -e "${YELLOW}Q1: How will you access Thoth?${NC}"
    echo ""
    echo "  a) This computer only [DEFAULT - SECURE]"
    echo "     → Access: http://localhost:8080"
    echo "     → Security: Maximum (not exposed to network)"
    echo ""
    echo "  b) From other machines on home WiFi"
    echo "     → Access: http://<your-ip>:8080"
    echo "     → Security: ⚠️ No authentication by default"
    echo "     → Recommended: Add reverse proxy (see NETWORK_SETUP.md)"
    echo ""
    echo "  c) From the internet (expert mode)"
    echo "     → Requires: Reverse proxy (Nginx, Caddy, Cloudflare Tunnel)"
    echo "     → Security: Must add authentication and HTTPS"
    echo "     → See: NETWORK_SETUP.md for detailed guide"
    echo ""
    read -p "Choose [a/b/c]: " network_choice
    network_choice=${network_choice:-a}

    case "$network_choice" in
        b)
            THOTH_BIND="0.0.0.0"
            echo -e "${YELLOW}⚠️  WARNING:${NC} Network-accessible without authentication"
            echo "  Recommendation: Add reverse proxy for security"
            echo "  See: references/NETWORK_SETUP.md"
            ;;
        c)
            THOTH_BIND="127.0.0.1"
            echo -e "${YELLOW}⚠️  WARNING:${NC} Internet access requires secure setup"
            echo "  You need: Reverse proxy + HTTPS + authentication"
            echo "  See: references/NETWORK_SETUP.md for examples"
            ;;
        *)
            THOTH_BIND="127.0.0.1"
            echo -e "${GREEN}✓${NC} Localhost only (most secure)"
            ;;
    esac
    echo ""

    # ===== Q2: LLM PROVIDER =====
    echo -e "${YELLOW}Q2: What matters most for language models?${NC}"
    echo ""
    echo "  a) Privacy & Control (run models locally)"
    echo ""
    echo "  b) Cost Savings (cloud provider is cheaper)"
    echo ""
    echo "  c) Quality & Speed (best models available)"
    echo ""
    echo "  d) Show me all options [DEFAULT]"
    echo ""
    read -p "Choose [a/b/c/d]: " llm_choice
    llm_choice=${llm_choice:-d}

    echo ""

    case "$llm_choice" in
        a)
            echo "Privacy & Local Processing"
            echo ""
            if [[ "$RAM_GB" != "unknown" && "$RAM_GB" -lt 8 ]]; then
                echo -e "${YELLOW}⚠️  Your system has ~${RAM_GB}GB RAM${NC}"
                echo "  Minimum for reliable local LLM: 8GB"
                echo "  Recommended: 16GB+ for comfortable speed"
                echo ""
                echo "  Suggestion: Use cloud provider or add more RAM"
                echo ""
            fi
            echo "See LOCAL_LLM_OPTIONS.md for:"
            echo "  • Detailed hardware requirements"
            echo "  • Model size recommendations"
            echo "  • Speed/quality tradeoffs"
            echo ""

            USE_OLLAMA=true
            LLM_PROVIDER="ollama"
            ;;

        b)
            echo "Cost Savings"
            echo ""
            echo "Recommended providers:"
            echo "  • OpenRouter (cheap models: Mistral, Llama 2, ~\$0.01-0.50 per use)"
            echo "  • OpenAI GPT-4 (high quality: ~\$0.03-0.06 per 1K tokens)"
            echo ""
            echo "Estimate: \$5-20/month for moderate use"
            echo ""
            echo "See LOCAL_LLM_OPTIONS.md for comparison"
            echo ""

            USE_OLLAMA=false
            LLM_PROVIDER="openrouter"
            ;;

        c)
            echo "Quality & Speed"
            echo ""
            echo "Best models available:"
            echo "  • Claude 3 Opus (reasoning, accuracy)"
            echo "  • GPT-4 Turbo (versatile, fast)"
            echo "  • Claude 3 Sonnet (balanced)"
            echo ""
            echo "Cost: \$10-50/month depending on usage"
            echo ""
            echo "See LOCAL_LLM_OPTIONS.md for model details"
            echo ""

            USE_OLLAMA=false
            LLM_PROVIDER="openrouter"
            ;;

        *)
            echo "Options Available:"
            echo ""
            echo "1. ${GREEN}OLLAMA${NC} (Local, Private, Free)"
            echo "   • Runs models on your computer"
            echo "   • All data stays private (never leaves your machine)"
            echo "   • Cost: Free (uses your hardware)"
            echo "   • Requirement: 8GB+ RAM, decent CPU/GPU"
            echo "   • Speed: Medium (depends on hardware)"
            echo ""
            echo "2. ${GREEN}OPENROUTER${NC} (Cloud, Cheap, Fast)"
            echo "   • Hosted models (no local setup)"
            echo "   • Pay per token (~\$0.01-0.50 per use)"
            echo "   • Best for cost-conscious users"
            echo "   • Requires API key from openrouter.ai"
            echo ""
            echo "3. ${GREEN}OPENAI${NC} (Cloud, Quality, Higher Cost)"
            echo "   • GPT-4 Turbo (best general quality)"
            echo "   • Cost: \$0.03-0.06 per 1K tokens (~\$10-50/month)"
            echo "   • Very fast inference"
            echo "   • Requires API key from openai.com"
            echo ""
            echo "4. ${GREEN}ANTHROPIC${NC} (Cloud, High Quality)"
            echo "   • Claude 3 models (best at reasoning)"
            echo "   • Cost: \$0.08+ per 1K tokens"
            echo "   • Requires API key from anthropic.com"
            echo ""
            echo "For detailed comparison, see LOCAL_LLM_OPTIONS.md"
            echo ""

            read -p "Which sounds best? [ollama/openrouter/openai/anthropic]: " llm_choice2
            case "$llm_choice2" in
                openrouter)
                    USE_OLLAMA=false
                    LLM_PROVIDER="openrouter"
                    ;;
                openai)
                    USE_OLLAMA=false
                    LLM_PROVIDER="openai"
                    ;;
                anthropic)
                    USE_OLLAMA=false
                    LLM_PROVIDER="anthropic"
                    ;;
                *)
                    USE_OLLAMA=true
                    LLM_PROVIDER="ollama"
                    ;;
            esac
            echo ""
            ;;
    esac

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
    sed -i.bak "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE" || \
    sed -i '' "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE"

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

                    sed -i.bak '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE"

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

                    sed -i.bak '/^# THOTH_LLM_PROVIDER=openai/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# THOTH_LLM_PROVIDER=openai/s/^# //' "$ENV_FILE"

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

                    sed -i.bak '/^# ANTHROPIC_API_KEY/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# ANTHROPIC_API_KEY/s/^# //' "$ENV_FILE"

                    sed -i.bak '/^# THOTH_LLM_PROVIDER=anthropic/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# THOTH_LLM_PROVIDER=anthropic/s/^# //' "$ENV_FILE"

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

# Source the .env file for checking
set -a
source "$ENV_FILE"
set +a

# Final summary
echo -e "${GREEN}Your Configuration:${NC}"
echo ""
if [[ "$THOTH_BIND" == "127.0.0.1" ]]; then
    echo "  Network: Localhost only (most secure) ✓"
    echo "  Access:  http://localhost:8080"
elif [[ "$THOTH_BIND" == "0.0.0.0" ]]; then
    echo "  Network: Home network accessible"
    echo "  Access:  http://<your-ip>:8080"
fi

if grep -q "^THOTH_LLM_PROVIDER=ollama" "$ENV_FILE"; then
    echo "  LLM:     Ollama (local, private) ✓"
elif grep -q "^THOTH_LLM_PROVIDER=openrouter" "$ENV_FILE"; then
    echo "  LLM:     OpenRouter (cloud)"
elif grep -q "^THOTH_LLM_PROVIDER=openai" "$ENV_FILE"; then
    echo "  LLM:     OpenAI (cloud)"
elif grep -q "^THOTH_LLM_PROVIDER=anthropic" "$ENV_FILE"; then
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
echo "1. Review your .env file (optional):"
echo "   cat .env"
echo ""
echo "2. Start Thoth:"
echo "   docker-compose up -d"
echo ""
echo "3. Access Thoth:"
echo "   ${THOTH_BIND == '127.0.0.1' && echo 'http://localhost:8080' || echo 'http://<your-ip>:8080'}"
echo ""
echo -e "${GREEN}Learning Resources:${NC}"
echo "  • Why Docker:       See DOCKER_WHY.md"
echo "  • LLM Options:      See LOCAL_LLM_OPTIONS.md"
echo "  • Network Access:   See references/NETWORK_SETUP.md"
echo "  • Troubleshooting:  See TROUBLESHOOTING.md"
echo "  • Full Commands:    See CLAUDE.md"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
