# Getting Started with Row-Bot Docker

This guide walks you through your first steps after setup.sh completes.

## Prerequisites

You've already:
- Run `./setup.sh` (macOS/Linux). Windows: run `scripts\setup.bat` — it checks prerequisites and walks you through running setup.sh via WSL or Git Bash
- Created a `.env` file with your configuration
- Started the container with `docker-compose up -d`

If not, start there: `./setup.sh`

---

## 1. Verify Row-Bot is Running

Check that the container started successfully:

```bash
docker-compose ps
```

You should see `rowbot` in the output with status `Up`.

If the container is not running, check the logs:

```bash
docker-compose logs --tail=50 rowbot
```

Look for errors about:
- Missing dependencies
- Port 8080 already in use
- Permission denied on volumes
- Ollama connection failures

---

## 2. Access the Row-Bot Web Interface

Open your browser to: **http://localhost:8080**

You should see the Row-Bot dashboard. If it's loading, wait 30 seconds — Row-Bot can take time to initialize.

### If you can't access it:

**On macOS/Linux:**
```bash
curl -I http://localhost:8080
```

Should return HTTP 200 or 303 (redirect). If "Connection refused", the container may not be listening yet or port 8080 is blocked.

**On Windows WSL2:**
Same as above — `localhost:8080` should work.

**If port 8080 is in use:**
```bash
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows
```

If something else is using port 8080, either:
- Stop that service, OR
- Edit `.env` and change `ROW_BOT_PORT=8081` (or any free port), then restart:
  ```bash
  docker-compose down
  docker-compose up -d
  ```

---

## 3. Test LLM Connectivity

Row-Bot can use either **Ollama** (local, free) or **cloud providers** (OpenAI, Claude, OpenRouter).

### Check Ollama (if you configured it):

```bash
# From your host machine:
curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*' | cut -d'"' -f4
```

Should list your Ollama models (e.g., `qwen2`, `llama2`).

If Ollama is running on a different machine:
```bash
curl -s http://<ollama-host-ip>:11434/api/tags
```

### Check cloud provider (if you configured an API key):

Inside Row-Bot, create a test conversation:
1. Click the **+** (new chat) button
2. Type: "What is 2+2?"
3. Send the message

If Row-Bot responds, your LLM provider is working.

If it hangs or errors:
- Check that your API key is correct in `.env`
- Verify your API key hasn't expired
- Check cloud provider status (openrouter.io, openai.com, etc.)
- Look at container logs: `docker-compose logs --tail=20 rowbot`

---

## 4. Explore Row-Bot Features

Once you're connected to an LLM:

### Create a Project (optional)

- Click **Workspace** or **Projects**
- Create a new project (Row-Bot will guide you)
- Projects let you organize conversations and knowledge

### Use the Knowledge Graph (optional)

- Click **Knowledge** or **Memory**
- Row-Bot automatically builds a knowledge graph from conversations
- You can see entities (people, concepts) and their relationships

### Configure Tools (optional)

- Click **Settings** or **Tools**
- Row-Bot can integrate with external tools (APIs, web search, etc.)
- Your API keys from `.env` are already loaded here

---

## 5. Keep Row-Bot Running

### Check container health:

```bash
docker-compose exec rowbot curl -s http://localhost:8080 | head -20
```

### View live logs:

```bash
docker-compose logs -f rowbot
```

Press `Ctrl+C` to stop watching logs.

### Restart if needed:

```bash
docker-compose restart rowbot
```

### Changed `.env` (added/updated an API key)?

A plain `restart` does **not** reload `.env` — recreate the container instead:

```bash
docker-compose up -d
```

Your data is safe; it lives in Docker volumes, not the container.

### Stop Row-Bot (but keep data):

```bash
docker-compose stop
```

### Start again:

```bash
docker-compose up -d
```

### Delete everything (⚠️ destructive):

```bash
docker-compose down -v  # Deletes all data!
```

