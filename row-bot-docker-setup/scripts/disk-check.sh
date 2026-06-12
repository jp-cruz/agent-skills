#!/bin/bash
# Row-Bot Docker Storage Assessment
# Detects all mounted drives, recommends optimal storage locations
# Exports DISK_CHECK_RECOMMENDED_* env vars for setup.sh to consume
# Bash 3.x compatible (no associative arrays)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse flags: --quiet (legacy), --export-only (exports vars, no output)
QUIET=0
EXPORT_ONLY=0

if [ "$1" = "--quiet" ]; then
    QUIET=1
elif [ "$1" = "--export-only" ]; then
    QUIET=1
    EXPORT_ONLY=1
fi

log() {
    if [ $QUIET -eq 0 ]; then
        echo -e "$@"
    fi
}

log "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
log "${BLUE}║          ROW-BOT DOCKER STORAGE ASSESSMENT                              ║${NC}"
log "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"

# ============================================================================
# OS DETECTION
# ============================================================================

OS="unknown"
if [ "$OSTYPE" = "darwin" ] || [ "$OSTYPE" = "darwin18.6.0" ] || echo "$OSTYPE" | grep -q "^darwin"; then
    OS="macos"
elif echo "$OSTYPE" | grep -q "^linux"; then
    OS="linux"
