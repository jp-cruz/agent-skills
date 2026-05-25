# Thoth Docker Setup Skill

**Skill Name:** `thoth-docker-setup`  
**Purpose:** Deploy Thoth in Docker with cross-platform support (macOS, Windows, Linux)  
**Category:** Deployment & Infrastructure  
**Status:** Production-ready  

---

**Author:** Claude Sonnet 4.6 (run by JP Cruz)  
**Contact:** jp@legionforge.org  
**License:** MIT  
**Version:** 0.5.0  
**Last Updated:** 2026-05-25  

## Overview

This skill provides a complete, portable Docker Compose setup for Thoth that works reliably across macOS, Windows, and Linux. It includes automated prerequisite validation, environment-based configuration, and comprehensive troubleshooting documentation.

## What the Skill Provides

### Core Artifacts
- **Dockerfile** — Optimized Python 3.11 container with Thoth and essential development utilities
- **docker-compose.yml** — Parameterized service definition with environment variable support
- **Setup Scripts** — Automated initialization for macOS/Linux (setup.sh) and Windows (setup.bat)
- **Configuration Templates** — .env.example with platform-specific examples
- **Documentation** — README, CLAUDE.md, and architecture guides

### Included Utilities in Container
- **nano** — Text editor for configuration files
- **vim-tiny** — Lightweight Vi implementation
- **jq** — JSON processing (essential for debugging Ollama API)
- **less** — File pager
- **file** — File type identification
- **tree** — Directory visualization
- **unzip** — Archive extraction
- **curl, git, ffmpeg, gcc** — Already included

All utilities are installed as root and accessible to the `thoth` user (UID 1000).

## Quick Start

### One-liner Setup
```bash
curl -O https://raw.githubusercontent.com/jp-cruz/agent-skills/main/thoth-docker-setup/setup.sh
chmod +x setup.sh
./setup.sh
docker-compose up -d
```

### Manual Setup
```bash
git clone https://github.com/jp-cruz/agent-skills
cd agent-skills/thoth-docker-setup

./setup.sh          # macOS/Linux
# or setup.bat      # Windows

# Edit .env if needed
vim .env

docker-compose up -d
```

## Configuration

All configuration is environment-based via `.env`:

```bash
# Ollama connection (auto-detected for your platform)
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Container port
THOTH_PORT=8080

# Data persistence paths
THOTH_DATA_DIR=/Users/$(whoami)/thoth-data
THOTH_WORKSPACE_DIR=/Users/$(whoami)/thoth-workspace
```

Setup scripts automatically detect your platform and provide platform-specific guidance.

## Platform Support

### macOS (Intel & Apple Silicon)
- ✅ Docker Desktop 4.0+
- ✅ Automatic Ollama detection via `host.docker.internal`
- ✅ ARM64 support for Apple Silicon

### Windows (WSL 2 Backend)
- ✅ Docker Desktop with WSL 2
- ✅ PowerShell or Git Bash setup
- ✅ Automatic path handling for Windows paths

### Linux
- ✅ Docker Engine + Docker Compose 1.29+
- ✅ Automatic local IP detection for Ollama
- ✅ Remote Ollama support (specify IP in .env)

## Common Operations

```bash
# Start Thoth
docker-compose up -d

# View logs
docker-compose logs -f

# Open shell in container
docker-compose exec thoth bash

# Edit config inside container
docker-compose exec thoth nano /home/thoth/.thoth/config.yaml

# Check Ollama connectivity
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags

# Parse API response with jq
docker-compose exec thoth curl -s http://host.docker.internal:11434/api/tags | jq '.models[]'

# Stop Thoth
docker-compose stop

# Full cleanup
docker-compose down -v
```

## Troubleshooting

### Container Won't Start
```bash
docker-compose logs thoth
```

### Ollama Connection Failed
```bash
# From your host
curl http://localhost:11434/api/tags

# From inside container
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags
```

### Port Already in Use
Edit `.env`:
```bash
THOTH_PORT=8081
docker-compose up -d
```

