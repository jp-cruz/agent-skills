# Row-Bot Disk Management Guide

## Overview

Row-Bot's memory system can grow rapidly. Understanding where data lives, why it grows, and how to manage it is critical for maintaining a healthy system — especially on space-constrained hardware like a Mac Mini M4 with 256GB.

---

## Where Row-Bot Data Lives

### On-Disk Structure

```
ROW_BOT_DATA_DIR (default: ./rowbot-data)
├── memory.db              # Main memory/context database
├── threads.db             # Conversation threads
├── tasks.db               # Task tracking database
├── model_catalog_cache.json
├── cloud_models_cache.json
├── context_catalog_cache.json
├── dream_journal.json
├── rowbot_app.log          # Application logs (rotates to .prev)
├── rowbot_app.log.prev
├── memory_extraction_state.json
└── tools_config.json

ROW_BOT_WORKSPACE_DIR (default: ./rowbot-workspace)
├── projects/
├── files/
├── artifacts/
└── [user-created files]
```

### Why It Grows

| Component | Grows | Reason |
|-----------|-------|--------|
| **memory.db** | 5–15 MB/week | Each conversation adds context to memory. SQLite database grows as you work. |
| **threads.db** | 2–5 MB/week | Full conversation history, including all messages. |
| **tasks.db** | 1–3 MB/week | Task completions and state changes. |
| **Cache files** | 500 MB–2 GB | LLM model catalogs, model weights, context embeddings stored locally. |
| **Logs** | 100 MB–500 MB | rowbot_app.log grows as Row-Bot runs. |
| **Workspace files** | User-dependent | Projects, code, artifacts you create. |

### Docker Image & Layers

| Layer | Size | Notes |
|-------|------|-------|
| Docker image (uncompressed) | ~5 GB | Pulled once, cached |
| Build cache | 1–3 GB | Intermediate layers from `docker-compose build` |
| Volumes (rowbot-data, workspace) | Grows over time | Separate from image, lives on host filesystem |

---

## Total Disk Impact Timeline

### Conservative Use (1–2 hours/day)

| Week | Row-Bot Data | Docker | Workspace | Total |
|------|-----------|--------|-----------|-------|
| 1 | 500 MB | 5 GB | 100 MB | ~5.6 GB |
| 2 | 1 GB | 5 GB | 200 MB | ~6.2 GB |
| 4 | 2 GB | 5 GB | 500 MB | ~7.5 GB |
| 8 | 4 GB | 5 GB | 1 GB | ~10 GB |
| 12 | 6 GB | 5 GB | 1.5 GB | ~12.5 GB |

### Heavy Use (4+ hours/day)

| Week | Row-Bot Data | Docker | Workspace | Total |
|------|-----------|--------|-----------|-------|
| 1 | 2 GB | 5 GB | 500 MB | ~7.5 GB |
| 2 | 4 GB | 5 GB | 1 GB | ~10 GB |
| 4 | 8 GB | 5 GB | 2 GB | ~15 GB |
| 8 | 15 GB | 5 GB | 5 GB | ~25 GB |
| 12 | 20 GB | 5 GB | 8 GB | ~33 GB |

**On a 256GB Mac Mini:** After 2 months of heavy use, you could have 20+ GB consumed, leaving ~230GB. That's fine, but long-term (6+ months), you may reach 50+ GB and see significant slowdowns.

---

## Storage Recommendations

### Option 1: System Drive (Default) — Use If

- You have > 100GB free on system drive
- You use Row-Bot < 5 hours/week
- You don't mind potential slowdown over months

### Option 2: External Thunderbolt SSD — Recommended If

- You have a Mac Mini M4 with 256GB
- You use Row-Bot regularly (> 5 hours/week)
- You want seamless performance and longevity

**Drive specs:**
- **Interface:** Thunderbolt 3/4 or USB 3.2 Gen 2 (Type-C)
- **Speed:** >300 MB/s read/write (typical for modern SSDs)
- **Capacity:** 1TB minimum (leaves plenty of headroom)
- **Cost:** $80–200 (1TB Thunderbolt SSD)