elif [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    OS="windows"
fi

log "\n${GREEN}[1/6] SYSTEM INFORMATION${NC}"
log "  OS: $OS"
log "  Architecture: $(uname -m)"

# ============================================================================
# SYSTEM DRIVE STATUS
# ============================================================================

log "\n${GREEN}[2/6] SYSTEM DRIVE STATUS${NC}"

SYSTEM_FREE_KB=$(df -k / | tail -1 | awk '{print $4}')
SYSTEM_FREE_GB=$((SYSTEM_FREE_KB / 1024 / 1024))
SYSTEM_TOTAL_KB=$(df -k / | tail -1 | awk '{print $2}')
SYSTEM_TOTAL_GB=$((SYSTEM_TOTAL_KB / 1024 / 1024))
SYSTEM_USED_GB=$((SYSTEM_TOTAL_GB - SYSTEM_FREE_GB))

log "  System Drive: / (Macintosh HD / root)"
log "  Total: ${SYSTEM_TOTAL_GB}GB"
log "  Used: ${SYSTEM_USED_GB}GB"
log "  Free: ${SYSTEM_FREE_GB}GB"

# Determine warning level
DISK_CHECK_WARNING_LEVEL="ok"
if [ $SYSTEM_FREE_GB -lt 30 ]; then
    log "  ${RED}✗ CRITICAL: Less than 30GB free${NC}"
    DISK_CHECK_WARNING_LEVEL="critical"
elif [ $SYSTEM_FREE_GB -lt 50 ]; then
    log "  ${RED}✗ WARNING: Less than 50GB free${NC}"
    DISK_CHECK_WARNING_LEVEL="warn"
elif [ $SYSTEM_FREE_GB -lt 100 ]; then
    log "  ${YELLOW}⚠ CAUTION: Less than 100GB free${NC}"
    DISK_CHECK_WARNING_LEVEL="warn"
else
    log "  ${GREEN}✓ Adequate space${NC}"
fi

export DISK_CHECK_SYSTEM_FREE_GB=$SYSTEM_FREE_GB
export DISK_CHECK_WARNING_LEVEL

# ============================================================================
# EXTERNAL DRIVE DETECTION (Simplified for Bash 3.x)
# ============================================================================

log "\n${GREEN}[3/6] DETECTING EXTERNAL DRIVES${NC}"

# Store drives as temp file instead of associative array
DRIVES_FILE=$(mktemp)
trap "rm -f $DRIVES_FILE" EXIT

BEST_DRIVE=""
BEST_SCORE=0

if [ "$OS" = "macos" ]; then
    # Get all mounted volumes excluding system volumes
    df | tail -n +2 | awk '{print $NF}' | while read -r MOUNT; do
        if [ -z "$MOUNT" ]; then
            continue
        fi

        # Skip system volumes and special mounts
        if echo "$MOUNT" | grep -qE "^/System/|^/dev$|^/proc|^/private|^/var$" || [ "$MOUNT" = "/" ]; then
            continue
        fi

        # Get free space
        FREE_KB=$(df -k "$MOUNT" 2>/dev/null | tail -1 | awk '{print $4}')
        if [ -z "$FREE_KB" ]; then
            continue
        fi

        FREE_GB=$((FREE_KB / 1024 / 1024))
        TOTAL_KB=$(df -k "$MOUNT" 2>/dev/null | tail -1 | awk '{print $2}')
        TOTAL_GB=$((TOTAL_KB / 1024 / 1024))

        # Try to determine if external
        IS_EXTERNAL=0
        DRIVE_TYPE="unknown"

        # Check if mounted volume is external via diskutil
        DISK_NAME=$(diskutil info "$MOUNT" 2>/dev/null | grep "Device Identifier" | awk '{print $NF}')
        if [ -n "$DISK_NAME" ]; then
            if diskutil info "$DISK_NAME" 2>/dev/null | grep -q "Internal.*No"; then
                IS_EXTERNAL=1
            fi

            # Try to get connection type
            if diskutil info "$DISK_NAME" 2>/dev/null | grep -q "Protocol.*USB"; then
                DRIVE_TYPE="USB"
            elif diskutil info "$DISK_NAME" 2>/dev/null | grep -q "Protocol.*Thunderbolt"; then
                DRIVE_TYPE="Thunderbolt"
            fi
        fi

        # Only include external drives
        if [ $IS_EXTERNAL -eq 1 ] && [ $FREE_GB -gt 10 ]; then
            echo "$MOUNT|$FREE_GB|$TOTAL_GB|$DRIVE_TYPE" >> $DRIVES_FILE
            log "  ✓ $(basename "$MOUNT") — ${DRIVE_TYPE:-External} | ${FREE_GB}GB free of ${TOTAL_GB}GB"
        fi
    done

elif [ "$OS" = "linux" ]; then
    # On Linux, find external mounts
    df | tail -n +2 | awk '{print $NF}' | while read -r MOUNT; do
        if [ -z "$MOUNT" ]; then
            continue
        fi

        if echo "$MOUNT" | grep -qE "^/sys|^/proc|^/dev$|^/run" || [ "$MOUNT" = "/" ]; then
            continue
        fi

        FREE_KB=$(df -k "$MOUNT" 2>/dev/null | tail -1 | awk '{print $4}')
        if [ -z "$FREE_KB" ]; then
            continue
        fi

        FREE_GB=$((FREE_KB / 1024 / 1024))
        TOTAL_KB=$(df -k "$MOUNT" 2>/dev/null | tail -1 | awk '{print $2}')
        TOTAL_GB=$((TOTAL_KB / 1024 / 1024))

        # Only include non-root mounts with >10GB free
        if [ "$MOUNT" != "/" ] && [ $FREE_GB -gt 10 ]; then
            echo "$MOUNT|$FREE_GB|$TOTAL_GB|USB" >> $DRIVES_FILE
            log "  ✓ $(basename "$MOUNT") — USB | ${FREE_GB}GB free of ${TOTAL_GB}GB"
        fi
    done
fi

# Count and process drives
DRIVE_COUNT=$([ -f "$DRIVES_FILE" ] && wc -l < "$DRIVES_FILE" || echo 0)
if [ "$DRIVE_COUNT" -eq 0 ]; then
    log "  ✗ No external drives with >10GB free detected"
fi

# ============================================================================
# DOCKER STORAGE ANALYSIS
# ============================================================================

log "\n${GREEN}[4/6] DOCKER STORAGE ANALYSIS${NC}"

if command -v docker >/dev/null 2>&1; then
    DOCKER_ROOT=$(docker system info 2>/dev/null | grep "Docker Root Dir" | awk '{print $NF}')
    if [ -n "$DOCKER_ROOT" ]; then
        log "  Docker Data Root: $DOCKER_ROOT"
    else
        log "  ✗ Docker not running"
    fi
else
    log "  ✗ Docker not installed"
fi

# ============================================================================
# RECOMMENDATION ENGINE
# ============================================================================

log "\n${GREEN}[5/6] STORAGE RECOMMENDATION${NC}"

DISK_CHECK_RECOMMENDED_DATA_DIR=""
DISK_CHECK_RECOMMENDED_WORKSPACE_DIR=""
BEST_DRIVE=""

if [ -f "$DRIVES_FILE" ] && [ -s "$DRIVES_FILE" ]; then
    # Find best drive by free space
    while IFS='|' read -r MOUNT FREE TOTAL TYPE; do
        SCORE=$((FREE * 10))  # Score by free space

        # Boost score for Thunderbolt
        if [ "$TYPE" = "Thunderbolt" ]; then
            SCORE=$((SCORE + 500))
        fi

        if [ $SCORE -gt $BEST_SCORE ]; then
            BEST_SCORE=$SCORE
            BEST_DRIVE="$MOUNT"
        fi
    done < "$DRIVES_FILE"

    if [ -n "$BEST_DRIVE" ]; then
        DISK_CHECK_RECOMMENDED_DATA_DIR="${BEST_DRIVE}/rowbot-data"
        DISK_CHECK_RECOMMENDED_WORKSPACE_DIR="${BEST_DRIVE}/rowbot-workspace"

        log "  ${GREEN}✓ Recommended external drive found:${NC}"
        log "    Location: $BEST_DRIVE"
        log "    Suggested paths:"
        log "      ROW_BOT_DATA_DIR=$DISK_CHECK_RECOMMENDED_DATA_DIR"
        log "      ROW_BOT_WORKSPACE_DIR=$DISK_CHECK_RECOMMENDED_WORKSPACE_DIR"
    fi
else
    log "  ${YELLOW}⚠ No external drive found${NC}"
    if [ "$DISK_CHECK_WARNING_LEVEL" = "critical" ]; then
        log "    ${RED}CRITICAL: System drive only, but < 30GB free${NC}"
    elif [ "$DISK_CHECK_WARNING_LEVEL" = "warn" ]; then
        log "    ${YELLOW}WARNING: System drive only, < 100GB free${NC}"
    fi
fi

# ============================================================================
# GROWTH WARNING
# ============================================================================

log "\n${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
log "${BLUE}║                   ROW-BOT GROWTH EXPECTATIONS                            ║${NC}"
log "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"

log ""
log "${YELLOW}⚠  DISK SPACE GROWTH:${NC}"
log "  • Row-Bot memory grows 1–3 GB per week of active use"
log "  • After 2–3 weeks: ~10 GB typical"
log "  • After 1 month: ~15–20 GB"
log "  • Long-running systems: can reach 50+ GB"
log ""
log "  Plan accordingly: use external storage for rowbot-data and rowbot-workspace"
log "  See references/DISK_MANAGEMENT.md for cleanup and archival strategies"

# Export variables
export DISK_CHECK_RECOMMENDED_DATA_DIR
export DISK_CHECK_RECOMMENDED_WORKSPACE_DIR

log "\n${GREEN}✓ Storage assessment complete.${NC}\n"
