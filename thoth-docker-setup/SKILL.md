---
name: thoth-docker-setup
description: Production-ready Docker Compose setup for Thoth with cross-platform support (macOS, Windows, Linux). Includes automated environment detection, multi-provider LLM integration (Ollama, OpenRouter, OpenAI, Anthropic), persistent volumes, and comprehensive guides. Use when deploying Thoth in containerized environments or setting up Docker infrastructure for AI agents.
license: MIT
compatibility: Requires Docker 20.10+, Docker Compose 1.29+, bash 4.0+, and curl. Supports macOS (Intel/Apple Silicon), Windows (WSL2), and Linux. Optional: Ollama or alternative LLM backends.
requires_terminal: true
metadata:
  author: Claude Sonnet 4.6 (run by JP Cruz)
  contact: jp@legionforge.org
  version: "0.6.1"
  category: deployment
  tested-platforms: macOS Tahoe (M4), Linux/Windows validation pending
  execution_context: Interactive terminal (Aider, Claude Code CLI, VS Code, OpenCode, or bash)
---

# Thoth Docker Setup

Production-ready Docker Compose configuration for deploying Thoth with cross-platform support.

## What this skill provides

- **Automated Docker setup** — One-command initialization with environment detection
- **Cross-platform support** — Works on macOS (Intel/Apple Silicon), Windows (WSL2), and Linux
- **Multi-provider LLM integration** — Seamless support for Ollama, OpenRouter, OpenAI, and Anthropic
- **Environment detection** — Automatically detects OS, installed LLM backends, Python environment, and secrets management
- **Persistent data volumes** — Application data and workspace files survive container restarts
- **Storage intelligence** — Disk space monitoring, external drive recommendation, cleanup tools
- **Security hardening** — Non-root user execution, pinned base images, no hardcoded secrets
- **Comprehensive documentation** — Setup guides, troubleshooting, Docker education for beginners

## ⚠️ Requires Interactive Terminal

**This skill requires an interactive terminal with bash, Docker, and file system access. It cannot run from Claude.ai web or the desktop app.**

### Compatible Execution Environments

You can run this skill from any of these:

| Environment | How | Status |
|-------------|-----|--------|
| **Claude Code CLI** | `npm install -g @anthropic-ai/claude-code && claude` | ✅ Recommended |
| **Aider** | `aider` (Claude in terminal) | ✅ Works great |
| **VS Code terminal** | Ask Claude in VS Code Chat with code execution | ✅ Works |
| **OpenCode** | Terminal within OpenCode | ✅ Works |
| **Any bash terminal** | `bash setup.sh` (manual) | ✅ Works |

**NOT compatible:**
- Claude.ai web chat ❌
- Claude desktop app ❌
- ChatGPT web ❌

### Why Terminal-Only?

This skill needs:
- **File system access** — Detect external drives, read/write `.env`, create directories
- **Command execution** — Run `docker-compose`, `curl`, `mkdir`, Git commands
- **Real-time feedback** — Stream Docker build progress, show live logs
- **Interactive prompts** — TTY for `read` commands during setup
- **Reliable error handling** — Detect and recover from failures mid-execution

### Quick Start: Claude Code CLI (Recommended)

```bash
npm install -g @anthropic-ai/claude-code
claude  # Start interactive session in your terminal
```

Then ask: **"Help me set up thoth-docker-setup"**

Claude will:
- Run disk detection and recommend optimal storage
- Auto-detect your OS, Docker, Ollama, and LLM backends
- Interactively ask for customization
- Create `.env` and validate everything
- Start Thoth and show you the URL

### What You Get with CLI

✅ Real-time Docker build progress  
✅ Auto-detection of your system state  
✅ Interactive prompts with immediate feedback  
✅ Automatic `.env` configuration  
✅ File system integration (volumes, data directories)  
✅ Live troubleshooting and error messages  

### Why Not Web/Desktop?

- Can't read your file system
- Can't execute shell commands
- Can't detect installed software
- Can't show live progress
- Can't create or modify local files

**Use Claude Code CLI instead. It takes 60 seconds to install.**

## Quick start

### Option 1: Automated setup (recommended)

```bash
cd thoth-docker-setup
./scripts/setup.sh
docker-compose up -d
```

Then open http://localhost:8080

### Option 2: Step-by-step setup

1. **Check your environment:**
   ```bash
   bash scripts/preflight-check.sh
   ```
   This detects your OS, installed LLM backends, and suggests configuration.

2. **Configure:**
   ```bash
   cp .env.example .env
   # Edit .env to customize paths, ports, and LLM provider
   ```

