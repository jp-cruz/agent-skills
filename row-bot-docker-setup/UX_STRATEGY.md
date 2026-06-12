# UX Strategy: Security-First Setup for Docker-Naive Users

## Problem Statement

**Target audience:** GitHub-aware but Docker-naive users who want to run AI agent software safely.

**Core risk (bare metal installation):**
1. **Hard drive wipe** — Malicious agent code or command injection could format storage
2. **App control & site access** — Agent could manipulate applications, access sensitive files, visit sites as the user
3. **Security breach cascade** — Single vulnerability (malicious website, command injection, bad actor) compromises entire system and all user identity/credentials

**Docker solution:** Containerization creates a security boundary that isolates the agent platform from the host system. If Row-Bot is compromised, the attacker is confined to the container—they cannot wipe drives, access host files, or impersonate the user on external sites.

---

## UX Strategy: Two Pathways

### Design Principle
Both pathways produce the **same safe defaults** through system scanning. The difference is *friction*:
- **Quick/Easy:** Scan → Recommend → One approval → Done (2 min)
- **Advanced:** Scan → Recommend → Question-by-question customization → CTAs (5-10 min)

---

## Pathway 1: Quick/Easy Setup

**Goal:** New users get a working, safe installation with zero decisions.

### Flow

```
┌─────────────────────────────────────────┐
│ Welcome: Why Docker for Agent Software? │
│                                         │
│ Running untrusted code on bare metal:  │
│  • Malicious code can wipe your drive  │
│  • Compromised agents access your apps │
│  • Security breaches expose everything │
│                                         │
│ Docker isolates Row-Bot in a container │
│ — safer for you, same power.          │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ System Scan                             │
│ • RAM: 16 GB (supports local LLM ✓)   │
│ • Docker: Installed ✓                   │
│ • Ollama: Installed ✓                   │
│ • Port 8080: Available ✓                │
│ • Network: Home network detected        │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Recommended Setup                       │
│                                         │
│ ✓ Network: Localhost only (secure)     │
│   Access from this computer only        │
│                                         │
│ ✓ LLM: Ollama (private, on your machine)│
│   Your data stays on your computer      │
│                                         │
│ [Accept These Defaults] [Advanced Setup]│
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Creating .env...                        │
│ Starting Row-Bot...                       │
│                                         │
│ ✅ Setup complete!                      │
│ Access Row-Bot at: http://localhost:8080 │
│                                         │
│ Learn more: see DOCKER_WHY.md           │
└─────────────────────────────────────────┘
```

### Key Messages
- **Why Docker:** Lead with security (isolation), not technical details
- **Scan results:** "This is what we detected about your computer"
- **Defaults:** "Based on your hardware, here's what we recommend"
- **One decision:** "Accept these safe defaults or customize?"

### System Scan Logic

```
Detect:
├─ RAM (GB)
│   ├─ < 8GB    → Warn: local LLM risky, suggest cloud
│   ├─ 8-16GB   → Local LLM OK (smaller models)
│   └─ 16GB+    → Local LLM recommended
├─ Ollama installed?
│   └─ Yes → Check if reachable on standard ports
├─ Docker installed?
│   └─ Yes → Verify version 20.10+
├─ Port 8080 available?
│   └─ Check for conflicts
└─ Network topology
    ├─ Single-user machine → Recommend localhost-only
    ├─ Shared WiFi → Warn: consider advanced for network access
    └─ Needs internet access → Recommend advanced for proxy
```

### Defaults Applied
- `ROWBOT_BIND=127.0.0.1` (localhost only — most secure)
- `ROWBOT_PORT=8080` (standard, available)
- `LLM_PROVIDER=ollama` (if RAM ≥ 8GB and Ollama detected)
- `LLM_PROVIDER=openrouter` (if RAM < 8GB, no Ollama, ask for API key)
- `RESTART_POLICY=unless-stopped`

---

## Pathway 2: Advanced Setup

**Goal:** Power users can customize every aspect while still respecting security defaults.

### Flow

```
┌─────────────────────────────────────────┐
│ Welcome: Advanced Docker Setup          │
│                                         │
│ This is for users who want to:          │
│  • Customize network access             │
│  • Try different LLM providers          │
│  • Set up reverse proxies                │
│  • Fine-tune performance                │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ System Scan [Same as Quick]             │
│ • RAM: 16 GB (supports local LLM ✓)   │
│ • Docker: Installed ✓                   │
│ • Ollama: Installed ✓                   │
│ • Port 8080: Available ✓                │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Q1: Network Access                      │
│                                         │
│ How will you access Row-Bot?              │
│  a) This computer only [DEFAULT - Secure]│
│  b) From other machines on home WiFi    │
│  c) From the internet (expert mode)     │
│                                         │
│ → If (b) or (c): Show NETWORK_SETUP.md  │
│   and proxy setup CTA                   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Q2: LLM Provider                        │
│                                         │
│ What matters most?                      │
│  a) Privacy & control (local Ollama)    │
│  b) Cost (OpenRouter, cheap models)     │
│  c) Quality (GPT-4, Claude)             │
│  d) Show me all options [DEFAULT]       │
│                                         │
│ → Explain tradeoffs                     │
│ → If cloud: Ask for API key             │
│ → Show LOCAL_LLM_OPTIONS.md CTA         │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Q3: Optional Power User CTAs            │
│                                         │
│ Interested in:                          │
│  □ Custom models (vLLM, llama.cpp)      │
│  □ GPU acceleration                     │
│  □ Reverse proxy setup (Nginx, Caddy)   │
│  □ Kubernetes deployment                │
│                                         │
│ [Links to guides]                       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Review Configuration                    │
│                                         │
│ Network: [user choice or default]       │
│ LLM: [user choice or default]           │
│ Port: [8080 or custom]                  │
│                                         │
│ [Confirm] [Edit] [Back]                 │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Creating .env...                        │
│ Starting Row-Bot...                       │
│                                         │
│ ✅ Setup complete!                      │
│                                         │
│ Next steps:                             │
│ • [Network Access Guide] (if chosen)    │
│ • [LLM Options Reference]               │
│ • [Security Best Practices]             │
│ • [Troubleshooting]                     │
└─────────────────────────────────────────┘
```

