#!/bin/bash
# Row-Bot Disk Maintenance & Cleanup Utility
# Manages cleanup, archival, and monitoring of Row-Bot disk usage

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect if running in auto mode
AUTO_MODE=0
if [[ "$1" == "auto" ]]; then
    AUTO_MODE=1
fi

# Find .env file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "${RED}✗ .env not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Source .env
set -a
source "$ENV_FILE"
set +a

# Resolve paths
ROWBOT_DATA_DIR="${ROWBOT_DATA_DIR:-.}"
ROWBOT_WORKSPACE_DIR="${ROWBOT_WORKSPACE_DIR:-.}"

# Make paths absolute
if [[ "$ROWBOT_DATA_DIR" != /* ]]; then
    ROWBOT_DATA_DIR="$SCRIPT_DIR/$ROWBOT_DATA_DIR"
fi
if [[ "$ROWBOT_WORKSPACE_DIR" != /* ]]; then
    ROWBOT_WORKSPACE_DIR="$SCRIPT_DIR/$ROWBOT_WORKSPACE_DIR"
fi

if [[ $AUTO_MODE -eq 0 ]]; then
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          ROW-BOT DISK MAINTENANCE & CLEANUP                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
fi

# ============================================================================
# USAGE REPORT
# ============================================================================

if [[ $AUTO_MODE -eq 0 ]]; then
    echo -e "\n${GREEN}[1/3] CURRENT DISK USAGE${NC}\n"

    if [[ -d "$ROWBOT_DATA_DIR" ]]; then
        DATA_SIZE=$(du -sh "$ROWBOT_DATA_DIR" 2>/dev/null | awk '{print $1}')
        echo "  Row-Bot Data: $DATA_SIZE"
    else
        echo "  Row-Bot Data: Not found ($ROWBOT_DATA_DIR)"
    fi

    if [[ -d "$ROWBOT_WORKSPACE_DIR" ]]; then
        WORKSPACE_SIZE=$(du -sh "$ROWBOT_WORKSPACE_DIR" 2>/dev/null | awk '{print $1}')
        echo "  Workspace: $WORKSPACE_SIZE"
    else
        echo "  Workspace: Not found ($ROWBOT_WORKSPACE_DIR)"
    fi

    # Docker usage
    if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
        echo ""
        echo "  Docker System:"
        docker system df --format "table {{.Type}}\t{{.Used}}\t{{.TotalCount}}" 2>/dev/null | \
            awk 'NR>1 {printf "    %-12s Used: %-10s Items: %d\n", $1, $2, $3}' || true
    fi

    # Estimate total
    THOTH_DATA_MB=$(du -sm "$ROWBOT_DATA_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
    THOTH_WORKSPACE_MB=$(du -sm "$ROWBOT_WORKSPACE_DIR" 2>/dev/null | awk '{print $1}' || echo 0)
    TOTAL_MB=$((THOTH_DATA_MB + THOTH_WORKSPACE_MB))

    echo ""
    echo -e "  ${YELLOW}Total Thoth Usage: ~${TOTAL_MB} MB${NC}"
    echo ""
fi

# ============================================================================
# CLEANUP MENU
# ============================================================================

if [[ $AUTO_MODE -eq 0 ]]; then
    echo -e "${GREEN}[2/3] CLEANUP OPTIONS${NC}\n"
    echo "  [1] Clean Docker build cache (frees 500MB–2GB)"
    echo "  [2] Remove stopped containers"
    echo "  [3] Remove dangling images"
    echo "  [4] Truncate Thoth logs"
    echo "  [5] Archive old workspace (interactive)"
    echo "  [6] Deep clean (all of 1–4)"
    echo "  [0] Exit"
    echo ""
    read -p "Choose an option [0-6]: " CHOICE
else
    # Auto mode: run 1-4
    CHOICE=6
fi

# Helper function: run cleanup task
cleanup_docker_build_cache() {
    if docker builder prune -f &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Docker build cache cleaned${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠ Docker build cache cleanup skipped (docker not available)${NC}"
        return 0
    fi
}

cleanup_stopped_containers() {
    if docker container prune -f &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Stopped containers removed${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠ Container cleanup skipped (docker not available)${NC}"
        return 0
    fi
}

cleanup_dangling_images() {
    if docker image prune -f &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Dangling images removed${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠ Image cleanup skipped (docker not available)${NC}"
        return 0
    fi
}

truncate_logs() {
    if [[ -f "$ROWBOT_DATA_DIR/thoth_app.log" ]]; then
        > "$ROWBOT_DATA_DIR/thoth_app.log"
        echo -e "  ${GREEN}✓ Thoth logs truncated${NC}"
    fi
    return 0
}

execute_cleanup() {
    case "$1" in
        1)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Running cleanup...${NC}\n"
            fi
            cleanup_docker_build_cache
            ;;
        2)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Running cleanup...${NC}\n"
            fi
            cleanup_stopped_containers
            ;;
        3)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Running cleanup...${NC}\n"
            fi
            cleanup_dangling_images
            ;;
        4)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Running cleanup...${NC}\n"
            fi
            truncate_logs
            ;;
        5)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Archive workspace${NC}\n"
                read -p "Destination path for archive (e.g., /Volumes/External/thoth-backup): " ARCHIVE_DEST

                if [[ ! -d "$ARCHIVE_DEST" ]]; then
                    echo -e "${RED}✗ Destination not found: $ARCHIVE_DEST${NC}"
                    return 1
                fi

                ARCHIVE_FILE="$ARCHIVE_DEST/thoth-workspace-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
                echo -e "  Creating archive: $ARCHIVE_FILE"
                tar -czf "$ARCHIVE_FILE" -C "$(dirname "$ROWBOT_WORKSPACE_DIR")" "$(basename "$ROWBOT_WORKSPACE_DIR")"
                echo -e "  ${GREEN}✓ Workspace archived${NC}"
            fi
            ;;
        6)
            if [[ $AUTO_MODE -eq 0 ]]; then
                echo -e "\n${YELLOW}Deep clean: running all cleanup operations...${NC}\n"
            fi
            cleanup_docker_build_cache
            cleanup_stopped_containers
            cleanup_dangling_images
            truncate_logs
            ;;
        0)
            echo -e "${GREEN}Exiting without changes${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
}

# Execute the chosen cleanup
execute_cleanup "$CHOICE"

# ============================================================================
# CRON SCHEDULING (interactive mode only)
# ============================================================================

if [[ $AUTO_MODE -eq 0 ]] && [[ "$CHOICE" != "0" ]]; then
    echo ""
    read -p "Schedule automatic weekly cleanup? [y/N] " SCHEDULE_CRON

    if [[ "$SCHEDULE_CRON" == "y" || "$SCHEDULE_CRON" == "Y" ]]; then
        CRON_CMD="0 3 * * 0 $SCRIPT_DIR/scripts/thoth-maintenance.sh auto >> ~/.thoth-maintenance.log 2>&1"

        # Check if already scheduled
        if crontab -l 2>/dev/null | grep -q "thoth-maintenance.sh auto"; then
            echo -e "${YELLOW}⚠ Cron job already scheduled${NC}"
        else
            # Add to crontab
            (
                crontab -l 2>/dev/null || true
                echo "$CRON_CMD"
            ) | crontab -

            echo -e "${GREEN}✓ Cron job scheduled${NC}"
            echo "  Runs: Every Sunday at 3:00 AM"
            echo "  Log: ~/.thoth-maintenance.log"
        fi
    fi

    echo ""
    echo -e "${GREEN}✓ Maintenance complete${NC}\n"
fi