**Performance:** Thunderbolt SSDs on M4 Macs are indistinguishable from internal drives. Fully recommended.

### Option 3: USB-A External HDD — Use Only If

- Thunderbolt/USB-C not available
- Budget is critical
- Row-Bot performance is not a concern

**Caveats:**
- USB-A (older) is 10–20x slower than Thunderbolt
- High latency for database operations (memory.db lookups)
- Not recommended for regular use

---

## Setting Up External Storage

### Initial Setup (During `setup.sh`)

The `setup.sh` script now calls `disk-check.sh`, which:
1. Detects all mounted drives
2. Identifies external drives with sufficient free space
3. Tests drive speed and connection type
4. **Recommends** an optimal location

When prompted, approve the recommendation to automatically update `.env`:

```bash
$ ./scripts/setup.sh

[... setup runs ...]

[0/5] STORAGE ASSESSMENT
  System Drive: / 
  Free: 75GB
  ✓ Caution: Less than 100GB free

  ✓ ExternalSSD — Thunderbolt | 450GB free of 500GB

Recommended data storage location:
  /Volumes/ExternalSSD/rowbot-data

Use this location for Row-Bot data? [Y/n] Y
✓ .env updated with recommended paths
```

This updates your `.env`:

```bash
ROW_BOT_DATA_DIR=/Volumes/ExternalSSD/rowbot-data
ROW_BOT_WORKSPACE_DIR=/Volumes/ExternalSSD/rowbot-workspace
```

### Moving Existing Data

If you've already set up Row-Bot on system drive and want to move it:

```bash
# Stop the container
docker-compose down

# Create new directories on external drive
mkdir -p /Volumes/ExternalSSD/rowbot-data
mkdir -p /Volumes/ExternalSSD/rowbot-workspace

# Copy existing data
cp -r ./rowbot-data/* /Volumes/ExternalSSD/rowbot-data/
cp -r ./rowbot-workspace/* /Volumes/ExternalSSD/rowbot-workspace/

# Update .env
sed -i.bak 's|^ROW_BOT_DATA_DIR=.*|ROW_BOT_DATA_DIR=/Volumes/ExternalSSD/rowbot-data|' .env
sed -i.bak 's|^ROW_BOT_WORKSPACE_DIR=.*|ROW_BOT_WORKSPACE_DIR=/Volumes/ExternalSSD/rowbot-workspace|' .env

# Verify permissions
chmod 755 /Volumes/ExternalSSD/rowbot-data
chmod 755 /Volumes/ExternalSSD/rowbot-workspace

# Restart the container
docker-compose up -d
```

---

## Relocating Docker Storage (Advanced)

Docker images and build cache can consume 1–5 GB. On space-constrained systems, you may want Docker to use external storage too.

### macOS — Docker Desktop

1. Open **Docker Desktop** → Preferences
2. Go to **Resources** → **File Sharing**
3. Add your external drive mount point (e.g., `/Volumes/ExternalSSD`)
4. Go to **Resources** → **Disk**
5. Note the current disk location
6. To move Docker data-root (advanced):
   - Quit Docker Desktop
   - Use Docker's data-root option (requires CLI configuration)
   - Or use a symlink (simpler but less clean)

**Symlink approach** (easier):

```bash
# Stop Docker
osascript -e 'quit app "Docker"'
sleep 5

# Move Docker data
sudo mv /Users/<your-user>/Library/Containers/com.docker.docker/Data \
        /Volumes/ExternalSSD/docker-data

# Create symlink
sudo ln -s /Volumes/ExternalSSD/docker-data \
        /Users/<your-user>/Library/Containers/com.docker.docker/Data

# Restart Docker
open -a Docker
```

### Linux — Docker Daemon

Edit `/etc/docker/daemon.json`:

```json
{
    "data-root": "/mnt/external/docker"
}
```

Then restart Docker:

```bash
sudo systemctl restart docker
```

### Windows — Docker Desktop

1. Open **Settings** → **Resources** → **File Sharing**
2. Add your external drive
3. Docker will use it automatically for new images

---

## Monitoring & Cleanup

### Check Current Usage

