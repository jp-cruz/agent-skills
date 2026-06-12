# Three-Tier Setup Workflow

**Choose your setup method based on needs and complexity.**

---

## Overview

You have three options for setting up Row-Bot Docker:

| Option | Time | Method | Best For |
|--------|------|--------|----------|
| **Quick** | 1 min | `setup.sh` | Most users, standard setup |
| **Detailed** | 2 min | `preflight-check.sh` | Custom configs, troubleshooting |
| **Intelligent** | 3-5 min | Claude Code Agent | Complex setups, detailed recommendations |

---

## Tier 1: Quick Setup (Recommended for Most Users)

### When to Use
- You want to get running immediately
- Standard single LLM backend setup
- No complex environment requirements

### Steps

```bash
cd row-bot-docker-setup

# 1. Run setup (auto-creates .env from defaults)
./setup.sh

# 2. Optional: Customize .env
vim .env

# 3. Start Row-Bot
docker-compose up -d

# 4. Access
open http://localhost:8080
```

### What setup.sh Does
✅ Detects OS (macOS/Windows/Linux)
✅ Creates .env from .env.example if missing
✅ Creates data directories
✅ Validates Docker/docker-compose
✅ Checks if Ollama is reachable
✅ Verifies port availability
✅ Provides next steps

### Example Output
```
✓ Setup complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Configuration:
  Data Directory:      ./rowbot-data
  Workspace Directory: ./rowbot-workspace
  Row-Bot Port:          8080
  Ollama URL:          http://host.docker.internal:11434

✓ Docker is installed
✓ Docker Compose is installed
✓ Ollama is running and reachable
✓ Port 8080 is available

Next steps:
  1. Review and customize .env if needed
  2. Ensure Ollama is running: ollama serve
  3. Start Row-Bot: docker-compose up -d
  4. Open http://localhost:8080
```

---

## Tier 2: Detailed Assessment

### When to Use
- You have multiple LLM backends (Ollama, LM Studio, vLLM)
- You want to see all available options
- You're troubleshooting setup issues
- You want detailed environment report

### Steps

```bash
cd row-bot-docker-setup

# 1. Run comprehensive assessment
./preflight-check.sh

# 2. Read output and copy recommended config
# (Output shows tailored .env suggestions)

# 3. Create .env with recommendations
cp .env.example .env
# Edit with recommended settings from preflight-check output

# 4. Install any missing dependencies (if needed)
pip install keyring
pip install keyrings.alt  # Windows

# 5. Start Row-Bot
docker-compose up -d
```

### What preflight-check.sh Detects

**LLM Backends:**
- ✓ Ollama (version, running status, models)
- ✓ LM Studio (installed location)
- ✓ vLLM (Python package)
- ✓ llama.cpp
- ✓ GPT4All

**Python Environment:**
- ✓ Python version
- ✓ keyring installation
- ✓ keyrings.alt (Windows)

**Secrets Management:**
- ✓ macOS Keychain
- ✓ Linux Secret Service (DBus)
- ✓ Windows Credential Manager

**Docker:**
- ✓ Docker version
- ✓ Docker Compose version

**Utilities:**
- ✓ curl, git, nano, jq

**System Info:**
- ✓ OS (macOS/Windows/Linux)
- ✓ Architecture (Intel/ARM/x86_64)
- ✓ Environment variables

### Example Output

```
╔════════════════════════════════════════════════════════════════════════╗
║         ROW-BOT DOCKER SETUP — ENVIRONMENT ASSESSMENT                   ║
╚════════════════════════════════════════════════════════════════════════╝

[1/5] DETECTING OPERATING SYSTEM
  OS: macos
  Architecture: apple-silicon
  Shell: /bin/zsh

[2/5] DETECTING AVAILABLE LLM BACKENDS
  ✓ Ollama — Running
    Version: 0.1.28
    Models available: 3
  ✗ LM Studio — Not installed
  ✗ vLLM — Not installed
  → Using: ollama

[3/5] CHECKING PYTHON ENVIRONMENT
  ✓ Python3: Python 3.11.5
  ✓ keyring — Installed (Python)
  ⊘ keyrings.alt — Not installed (only needed on Windows)

[4/5] CHECKING SECRETS MANAGEMENT
  ✓ macOS Keychain — Available

[5/5] CHECKING UTILITIES
  ✓ Docker: Docker version 24.0.0
  ✓ Docker Compose is installed
  ✓ Git: git version 2.42.0
  ✓ curl: curl 7.64.1
  ✓ nano: GNU nano, version 2.1.1
  ✓ jq: jq-1.7.1

═══════════════════════════════════════════════════════════════════════════

Suggested .env Configuration:

# ============================================
# RECOMMENDED .env (based on your system)
# ============================================

# Port for Row-Bot
ROW_BOT_PORT=8080

# LLM Backend Configuration
# Using Ollama (detected on host)
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Data Persistence Paths
ROW_BOT_DATA_DIR=/Users/<user>/rowbot-data
ROW_BOT_WORKSPACE_DIR=/Users/<user>/rowbot-workspace

# Container Restart Policy
RESTART_POLICY=unless-stopped

# Secrets Management
PYTHON_KEYRING_BACKEND=keyring.backends.macOS.Keyring
ROW_BOT_SECRETS_BACKEND=keyring

═══════════════════════════════════════════════════════════════════════════

NEXT STEPS
1. Copy recommended config above to .env
2. Ensure Ollama is running: ollama serve
3. Start Row-Bot: docker-compose up -d
4. Open http://localhost:8080
```