### Questions & Customization

**Network Access (Q1):**
- Default: Localhost only (127.0.0.1) — same as Quick pathway
- Option B: Home network access (0.0.0.0) — warn about lack of auth, link to NETWORK_SETUP.md
- Option C: Internet access — require reverse proxy acknowledgment, link to examples

**LLM Provider (Q2):**
- Default: Local Ollama (if detected and RAM ≥ 8GB) or OpenRouter (if smaller hardware)
- Option A: Force local LLM, ask for model selection
- Option B: Force cost-optimized cloud
- Option C: Force quality
- Option D (default): Show comparison table, let user choose
  - For each choice: Ask for API key if cloud provider

**Power User CTAs (Q3):**
- Custom models: Link to `LOCAL_LLM_OPTIONS.md` + Ollama/vLLM docs
- GPU acceleration: Link to Docker GPU setup guide
- Reverse proxy: Link to Nginx + Caddy examples in NETWORK_SETUP.md
- Kubernetes: Link to future K8s deployment guide (v2.0+)

---

## Security Messaging Framework

### For Both Pathways

**Lead message:**
> "Row-Bot uses **Docker** to isolate the AI agent from your computer. If Row-Bot is compromised, the attacker is confined to the container—they can't wipe drives, access your files, or impersonate you online."

### Expanded Security Frame (Advanced only)

**Why Docker matters for agent safety:**

| Risk | Bare Metal | Docker Container |
|------|-----------|------------------|
| **Hard drive wipe** | ⚠️ Possible — malicious code runs as you | ✅ Blocked — confined to /home/thoth |
| **App manipulation** | ⚠️ Possible — code can modify any app | ✅ Blocked — can't access host processes |
| **Site access as user** | ⚠️ Possible — network requests use your IP | ✅ Blocked — requests come from container |
| **Data breach cascade** | ⚠️ Entire system at risk if Row-Bot compromised | ✅ Only container data at risk |
| **Credential theft** | ⚠️ Access to ~/.ssh, API keys, passwords | ✅ Can't access host home directory |

**This doesn't mean no risk:**
- If Thoth itself is malicious, bad actor has container access
- Container networking could be exploited by advanced attackers
- Always use trusted AI models and updates

**Our defaults reduce risk further:**
- Localhost-only networking (no external access by default)
- Ollama keeps data private on your machine (no cloud)
- Non-root user (thoth) even inside container

---

## Files to Create/Update

### New Files
1. **DOCKER_WHY.md** — Non-technical explanation of Docker security and isolation
2. **LOCAL_LLM_OPTIONS.md** — Detailed comparison of Ollama, LMStudio, llama.cpp, oMLX, vLLM

### Updated Files
1. **setup.sh** — Implement Quick/Easy vs Advanced pathways
2. **README.md** — Add "Choose Your Path" section with links to both flows
3. **.env.example** — Add security-framing comments

### Referenced (No changes needed)
- **NETWORK_SETUP.md** — Link from Advanced pathway for network access options
- **TROUBLESHOOTING.md** — Link for common issues

---

## Implementation Checklist

- [ ] Create DOCKER_WHY.md (non-technical, visual)
- [ ] Create LOCAL_LLM_OPTIONS.md (comparison table, tradeoffs)
- [ ] Update setup.sh to detect Quick vs Advanced request
- [ ] Implement system scanning (RAM, Docker, Ollama, ports)
- [ ] Implement Quick/Easy flow (minimal questions, one approval)
- [ ] Implement Advanced flow (detailed questions, CTAs)
- [ ] Add security messaging to both flows
- [ ] Update README.md with pathway selector
- [ ] Test both flows with Docker-naive user (ask Dylan or friend)
- [ ] Document any edge cases (old Docker, low RAM, no Ollama, port conflicts)

---

## Success Criteria

**Quick/Easy pathway:**
- Completes in < 2 minutes
- User sees security benefit explained
- Final setup is operationally safe (can't break anything with defaults)
- Single decision point (accept or go to Advanced)

**Advanced pathway:**
- Completes in 5-10 minutes
- User understands each choice and tradeoffs
- CTAs are useful (not overwhelming)
- Final setup respects user preferences while staying safe

**Both pathways:**
- Docker-naive user can complete without external help
- Security story is clear ("Why Docker protects you from agent risks")
- Defaults prevent common mistakes (bare metal exposure, insecure network binding)
- Documentation is linked, not external
