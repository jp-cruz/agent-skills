#!/bin/bash

# Health Check for Row-Bot Docker Setup
# Verifies Docker, Row-Bot container, Ollama, and basic connectivity

set +e  # Don't exit on errors, let us check them all

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to print check results
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              Row-Bot Docker Health Check${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# CHECK 1: Docker is installed and running
# ============================================================================

echo -e "${YELLOW}Checking Docker...${NC}"

if ! command -v docker &> /dev/null; then
    check_fail "Docker not installed. Install from https://docker.com"
else
    check_pass "Docker installed"

    if ! docker info > /dev/null 2>&1; then
        check_fail "Docker daemon not running. Start Docker Desktop."
    else
        check_pass "Docker daemon running"
        DOCKER_VERSION=$(docker --version | grep -oP 'version \K[^ ,]+')
        check_pass "Docker version: $DOCKER_VERSION"
    fi
fi

# ============================================================================
# CHECK 2: Docker Compose
# ============================================================================

echo ""
echo -e "${YELLOW}Checking Docker Compose...${NC}"

if ! command -v docker-compose &> /dev/null; then
    check_fail "docker-compose not found. Install Docker Desktop or docker-compose."
else
    check_pass "docker-compose installed"
fi

# ============================================================================
# CHECK 3: .env file
# ============================================================================

echo ""
echo -e "${YELLOW}Checking configuration...${NC}"

if [ ! -f "$ENV_FILE" ]; then
    check_fail ".env not found. Run: ./setup.sh"
else
    check_pass ".env file exists"

    # Check required variables
    if grep -q "^ROWBOT_BIND=" "$ENV_FILE"; then
        ROWBOT_BIND=$(grep "^ROWBOT_BIND=" "$ENV_FILE" | cut -d= -f2)
        check_pass "ROWBOT_BIND configured: $ROWBOT_BIND"
    else
        check_warn "ROWBOT_BIND not configured (using default)"
    fi

    if grep -q "^ROWBOT_PORT=" "$ENV_FILE"; then
        ROWBOT_PORT=$(grep "^ROWBOT_PORT=" "$ENV_FILE" | cut -d= -f2)
        check_pass "ROWBOT_PORT configured: $ROWBOT_PORT"
    else
        ROWBOT_PORT=8080
        check_warn "ROWBOT_PORT not configured (using default: 8080)"
    fi
fi

# ============================================================================
# CHECK 4: Port availability
# ============================================================================

echo ""
echo -e "${YELLOW}Checking ports...${NC}"

if lsof -i :${ROWBOT_PORT:-8080} > /dev/null 2>&1 || \
   netstat -tln 2>/dev/null | grep -q ":${ROWBOT_PORT:-8080} "; then
    check_warn "Port ${ROWBOT_PORT:-8080} is in use. Row-Bot may not be able to start."
    check_warn "To use a different port, edit .env and set ROWBOT_PORT=8081"
else
    check_pass "Port ${ROWBOT_PORT:-8080} is available"
fi

# ============================================================================
# CHECK 4b: Firewall status (important for LAN access)
# ============================================================================

echo ""
echo -e "${YELLOW}Checking firewall...${NC}"

FIREWALL_STATUS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: check pf (packet filter) — don't use sudo to avoid password prompt
    if pfctl -s info 2>/dev/null | grep -q "Status: Enabled"; then
        check_pass "Firewall: Enabled (blocks external access)"
        FIREWALL_STATUS="enabled"
    elif pfctl -s info 2>/dev/null | grep -q "Status: Disabled"; then
        check_warn "Firewall: Disabled (recommended: enable in System Preferences)"
        FIREWALL_STATUS="disabled"
    else
        check_warn "Firewall status: Unable to check (run without sudo to verify manually)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: check ufw or firewalld — don't use sudo to avoid password prompt
    if ufw status 2>/dev/null | grep -q "Status: active"; then
        check_pass "Firewall: Enabled (ufw active)"
        FIREWALL_STATUS="enabled"
    elif firewall-cmd --state 2>/dev/null | grep -q "running"; then
        check_pass "Firewall: Enabled (firewalld running)"
        FIREWALL_STATUS="enabled"
    else
        check_warn "Firewall status: Unable to determine (recommended: enable ufw or firewalld)"
    fi
else
    check_warn "Firewall status: Unable to check on this OS"
fi

if [[ "$FIREWALL_STATUS" == "disabled" ]]; then
    check_warn "⚠️  If using ROWBOT_BIND=0.0.0.0 (LAN access), verify router has firewall enabled"
    check_warn "    Otherwise, Row-Bot may be exposed to the internet"
fi

# ============================================================================
# CHECK 5: Container status
# ============================================================================

echo ""
echo -e "${YELLOW}Checking Row-Bot container...${NC}"

if ! docker ps --all 2>/dev/null | grep -q rowbot; then
    check_warn "Row-Bot container not created yet. Run: docker-compose up -d"
else
    if docker ps 2>/dev/null | grep -q "rowbot.*Up"; then
        check_pass "Row-Bot container is running"

        # Check container health
        if docker ps 2>/dev/null | grep -q "rowbot.*(healthy)"; then
            check_pass "Container health: Healthy"
        elif docker ps 2>/dev/null | grep -q "rowbot.*(unhealthy)"; then
            check_fail "Container health: Unhealthy"
            check_warn "Container may still be starting. Wait 30 seconds and check again."
        else
            check_warn "Container health: Unknown (starting or no health check defined)"
        fi
    else
        check_fail "Row-Bot container is not running. Start with: docker-compose up -d"
    fi
fi

# ============================================================================
# CHECK 6: Row-Bot connectivity
# ============================================================================

echo ""
echo -e "${YELLOW}Checking Row-Bot connectivity...${NC}"

if docker ps 2>/dev/null | grep -q "rowbot.*Up"; then
    if docker-compose exec rowbot curl -s http://localhost:8080 > /dev/null 2>&1; then
        check_pass "Row-Bot is responding on port 8080"
    else
        check_warn "Row-Bot not responding yet (may still be starting)"
    fi
else
    check_warn "Row-Bot container not running, skipping connectivity check"
fi

# ============================================================================
# CHECK 7: LLM provider
# ============================================================================

echo ""
echo -e "${YELLOW}Checking LLM provider...${NC}"

if grep -q "^OLLAMA_BASE_URL=" "$ENV_FILE"; then
    OLLAMA_URL=$(grep "^OLLAMA_BASE_URL=" "$ENV_FILE" | cut -d= -f2)
    check_pass "Ollama configured at: $OLLAMA_URL"

    if curl -s "$OLLAMA_URL/api/tags" > /dev/null 2>&1; then
        check_pass "Ollama is reachable"

        # Try to get model list
        MODELS=$(curl -s "$OLLAMA_URL/api/tags" 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4)
        if [ ! -z "$MODELS" ]; then
            MODEL_COUNT=$(echo "$MODELS" | wc -l)
            check_pass "Ollama has $MODEL_COUNT model(s) available"
        else
            check_warn "Ollama is running but no models downloaded"
            check_warn "Download a model: ollama pull mistral"
        fi
    else
        check_fail "Ollama is not reachable at $OLLAMA_URL"
        check_warn "Start Ollama and ensure it's accessible"
    fi
elif grep -q "^ROWBOT_LLM_PROVIDER=" "$ENV_FILE"; then
    LLM_PROVIDER=$(grep "^ROWBOT_LLM_PROVIDER=" "$ENV_FILE" | cut -d= -f2)
    check_pass "LLM Provider configured: $LLM_PROVIDER"

    case "$LLM_PROVIDER" in
        openai)
            if grep -q "^OPENAI_API_KEY=" "$ENV_FILE"; then
                check_pass "OpenAI API key is set"
            else
                check_warn "OpenAI API key not configured"
            fi
            ;;
        openrouter)
            if grep -q "^OPENROUTER_API_KEY=" "$ENV_FILE"; then
                check_pass "OpenRouter API key is set"
            else
                check_warn "OpenRouter API key not configured"
            fi
            ;;
        anthropic)
            if grep -q "^ANTHROPIC_API_KEY=" "$ENV_FILE"; then
                check_pass "Anthropic API key is set"
            else
                check_warn "Anthropic API key not configured"
            fi
            ;;
    esac