```bash
# Show Row-Bot data size
du -sh $(grep ROW_BOT_DATA_DIR .env | cut -d= -f2)

# Show workspace size
du -sh $(grep ROW_BOT_WORKSPACE_DIR .env | cut -d= -f2)

# Show Docker usage
docker system df
```

### Automatic Cleanup (Weekly)

```bash
# Run maintenance tool
./scripts/rowbot-maintenance.sh

# Or schedule for weekly execution
# (the tool offers to set up a cron job)
```

**What it cleans:**
- Docker build cache (frees 500MB–2GB)
- Stopped containers
- Dangling images
- Old logs (truncates rowbot_app.log)

### Manual Cleanup

#### Clean Docker

```bash
# Remove build cache (safest)
docker builder prune -f

# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -f

# Full cleanup (removes all unused resources)
docker system prune -a --volumes
```

#### Archive Old Workspace

```bash
# Compress and move to external drive for archival
tar -czf /Volumes/ExternalSSD/rowbot-workspace-backup.tar.gz \
    ./rowbot-workspace

# Remove the large directory to free space
rm -rf ./rowbot-workspace
mkdir -p ./rowbot-workspace
```

#### Reset Everything (Nuclear Option)

```bash
# Stop container
docker-compose down

# Remove all volumes
docker-compose down -v

# Delete Row-Bot data
rm -rf $(grep ROW_BOT_DATA_DIR .env | cut -d= -f2)
rm -rf $(grep ROW_BOT_WORKSPACE_DIR .env | cut -d= -f2)

# Recreate empty directories
mkdir -p $(grep ROW_BOT_DATA_DIR .env | cut -d= -f2)
mkdir -p $(grep ROW_BOT_WORKSPACE_DIR .env | cut -d= -f2)

# Restart
docker-compose up -d
```

---

## Signs You Need to Act

| Signal | Action |
|--------|--------|
| System drive < 30GB free | **URGENT:** Add external drive or clean aggressively |
| System drive < 50GB free | Consider external drive if using Row-Bot regularly |
| Row-Bot container slow | May be disk I/O contention; move data to faster drive |
| `docker-compose up` fails with "disk full" | Run cleanup immediately |
| rowbot-data > 20GB | Archive old sessions or truncate logs |

---

## FAQ

**Q: Can I use an external HDD instead of SSD?**  
A: Yes, but Row-Bot will be slow (memory.db is a database with many small lookups). Thunderbolt/USB-C SSD is strongly recommended.

**Q: Can I use a network drive (NAS)?**  
A: Yes, but expect latency. NFS/SMB adds ~5–20ms per disk operation. For development, Thunderbolt is better.

**Q: How often should I clean up?**  
A: Monthly for most users. Weekly if you use Row-Bot >5 hours/day.

**Q: Will cleanup remove my work?**  
A: No. Cleanup only removes:
- Docker build artifacts (not your data)
- Old application logs (not conversation history in memory.db)
- Optionally: archived workspaces (with confirmation)

**Q: Can I shrink memory.db?**  
A: SQLite doesn't automatically shrink on delete. You can:
```bash
docker-compose exec rowbot sqlite3 /home/rowbot/.row-bot/memory.db "VACUUM;"
```

**Q: What if I run out of space unexpectedly?**  
A: See "Signs You Need to Act" table above. Quick fix:
```bash
./scripts/rowbot-maintenance.sh  # Choose [6] for deep clean
```

---

## Summary

1. **Plan ahead:** Use external Thunderbolt SSD for Row-Bot on Mac Mini M4 (256GB)
2. **During setup:** Let `disk-check.sh` recommend storage; approve it
3. **Ongoing:** Run `./scripts/rowbot-maintenance.sh` monthly to clean up
4. **If moving data:** Stop container → copy files → update .env → restart
5. **Long-term:** Monitor with `du -sh`, react when approaching 50% of available space

For more details on Docker configuration, see [DOCKER_COMPOSE_EXPLAINED.md](DOCKER_COMPOSE_EXPLAINED.md).

---

**Last updated:** 2026-05-27  
**Version:** 1.0
