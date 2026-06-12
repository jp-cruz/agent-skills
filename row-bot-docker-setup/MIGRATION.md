# Migration Guide: Bind Mounts → Pure Docker Volumes (Legacy)

> **Who needs this?** Only users coming from the old **thoth-docker-setup**
> template that used host bind mounts. All current row-bot-docker-setup
> releases (v0.5.0+) already use pure Docker volumes — fresh installs can
> ignore this guide. To upgrade the Row-Bot version itself, see the
> "Upgrading Row-Bot" section in [CLAUDE.md](CLAUDE.md). Migrating from a
> bare-metal (non-Docker) Row-Bot? See [MIGRATION_NOTES.md](MIGRATION_NOTES.md).

## Overview

This setup uses **pure Docker volumes** instead of host bind mounts. This guide helps you migrate from the old bind-mount setup to the new stable architecture.

**Why migrate?**
- ✅ **Portable**: Volumes work on any Docker host (macOS, Linux, Windows, cloud)
- ✅ **Upgrade-safe**: Row-Bot upgrades don't risk data loss or permission issues
- ✅ **Disaster-recovery ready**: Backup/restore works seamlessly
- ✅ **Permission-clean**: No UID/GID mismatch issues

## Migration Checklist

### Step 1: Back Up Your Current Data

```bash
# Create a full backup of your current setup
tar -czf rowbot-data-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  $(grep ROW_BOT_DATA_DIR .env | cut -d= -f2) \
  $(grep ROW_BOT_WORKSPACE_DIR .env | cut -d= -f2)

# Verify backup was created
ls -lh rowbot-data-backup-*.tar.gz
```

### Step 2: Stop the Container

```bash
docker-compose down
```

### Step 3: Delete Old Bind-Mount Volumes

```bash
# List current volumes
docker volume ls | grep rowbot

# Delete the old bind-mount volumes
docker volume rm row-bot-docker-setup_rowbot-data row-bot-docker-setup_rowbot-workspace
```

### Step 4: Update docker-compose.yml

Ensure your `docker-compose.yml` has pure Docker volumes (no `driver_opts`):

```yaml
volumes:
  rowbot-data:
    driver: local
  rowbot-workspace:
    driver: local
```

**NOT like this (old bind mount way):**
```yaml
volumes:
  rowbot-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./rowbot-data
```

### Step 5: Start Container (Creates New Pure Volumes)

```bash
docker-compose up -d
```

Docker will create new pure Docker volumes automatically.

### Step 6: Restore Your Data

```bash
# Copy your backed-up data into the new volumes
docker run --rm \
  -v row-bot-docker-setup_rowbot-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/rowbot-data-backup-*.tar.gz -C /data

# Fix ownership (restored files may have wrong UID)
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  alpine chown -R 1000:1000 /data

# Restart container to apply changes
docker-compose down
docker-compose up -d
```

### Step 7: Verify Migration

```bash
# Check that volumes are pure Docker volumes (not bind mounts)
docker volume inspect row-bot-docker-setup_rowbot-data | grep -i "options"
# Should show: "Options": null

# Verify container is healthy
docker-compose ps
# Should show: STATUS: Up X seconds (healthy)

# Verify data is accessible
docker-compose exec rowbot ls -la /home/rowbot/.row-bot/memory.db
```

## Troubleshooting Migration

### Issue: "Volume exists but doesn't match configuration"

This warning means Docker found old volumes with the old config. Solution:
```bash
docker-compose down
docker volume rm row-bot-docker-setup_rowbot-data row-bot-docker-setup_rowbot-workspace
docker-compose up -d
```

### Issue: "Permission denied" after restore

Files were restored with wrong UID. Fix with:
```bash
docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
  alpine chown -R 1000:1000 /data
```

### Issue: Projects not visible in Developer Studio

Recreate the symlink:
```bash
docker-compose exec rowbot mkdir -p /home/rowbot/Documents/Row-Bot
docker-compose exec rowbot ln -s /home/rowbot/.row-bot/Documents/Row-Bot/projects \
  /home/rowbot/Documents/Row-Bot/projects
```

## Verifying the New Setup

After migration, verify everything is stable:

```bash
# Test 1: Container stays healthy
docker-compose ps
# STATUS should be "Up X seconds (healthy)"

# Test 2: Data is accessible with correct ownership
docker-compose exec rowbot ls -lh /home/rowbot/.row-bot/memory.db
# Should show: rowbot:rowbot ownership, readable

# Test 3: Projects are accessible
docker-compose exec rowbot ls -1 /home/rowbot/Documents/Row-Bot/projects/ | wc -l
# Should show number of projects

# Test 4: Git is available
docker-compose exec rowbot git --version
# Should show: git version X.Y.Z

# Test 5: Volume is pure Docker (not bind mount)
docker volume inspect row-bot-docker-setup_rowbot-data | grep -E '"Options"|"Mountpoint"'
# Should show: "Options": null and Mountpoint: /var/lib/docker/volumes/...
```

## After Migration

Once migrated, you can:

1. **Safely upgrade Row-Bot**:
   ```bash
   # Edit Dockerfile to new version
   docker-compose build --no-cache
   docker-compose up -d
   # Data remains intact
   ```

2. **Reliably back up**:
   ```bash
   docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
     -v ./backups:/backup alpine tar czf /backup/rowbot-data-$(date +%Y%m%d).tar.gz -C /data .
   ```

3. **Restore from backup**:
   ```bash
   docker-compose down
   docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
     -v ./backups:/backup alpine tar xzf /backup/rowbot-data-*.tar.gz -C /data
   docker run --rm -v row-bot-docker-setup_rowbot-data:/data \
     alpine chown -R 1000:1000 /data
   docker-compose up -d
   ```

## Cleaning Up Old Files

After successful migration, you can remove the old host directories (optional):

```bash
# Verify you have backups first!
ls -la ./rowbot-data-backup-*.tar.gz

# Remove old directories (if you're sure)
rm -rf ./rowbot-data ./rowbot-workspace

# Remove old backup location (if it exists)
rm -rf /path/to/old/rowbot-data.backup-*
```

**Important**: Keep at least one backup before deleting these directories!

## Questions?

See [CLAUDE.md](CLAUDE.md) for detailed architecture information and [README.md](README.md) for general setup guide.
