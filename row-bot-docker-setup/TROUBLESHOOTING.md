# Troubleshooting Row-Bot Docker

Quick fixes for common issues.

---

## Container Issues

### Row-Bot won't start / container keeps restarting

**Check status:**
```bash
docker-compose ps
```

**View detailed logs:**
```bash
docker-compose logs --tail=100 rowbot
```

**Common causes:**

**Error: "Permission denied on file"**
- Fix ownership: `docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine chown -R 1000:1000 /data`
- Restart: `docker-compose restart rowbot`

**Error: "Port 8080 already in use"**
- Find what's using it: `lsof -i :8080` (macOS/Linux) or `netstat -ano | findstr :8080` (Windows)
- Change port in `.env`: set `ROWBOT_PORT=8081` (or any free port)
- Restart: `docker-compose down && docker-compose up -d`

**Error: "Out of memory" or killed unexpectedly**
- Row-Bot needs at least 2GB RAM. Check: `docker stats rowbot`
- If near limit, stop other containers or increase Docker memory limit

**Error: "health check failed"**
- Row-Bot is still starting (takes 30-60 seconds on first run)
- Wait 1 minute and retry: `docker-compose ps`

---

### Container runs but doesn't respond on http://localhost:8080

**Verify it's listening:**
```bash
docker-compose exec rowbot curl -s http://localhost:8080 | head
```

Should return HTML. If error:
- Wait another 30 seconds (Row-Bot is initializing)
- Check logs: `docker-compose logs --tail=20 rowbot | tail`

**Can't access from browser but curl works:**
- Firewall may be blocking. Try: `curl http://localhost:8080`
- If curl works, firewall is blocking browser. Disable temporarily or whitelist port 8080.

**Can't access from other machine:**
- By default, Row-Bot only listens on localhost (secure)
- To access from network, change `.env`: set `ROWBOT_BIND=0.0.0.0`
- Restart: `docker-compose down && docker-compose up -d`
- **Security warning:** This exposes Row-Bot to your local network. See NETWORK_SETUP.md for safer alternatives (tunnel, VPN).

---

## LLM / AI Issues

### Row-Bot won't generate responses

**Check LLM provider is configured:**
```bash
grep "^ROWBOT_LLM_PROVIDER\|^OLLAMA_BASE_URL\|^OPENROUTER_API_KEY\|^OPENAI_API_KEY\|^ANTHROPIC_API_KEY" .env
```

Should show at least one provider configured.

**If using Ollama (local):**

Verify Ollama is running on your machine:
```bash
curl http://localhost:11434/api/tags
```

Should list models. If error:
- Start Ollama: `ollama serve` (in a separate terminal)
- Check it's on port 11434

Verify Row-Bot can reach it from container:
```bash
docker-compose exec rowbot curl http://host.docker.internal:11434/api/tags
```

(On Linux, use `localhost` instead of `host.docker.internal`)

If still not working:
- Ollama may be on a different machine. Check `.env` has correct `OLLAMA_BASE_URL=http://<your-ollama-ip>:11434`

**If using cloud provider (OpenAI, Claude, OpenRouter):**

Check API key is in `.env`:
```bash
grep "API_KEY" .env
```

Verify key isn't expired or empty (`sk-...` values should be present)

Test the API key manually:
```bash
# OpenRouter example
curl -H "Authorization: Bearer YOUR_KEY_HERE" https://api.openrouter.ai/api/v1/models

# OpenAI example
curl -H "Authorization: Bearer YOUR_KEY_HERE" https://api.openai.com/v1/models
```

If "401 Unauthorized": key is wrong or expired. Update `.env` and restart:
```bash
docker-compose restart rowbot
```

**Row-Bot is slow/hanging:**

Check logs for errors:
```bash
docker-compose logs --tail=30 rowbot | grep -i "error\|timeout\|refused"
```

If using Ollama: model may be too large. Check memory: `docker stats rowbot`

If using cloud provider: API may be rate-limited or slow. Try a different model in `.env`.

---

## Setup Issues

### setup.sh failed or didn't create .env

**Run setup again:**
```bash
./setup.sh
```

Choose "Advanced" to see each step and skip past failures.

