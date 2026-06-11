# Row-Bot Bare-Metal to Docker Migration Guide

> Version 0.5.0 Release Notes
> 
> This document captures real-world lessons from migrating Row-Bot (formerly Thoth) from bare-metal installation to containerized deployment. Use this guide if you're moving from a desktop installation to Docker.

---

## Overview: Why Migrate to Docker?

Running Row-Bot on bare metal works, but Docker provides:

- **Isolation:** If Row-Bot or one of its agents misbehaves, the damage is contained to the container
- **Consistency:** Same setup works on macOS, Windows, Linux, cloud servers
- **Reproducibility:** Backup/restore entire deployments (volumes, config, data)
- **Cleanup:** Remove everything with `docker-compose down -v`; bare metal leaves files scattered

**Cost:** 5-10 minute initial setup. Well worth it if Row-Bot is business-critical.

---

## Pre-Migration: Inventory Your Data

Before moving, know what you're migrating:

### Key Files to Backup

Row-Bot stores everything in `~/.row-bot/` (Linux/macOS) or similar on Windows:

| Directory | Contents | Size Impact | Notes |
|-----------|----------|------------|-------|
| `memory.db` | Knowledge graph (entities, relations) | Small (~1MB) | **Critical** — contains knowledge |
| `memory_vectors/` | FAISS embeddings index | Medium (~1-10MB) | Must migrate with memory.db |
| `threads.db` | Conversation history | Can be large (100MB+) | Backup before migration |
| `tasks.db` | Task execution history | Small-medium | Auto-created if missing |
| `vault/wiki/` | User documentation, projects | Varies | Critical for context |
| `Documents/Row-Bot/` | Project files, workspace | Varies | Must preserve paths correctly |
| `api_keys.json` | API credentials, keyring data | Tiny | **CRITICAL** — don't lose |

**Backup command (bare metal):**
```bash
tar -czf row-bot-backup-$(date +%Y%m%d).tar.gz ~/.row-bot
# Store off-machine: external drive, cloud, etc.
```

---

## Major Challenges & Solutions

### Challenge 1: SQLite WAL File Corruption

**Problem:** When copying a live SQLite database (like `memory.db`) without stopping the source process, the database may have an active Write-Ahead Log (WAL) file (`memory.db-wal`). If you copy both files to the destination, SQLite sees an inconsistent state and may reset the database to empty on first read.

**Symptom:** Migration completes, but `memory.db` shows 0 entities after startup (was 235 before).

**Solution:** Use Python's `sqlite3.backup()` API instead of `shutil.copy2()`:

```python
import sqlite3
import shutil

# WRONG - don't do this:
shutil.copy2("/source/memory.db", "/dest/memory.db")

# RIGHT - use backup API:
source_db = sqlite3.connect("/source/memory.db")
dest_db = sqlite3.connect("/dest/memory.db")
source_db.backup(dest_db)
source_db.close()
dest_db.close()
```

**Or (simpler):** Stop the source container before copying:
```bash
docker stop source-rowbot
# Copy files now — WAL is merged into base .db
docker start source-rowbot
```

**Lesson:** Never copy a live SQLite WAL-mode database. Always use `sqlite3.backup()` or stop the source first.

---

### Challenge 2: Workspace Path Mismatch After Rebrand

**Problem:** Row-Bot's migration script automatically rewrites config files from `Thoth` → `Row-Bot`, including paths in `tools_config.json`. But if those paths are ephemeral (outside Docker volumes), they get lost on container restart.

Example:
- Old: `~/Documents/Thoth/projects/` (on bare metal)
- Auto-rewritten to: `~/Documents/Row-Bot/projects/` (still on bare metal, ephemeral)
- Inside container: Path doesn't exist because it's outside the volume

**Symptom:** Row-Bot starts, but project workspace is empty. Tools that reference old `/home/thoth/...` paths fail.

**Solution:**

1. **Identify the authoritative data location**
   ```bash
   # Check which path exists in migrated volume:
   ls -la /Volumes/MAC_MINI_1TB/docker/docker-root/rowbot-data/Documents/
   # You'll see either "Thoth/" or "Row-Bot/" directory
   ```

2. **Rename to final path (on host)**
   ```bash
   mv rowbot-data/Documents/Thoth rowbot-data/Documents/Row-Bot
   ```