---

## Tier 3: Intelligent Setup (Claude Code Agent)

### When to Use
- Complex environment (multiple backends, custom paths)
- You want AI-driven recommendations
- Detailed assessment and verification
- Multi-backend switching capabilities
- Advanced troubleshooting

### Steps

```bash
cd row-bot-docker-setup

# Option A: Direct Agent Call
# Open Claude Code and ask:
# "Assess my Row-Bot environment and generate .env"
# or
# "I have Ollama and LM Studio, which should I use?"

# Option B: Manual Assessment Export
./preflight-check.sh > assessment.txt
# Paste assessment.txt output to Claude Code with your question

# Option C: Chat-based Setup
# Ask Claude Code:
# "Guide me through Row-Bot Docker setup on [Windows|Mac|Linux]"
# Agent runs checks and guides you through each step
```

### What Claude Code Agent Does

**Analysis:**
- Parses preflight-check output
- Understands your specific environment
- Compares available options
- Identifies optimal configuration

**Recommendations:**
- Which LLM backend to use (with reasoning)
- Keyring/secrets management best practices
- Performance optimization suggestions
- Troubleshooting guidance

**Generation:**
- Generates customized .env file
- Creates setup shell commands (if needed)
- Provides step-by-step next actions
- Explains each configuration choice

**Verification:**
- Confirms paths exist or can be created
- Tests configuration before saving
- Verifies all dependencies are met
- Provides rollback instructions if needed

### Example Agent Interaction

**You ask:**
```
I have Ollama, LM Studio, and vLLM installed on my Mac.
Which should I use with Row-Bot?
I also want to use macOS Keychain for secrets.
Generate my .env file.
```

**Agent responds:**

```
Based on your environment, here's my analysis:

AVAILABLE BACKENDS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Ollama ✓ (Recommended)
   • Easiest to use and maintain
   • Best community support
   • Lowest resource usage
   • Models: llama2, neural-chat, etc.

2. LM Studio (Alternative)
   • Better UI for model management
   • More memory-intensive
   • Good for testing models

3. vLLM (Advanced)
   • Best performance with VRAM
   • Requires more setup
   • Not recommended unless you have GPU

RECOMMENDATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Use Ollama as primary, with LM Studio as fallback:

# Primary
OLLAMA_BASE_URL=http://host.docker.internal:11434

# If Ollama fails, manually switch to:
# OLLAMA_BASE_URL=http://host.docker.internal:1234/v1  # LM Studio

SECRETS MANAGEMENT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your system supports macOS Keychain perfectly.
This is the best option for secure credential storage.

PYTHON_KEYRING_BACKEND=keyring.backends.macOS.Keyring
ROW_BOT_SECRETS_BACKEND=keyring

GENERATED .env:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Full .env file with all optimal settings]

NEXT STEPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Save above .env file
2. Start Ollama: ollama serve
3. Run: docker-compose up -d
4. Access: http://localhost:8080
5. If Ollama unavailable, switch to LM Studio:
   - Modify OLLAMA_BASE_URL in .env
   - Run: docker-compose restart
```

---

## Setup Decision Tree

