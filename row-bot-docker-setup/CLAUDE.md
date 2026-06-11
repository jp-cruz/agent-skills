# CLAUDE.md — Row-Bot Docker Development Guide

This file provides guidance to Claude Code (claude.ai/code) when working with code in this skill repository.

## Project Overview

**row-bot-docker-setup** is a Docker Compose configuration for running [Row-Bot](https://github.com/siddsachar/row-bot), an open-source desktop AI application, in a containerized environment. The setup was derived from Thoth project experience and migration learnings (Thoth → Row-Bot rebrand, 2026-05-28 through 2026-06-05).

Row-Bot is now a desktop application, but containerization provides:
- Isolation: Failures contained to the container
- Consistency: Same setup works on macOS, Linux, Windows
- Reproducibility: Volumes backup/restore complete state

### Key Architecture Points

- **Single-service setup**: The `rowbot` container runs Row-Bot at port 8080
- **Host Ollama integration**: Row-Bot connects to Ollama on the host via `host.docker.internal:11434` (Docker Desktop) or `localhost:11434` (Linux with `--network=host`)
- **Persistent volumes**: Two named volumes preserve application data and workspace files across container restarts
- **Non-root user**: Row-Bot runs as user `rowbot` (UID 1000) for security; all files owned by this user
- **Git source**: Dockerfile clones from `https://github.com/siddsachar/row-bot.git` (latest)

### Architecture Improvements (v0.5.0)

✅ **Implemented:**
- Multi-stage Dockerfile build (separate builder and runtime stages) — reduces final image size by ~50%
- **Pure Docker volumes** (not host bind mounts) for portable, upgradeable setup
- Optimized .dockerignore for minimal build context
- Environment file (.env) support with sensible defaults
- Fixed PYTHONPATH syntax with absolute paths
- Health check in docker-compose.yml and Dockerfile
- Automated setup.sh script to initialize directories and validate Ollama connectivity
- **All required utilities in runtime** (git, nano, jq, less, tree, file, unzip, vim-tiny) — MUST NOT be removed
- **Developer Studio symlink** for workspace accessibility (`/home/rowbot/Documents/Row-Bot/projects`)
- Tested upgrade and disaster recovery procedures
- **Lessons learned from bare-metal migrations:** SQLite WAL handling, path migration, API key management — documented in MIGRATION_NOTES.md

## Quick Start

1. **Initialize the setup** (first time only):
   ```bash
   cd /path/to/docker-compose.yml  # This directory contains docker-compose.yml
   ./setup.sh
   ```

2. **Start the container**:
   ```bash
   docker-compose up -d
   ```

3. **Access Row-Bot** at `http://localhost:8080`

## Important: Running from the Correct Directory

All `docker-compose` commands must be run from the directory containing `docker-compose.yml`. The relative paths in `.env` (like `./rowbot-data`) are resolved relative to this directory.

```bash
# ✓ Correct - run from the directory with docker-compose.yml
cd /path/to/row-bot-docker-setup
docker-compose up -d

# ✗ Wrong - running from parent directory won't work with relative paths
cd /path/to/parent
docker-compose -f row-bot-docker-setup/docker-compose.yml up -d
```

## Common Commands

### Building

```bash
# Build the Docker image from the Dockerfile
docker-compose build

# Build with no cache (fresh rebuild)
docker-compose build --no-cache

# Build and start in one command
docker-compose up -d --build
```

### Running

```bash
# Start the Row-Bot container in background (builds if needed)
docker-compose up -d

# Start in foreground and watch logs
docker-compose up

# Stop the container
docker-compose stop

# Fully remove container
docker-compose down

# Remove container and volumes (⚠️ deletes persistent data)
docker-compose down -v

# Remove everything including the image
docker-compose down -v --rmi all
```

### Development & Debugging

```bash
# Open a shell inside the running container
docker-compose exec rowbot bash

# View live logs (Ctrl+C to stop)
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100

# View logs for specific service
docker-compose logs -f rowbot

# Check container status
docker-compose ps

# Inspect environment variables
docker-compose exec rowbot env | grep OLLAMA
docker-compose exec rowbot env | grep ROWBOT
```

### Testing Individual Components

```bash
# Run a Python command inside the container
docker-compose exec rowbot python launcher.py --help

# Verify Ollama connectivity from inside container
docker-compose exec rowbot curl http://host.docker.internal:11434/api/tags

# Check Row-Bot is listening on correct port
docker-compose exec rowbot curl http://localhost:8080

# Verify all dependencies are installed
docker-compose exec rowbot pip list | grep -i row
```

## File Structure

```
.
├── .dockerignore              # Excludes unnecessary files from build context
├── .env.example               # Configuration template (copy to .env)
├── .gitignore                 # Git ignore patterns
├── README.md                  # Complete setup guide with platform-specific instructions
├── MIGRATION_NOTES.md         # Bare-metal to Docker migration guide (lessons learned)
├── CLAUDE.md                  # This file - development guide
└── docker/
    ├── Dockerfile             # Python 3.11 slim base, Row-Bot from GitHub
    └── entrypoint.sh          # Startup script for symlink/directory setup
```

## Configuration Notes

### Environment Variables (via .env)

All paths and ports are configurable through `.env`:

- `OLLAMA_BASE_URL`: Ollama endpoint (default: `http://host.docker.internal:11434`)
  - Use `host.docker.internal` on macOS/Windows Docker Desktop
  - Use `http://localhost:11434` on Linux with `--network=host`
  - Use `http://<host-ip>:11434` on Linux with bridge network or remote Ollama
- `ROWBOT_PORT`: Container port (default: 8080)
- `ROWBOT_BIND`: Host binding for web access (default: 127.0.0.1 for localhost only)
- `ROWBOT_DATA_DIR`: Host path for application data (deprecated, pure volumes used instead)
- `ROWBOT_WORKSPACE_DIR`: Host path for workspace files (deprecated, pure volumes used instead)
- `RESTART_POLICY`: Container restart behavior (default: `unless-stopped`)

### Runtime Environment (Inside Container)

- `HOME`: `/home/rowbot`
- `PYTHONPATH`: Includes user-level pip packages
- Container runs as non-root user `rowbot` (UID 1000)

### Volumes (Pure Docker Volumes - Production Ready)

This setup uses **pure Docker volumes** (not host bind mounts) for maximum stability and portability:

- `rowbot-data`: Stores Row-Bot application state, cache, and configuration
  - **Location**: `/var/lib/docker/volumes/row-bot-docker-setup_rowbot-data/_data`
  - **Container path**: `/home/rowbot/.row-bot`
  - **Contents**: memory.db, memory_vectors, vault, api_keys.json, projects, configs
  - **Portability**: Works identically on any machine with Docker (no host path dependencies)
  
- `rowbot-workspace`: User workspace and project files
  - **Location**: `/var/lib/docker/volumes/row-bot-docker-setup_rowbot-workspace/_data`
  - **Container path**: `/app/workspace`
  - **Portability**: Fully portable

**Why pure Docker volumes (not bind mounts)?**
- ✅ Portable: Same volumes work on any Docker host (macOS, Linux, Windows, cloud)
- ✅ Upgrades are safe: Volumes persist across image updates and Row-Bot version upgrades
- ✅ Disaster recovery is clean: Backup/restore volumes anywhere
- ✅ No host filesystem dependencies: Data stays with Docker, not tied to `/path/on/host`
- ✅ Permission-safe: Consistent UID/GID handling (rowbot user = UID 1000)

## Before Making Changes

1. **Test on target platform**: Before significant changes, verify they work on macOS, Windows, and Linux

2. **Backup data before testing destructive changes**:
   ```bash
   docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
     -v ./backups:/backup alpine tar czf /backup/rowbot-data-$(date +%Y%m%d).tar.gz -C /data .
   ```

3. **Test Ollama connectivity**: Verify Ollama is reachable before starting the container:
   ```bash
   curl ${OLLAMA_BASE_URL:-http://localhost:11434}/api/tags
   ```

4. **Check port availability**: Ensure `ROWBOT_PORT` is not in use:
   ```bash
   lsof -i :${ROWBOT_PORT:-8080}  # macOS
   netstat -tlnp | grep ${ROWBOT_PORT:-8080}  # Linux
   ```

## ⚠️ CRITICAL: Required Runtime Utilities

The following utilities **MUST ALWAYS be included** in the Docker runtime stage. These are not optional:

```dockerfile
git curl ffmpeg nano vim-tiny less file tree jq unzip
```

**Why they're mandatory:**
- **git**: Required for committing/pushing changes, managing project state, and Row-Bot's developer tools
- **curl/ffmpeg**: Core Row-Bot dependencies for API calls and media processing
- **nano/vim-tiny**: Essential for editing config files and scripts inside the container
- **less/file/tree**: Debugging and exploration tools that Row-Bot and its skills depend on
- **jq**: JSON processing for API response debugging
- **unzip**: Archive extraction for model packages and configurations

**Do NOT remove these from the runtime stage** even when optimizing image size. They are essential for Row-Bot's functionality and developer workflows. If size optimization is needed, use other strategies (layer caching, image compression, etc.) but keep these utilities installed.

See [UTILITIES_ANALYSIS.md](references/UTILITIES_ANALYSIS.md) for detailed rationale on each utility's necessity and safety.

## Implementation Status

✅ **Complete:**
- [x] Parameterized docker-compose.yml with environment variable substitution
- [x] Created `.dockerignore` for optimized build context
- [x] Added `.env.example` with comprehensive configuration documentation
- [x] Created multi-platform README with Linux/macOS/Windows setup instructions
- [x] Added troubleshooting guide covering common platform-specific issues
- [x] Documented volume backup/restore and data persistence strategies
- [x] Added essential development utilities to Dockerfile (nano, jq, vim-tiny, etc.)
- [x] Created skill structure for agent-skills repository
- [x] Documented utilities analysis and rationale
- [x] Created publication guide for agent-skills
- [x] Added MIGRATION_NOTES.md with bare-metal migration lessons and challenges
- [x] Thoth → Row-Bot rebrand (skill rename, manifest, docker-compose, scripts, documentation)

## Skill Packaging

This is ready for distribution as an agent skill:
- **Manifest:** `skill-manifest.json` with full metadata
- **Publication Guide:** References in README point to agent-skills integration
- **Quick Start:** Pre-configured setup scripts for all platforms
- **Documentation:** README, CLAUDE, SKILL, MIGRATION_NOTES, UTILITIES_ANALYSIS

## Upgrading Row-Bot (Safe & Stable)

To upgrade Row-Bot to a new version:

1. **Update Dockerfile** (line 10):
   ```dockerfile
   RUN git clone https://github.com/siddsachar/row-bot.git . && \
       git checkout <TAG_OR_COMMIT>  # e.g., v1.0.0 or commit hash
   ```

2. **Rebuild and restart**:
   ```bash
   docker-compose build --no-cache
   docker-compose up -d
   ```

3. **Data is completely safe**: Volumes persist across this entire process
   - memory.db, vault, projects, configs all remain intact
   - Container restarts with new Row-Bot code, same data
   - Zero data loss risk

## Disaster Recovery

### Backing up data

```bash
# Full volume backup (includes everything)
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  -v ./backups:/backup alpine tar czf /backup/rowbot-data-$(date +%Y%m%d).tar.gz -C /data .

# Store backup off-machine (critical!)
# Option A: External drive
cp ./backups/rowbot-data-*.tar.gz /Volumes/ExternalDrive/rowbot-backups/

# Option B: Cloud storage (S3, Google Drive, etc.)
```

### Restoring from backup

```bash
# Stop container
docker-compose down

# Restore volume (choose one)
# From local backup:
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  -v ./backups:/backup alpine tar xzf /backup/rowbot-data-YYYYMMDD.tar.gz -C /data

# Fix ownership (files may have different UID after restore)
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  alpine chown -R 1000:1000 /data

# Restart
docker-compose up -d
```

### Testing Your Backup (Critical!)

**You must test that backups actually work before you need them.** Untested backups often fail when you need them most.

**Quarterly backup test procedure:**

```bash
# Step 1: Create a test backup
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  -v ./backups:/backup alpine tar czf /backup/rowbot-test-restore-$(date +%Y%m%d).tar.gz -C /data .

# Step 2: Create a test volume for restore
docker volume create rowbot-test-restore

# Step 3: Restore to test volume
docker run --rm -v rowbot-test-restore:/data \
  -v ./backups:/backup alpine tar xzf /backup/rowbot-test-restore-*.tar.gz -C /data

# Step 4: Fix ownership
docker run --rm -v rowbot-test-restore:/data \
  alpine chown -R 1000:1000 /data

# Step 5: Verify restore by mounting in temporary container
docker run --rm -it -v rowbot-test-restore:/data alpine ls -la /data/Documents/Row-Bot/projects/
# Should list your projects

# Step 6: Check file integrity (spot-check a few files)
docker run --rm -v rowbot-test-restore:/data alpine du -sh /data/memory.db
# Should show non-zero size

# Step 7: Clean up test volume
docker volume rm rowbot-test-restore

# Step 8: Document the test
echo "Backup test passed on $(date)" >> backup-test-log.txt
```

**Red flags (if you see these, your backup has issues):**
- ❌ Tar extraction returns errors
- ❌ Ownership fix shows "operation not permitted"
- ❌ Projects directory is empty
- ❌ memory.db is 0 bytes
- ❌ Any permission denied errors

**What to do if test fails:**
1. Don't trust that backup
2. Create a fresh backup immediately
3. Test the new backup before deleting the old one
4. Investigate what went wrong

**Restore time estimate:**
- Backup creation: 5-10 minutes (for 25GB)
- Restore: 5-10 minutes
- Ownership fix: 1-2 minutes
- Container startup: 30-60 seconds
- **Total: ~20 minutes**

### Important Notes

- **Off-machine storage:** Keep backups on external drives, not just on the same computer
- **Retention policy:** Keep at least 2-3 backups (daily, weekly, monthly)
- **Test quarterly:** Test a full restore procedure at least every 3 months
- **Document recovery:** Write down the exact commands you'd run (save them in a README in your backups folder)

## Troubleshooting Stability

**Issue: Container restarts repeatedly**
- Check logs: `docker-compose logs --tail=50 rowbot`
- Often caused by file permission issues
- Fix: `docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine chown -R 1000:1000 /data`

**Issue: Permission denied on files**
- Happens after restoring backups (files may be owned by different UID)
- Fix ownership: `docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine chown -R 1000:1000 /data`

**Issue: Projects not visible in Developer Studio**
- Ensure symlink exists: `docker-compose exec rowbot ln -s /home/rowbot/.row-bot/Documents/Row-Bot/projects /home/rowbot/Documents/Row-Bot/projects`
- This should be automatic but may need recreation after container rebuilds

## Migration from Bare-Metal Row-Bot

If you're moving from a bare-metal installation, see **[MIGRATION_NOTES.md](MIGRATION_NOTES.md)** for:
- Real-world migration challenges and solutions
- Step-by-step migration procedures
- Data preservation strategies
- API key management
- Validation checklist

The migration guide incorporates lessons learned from actual bare-metal-to-Docker transitions and SQLite data migration pitfalls.

## Future Enhancements (Optional)

- Automatic symlink creation in entrypoint script (for Developer Studio portability)
- Pre-built images on Docker Hub for instant startup
- Kubernetes manifests for orchestration
- Health check improvements for Row-Bot-specific endpoints