3. **Update `tools_config.json` inside volume**
   ```json
   {
     "workspace_root": "/home/rowbot/.row-bot/Documents/Row-Bot"
   }
   ```

4. **Restart and verify**
   ```bash
   docker-compose restart
   docker-compose exec rowbot ls -la /home/rowbot/.row-bot/Documents/Row-Bot/projects/
   ```

**Lesson:** Paths in Docker must be in-volume paths (persistent). Host paths are ephemeral. Always use container-relative paths in configs.

---

### Challenge 3: API Keys in Keychain vs Docker Secrets

**Problem:** On bare metal, Row-Bot stores API keys in the OS keychain (macOS: Keychain.app, Linux: secretstorage, etc.). Docker containers can't access the host keychain — they're isolated by design.

**Symptom:** After migration, Row-Bot runs but can't authenticate to OpenRouter, Tavily, etc.

**Solution:** Use Docker Secrets (for Compose) or environment variables:

**Option A: Docker Secrets (Recommended)**
```bash
# Create secrets directory on host
mkdir -p ~/secrets

# Add each key as a file
echo "sk-or-your-api-key-here" > ~/secrets/OPENROUTER_API_KEY
chmod 600 ~/secrets/OPENROUTER_API_KEY

# Reference in docker-compose.yml:
services:
  rowbot:
    secrets:
      - OPENROUTER_API_KEY
      - TAVILY_API_KEY

secrets:
  OPENROUTER_API_KEY:
    file: ~/secrets/OPENROUTER_API_KEY
  TAVILY_API_KEY:
    file: ~/secrets/TAVILY_API_KEY
```

**Option B: .env file (simpler but less secure)**
```bash
# .env file (add to .gitignore!)
OPENROUTER_API_KEY=sk-or-...
TAVILY_API_KEY=tvly-...
```

**Option C: Hybrid (best practice)**
- Use Docker Secrets for sensitive credentials
- Use .env for non-sensitive config (ports, timeouts, etc.)

**Lesson:** Never store bare credentials in configs. Use secrets management. Docker Secrets is built-in and doesn't require external tools.

---

### Challenge 4: Volume Ownership After Restore

**Problem:** After restoring a database backup (especially via `tar xzf`), files may be owned by a different UID than the container user (rowbot = UID 1000). The container can't write to these files.

**Symptom:** Container starts but crashes with "permission denied" on first startup.

**Solution:**
```bash
# Fix ownership inside the volume (using a temporary alpine container):
docker run --rm -v rowbot-data:/data alpine chown -R 1000:1000 /data

# Verify:
docker run --rm -v rowbot-data:/data alpine ls -la /data | head
# Should show "1000 1000" for owner/group
```

**Lesson:** Always fix ownership after restoring backups from external sources.

---

## Step-by-Step Migration

### Phase 1: Prepare (On Bare Metal, Before Docker)

```bash
# 1. Stop the bare-metal Row-Bot instance
pkill -f rowbot  # or however you normally stop it

# 2. Backup everything (critical!)
tar -czf row-bot-backup-$(date +%Y%m%d_%H%M%S).tar.gz ~/.row-bot
# Copy to external drive / cloud storage

# 3. Verify backup is valid
tar -tzf row-bot-backup-*.tar.gz | head
# Should see: .row-bot/memory.db, .row-bot/threads.db, etc.
```

### Phase 2: Docker Setup (First Time)

```bash
# 1. Clone this skill repo
git clone https://github.com/jp-cruz/agent-skills.git
cd agent-skills/row-bot-docker-setup

# 2. Run setup.sh (generates .env, docker-compose.yml)
./setup.sh

# 3. Start empty Row-Bot (verify Docker works)
docker-compose up -d
docker-compose logs -f rowbot
# Wait for "Row-Bot is running at http://localhost:8080"
# Then Ctrl+C and proceed
```

### Phase 3: Copy Bare-Metal Data

