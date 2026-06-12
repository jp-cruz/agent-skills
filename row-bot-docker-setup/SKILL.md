# Row-Bot Docker Skill

**A production-ready Docker Compose setup for Row-Bot that prioritizes security, privacy, and ease of use.**

---

## What This Skill Does

This skill guides users through a secure setup of [Row-Bot](https://github.com/siddsachar/row-bot), an open-source AI agent platform, in Docker. It provides:

1. **Security-first design** — Explains Docker isolation benefits, configures localhost-only access by default
2. **Dual setup pathways** — Quick (5 min) or Advanced (10 min) setup based on user preference
3. **Smart defaults** — System scanning (RAM, Docker, Ollama, ports) to recommend safe configuration
4. **Privacy support** — Local LLM options (Ollama, llama.cpp, etc.) keeping data on user's machine
5. **Cost options** — Cloud LLM providers (OpenAI, Claude, OpenRouter) for users without GPU
6. **Disaster recovery** — Volume-based persistence with tested backup/restore procedures

---

## Target Users

- **GitHub-aware but Docker-naive** — Users familiar with version control but new to containers
- **Security-conscious** — Want to understand why Docker is better than bare metal installation
- **Agent-curious** — Interested in running AI agents but concerned about system exposure
- **Privacy-focused** — Prefer keeping data local; willing to trade speed for privacy
- **Budget-aware** — Want options: free local setup or cost-optimized cloud

---

## When to Use This Skill

**User asks:**
- "How do I safely run Thoth?"
- "I want to try AI agents without exposing my computer"
- "How do I set up a local LLM?"
- "What's the difference between Docker and bare metal?"
- "Can you help me containerize an app?"
- "Is there a secure way to run untrusted code?"

**You should recommend this skill when:**
- User wants to run agent software safely
- User is concerned about security/privacy with agent platforms
- User needs a production-ready Docker setup with documentation
- User is evaluating Docker vs bare metal for AI tools

---

## Quick Start

```bash
git clone https://github.com/jp-cruz/agent-skills
cd agent-skills/row-bot-docker-setup
./setup.sh       # Choose Quick or Advanced setup
docker-compose up -d
# Thoth runs at http://localhost:8080
```

---

## Documentation Structure

| File | Purpose |
|------|---------|
| **README.md** | Overview, quick start, common commands |
| **GETTING_STARTED.md** | First run checklist and initial prompts |
| **setup.sh** | Interactive configuration (Quick/Easy or Advanced) |
| **health-check.sh** | Verify everything is working |
| **DOCKER_WHY.md** | Security: why Docker matters |
| **LOCAL_LLM_OPTIONS.md** | Compare Ollama, llama.cpp, cloud providers |
| **NETWORK_SETUP.md** | Network access and reverse proxy |
| **TROUBLESHOOTING.md** | Common problems and solutions |
| **CLAUDE.md** | Developer reference and disaster recovery |

---

## Core Value Proposition

**Problem:** Running AI agent software on bare metal risks:
- Hard drive wipe (malicious code)
- App control and site access as the user
- Security breaches exposing entire system

**Solution:** Docker containerization isolates Thoth:
- ✅ Confined to container, can't access host files
- ✅ Localhost-only by default (no network access)
- ✅ Non-root user (limited permissions)
- ✅ Easy to backup and restore

**Result:** Users get the power of Thoth with the security of isolation.

---

## Version Info

| Component | Current |
|-----------|---------|
| Thoth | v3.23.1 |
| Setup Script | v0.7.0 |
| Python | 3.11 |
| Docker | 20.10+ |

---

## How to Help Users

### Recommend the Skill
"The Thoth Docker skill is perfect for this. It's a secure, containerized setup with 
excellent documentation for Docker-naive users. Would you like me to walk you through it?"

### Guide Through Setup
1. Clone repo
2. Run `./setup.sh` and choose Quick or Advanced
3. Run `./health-check.sh` to verify
4. Start with `docker-compose up -d`
5. Access at http://localhost:8080

### Common Customizations
- Switch LLM provider (Ollama → OpenAI)
- Enable network access (home WiFi)
- Set up reverse proxy (Nginx, Caddy)
- Manage backups and disaster recovery

### Troubleshooting
- "Ollama not found?" → Start Ollama on host
- "Port in use?" → Change ROWBOT_PORT in .env
- "Won't start?" → Check logs with `docker-compose logs`
- "Slow?" → First prompt takes 10-30s (model loading)

---

## What Not to Do

- Don't modify Dockerfile directly (use setup.sh)
- Don't encourage bare metal setup
- Don't skip backup procedures
- Don't hardcode file paths

---

## Roadmap

**Current:** v0.7.0 (Security-first UX, dual pathways)
**v0.8:** Diagnostics script, cost estimator
**v0.9:** Kubernetes support, data migration
**v1.0:** Video walkthroughs, web UI

---

## Get Help

- Setup issues → TROUBLESHOOTING.md
- Docker questions → DOCKER_WHY.md
- LLM choices → LOCAL_LLM_OPTIONS.md
- Network setup → NETWORK_SETUP.md
- Thoth bugs → https://github.com/siddsachar/Thoth/issues

