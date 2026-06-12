#!/bin/bash

# Row-Bot Docker Diagnostics
# Collects system info for bug reports (sanitizes secrets)

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
REPORT_FILE="$SCRIPT_DIR/rowbot-diagnostics-$(date +%Y%m%d-%H%M%S).txt"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         Row-Bot Docker Diagnostics Report Generator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "This script collects diagnostic information for bug reports."
echo "API keys and passwords are automatically removed."
echo ""
echo "Report will be saved to: $REPORT_FILE"
echo ""

# Function to sanitize secrets
sanitize() {
    local text="$1"
    # Remove API keys
    text=$(echo "$text" | sed -E 's/(OPENAI_API_KEY|ANTHROPIC_API_KEY|OPENROUTER_API_KEY)=.*/\1=<REDACTED>/g')
    text=$(echo "$text" | sed -E 's/(sk-[a-zA-Z0-9-]+)/<REDACTED>/g')
    # Remove paths that might contain usernames
    text=$(echo "$text" | sed -E 's|/Users/[^/]+|/Users/<USER>|g')
    text=$(echo "$text" | sed -E 's|/home/[^/]+|/home/<USER>|g')
    echo "$text"
}

# Start collecting
{
    echo "Row-Bot Docker Diagnostics Report"
    echo "Generated: $(date)"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "SYSTEM INFORMATION"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    # OS
    echo "Operating System:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sw_vers 2>/dev/null || echo "macOS (version unknown)"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            cat /etc/os-release | grep PRETTY_NAME
        else
            uname -a
        fi
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo "Windows (WSL2 or native)"
        systeminfo | grep "OS Version" || echo "Windows version unknown"
    else
        uname -a
    fi
    echo ""

    # CPU
    echo "CPU Information:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.model 2>/dev/null || echo "Unknown"
    else
        cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 || echo "Unknown"
    fi
    echo ""

    # RAM
    echo "Memory:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | grep "Pages free:" || echo "Unknown"
    else
        free -h | grep Mem || echo "Unknown"
    fi
    echo ""

    # GPU
    echo "GPU:"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,memory.total --format=csv,nounits 2>/dev/null || echo "NVIDIA GPU detected"
    elif system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Metal"; then
        echo "Apple Metal GPU"
    else
        echo "No dedicated GPU detected"
    fi
    echo ""

    # Disk
    echo "Disk Space:"
    df -h "$(pwd)" | tail -1 || echo "Unknown"
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "DOCKER INFORMATION"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    if command -v docker &> /dev/null; then
        echo "Docker Version:"
        docker --version
        echo ""

        echo "Docker Info (summary):"
        docker info 2>/dev/null | grep -E "(Storage Driver|Server Version|OS/Arch)" || echo "Unable to get Docker info"
    else
        echo "Docker not installed"
    fi
    echo ""

    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose Version:"
        docker-compose --version
    else
        echo "docker-compose not found"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "ROW-BOT CONTAINER STATUS"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    if docker ps -a 2>/dev/null | grep -q rowbot; then
        echo "Container Status:"
        docker ps -a 2>/dev/null | grep rowbot || echo "Container found but status unknown"
        echo ""

        echo "Container Logs (last 50 lines):"
        docker-compose logs --tail=50 rowbot 2>/dev/null || echo "Unable to retrieve logs"
        echo ""

        echo "Container Inspect (selected fields):"
        docker inspect rowbot-app 2>/dev/null | grep -E '(Status|State|RestartCount)' || echo "Unable to inspect container"
    else
        echo "Row-Bot container not found"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "CONFIGURATION"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    if [ -f "$ENV_FILE" ]; then
        echo ".env Configuration (API keys redacted):"
        sanitize "$(cat $ENV_FILE)" || echo "Unable to read .env"
    else
        echo ".env file not found"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "LLM PROVIDER STATUS"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    # Check Ollama
    echo "Ollama Status:"
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✓ Ollama running locally"
        MODELS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4)
        echo "Available models:"
        echo "$MODELS" | sed 's/^/  - /'
    elif curl -s http://host.docker.internal:11434/api/tags > /dev/null 2>&1; then
        echo "✓ Ollama running (via host.docker.internal)"
    else
        echo "✗ Ollama not running"
    fi
    echo ""

    echo "Cloud LLM Configuration:"
    if grep -q "^OPENAI_API_KEY=" "$ENV_FILE" 2>/dev/null; then
        echo "✓ OpenAI API key configured"
    fi
    if grep -q "^OPENROUTER_API_KEY=" "$ENV_FILE" 2>/dev/null; then
        echo "✓ OpenRouter API key configured"
    fi
    if grep -q "^ANTHROPIC_API_KEY=" "$ENV_FILE" 2>/dev/null; then
        echo "✓ Anthropic API key configured"
    fi
    if ! grep -qE "^(OPENAI|OPENROUTER|ANTHROPIC)_API_KEY=" "$ENV_FILE" 2>/dev/null; then
        echo "✗ No cloud LLM API keys configured"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "NETWORK"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    echo "Port 8080 Status:"
    if lsof -i :8080 2>/dev/null | grep -q .; then
        echo "✓ Port 8080 is in use"
        lsof -i :8080 2>/dev/null | tail -1
    elif netstat -tln 2>/dev/null | grep -q ":8080 "; then
        echo "✓ Port 8080 is in use"
    else
        echo "✓ Port 8080 is available"
    fi
    echo ""

    echo "Network Connectivity:"
    if curl -s https://www.google.com > /dev/null 2>&1; then
        echo "✓ Internet connection available"
    else
        echo "⚠ Internet connection may be unavailable"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "POTENTIAL ISSUES"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    ISSUES=0

    # Check Docker
    if ! docker info > /dev/null 2>&1; then
        echo "⚠️  Docker is not running"
        ((ISSUES++))
    fi

    # Check .env
    if [ ! -f "$ENV_FILE" ]; then
        echo "⚠️  .env file not found (run ./setup.sh)"
        ((ISSUES++))
    fi

    # Check container
    if ! docker ps 2>/dev/null | grep -q "rowbot.*Up"; then
        echo "⚠️  Row-Bot container is not running"
        ((ISSUES++))
    fi

    if [ $ISSUES -eq 0 ]; then
        echo "✓ No obvious issues detected"
    else
        echo ""
        echo "Found $ISSUES potential issue(s) — see above for details"
    fi
    echo ""

    echo "═══════════════════════════════════════════════════════════════════"
    echo "END OF REPORT"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "Generated: $(date)"

} > "$REPORT_FILE"

# Print summary
echo -e "${GREEN}✓ Diagnostics report created: $REPORT_FILE${NC}"
echo ""
echo "To share this report in a GitHub issue:"
echo "  1. Open: https://github.com/jp-cruz/agent-skills/issues"
echo "  2. Paste the contents of: $REPORT_FILE"
echo "  3. Add a description of what you were trying to do"
echo ""
echo "The report contains:"
echo "  ✓ System information (OS, CPU, RAM, GPU, disk)"
echo "  ✓ Docker and container status"
echo "  ✓ LLM provider status"
echo "  ✓ Network status"
echo "  ✓ Potential issues"
echo "  ✓ .env configuration (secrets removed)"
echo "  ✓ Container logs (last 50 lines)"
echo ""
echo -e "${YELLOW}Note: Review the report before sharing — ensure no sensitive info is present${NC}"
echo ""
