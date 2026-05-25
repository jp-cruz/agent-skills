#!/bin/bash
# Thoth Docker Template Setup Script
# Initializes .env, creates data directories, and validates prerequisites
# Optional: Run './preflight-check.sh' first for detailed assessment

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Thoth Docker Template Setup${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Tip: Run './preflight-check.sh' first for detailed environment assessment${NC}"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo -e "${YELLOW}⚠️  .env already exists. Skipping creation.${NC}"
else
    echo -e "${GREEN}✓ Creating .env from .env.example${NC}"
    cp .env.example .env
    echo -e "${GREEN}  → .env created. Please edit to customize paths and settings.${NC}"
fi

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo -e "${GREEN}✓ Detected OS: ${OS}${NC}"

# Extract paths from .env
THOTH_DATA_DIR=$(grep "^THOTH_DATA_DIR=" .env | cut -d= -f2)
THOTH_WORKSPACE_DIR=$(grep "^THOTH_WORKSPACE_DIR=" .env | cut -d= -f2)
THOTH_PORT=$(grep "^THOTH_PORT=" .env | cut -d= -f2)
OLLAMA_BASE_URL=$(grep "^OLLAMA_BASE_URL=" .env | cut -d= -f2)

# Expand ~ if present
THOTH_DATA_DIR="${THOTH_DATA_DIR/#\~/$HOME}"
THOTH_WORKSPACE_DIR="${THOTH_WORKSPACE_DIR/#\~/$HOME}"

echo -e "\n${GREEN}Configuration:${NC}"
echo "  Data Directory:      $THOTH_DATA_DIR"
echo "  Workspace Directory: $THOTH_WORKSPACE_DIR"
echo "  Thoth Port:          $THOTH_PORT"
echo "  Ollama URL:          $OLLAMA_BASE_URL"

# Create directories
echo -e "\n${GREEN}✓ Creating data directories${NC}"
mkdir -p "$THOTH_DATA_DIR"
mkdir -p "$THOTH_WORKSPACE_DIR"
echo -e "${GREEN}  → Directories created${NC}"

# Check Docker
echo -e "\n${GREEN}✓ Checking Docker installation${NC}"
if ! ./check-docker.sh 2>&1 | grep -q "ALL CHECKS PASSED"; then
    echo -e "${RED}Docker check failed. Please see DOCKER_GUIDE_FOR_BEGINNERS.md${NC}"
    exit 1
fi

# Check Ollama
echo -e "\n${GREEN}✓ Checking Ollama connectivity${NC}"
if curl -s "${OLLAMA_BASE_URL}/api/tags" > /dev/null 2>&1; then
    MODELS=$(curl -s "${OLLAMA_BASE_URL}/api/tags" | grep -o '"name":"[^"]*"' | wc -l)
    echo -e "${GREEN}  ✓ Ollama is running and reachable${NC}"
    echo -e "${GREEN}  → Available models: $MODELS${NC}"
else
    echo -e "${YELLOW}  ⚠️  Ollama is not reachable at ${OLLAMA_BASE_URL}${NC}"
    echo -e "${YELLOW}     Start Ollama before running docker-compose up${NC}"
fi

# Check port availability
echo -e "\n${GREEN}✓ Checking port ${THOTH_PORT}${NC}"
if [[ "$OS" == "macos" ]]; then
    if ! lsof -i ":${THOTH_PORT}" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Port ${THOTH_PORT} is available${NC}"
    else
        echo -e "${RED}  ✗ Port ${THOTH_PORT} is already in use${NC}"
        echo -e "${RED}     Change THOTH_PORT in .env and re-run setup${NC}"
        exit 1
    fi
elif [[ "$OS" == "linux" ]]; then
    if ! netstat -tlnp 2>/dev/null | grep -q ":${THOTH_PORT} " ; then
        echo -e "${GREEN}  ✓ Port ${THOTH_PORT} is available${NC}"
    else
        echo -e "${RED}  ✗ Port ${THOTH_PORT} is already in use${NC}"
        exit 1
    fi
fi

# Summary
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${GREEN}Next steps:${NC}"
echo "  1. Review and customize .env if needed"
echo "  2. Ensure Ollama is running: ollama serve"
echo "  3. Start Thoth: docker-compose up -d"
echo "  4. Open http://localhost:${THOTH_PORT}"
echo ""
echo -e "${GREEN}Useful commands:${NC}"
echo "  docker-compose up -d          # Start in background"
echo "  docker-compose logs -f        # View logs"
echo "  docker-compose ps             # Check status"
echo "  docker-compose exec thoth bash # Open shell in container"
echo ""
