# Thoth Docker Template

Production-ready Docker Compose setup for [Thoth](https://github.com/siddsachar/Thoth) across macOS, Windows, and Linux. Built on learnings from the Jeli project.

---

## Choose Your Path

**What do you want to do?**

| Goal | Start Here | Time |
|------|-----------|------|
| **First time setup** | Quick Start (below) | 5 min |
| **Upgrading from v0.5.x** | [MIGRATION.md](MIGRATION.md) | 15 min |
| **Troubleshooting issues** | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 10 min |
| **Understanding architecture** | [ARCHITECTURE.md](references/ARCHITECTURE.md) | 15 min |
| **Network/firewall setup** | [NETWORK_SETUP.md](references/NETWORK_SETUP.md) | 10 min |
| **Disaster recovery testing** | [CLAUDE.md](CLAUDE.md) (Disaster Recovery section) | 20 min |
| **Security considerations** | [SECURITY.md](SECURITY.md) | 10 min |
| **Contributing/Development** | [CONTRIBUTING.md](CONTRIBUTING.md) | — |

---

## Quick Start

```bash
git clone <repo-url> thoth-docker-template
cd thoth-docker-template
./setup.sh
```

That's it. The setup script detects your system, recommends optimal storage, and walks you through the only decisions that matter.

Then start Thoth:
```bash
docker-compose up -d
```

Open your browser to `http://localhost:8080`

---

## Advanced Options

For more control, you can run these before setup:

**Storage Assessment (detect external drives):**
```bash
./scripts/disk-check.sh
```

**Full Environment Scan (LLM backends, Docker, WSL2, secrets):**
```bash
./scripts/preflight-check.sh
```

**Intelligent Guided Setup via Claude Code CLI:**
```bash
claude  # Start Claude Code CLI, then ask: "Help me set up thoth-docker-setup"
```

---

## Common Commands

### Container Management

```bash
# Start container in background
docker-compose up -d

# Stop container
docker-compose stop

# Remove container and volumes
docker-compose down

# Remove container, volumes, and image
docker-compose down -v --rmi all

# View live logs
docker-compose logs -f

# View last 100 lines of logs
docker-compose logs --tail=100
```

### Development & Debugging

```bash
# Open shell inside container
docker-compose exec thoth bash

# Run Python command
docker-compose exec thoth python launcher.py --help

# Check Ollama connectivity from inside container
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags

# Inspect container environment
docker-compose exec thoth env | grep OLLAMA
docker-compose exec thoth env | grep THOTH
```

### Rebuild After Changes

```bash
# Full rebuild (no cache)
docker-compose build --no-cache

# Rebuild and restart
docker-compose up -d --build
```

## Container Utilities

The Thoth container includes essential command-line utilities pre-installed and accessible to the `thoth` user:

| Utility | Purpose | Example |
|---------|---------|---------|
| **nano** | Text editor | `docker-compose exec thoth nano /home/thoth/.thoth/config.yaml` |
| **vim-tiny** | Vi implementation | `docker-compose exec thoth vim /home/thoth/.thoth/config.yaml` |
| **jq** | JSON processing | `docker-compose exec thoth curl -s http://host.docker.internal:11434/api/tags \| jq '.'` |
| **less** | File pager | `docker-compose exec thoth less /home/thoth/.thoth/logs.json` |
| **tree** | Directory explorer | `docker-compose exec thoth tree -L 2 /home/thoth/.thoth` |
| **file** | File type check | `docker-compose exec thoth file /home/thoth/workspace/model.gguf` |
| **unzip** | Archive extraction | `docker-compose exec thoth unzip models.zip -d /home/thoth/.thoth/models` |
| **curl** | HTTP requests | `docker-compose exec thoth curl http://host.docker.internal:11434/api/tags` |
| **git** | Version control | `docker-compose exec thoth git clone <repo>` |

All utilities are installed as root during build and accessible to the `thoth` user at runtime.

See [UTILITIES_ANALYSIS.md](UTILITIES_ANALYSIS.md) for detailed rationale on each utility.

## Docker Installation (Required)

**Don't have Docker?** See [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md) for:
- What Docker is and why it's essential
- Installation for macOS, Windows, and Linux
- Verification and troubleshooting
- Common questions answered

**Quick Version:**
```bash
# macOS: Download Docker Desktop from https://www.docker.com/products/docker-desktop
# Windows: Download Docker Desktop + enable WSL 2
# Linux: sudo apt install docker.io docker-compose

# Verify
docker --version
docker-compose --version
```

---

## Ollama Setup (If Using Local LLM)

Thoth requires Ollama running on your host machine (if you choose local models). Ollama provides the LLM backend.

### Install Ollama

- **macOS/Windows:** Download from [ollama.ai](https://ollama.ai)
- **Linux:** 
  ```bash
  curl https://ollama.ai/install.sh | sh
  ```

### Start Ollama

**macOS/Windows:** Launch the Ollama application (runs in background on port 11434)

**Linux:** 
```bash
ollama serve
```

### Verify Ollama is Running

```bash
curl http://localhost:11434/api/tags
```

You should get a JSON response with available models. If Ollama isn't running yet, pull a model:

```bash
ollama pull llama2
```

## Persistent Data

Two volumes store data across container restarts:

1. **thoth-data** (`${THOTH_DATA_DIR}`)
   - Thoth application state, cache, configuration
   - Mounted at `/home/thoth/.thoth` inside container

2. **thoth-workspace** (`${THOTH_WORKSPACE_DIR}`)
   - User workspace and projects
   - Mounted at `/app/workspace` inside container

Both are bind mounts, so files are stored on your host filesystem and survive container removal.

### Backup & Restore

**Backup:**
```bash
# Create backup tarball
tar -czf thoth-backup-$(date +%Y%m%d).tar.gz \
  "$(grep THOTH_DATA_DIR .env | cut -d= -f2)" \
  "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
```

**Restore:**
```bash
# Extract backup (after ensuring container is stopped)
tar -xzf thoth-backup-20240525.tar.gz -C /
```

**Full data reset:**
```bash
docker-compose down -v
rm -rf "$(grep THOTH_DATA_DIR .env | cut -d= -f2)"
rm -rf "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
mkdir -p "$(grep THOTH_DATA_DIR .env | cut -d= -f2)"
mkdir -p "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
docker-compose up -d
```

## Troubleshooting

### Port Already in Use

If port 8080 is in use, change it in `.env`:
```bash
THOTH_PORT=8081
```

Then restart:
```bash
docker-compose up -d
```

### Ollama Connection Failed

**Symptom:** `Connection refused` or `Network unreachable` when Thoth tries to reach Ollama

**Check 1:** Ollama is running
```bash
curl http://localhost:11434/api/tags
```

**Check 2:** Docker can reach the host
```bash
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags  # macOS/Windows
docker-compose exec thoth curl http://<your-local-ip>:11434/api/tags      # Linux
```

**Check 3:** Firewall isn't blocking port 11434
```bash
# macOS
sudo lsof -i :11434

# Linux
sudo netstat -tlnp | grep 11434
```

**Check 4:** On Linux, if using a different IP, verify it's reachable:
```bash
ping <ollama-host-ip>
```

### Volume Permission Issues

If you get "Permission denied" errors, ensure the directories are writable:
```bash
chmod 755 "$(grep THOTH_DATA_DIR .env | cut -d= -f2)"
chmod 755 "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
```

If issues persist, check container user permissions:
```bash
docker-compose exec thoth id
docker-compose exec thoth ls -la /home/thoth/.thoth
```

### Container Won't Start

Check logs for the error:
```bash
docker-compose logs thoth
```

Common causes:
- **Out of disk space:** `docker system prune` to clean up old images
- **Port in use:** See [Port Already in Use](#port-already-in-use)
- **Ollama not running:** See [Ollama Connection Failed](#ollama-connection-failed)
- **Bad `.env` file:** Verify paths are correct and directories exist

### Slow on Windows/macOS

Docker volume performance on WSL 2 and Docker Desktop can be slow. To improve:

1. Use native paths (not network shares)
2. Reduce bind mount depth if possible
3. Consider using named volumes instead (less portable but faster)

---

## Disk Space Planning

> **Mac Mini M4 with 256GB drive? Linux workstation with storage constraints?** Read this section.

Thoth's memory system grows 1–3 GB/week. On smaller drives, plan ahead.

### Space Requirements

| Component | Size | Notes |
|-----------|------|-------|
| Docker image (Thoth) | ~5 GB uncompressed | One-time; cached after first build |
| Docker build cache | 1–3 GB | Grows with rebuilds |
| Thoth data (memory.db, etc.) | 1 GB → 10 GB+ | Grows with use; 10GB typical after 2–3 weeks |
| Workspace files | Variable | Your files |
| **Total after 1 month** | **~15–20 GB** | Plan accordingly |

### Recommendation

- **External Thunderbolt/USB-C SSD**: Best for Thoth data. Thunderbolt 3/4 and USB 3.2 Gen 2 SSDs (>300 MB/s) are fast enough for seamless use.
- **Setup script automation:** `./setup.sh` detects external drives and offers to use them automatically.
- **Move data later:** If you've already installed, see [references/DISK_MANAGEMENT.md](references/DISK_MANAGEMENT.md) for migration steps.

### External Drive Recommended When

- Total drive space < 500 GB
- System drive free space < 100 GB
- You expect to use Thoth heavily (>10 hours/week)
- You plan to keep Thoth running for months

---

## Multi-Machine Deployments

To run Thoth and Ollama on different machines:

**Machine 1 (Ollama Host):**
```bash
ollama serve
# Or in Docker: docker run -d -p 11434:11434 ollama/ollama:latest
```

**Machine 2 (Thoth Host):**
```bash
# In .env, set:
OLLAMA_BASE_URL=http://<machine1-ip>:11434

# Then start as normal
docker-compose up -d
```

## Architecture

- **Base:** Python 3.11 slim
- **Runtime:** Thoth (GitHub commit `deb5d11`)
- **Port:** 8080 (configurable)
- **User:** `thoth` (UID 1000, non-root)
- **Restart:** Automatic unless stopped
- **Networking:** Bridge mode (macOS/Windows), configurable on Linux

## File Structure

```
.
├── .dockerignore           # Excludes unnecessary files from Docker build
├── .env.example            # Configuration template (copy to .env)
├── .gitignore              # Git ignore patterns
├── README.md               # This file
├── CLAUDE.md               # Development guide for Claude Code
└── docker/
    ├── Dockerfile          # Container definition
    └── docker-compose.yml  # Service orchestration with env variable support
```

## Contributing

When making changes:

1. Test on at least one platform (macOS, Windows, or Linux)
2. Update `docker-compose.yml` to use env variables for paths
3. Document any platform-specific workarounds in this README
4. Update CLAUDE.md if build/test commands change

## License

This template is provided as-is. See the [Thoth project](https://github.com/siddsachar/Thoth) for its license.