```bash
# 1. Stop the Docker container
docker-compose down

# 2. Extract backup into Docker volume location
# Get the volume path:
VOLUME_PATH=$(docker volume inspect row-bot-docker-setup_rowbot-data --format '{{.Mountpoint}}')

# 3. Copy data from backup (or directly from bare metal):
# Option A: From backup tar
tar -xzf row-bot-backup-*.tar.gz -C "$VOLUME_PATH" --strip-components=1
# (--strip-components=1 removes the .row-bot/ prefix)

# Option B: Direct copy from bare metal
# Assuming ~/.row-bot exists on bare metal:
cp -r ~/.row-bot/* "$VOLUME_PATH"

# 4. Fix ownership
docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine chown -R 1000:1000 /data

# 5. Handle SQLite files carefully
# If the source was live, run backup API instead:
python3 << 'EOF'
import sqlite3
import os

source = os.path.expanduser("~/.row-bot/memory.db")
dest = f"{VOLUME_PATH}/memory.db"

if os.path.exists(source):
    src = sqlite3.connect(source)
    dst = sqlite3.connect(dest)
    src.backup(dst)
    src.close()
    dst.close()
    print(f"Safely migrated memory.db")
EOF
```

### Phase 4: Fix Paths & Config

```bash
# 1. Start the container
docker-compose up -d

# 2. Wait for startup, then check logs
docker-compose logs --tail=50 rowbot

# 3. If you see workspace path errors, rename directories:
# Enter the volume to check structure
docker-compose exec rowbot ls -la ~/.row-bot/Documents/

# Rename if needed:
docker-compose exec rowbot mv ~/.row-bot/Documents/Thoth ~/.row-bot/Documents/Row-Bot 2>/dev/null || true

# 4. Verify workspace is accessible
docker-compose exec rowbot ls -la ~/.row-bot/Documents/Row-Bot/projects/
# Should list your project directories
```

### Phase 5: Restore API Keys

```bash
# Option A: Enter container and paste keys manually
docker-compose exec rowbot bash
# Then use Row-Bot's UI or config command to add API keys

# Option B: Use Docker Secrets (recommended)
# See "Challenge 3" section above for setup

# Verify connectivity:
docker-compose exec rowbot curl -I https://api.openrouter.ai
# Should return 200 or 401 (not connection refused)
```

### Phase 6: Verify & Test

```bash
# Run health check
./health-check.sh

# Test a simple query in Row-Bot UI
# Visit http://localhost:8080
# Create a conversation
# Send a test message

# Check container logs
docker-compose logs -f rowbot

# Verify no permission errors
docker-compose logs rowbot | grep -i "permission\|denied"
# Should be empty
```

---

## Validation Checklist

After migration, verify:

- [ ] Row-Bot starts without errors (`docker-compose logs`)
- [ ] Web UI accessible at http://localhost:8080
- [ ] Knowledge graph loads (check memory.db entity count)
- [ ] Projects visible in workspace
- [ ] API keys configured and tested
- [ ] Health check passes: `./health-check.sh`
- [ ] No "permission denied" errors in logs
- [ ] Conversation history restored (threads visible)
- [ ] Backup of bare-metal version kept safe

---

## Rollback Plan

If migration fails:

```bash
# 1. Stop Docker
docker-compose down

# 2. Restore from backup on bare metal
tar -xzf row-bot-backup-*.tar.gz -C ~

# 3. Restart bare-metal Row-Bot
# (however you normally do it)

# 4. Investigate Docker issue (check logs, disk space, etc.)
```

You'll be back to normal in <5 minutes.

---

## Lessons Learned (Summary)

| Lesson | When | Action |
|--------|------|--------|
| SQLite WAL corruption | Copying live databases | Use `sqlite3.backup()` or stop source first |
| Workspace path mismatch | After rebrand migration | Ensure paths are in-volume (persistent) |
| API keys inaccessible | After Docker migration | Use Docker Secrets, not OS keychain |
| File permission denied | After restoring from backup | `docker run --rm chown -R 1000:1000` |
| Untested backups fail | During real disaster | Test restores quarterly |
| Volume naming changed | When renaming containers | Update backup scripts to use volume path |

---

## Attribution

**Row-Bot created by:** [Sidds Sachar](https://github.com/siddsachar/row-bot)  
**Docker setup & migration guide:** JP Cruz ([@jp-cruz](https://github.com/jp-cruz))

This skill builds on lessons from real-world migrations (Thoth → Row-Bot, 2026-05-28 through 2026-06-05).

---

## Further Reading

- [DOCKER_WHY.md](DOCKER_WHY.md) — Why Docker is worth the setup cost
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Solutions to common issues
- [CLAUDE.md](CLAUDE.md) — Disaster recovery & backup procedures
- [Row-Bot GitHub Issues](https://github.com/siddsachar/row-bot/issues) — Report bugs to Row-Bot itself

