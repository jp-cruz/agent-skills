# Troubleshooting Guide

Quick answers to common problems.

---

## Thoth Won't Start

### Check container status

```bash
docker-compose ps
# STATUS should be: Up X seconds (healthy)
```

### If status is "Exiting" or "Restarting"

```bash
# View detailed error logs
docker-compose logs --tail=100 thoth
```

### Common startup errors

#### Error: Permission denied on thoth_app.log

**Cause:** File ownership issue after data restore

**Fix:**
```bash
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  alpine chown -R 1000:1000 /data
docker-compose up -d
```

#### Error: Address already in use

**Cause:** Port 8080 (or configured port) is in use

**Fix:**
```bash
# Find what's using port 8080
lsof -i :8080  # macOS
netstat -tlnp | grep 8080  # Linux

# Either stop that process or change THOTH_PORT in .env
# Then restart:
docker-compose down
docker-compose up -d
```

#### Error: Failed to connect to Docker daemon

**Cause:** Docker Desktop not running

**Fix:**
```bash
# Start Docker
open -a Docker  # macOS
# Or: Start Docker Desktop app on Windows

# Wait 10 seconds then try again
docker-compose up -d
```

---

## Can't Access Thoth

### Thoth is running but page won't load

```bash
# Test container is listening
docker-compose exec thoth curl http://localhost:8080
# Should return HTML

# Check binding (default is localhost only)
docker-compose ps
# Should show: 127.0.0.1:8080->8080 (localhost only)
# or: 0.0.0.0:8080->8080 (network-wide)
```

### Can't access from other computer on network

**Cause:** Default binding is localhost-only (127.0.0.1)

**Fix:**
```bash
# In .env, change:
THOTH_BIND=0.0.0.0

# Rebuild and restart:
docker-compose down
docker-compose up -d

# Then access from other machine using your IP:
# http://<your-machine-ip>:8080
```

See [NETWORK_SETUP.md](references/NETWORK_SETUP.md) for details.

---

## Ollama Issues

### Ollama not reachable

```bash
# Check if Ollama is running
curl http://host.docker.internal:11434/api/tags  # macOS/Windows
curl http://localhost:11434/api/tags  # Linux

# Should return JSON with list of models
```

### If Ollama is not running

```bash
# Start Ollama
# macOS/Windows: Open Ollama app
# Linux: ollama serve

# Then from inside container:
docker-compose exec thoth curl http://host.docker.internal:11434/api/tags
```

### Thoth says "Could not connect to Ollama"

**Cause:** OLLAMA_BASE_URL in .env doesn't match where Ollama is running

**Fix:**
```bash
# Check OLLAMA_BASE_URL in .env
cat .env | grep OLLAMA

# macOS/Windows Docker Desktop:
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Linux (if Ollama on same host):
OLLAMA_BASE_URL=http://localhost:11434

# Linux (if Ollama on different machine):
OLLAMA_BASE_URL=http://<ollama-machine-ip>:11434
```

Then restart:
```bash
docker-compose restart thoth
```

### Ollama loads but model is slow

**Cause:** Model too large for your hardware

**Solutions:**
1. Use smaller model:
   ```bash
   ollama pull mistral  # Smaller than llama2
   ```

2. Check available RAM:
   ```bash
   docker stats  # See memory usage
   ```

3. Consider cloud provider instead (OpenRouter, OpenAI)

---

## Developer Studio Issues

### Projects not visible in Thoth UI

**Cause:** Symlink lost after container rebuild

**Fix (manual):**
```bash
docker-compose exec thoth mkdir -p /home/thoth/Documents/Thoth
docker-compose exec thoth ln -s /home/thoth/.thoth/Documents/Thoth/projects \
  /home/thoth/Documents/Thoth/projects 2>/dev/null || true
```

**Fix (automatic in v0.6.2+):** Should be automatic via entrypoint script. If not, try container restart:
```bash
docker-compose restart thoth
```

### Can't write to workspace

**Cause:** File ownership issue

**Fix:**
```bash
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  alpine chown -R 1000:1000 /data
docker-compose restart thoth
```

---

## Performance Issues

### Container uses lots of memory

```bash
# Check memory usage
docker stats

# Typical: 1-2 GB
# High: 4+ GB suggests memory leak
```

### Thoth is slow to respond

**Possible causes:**

1. **Ollama running on same machine** — Shares CPU/memory
   - Solution: Use cloud LLM instead (OpenRouter, OpenAI)

2. **Large conversation history** — memory.db is huge
   - Check size: `docker-compose exec thoth du -sh /home/thoth/.thoth/memory.db`
   - Solution: Archive old conversations or start fresh

3. **Docker resource limits** — Container isn't given enough resources
   - Check: `docker inspect thoth-app | grep Memory`
   - Solution: Increase Docker Desktop memory allocation

---

## Data Issues

### Lost all my conversations

**Prevention (for future):**
```bash
# Back up regularly
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  -v ./backups:/backup alpine tar czf /backup/thoth-data-$(date +%Y%m%d).tar.gz -C /data .
```

**Recovery (if backup exists):**
```bash
# Restore from backup
docker-compose down
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  -v ./backups:/backup alpine tar xzf /backup/thoth-data-*.tar.gz -C /data
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  alpine chown -R 1000:1000 /data
docker-compose up -d
```

See [CLAUDE.md](CLAUDE.md) "Disaster Recovery" section for full procedures.

---

## Upgrading Thoth

### Before upgrading

```bash
# Back up your data
docker run --rm -v thoth-docker-setup_thoth-data:/data \
  -v ./backups:/backup alpine tar czf /backup/thoth-backup-pre-upgrade-$(date +%Y%m%d).tar.gz -C /data .
```

### To upgrade to new Thoth version

```bash
# Edit Dockerfile, change line 11:
# git checkout v3.23.1  →  git checkout v3.24.0

# Rebuild and restart
docker-compose build --no-cache
docker-compose up -d
```

Your data is safe in Docker volumes — they persist across upgrades.

---

## When to Escalate

If you've tried the above and still have issues:

1. **Collect logs:**
   ```bash
   docker-compose logs --tail=200 thoth > thoth-logs.txt
   ```

2. **Document:**
   - What you tried
   - Exact error message
   - Your OS and Docker version
   - `.env` settings (without API keys)

3. **Report:**
   - [Thoth Issues](https://github.com/siddsachar/Thoth/issues) for Thoth-specific bugs
   - [This Repo Issues](https://github.com/jp-cruz/agent-skills/issues) for setup/Docker issues

---

## Quick Reference

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart thoth

# Stop
docker-compose stop

# Full reset (⚠️ deletes volumes)
docker-compose down -v

# Shell access
docker-compose exec thoth bash

# Check health
docker-compose ps
curl http://localhost:8080
```

See [CLAUDE.md](CLAUDE.md) for more detailed command reference.