else
    check_warn "No LLM provider configured (Ollama will be used by default)"
fi

# ============================================================================
# CHECK 8: Disk space
# ============================================================================

echo ""
echo -e "${YELLOW}Checking disk space...${NC}"

AVAILABLE_GB=$(df -k "$(pwd)" | awk 'NR==2 {print int($4/1024/1024)}')

if [ -z "$AVAILABLE_GB" ] || [ "$AVAILABLE_GB" -lt 0 ]; then
    check_warn "Could not determine available disk space"
elif [ "$AVAILABLE_GB" -lt 10 ]; then
    check_fail "Low disk space: ${AVAILABLE_GB}GB available (need at least 10GB)"
elif [ "$AVAILABLE_GB" -lt 50 ]; then
    check_warn "Low disk space: ${AVAILABLE_GB}GB available (recommended: 50GB+)"
else
    check_pass "Disk space: ${AVAILABLE_GB}GB available"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                          Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Checks passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Checks failed: ${RED}$CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your Row-Bot setup is ready. Next steps:"
    echo "  1. Start Row-Bot:  docker-compose up -d"
    echo "  2. Open browser: http://localhost:8080"
    echo "  3. See GETTING_STARTED.md for first steps"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed.${NC}"
    echo ""
    echo "Common fixes:"
    echo "  • Docker not running? → Start Docker Desktop"
    echo "  • Port in use? → Change ROWBOT_PORT in .env"
    echo "  • .env not found? → Run: ./setup.sh"
    echo "  • Ollama not found? → See LOCAL_LLM_OPTIONS.md"
    echo ""
    echo "For detailed help, see TROUBLESHOOTING.md"
    echo ""
    exit 1
fi
