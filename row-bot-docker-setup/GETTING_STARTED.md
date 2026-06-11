# Getting Started with Thoth Docker

Your setup is complete. Here's how to verify everything works and take your first steps.

---

## Step 1: Verify Setup (2 minutes)

Run the health check to confirm everything is working:

```bash
cd /path/to/thoth-docker-setup
./health-check.sh
```

You should see:
```
✓ Docker running
✓ Port 8080 available
✓ Ollama reachable (or cloud LLM configured)
✓ Thoth container healthy
✓ All checks passed
```

If you see ✗ instead, see [Troubleshooting](#troubleshooting) below.

---

## Step 2: Start Thoth (30 seconds)

If health check passed:

```bash
docker-compose up -d
```

Wait 10-15 seconds for the container to fully start.

---

## Step 3: Access Thoth (1 minute)

Open your browser to:

```
http://localhost:8080
```

You should see the Thoth interface. If not:
- **Chrome/Safari/Firefox not loading?** → Check Troubleshooting below
- **Port 8080 blocked?** → See [Port Conflicts](TROUBLESHOOTING.md#port-already-in-use)
- **Network error?** → Container may still be starting, wait 20 seconds and refresh

---

## Step 4: Your First Prompt (5 minutes)

Once Thoth loads, you're ready to interact. Try something simple:

```
"Tell me about yourself and what you can do."
```

Then try something practical:

```
"Create a simple Python script that prints 'Hello, World'"
```

**If responses are slow:**
- First response may take 10-30 seconds (model loading)
- Subsequent responses should be faster
- If consistently slow, see [Performance Issues](TROUBLESHOOTING.md#thoth-is-slow-to-respond)

---

## Step 5: Set Preferences (Optional)

Once you're comfortable, explore Thoth's settings:
- Click the settings icon (⚙️) in the interface
- Configure your preferred language model
- Set up any API integrations
- Customize behavior

See [Thoth Documentation](https://github.com/siddsachar/Thoth#readme) for detailed options.

---

## Common Questions

### "How does Thoth see my files?"

By default, Thoth **cannot see files on your computer**. For security, all workspace files live in the Docker container.

To share files with Thoth:
1. Use the web interface upload
2. Or mount additional volumes (advanced — see [CLAUDE.md](CLAUDE.md))

### "Can Thoth access the internet?"

By default, **no**. Thoth can make API calls to configured services (OpenAI, Anthropic, etc.) but cannot browse the web unless explicitly configured.

### "Where is my data stored?"

Your Thoth data lives in Docker volumes:
- **Application data** (memory.db, config): `/var/lib/docker/volumes/thoth-docker-setup_thoth-data/_data`
- **Workspace files**: `/var/lib/docker/volumes/thoth-docker-setup_thoth-workspace/_data`

To back up: See [CLAUDE.md](CLAUDE.md) "Disaster Recovery" section.

### "How do I update to a newer Thoth version?"

1. Edit `docker/Dockerfile` line 11: `git checkout v3.23.1` → change to new version
2. Run: `docker-compose build --no-cache`
3. Run: `docker-compose up -d`

Your data is safe — volumes persist across upgrades.

---

## Troubleshooting

### Thoth won't load in browser

**Check 1: Container is running**
```bash
docker-compose ps
# Should show: thoth  UP
```

**Check 2: Port is working**
```bash
docker-compose exec thoth curl http://localhost:8080
# Should return HTML (long response)
```

**Check 3: Try a different port**
```bash
# Edit .env
THOTH_PORT=8081

# Restart
docker-compose down
docker-compose up -d

# Try: http://localhost:8081
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#cant-access-thoth) for more.

---

### Ollama not found

If you chose local Ollama but it's not running:

```bash
# Check if Ollama is running on your machine
curl http://localhost:11434/api/tags

# If error: Start Ollama
# macOS: Open Ollama app
# Linux: ollama serve

# Then restart Thoth
docker-compose restart thoth
```

If you don't have Ollama installed: See [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md) for alternatives.

---

### No API key / cloud provider not responding

If you chose OpenAI/Claude/OpenRouter but getting "API error":

**Check 1: API key is set**
```bash
cat .env | grep -i openai  # or openrouter, anthropic
```

**Check 2: API key is correct**
- Re-run setup.sh to enter your key again
- Or edit .env directly (keep it secret!)

**Check 3: Key has credits/balance**
- Log in to your provider's dashboard
- Verify account has credits available
- Check for spending limits

---

### Container won't start

```bash
# View error logs
docker-compose logs --tail=50 thoth

# Common issues:
# - Out of disk space: docker system prune
# - Port already in use: see Port Conflicts section
# - Permission error: may need sudo
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#thoth-wont-start) for detailed fixes.

---

## Next Steps

### Want to use Thoth more effectively?

- **Read the Thoth docs**: https://github.com/siddsachar/Thoth#readme
- **Check Discord/forums**: Community support and examples
- **Create your first project**: Organize your work in Thoth

### Want to integrate with other tools?

- **GitHub integration**: See Thoth's Developer Studio
- **Discord bot**: Expose Thoth as a Discord bot (advanced)
- **API access**: Thoth exposes an API for custom integrations

### Want to customize Thoth?

- **Custom models**: See [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md)
- **Reverse proxy**: See [NETWORK_SETUP.md](references/NETWORK_SETUP.md)
- **Docker resources**: See [CLAUDE.md](CLAUDE.md)

### Want to back up your data?

See [CLAUDE.md](CLAUDE.md) "Disaster Recovery" section for:
- Monthly backup procedure
- Testing your backups (critical!)
- Full restore procedure

---

## Need Help?

1. **Quick issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. **Docker questions**: See [DOCKER_WHY.md](DOCKER_WHY.md)
3. **LLM setup**: See [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md)
4. **Network access**: See [NETWORK_SETUP.md](references/NETWORK_SETUP.md)
5. **Thoth issues**: Check [Thoth GitHub Issues](https://github.com/siddsachar/Thoth/issues)

---

## Checklist: Your First Hour

- [ ] Ran `./health-check.sh` and all passed
- [ ] Started Thoth with `docker-compose up -d`
- [ ] Accessed Thoth at http://localhost:8080
- [ ] Successfully created a prompt and got a response
- [ ] Located where your data is stored
- [ ] Reviewed backup procedures
- [ ] Bookmarked this guide for future reference