3. **Validate Docker:**
   ```bash
   bash scripts/check-docker.sh
   ```

4. **Start Thoth:**
   ```bash
   docker-compose up -d
   ```

## Common tasks

### Check Thoth is running
```bash
docker-compose ps
curl http://localhost:8080
```

### View logs
```bash
docker-compose logs -f
```

### Access container shell
```bash
docker-compose exec thoth bash
```

### Stop or restart
```bash
docker-compose stop      # Stop container
docker-compose restart   # Restart container
docker-compose down      # Remove container
```

### Change Thoth port
Edit `.env`:
```bash
THOTH_PORT=9090
docker-compose restart
# Now access at http://localhost:9090
```

### Use different LLM provider

Edit `.env`:
```bash
# For OpenRouter (cloud-based, requires API key)
OLLAMA_BASE_URL=https://openrouter.ai/api/v1
# Then configure in Thoth UI

# For local Ollama on another machine
OLLAMA_BASE_URL=http://<machine-ip>:11434

# For local LLM Studio (port 1234 by default)
OLLAMA_BASE_URL=http://localhost:1234/v1
```

Then restart: `docker-compose restart`

## Platform-specific notes

### macOS
- Uses `host.docker.internal` to reach host services (Ollama, etc.)
- Docker Desktop required (not colima)
- Supports both Intel and Apple Silicon Macs

### Windows
- Requires Docker Desktop with WSL2 enabled
- Uses `host.docker.internal` for host service access
- Run setup.bat for Windows-specific initialization

### Linux
- Requires Docker Engine and Docker Compose installed
- Update `.env` to use `localhost:11434` (not `host.docker.internal`)
- May need to add user to docker group: `sudo usermod -aG docker $USER`

## Troubleshooting

**Docker not found:**
See [DOCKER_GUIDE_FOR_BEGINNERS.md](references/DOCKER_GUIDE_FOR_BEGINNERS.md) for installation on your platform.

**Port 8080 already in use:**
Change `THOTH_PORT` in `.env` to an unused port (e.g., 9090, 9091).

**Ollama not reachable:**
1. Ensure Ollama is running: `ollama serve`
2. Check connection: `curl http://localhost:11434/api/tags`
3. Update `OLLAMA_BASE_URL` in `.env` if Ollama is on a different machine

**Volume permission issues:**
```bash
# Check ownership
ls -la $(grep THOTH_DATA_DIR .env | cut -d= -f2)
# Fix if needed
chmod 755 $(grep THOTH_DATA_DIR .env | cut -d= -f2)
```

## Detailed guides

- [Getting Started](references/GETTING_STARTED.md) — Step-by-step for beginners
- [Docker Guide](references/DOCKER_GUIDE_FOR_BEGINNERS.md) — Docker education and installation
- [Docker Compose Explained](references/DOCKER_COMPOSE_EXPLAINED.md) — Line-by-line explanation
- [LLM Provider Options](references/LLM_PROVIDER_OPTIONS.md) — Comparing Ollama, OpenRouter, OpenAI, Anthropic
- [OpenRouter Setup](references/OPENROUTER_SETUP.md) — Cloud-based LLM integration
- [Setup Workflow](references/SETUP_WORKFLOW.md) — Three-tier setup comparison
- [CI/CD Validation](references/CI_CD_VALIDATION_GUIDE.md) — Automated testing setup

## Scripts

All scripts are in `scripts/`:

- `setup.sh` — Automated initialization (macOS/Linux)
- `setup.bat` — Automated initialization (Windows)
- `preflight-check.sh` — Environment assessment and recommendations
- `check-docker.sh` — Docker installation verification

Run with: `bash scripts/setup.sh` or `bash scripts/preflight-check.sh`

## Files

- `docker-compose.yml` — Service orchestration
- `docker/Dockerfile` — Container image definition
- `.env.example` — Configuration template
- `.dockerignore` — Build optimization
- `docker/` — Docker configuration files
- `.github/` — CI/CD workflows (Dependabot, Renovate, Socket Security)

## Version & Support

**Version:** 0.5.0  
**Status:** Production-ready (tested on macOS Tahoe, Linux/Windows validation pending)  
**License:** MIT  
**Author:** Claude Sonnet 4.6 (run by JP Cruz)  
**Contact:** jp@legionforge.org

## Next steps after setup

1. Access Thoth at http://localhost:8080
2. Configure your LLM provider in Thoth UI
3. Create your first workspace
4. Start using Thoth for your projects

For questions or issues, refer to the detailed guides in `references/` or check the [GitHub repository](https://github.com/jp-cruz/agent-skills/tree/main/thoth-docker-setup).