---

## 6. Troubleshooting

**Problem:** "Connection refused" when accessing http://localhost:8080

**Solutions:**
- Wait 30 seconds (Row-Bot is starting)
- Check logs: `docker-compose logs --tail=50 rowbot`
- Verify port 8080 is free: `lsof -i :8080`
- Check firewall isn't blocking localhost access

---

**Problem:** Row-Bot starts but LLM doesn't respond

**Solutions:**
- If using Ollama: `curl http://localhost:11434/api/tags` (should list models)
- If using cloud LLM: check API key in `.env` is correct
- Pick your provider/model inside Row-Bot: Settings → Models (not via .env)
- View logs: `docker-compose logs --tail=50 rowbot | grep -i "llm\|ollama\|api"`

---

**Problem:** "Permission denied" errors in logs

**Solutions:**
- The container user may not have write access to volumes
- Fix with: `docker run --rm -v row-bot-docker-setup_rowbot-data:/data alpine chown -R 1000:1000 /data`
- Restart: `docker-compose restart rowbot`

---

**Problem:** Docker can't find container or service

**Solutions:**
- Make sure you're running `docker-compose` commands from the **row-bot-docker-setup** directory (where `docker-compose.yml` lives)
- The service name is **`rowbot`** (not `thoth`)
- The container name is **`rowbot-app`** (for direct `docker` commands)

---

## Can Row-Bot Touch My Files?

No. Docker isolates the container — Row-Bot can only see:
- `/home/rowbot/.row-bot` (its data, stored in the `rowbot-data` volume)
- `/home/rowbot/Documents/Row-Bot` (your workspace, stored in the `rowbot-workspace` volume)

It cannot read your host files, wipe your drive, or change your system. That isolation is the whole point of this setup — see [DOCKER_WHY.md](DOCKER_WHY.md).

---

## Quick FAQ

| Q | A |
|---|---|
| Do I need to know Docker? | No — setup.sh and these guides handle it. |
| Will this break my computer? | No — Row-Bot is isolated inside the container. |
| Where is my data? | In Docker volumes (`rowbot-data`, `rowbot-workspace`), safe across restarts and upgrades. |
| How do I uninstall? | `docker-compose down` (keep data) or `docker-compose down -v` (⚠️ deletes data), then delete this folder. |
| Can I move to another computer? | Yes, but your data lives in Docker volumes — back them up first (see [CLAUDE.md](CLAUDE.md)), don't just copy the folder. |
| Can I run multiple Row-Bots? | Yes — setup.sh asks and configures it (own folder, name, and port per instance; see README "Running Multiple Row-Bot Instances"). |
| How much does it cost? | Free with Ollama; cloud APIs bill per request — run `./estimate-costs.sh`. |
| Is my data private? | With Ollama, everything stays on your machine. Cloud providers see what you send them. |

---

## Next Steps

- **Learn Row-Bot:** Check the [Row-Bot GitHub](https://github.com/siddsachar/row-bot) docs
- **Migrate from bare-metal:** See [MIGRATION_NOTES.md](MIGRATION_NOTES.md) if you're moving from a non-Docker Row-Bot
- **Advanced configuration:** See [CLAUDE.md](CLAUDE.md) for developer options
- **Troubleshoot:** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

---

## Health Check

Run the included health-check script to verify everything:

```bash
./health-check.sh
```

This checks:
- Docker is installed and running
- docker-compose is available
- `.env` is configured
- Port 8080 is available
- Row-Bot container is running
- Ollama or cloud LLM is reachable

---

## Questions?

- **Row-Bot issues:** [github.com/siddsachar/row-bot/issues](https://github.com/siddsachar/row-bot/issues)
- **Docker setup issues:** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or run `./diagnostics.sh`
- **This skill issues:** [github.com/jp-cruz/agent-skills/issues](https://github.com/jp-cruz/agent-skills/issues)

Enjoy Row-Bot! 🚀