### Volume Permission Issues
```bash
chmod 755 "$(grep THOTH_DATA_DIR .env | cut -d= -f2)"
chmod 755 "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
```

See README.md for comprehensive troubleshooting.

## Design Decisions

### Why These Utilities?

| Utility | Why Included | Use Case |
|---------|-------------|----------|
| **nano** | User-friendly text editor | Edit config files in container |
| **vim-tiny** | Lightweight alternative | Power users who prefer vim |
| **jq** | JSON processing | Debug Ollama API responses |
| **less** | File paging | View large logs without memory overhead |
| **file** | Type identification | Understand file contents |
| **tree** | Directory visualization | Explore workspace structure |
| **unzip** | Archive extraction | Handle model or config packages |

### Why Non-Root User?
- **Security:** Container runs as `thoth` (UID 1000), not root
- **File Permissions:** Prevents root-owned files in mounted volumes
- **Multi-container:** Safe for multi-user environments

### Why Bind Mounts?
- **Persistence:** Data survives image updates
- **Host Access:** Files accessible from host machine
- **Backup:** Easy to backup and migrate
- **Development:** Direct edit from host IDE

## File Structure

```
thoth-docker-setup/
├── docker/
│   ├── Dockerfile              # Optimized Python 3.11 + Thoth
│   └── docker-compose.yml      # Parameterized service definition
├── .env.example                # Configuration template
├── .dockerignore               # Build optimization
├── setup.sh                    # macOS/Linux setup script
├── setup.bat                   # Windows setup script
├── README.md                   # Complete setup guide
├── CLAUDE.md                   # Developer guide
├── SKILL.md                    # This file
└── .gitignore
```

## Requirements

### Host Machine
- Docker Desktop (macOS/Windows) or Docker + Docker Compose (Linux)
- 2+ GB free disk space
- Ollama running and accessible

### Network
- Port 8080 available for Thoth (configurable)
- Port 11434 accessible for Ollama (configure in .env)

## Performance Notes

### macOS/Windows Docker Desktop
- First build: ~2-3 minutes (depends on internet speed)
- Subsequent builds: ~30 seconds (layers cached)
- Runtime: Minimal overhead, ~100-150MB RAM

### Linux
- Faster builds due to native Docker
- Lower memory overhead
- Best performance overall

## Data Persistence

Both volumes are bind-mounts to host filesystem:

```bash
# Backup
tar -czf thoth-backup.tar.gz $THOTH_DATA_DIR $THOTH_WORKSPACE_DIR

# Restore
tar -xzf thoth-backup.tar.gz -C /
```

Volumes survive:
- ✅ Container restarts
- ✅ Container updates
- ✅ Docker image deletion
- ❌ `.env` path changes (must manually move)
- ❌ Bind mount deletion from host

## Integration with Other Services

### Ollama on Different Machine
```bash
# .env
OLLAMA_BASE_URL=http://<local-ip>:11434
```

### Multiple Thoth Instances
```bash
# .env
THOTH_PORT=8080      # Instance 1
THOTH_DATA_DIR=/data/thoth-1
THOTH_WORKSPACE_DIR=/workspace/thoth-1

# .env (another directory)
THOTH_PORT=8081      # Instance 2
THOTH_DATA_DIR=/data/thoth-2
THOTH_WORKSPACE_DIR=/workspace/thoth-2
```

## Contributing

To improve this skill:

1. Test on all three platforms (macOS, Windows, Linux)
2. Update documentation if changing behavior
3. Keep Dockerfile minimal and fast
4. Document any new environment variables

## Future Enhancements

- [ ] Multi-stage build for smaller images
- [ ] Docker Buildkit support
- [ ] Health checks
- [ ] Kubernetes manifest
- [ ] GitHub Actions for cross-platform testing
- [ ] Pre-built Docker Hub images

## License

This skill is provided as-is for Thoth deployments.

## Support

- **Setup Issues:** See README.md troubleshooting section
- **Development:** See CLAUDE.md for architecture
- **Contributing:** Submit issues/PRs to agent-skills repo