**setup.sh asks for API key, doesn't save it:**

Check `.env` was created:
```bash
ls -la .env
```

If missing, setup.sh crashed. Check for errors: `tail -20 setup.sh.log` (if it exists)

Manually create .env:
```bash
cp .env.example .env
```

Edit with your values: `nano .env` (or use your editor)

**Sed errors on macOS:**

setup.sh uses BSD sed (different from GNU sed). If you see "sed: 1: ..." errors:
```bash
# Check your sed version
sed --version  # Will fail on macOS

# Install GNU sed
brew install gnu-sed
```

Then run setup.sh again.

---

## Docker / Compose Issues

### docker-compose command not found

**Install docker-compose:**

macOS/Windows: Included with Docker Desktop (download from docker.com)

Linux: `sudo apt install docker-compose` (Ubuntu/Debian) or equivalent for your distro

**docker: permission denied**

You need to be in the docker group:
```bash
sudo usermod -aG docker $USER
```

Then log out and back in, or: `newgrp docker`

**Cannot connect to Docker daemon**

Docker isn't running. Start it:
- macOS/Windows: Open Docker Desktop app
- Linux: `sudo systemctl start docker`

**docker-compose down removes my data!**

By default, `docker-compose down` only removes the container, not volumes.

`docker-compose down -v` removes volumes (⚠️ deletes data). Don't use `-v` unless you want to delete everything.

To safely stop: `docker-compose stop` (keeps data)

To safely remove: `docker-compose down` (removes container, keeps volumes)

---

## Disk / Storage Issues

### "No space left on device"

Check disk: `df -h`

Row-Bot uses the volumes (usually in `/var/lib/docker/volumes/` on Linux).

**To free space:**

Remove old backups: `ls -la backups/` and delete old `.tar.gz` files

Check what's using space:
```bash
docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine du -sh /data
```

If Row-Bot data is huge (>20GB), it's likely the threads.db grew too large.

---

## Health Check Issues

### ./health-check.sh reports failures

**Most common:** "Row-Bot container not running"
- Start container: `docker-compose up -d`
- Wait 10 seconds: `sleep 10 && docker-compose ps`

**"Port 8080 in use"**
- This is OK if Row-Bot is running (it uses port 8080)
- If Row-Bot is not running and port is in use, something else is listening

**"Firewall disabled"**
- On macOS: You disabled the firewall. Enable in System Preferences → Security & Privacy.
- On Linux: Install `ufw` or `firewalld` and enable
- This is optional but recommended for security.

**"Ollama not reachable"** (if using Ollama)
- Make sure Ollama is running: `ollama serve` (separate terminal)
- If Ollama is on another machine, update `.env`: `OLLAMA_BASE_URL=http://<ip>:11434`

---

## Getting More Help

**Run diagnostics:**
```bash
./diagnostics.sh
```

Generates a detailed report (with secrets redacted) you can attach to a bug report.

**Check logs thoroughly:**
```bash
docker-compose logs rowbot > /tmp/rowbot-logs.txt 2>&1
# Then share or review the logs
```

**Ask for help:**
- Row-Bot issue? [github.com/siddsachar/row-bot/issues](https://github.com/siddsachar/row-bot/issues)
- Docker setup issue? [github.com/jp-cruz/agent-skills/issues](https://github.com/jp-cruz/agent-skills/issues)

When asking for help, include:
- Output of `docker-compose ps`
- Last 50 lines of `docker-compose logs rowbot`
- Contents of your `.env` (redact API keys)
- Your OS and Docker version: `docker --version && docker-compose --version`

---

## Still Stuck?

Try a clean restart:

```bash
# Stop everything
docker-compose down

# Remove all data (⚠️ destructive!)
docker volume rm row-bot-docker-setup_rowbot-data

# Start fresh
docker-compose up -d

# Wait 30 seconds then check
sleep 30
docker-compose logs rowbot
```

This erases all your Row-Bot data. Only do this if nothing else works and you have a backup.

**To safely restore from backup after clean restart:**

See [MIGRATION_NOTES.md](MIGRATION_NOTES.md) Phase 3: Copy Bare-Metal Data.
