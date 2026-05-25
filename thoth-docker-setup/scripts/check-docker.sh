#!/bin/bash
# Docker Dependency Checker
# Verifies Docker installation and provides helpful guidance if missing

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           DOCKER DEPENDENCY CHECK                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo ""
    echo -e "${YELLOW}Why Docker is required for Thoth:${NC}"
    echo "  • Guarantees identical setup on all machines"
    echo "  • Isolates Thoth from your system"
    echo "  • Easy cleanup (remove container, everything's gone)"
    echo "  • Works on macOS, Windows, and Linux without changes"
    echo ""
    echo -e "${YELLOW}Installation guide:${NC}"
    echo "  See: DOCKER_GUIDE_FOR_BEGINNERS.md"
    echo ""
    echo -e "${YELLOW}Quick start:${NC}"

    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS:"
        echo "    1. Download Docker Desktop:"
        echo "       https://www.docker.com/products/docker-desktop"
        echo "    2. Open the .dmg file"
        echo "    3. Drag Docker.app to Applications"
        echo "    4. Open Applications/Docker.app"
        echo "    5. Verify: docker --version"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  Linux (Ubuntu/Debian):"
        echo "    sudo apt-get update"
        echo "    sudo apt-get install -y docker.io docker-compose"
        echo "    sudo usermod -aG docker \$USER"
        echo "    newgrp docker"
        echo "    Verify: docker --version"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "  Windows:"
        echo "    1. Download Docker Desktop:"
        echo "       https://www.docker.com/products/docker-desktop"
        echo "    2. Run the installer"
        echo "    3. Enable WSL 2 when prompted"
        echo "    4. Restart computer"
        echo "    5. Verify: docker --version"
    fi

    echo ""
    exit 1
fi

# Check Docker version
DOCKER_VERSION=$(docker --version 2>/dev/null)
echo -e "${GREEN}✓ Docker is installed${NC}"
echo "  $DOCKER_VERSION"
echo ""

# Check if Docker daemon is running
if ! docker ps &> /dev/null; then
    echo -e "${RED}✗ Docker daemon is not running${NC}"
    echo ""
    echo -e "${YELLOW}How to fix:${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS: Open Docker.app and wait for 'Docker is running' notification"
        echo "  (This can take 2-3 minutes)"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  Linux: sudo systemctl start docker"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "  Windows: Click Docker icon in system tray or restart Docker Desktop"
    fi

    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Docker daemon is running${NC}"
echo ""

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    echo ""
    echo -e "${YELLOW}How to fix:${NC}"
    echo "  macOS/Windows: Docker Compose is included with Docker Desktop"
    echo "    → Restart Docker Desktop"
    echo "  Linux: sudo apt-get install -y docker-compose"
    echo ""
    exit 1
fi

COMPOSE_VERSION=$(docker-compose --version 2>/dev/null)
echo -e "${GREEN}✓ Docker Compose is installed${NC}"
echo "  $COMPOSE_VERSION"
echo ""

# Test Docker
echo -e "${BLUE}Testing Docker...${NC}"
if docker run --rm hello-world &> /dev/null; then
    echo -e "${GREEN}✓ Docker is working correctly${NC}"
else
    echo -e "${RED}✗ Docker test failed${NC}"
    echo "  Try restarting Docker and running this script again"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ALL CHECKS PASSED - READY TO PROCEED!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Run: ./preflight-check.sh"
echo "  2. Run: ./setup.sh"
echo "  3. Run: docker-compose up -d"
echo "  4. Access: http://localhost:8080"
echo ""
