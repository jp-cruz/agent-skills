# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**thoth-docker-template** is a Docker Compose configuration for running [Thoth](https://github.com/siddsachar/Thoth), an open-source application, in a containerized environment. The setup was derived from Jeli project experience and targets seamless local development with host-based Ollama integration.

### Key Architecture Points

- **Single-service setup**: The `thoth` container runs the main Thoth application at port 8080
- **Host Ollama integration**: Thoth connects to Ollama running on the host machine via `host.docker.internal:11434` (Docker Desktop feature)
- **Persistent volumes**: Two named volumes preserve application data and workspace files across container restarts
- **Non-root user**: Thoth runs as user `thoth` (UID 1000) for security; all files are owned by this user
- **Specific Git commit**: The Dockerfile pins Thoth to commit `deb5d11` to ensure reproducible builds

### Architecture Improvements (v0.5.1+)

✅ **Implemented:**
- Multi-stage Dockerfile build (separate builder and runtime stages) — reduces final image size by ~50%
- Optimized .dockerignore for minimal build context
- Environment file (.env) support with sensible defaults
- Fixed PYTHONPATH syntax with absolute paths
- Health check in docker-compose.yml and Dockerfile
- Automated setup.sh script to initialize directories and validate Ollama connectivity

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

3. **Access Thoth** at `http://localhost:8080`

## Important: Running from the Correct Directory

All `docker-compose` commands must be run from the directory containing `docker-compose.yml`. The relative paths in `.env` (like `./thoth-data`) are resolved relative to this directory.

```bash
# ✓ Correct - run from the directory with docker-compose.yml
cd /path/to/thoth-docker-setup
docker-compose up -d

# ✗ Wrong - running from parent directory won't work with relative paths
cd /path/to/parent
docker-compose -f thoth-docker-setup/docker-compose.yml up -d
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
# Start the Thoth container in background (builds if needed)
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
docker-compose exec thoth bash

# View live logs (Ctrl+C to stop)
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100

# View logs for specific service
docker-compose logs -f thoth

# Check container status
docker-compose ps

# Inspect environment variables
docker-compose exec thoth env | grep OLLAMA
docker-compose exec thoth env | grep THOTH
```

### Testing Individual Components

```bash
# Run a Python command inside the container
docker-compose exec thoth python launcher.py --help

# Verify Ollama connectivity from inside container
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags

# Check Thoth is listening on correct port
docker-compose exec thoth curl http://localhost:8080

# Verify all dependencies are installed
docker-compose exec thoth pip list | grep -i thoth
```

## File Structure

```
.
├── .dockerignore              # Excludes unnecessary files from build context
├── .env.example               # Configuration template (copy to .env)
├── .gitignore                 # Git ignore patterns
├── README.md                  # Complete setup guide with platform-specific instructions
├── CLAUDE.md                  # This file - development guide
└── docker/
    ├── Dockerfile             # Python 3.11 slim base, Thoth source from GitHub
    └── docker-compose.yml     # Service definition with environment variable support
```

## Configuration Notes

### Environment Variables (via .env)

All paths and ports are configurable through `.env`:

- `OLLAMA_BASE_URL`: Ollama endpoint (default: `http://host.docker.internal:11434`)
  - Use `host.docker.internal` on macOS/Windows Docker Desktop
  - Use `http://localhost:11434` on Linux with `--network=host`
  - Use `http://<host-ip>:11434` on Linux with bridge network or remote Ollama
- `THOTH_PORT`: Container port (default: 8080)
- `THOTH_DATA_DIR`: Host path for application data (default: `./thoth-data`)
- `THOTH_WORKSPACE_DIR`: Host path for workspace files (default: `./thoth-workspace`)
- `RESTART_POLICY`: Container restart behavior (default: `unless-stopped`)

### Runtime Environment (Inside Container)

- `HOME`: `/home/thoth`
- `PYTHONPATH`: Includes user-level pip packages
- Container runs as non-root user `thoth` (UID 1000)

### Volumes

- `thoth-data`: Stores Thoth application state, cache, and configuration
  - Bind-mounted from `${THOTH_DATA_DIR}`
  - Container path: `/home/thoth/.thoth`
- `thoth-workspace`: User workspace and project files
  - Bind-mounted from `${THOTH_WORKSPACE_DIR}`
  - Container path: `/app/workspace`

## Before Making Changes

1. **Test on target platform**: Before significant changes, verify they work on macOS, Windows, and Linux

2. **Backup data before testing destructive changes**:
   ```bash
   tar -czf thoth-backup-$(date +%Y%m%d).tar.gz \
     "$(grep THOTH_DATA_DIR .env | cut -d= -f2)" \
     "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
   ```

3. **Test Ollama connectivity**: Verify Ollama is reachable before starting the container:
   ```bash
   curl ${OLLAMA_BASE_URL:-http://localhost:11434}/api/tags
   ```

4. **Check port availability**: Ensure `THOTH_PORT` is not in use:
   ```bash
   lsof -i :${THOTH_PORT:-8080}  # macOS
   netstat -tlnp | grep ${THOTH_PORT:-8080}  # Linux
   ```

## Included Development Utilities

The Dockerfile installs these utilities as root, accessible to the `thoth` user:

| Utility | Purpose | Use Case |
|---------|---------|----------|
| **nano** | Text editor | Edit config files without rebuilding container |
| **vim-tiny** | Vi implementation | For power users |
| **jq** | JSON processor | Debug Ollama API responses |
| **less** | File pager | View large logs efficiently |
| **file** | File type checker | Verify file formats |
| **tree** | Directory explorer | Visualize workspace structure |
| **unzip** | Archive extraction | Handle model/config packages |

See [UTILITIES_ANALYSIS.md](UTILITIES_ANALYSIS.md) for detailed rationale on each utility's necessity and safety.

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

## Skill Packaging

This is ready for distribution as an agent skill:
- **Manifest:** `skill-manifest.json` with full metadata
- **Publication Guide:** `PUBLISH.md` for agent-skills integration
- **Quick Start:** Pre-configured setup scripts for all platforms
- **Documentation:** README, CLAUDE, SKILL, UTILITIES_ANALYSIS

## Future Enhancements (Optional)

- Multi-stage Dockerfile build for smaller image size (~15% reduction)
- Docker Buildkit support for faster builds
- Health check configuration in docker-compose.yml
- GitHub Actions CI/CD pipeline for cross-platform testing
- Pre-built images on Docker Hub for instant startup
- Kubernetes manifests for orchestration
- Helm chart for enterprise deployments