```
START: Do I have time for detailed setup?

├─ NO, need to start now
│  └─ Use Tier 1: setup.sh (1 minute)
│     → Fast, sensible defaults
│     → Works for 95% of users
│
├─ YES, I want to see all options
│  └─ Use Tier 2: preflight-check.sh (2 minutes)
│     → See all available backends
│     → Manually select best option
│     → Understand your environment
│
└─ YES, and I want AI recommendations
   └─ Use Tier 3: Claude Code Agent (3-5 minutes)
      → Intelligent analysis
      → Detailed recommendations
      → Custom configuration
      → Expert guidance
```

---

## Comparison Matrix

| Feature | setup.sh | preflight-check.sh | Claude Code Agent |
|---------|----------|------------------|-------------------|
| **Speed** | 1 min | 2 min | 3-5 min |
| **Effort** | Minimal | Low | Minimal (AI does work) |
| **LLM Detection** | Basic | Advanced | Intelligent |
| **Keyring Support** | Yes | Yes | Yes |
| **Secrets Mgmt** | Auto | Detected | Recommended |
| **Multi-backend** | No | Display | Switch between |
| **Recommendations** | Basic | Detailed | Expert |
| **Troubleshooting** | Limited | Good | Excellent |
| **Path Customization** | Yes | Yes | Yes |

---

## When Each Fails and How to Fix

### Tier 1 (setup.sh) Fails

**Symptom:** "Ollama not reachable"

**Fix:**
```bash
# Start Ollama manually
ollama serve

# Re-run setup.sh in another terminal
./setup.sh
```

**If still fails:** Use Tier 2 or 3 for detailed diagnosis

### Tier 2 (preflight-check.sh) Incomplete

**Symptom:** "keyrings.alt not found (Windows)"

**Fix:**
```bash
pip install keyrings.alt

# Re-run preflight check
./preflight-check.sh
```

**If still fails:** Use Tier 3 for Claude to diagnose

### Tier 3 (Claude Code Agent) Issues

**Symptom:** "Agent can't find preflight-check output"

**Fix:**
```bash
# Manually run and capture
./preflight-check.sh > /tmp/assessment.txt

# Paste assessment.txt to Claude Code
# Ask: "Generate .env based on this assessment"
```

---

## Combining Methods

You can use methods together:

**Example workflow:**
```
1. Run Tier 2 (preflight-check.sh)
   → See what's available

2. Ask Claude Code (Tier 3)
   → "Based on this preflight check, what's optimal?"
   → Get detailed recommendations

3. Use Tier 1 (setup.sh)
   → Run final setup once you decide
```

---

## Installing Missing Dependencies

### Python Dependencies (All Tiers)

```bash
# Install keyring (all platforms)
pip install keyring

# Install keyrings.alt (Windows only)
pip install keyrings.alt

# Verify installation
python -c "import keyring; import keyrings.alt; print('OK')"
```

### System Dependencies

**macOS:**
```bash
# Keychain is built-in, nothing needed
# Verify it works:
security show-keychain-info -l
```

**Linux:**
```bash
# Secret Service (GNOME/KDE)
sudo apt install libsecret-1-dev gnome-keyring

# Or use Pass (password manager)
sudo apt install pass
```

**Windows:**
```bash
# Credential Manager is built-in
# keyrings.alt provides Python integration
pip install keyrings.alt

# Verify
python -c "import keyrings.alt; print('OK')"
```

---

## Troubleshooting Path Issues

### macOS
```bash
# Default paths work
ROW_BOT_DATA_DIR=/Users/$(whoami)/rowbot-data

# Or custom
ROW_BOT_DATA_DIR=/Volumes/ExternalDrive/rowbot-data

# Verify path exists
ls -la $ROW_BOT_DATA_DIR
```

### Linux
```bash
# Default paths work
ROW_BOT_DATA_DIR=/home/$(whoami)/rowbot-data

# Or NFS mount
ROW_BOT_DATA_DIR=/mnt/data/rowbot

# Verify path
mkdir -p $ROW_BOT_DATA_DIR
chmod 755 $ROW_BOT_DATA_DIR
```

### Windows (WSL2)
```bash
# Windows paths
ROW_BOT_DATA_DIR=C:\Users\%USERNAME%\rowbot-data

# Or WSL path
ROW_BOT_DATA_DIR=/home/username/rowbot-data

# Verify mount
ls /mnt/c/Users/
```

---

## Summary

**Choose your setup method:**

🟢 **Quick** (`setup.sh`) — 1 minute, sensible defaults
🟡 **Detailed** (`preflight-check.sh`) — 2 minutes, see all options
🔵 **Intelligent** (Claude Code) — 3-5 minutes, expert guidance

All three methods will get you running. Pick based on your comfort level and needs.
