# Row-Bot Docker Setup

Production-ready Docker Compose setup for [Row-Bot](https://github.com/siddsachar/row-bot) (formerly Thoth) across macOS, Windows, and Linux. Built on learnings from Thoth migrations, Jeli project experience, and bare-metal-to-container deployment challenges.

> **Version 0.5.0 (Initial Release):** This is the first release after the Thoth → Row-Bot rebrand. Row-Bot is a desktop application that benefits from containerization for isolation and consistency. See [MIGRATION_NOTES.md](MIGRATION_NOTES.md) for migration guidance and lessons learned from bare-metal deployments.

---

## Why Docker for Agent Software?

**Running untrusted code on bare metal is risky:**
- Malicious code could wipe your hard drive
- Compromised agents can access your files and API keys
- Security breaches expose your entire computer

**Docker solves this** by isolating Row-Bot in a container:
- Your files are protected
- Your API keys and credentials stay safe
- If Row-Bot is compromised, the damage is contained

**Default setup is secure:** Localhost-only access, optional cloud LLM providers, non-root user.

> **Learn more:** See [DOCKER_WHY.md](DOCKER_WHY.md) for detailed security explanation

---

## Quick Setup (Two Paths)

Running `./setup.sh` guides you through two options:

### Quick Setup (5 min)
- System scans your hardware
- Recommends safe defaults
- One-click approval
- Done — start Row-Bot immediately

### Advanced Setup (10 min)
- Same intelligent defaults
- Detailed customization options
- CTAs for power users
- Fine-tune every setting

**Both paths produce secure, safe-by-default configurations.**

---

## Choose Your Path

**What do you want to do?**

| Goal | Start Here | Time |
|------|-----------|------|
| **First time setup** | Run `./setup.sh` (Quick or Advanced) | 5-10 min |
| **Migrating from bare-metal Row-Bot** | [MIGRATION_NOTES.md](MIGRATION_NOTES.md) | 15 min |
| **Verify setup works** | Run `./health-check.sh` | 1 min |
| **Estimate monthly costs** | Run `./estimate-costs.sh` | 5 min |
| **Why Docker?** | [DOCKER_WHY.md](DOCKER_WHY.md) | 5 min |
| **LLM options** | [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md) | 10 min |
| **First steps with Row-Bot** | [GETTING_STARTED.md](GETTING_STARTED.md) | 5 min |
| **Remote access (safe)** | [REMOTE_ACCESS_GUIDE.md](REMOTE_ACCESS_GUIDE.md) | 10 min |
| **Bug report / debugging** | Run `./diagnostics.sh` | 2 min |
| **Upgrading Row-Bot versions** | [MIGRATION.md](MIGRATION.md) | 15 min |
| **Troubleshooting issues** | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 10 min |
| **Network/firewall setup** | [NETWORK_SETUP.md](references/NETWORK_SETUP.md) | 10 min |
| **Disaster recovery** | [CLAUDE.md](CLAUDE.md) (Disaster Recovery section) | 20 min |

---

## Quick Start

```bash
git clone <repo-url> row-bot-docker-setup
cd row-bot-docker-setup
./setup.sh
```

That's it. The setup script detects your system, recommends optimal storage, and walks you through the only decisions that matter.

Then start Row-Bot:
```bash
docker-compose up -d
```

Open your browser to `http://localhost:8080`

---

## Useful Scripts

**Health Check (verify setup works):**
```bash
./health-check.sh
# Checks: Docker, Row-Bot container, Ollama, disk space, LLM provider
```

**Cost Estimator (monthly LLM expenses):**
```bash
./estimate-costs.sh
# Interactive tool to estimate costs for different providers
# Helps choose between Ollama (free), OpenAI, Claude, OpenRouter
```

**Diagnostics (for bug reports):**
```bash
./diagnostics.sh
# Collects system info, Docker status, logs (with secrets removed)
# Safe to share in GitHub issues
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
docker-compose exec rowbot bash

# Run Python command
docker-compose exec rowbot python launcher.py --help

# Check Ollama connectivity from inside container
docker-compose exec rowbot curl http://host.docker.internal:11434/api/tags

# Inspect container environment
docker-compose exec rowbot env | grep OLLAMA
docker-compose exec rowbot env | grep ROWBOT
```

### Rebuild After Changes

```bash
# Full rebuild (no cache)
docker-compose build --no-cache

# Rebuild and restart
docker-compose up -d --build
```

## Container Utilities

The Row-Bot container includes essential command-line utilities pre-installed and accessible to the `rowbot` user:

| Utility | Purpose | Example |
|---------|---------|---------|
| **nano** | Text editor | `docker-compose exec rowbot nano /home/rowbot/.row-bot/config.yaml` |
| **vim-tiny** | Vi implementation | `docker-compose exec rowbot vim /home/rowbot/.row-bot/config.yaml` |
| **jq** | JSON processing | `docker-compose exec rowbot curl -s http://host.docker.internal:11434/api/tags \| jq '.'` |
| **less** | File pager | `docker-compose exec rowbot less /home/rowbot/.row-bot/logs.json` |
| **tree** | Directory explorer | `docker-compose exec rowbot tree -L 2 /home/rowbot/.row-bot` |
| **file** | File type check | `docker-compose exec rowbot file /home/rowbot/workspace/model.gguf` |
| **unzip** | Archive extraction | `docker-compose exec rowbot unzip models.zip -d /home/rowbot/.row-bot/models` |
| **curl** | HTTP requests | `docker-compose exec rowbot curl http://host.docker.internal:11434/api/tags` |
| **git** | Version control | `docker-compose exec rowbot git clone <repo>` |

All utilities are installed as root during build and accessible to the `rowbot` user at runtime.

See [UTILITIES_ANALYSIS.md](references/UTILITIES_ANALYSIS.md) for detailed rationale on each utility.

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

## Local LLM Setup (Optional)

Row-Bot can use local models (Ollama, llama.cpp, etc.) or cloud providers (OpenAI, Claude, OpenRouter).

**If you choose a local model**, you need Ollama (or another backend) running on your host machine.

> **Unsure which to choose?** See [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md) for detailed comparison of options, tradeoffs, and hardware requirements.

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

Two Docker volumes store data across container restarts:

1. **row-bot-docker-setup_rowbot-data**
   - Thoth application state, memory.db, configuration, API keys
   - Mounted at `/home/rowbot/.row-bot` inside container
   - Location on host: `/var/lib/docker/volumes/row-bot-docker-setup_rowbot-data/_data`

2. **row-bot-docker-setup_rowbot-workspace**
   - User workspace and projects
   - Mounted at `/app/workspace` inside container
   - Location on host: `/var/lib/docker/volumes/row-bot-docker-setup_rowbot-workspace/_data`

**Why Docker volumes (not bind mounts)?**
- ✅ Portable: Same volumes work on any Docker host
- ✅ Safe upgrades: Data persists across Thoth version upgrades
- ✅ Portable backups: Volumes can be backed up and restored anywhere
- ✅ Permission-safe: Automatic UID/GID handling

See [CLAUDE.md](CLAUDE.md) for full backup and disaster recovery procedures.

### Backup & Restore

**Backup (full volume backup):**
```bash
# Create backup of Thoth data volume
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  -v ./backups:/backup alpine tar czf /backup/thoth-data-$(date +%Y%m%d).tar.gz -C /data .
```

**Restore from backup:**
```bash
# Stop container
docker-compose down

# Restore volume
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  -v ./backups:/backup alpine tar xzf /backup/thoth-data-YYYYMMDD.tar.gz -C /data

# Fix ownership
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  alpine chown -R 1000:1000 /data

# Restart
docker-compose up -d
```

**Full data reset (⚠️ deletes all data):**
```bash
docker-compose down -v
docker-compose up -d
```

See [CLAUDE.md](CLAUDE.md) for complete backup, restore, and disaster recovery procedures including monthly testing guidance.

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
docker-compose exec rowbot curl http://host.docker.internal:11434/api/tags  # macOS/Windows
docker-compose exec rowbot curl http://<your-local-ip>:11434/api/tags      # Linux
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
chmod 755 "$(grep ROWBOT_DATA_DIR .env | cut -d= -f2)"
chmod 755 "$(grep THOTH_WORKSPACE_DIR .env | cut -d= -f2)"
```

If issues persist, check container user permissions:
```bash
docker-compose exec rowbot id
docker-compose exec rowbot ls -la /home/rowbot/.row-bot
```

### Container Won't Start

Check logs for the error:
```bash
docker-compose logs rowbot
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

This template is provided as-is. See the [Thoth project](https://github.com/siddsachar/row-bot) for its license.
