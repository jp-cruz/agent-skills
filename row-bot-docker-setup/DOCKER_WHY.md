# Why Docker? Security for AI Agent Software

TL;DR: **Docker runs Row-Bot in an isolated container, so if something goes wrong, your computer is safe.**

---

## The Risk: Running Untrusted Code

You want to run Row-Bot, an AI agent platform. The problem:

- Row-Bot itself might have a security flaw
- A malicious website could attack Row-Bot
- Someone could trick Row-Bot into running bad commands
- If a model or plugin is compromised, it could try to break out

**On bare metal (direct installation):** If any of these happen, the attacker has full access to your computer as *you*. They can:

- Delete your files
- Access your passwords and API keys
- Impersonate you on websites
- Install malware
- Steal your work

**This is the core risk of agent software.** You're running code that makes decisions and takes actions. If that code is compromised, your whole system is exposed.

---

## The Solution: Docker Isolation

Docker runs Row-Bot in a **container** — a sandboxed environment that looks like a separate computer, but shares your hardware.

### What a Container Provides

**Inside the container:**
```
┌─────────────────────────────┐
│ Row-Bot Container             │
├─────────────────────────────┤
│ • Row-Bot application         │
│ • Python environment        │
│ • Row-Bot's databases         │
│ • Row-Bot's projects          │
│                             │
│ User: rowbot (UID 1000)      │
│ Home: /home/rowbot           │
│ Can write to: /home/rowbot/* │
│ Cannot write to: /Users/... │
└─────────────────────────────┘
         ↓
    Docker Engine
         ↓
    Your Computer
```

**Key security boundaries:**
1. **File system isolation** — Container can't access your home folder, documents, or downloads
2. **Network isolation** — Container is localhost-only by default (can't reach outside unless you allow it)
3. **Process isolation** — Container can't see or control other applications
4. **User isolation** — Container runs as non-root user (rowbot), not as you
5. **Volume isolation** — Container data lives in Docker volumes, separate from your system

---

## Risk Comparison: Bare Metal vs. Docker

### Scenario 1: Row-Bot Has a Security Flaw

**Bare Metal:**
```
⚠️ DANGER
Attacker → Row-Bot flaw → Full access to your computer
```

**Docker:**
```
✅ SAFE (mostly)
Attacker → Row-Bot flaw → Confined to /home/rowbot in container
           ↓
           Can't touch your files
           Can't access your apps
           Can't see your other accounts
```

### Scenario 2: Malicious Website Attacks Row-Bot

**Bare Metal:**
```
⚠️ DANGER
Website → Malicious JavaScript → Exploit in Row-Bot → Your computer compromised
```

**Docker:**
```
✅ SAFE
Website → Malicious JavaScript → Exploit in Row-Bot → Confined to container
         (if Row-Bot even allows web access)
```

### Scenario 3: Someone Tricks Row-Bot Into Running Bad Commands

**Bare Metal:**
```
⚠️ DANGER
Bad command → Executes as you → rm -rf ~/ (deletes everything)
```

**Docker:**
```
✅ SAFER
Bad command → Executes in container → rm -rf ~/ (deletes container's files, not yours)
```

### Scenario 4: API Key or Credential Theft

**Bare Metal:**
```
⚠️ DANGER
Attacker → Access ~/.ssh (your SSH keys)
        → Access ~/.config (browser auth)
        → Access your password manager
        → Access ~/.aws credentials
```

**Docker:**
```
✅ SAFE
Attacker → Container has no access to ~/.ssh, ~/.config, or ~/.aws
        → Can only steal credentials it was explicitly given (in env vars)
        → And only for Row-Bot's own operations
```

---

## Docker Layers of Security (This Setup)

Our Row-Bot setup uses **multiple safety layers:**

### Layer 1: Container Isolation
- Row-Bot runs in Docker container, separate from your system
- Even if Row-Bot is fully compromised, attacker is confined

### Layer 2: Localhost-Only (Default)
- Row-Bot is only accessible from your computer (`127.0.0.1:8080`)
- Attacker can't reach it from the network
- You can optionally enable network access, with warnings

### Layer 3: Non-Root User
- Row-Bot runs as `rowbot` user (UID 1000), not root
- Even inside container, permissions are limited

### Layer 4: Volume Isolation
- Row-Bot's data (memory.db, projects, configs) lives in Docker volumes
- Not mixed with your system files
- Easy to backup, restore, or delete without touching your computer

### Layer 5: Optional Reverse Proxy
- For network access, we recommend Nginx or Caddy proxy
- Adds authentication, HTTPS, rate limiting
- See NETWORK_SETUP.md

---

## What This Does NOT Protect Against

Docker isolation is powerful, but not perfect:

1. **Compromised Docker itself** — If Docker has a 0-day exploit, attacker could potentially escape
   - *Mitigation:* Keep Docker updated

2. **Deliberately given credentials** — If you give Row-Bot your OpenAI API key, and Row-Bot is compromised, attacker gets that key
   - *Mitigation:* Use read-only API keys with spending limits

3. **Network-level attacks** — If you enable network access, advanced attackers might exploit container networking
   - *Mitigation:* Use reverse proxy with authentication (see NETWORK_SETUP.md)

4. **Social engineering** — If someone tricks you into running a malicious Docker image
   - *Mitigation:* Only use official images or images you trust

5. **Physical security** — If someone has access to your computer, all bets are off
   - *Mitigation:* Keep your computer physically secure

---

## Why Docker Over Alternatives?

### Virtual Machine (VirtualBox, VMware)
- ✅ More isolated than Docker
- ❌ Much slower (runs entire OS)
- ❌ Uses lots of disk space
- ❌ Harder to set up

### WSL2 (Windows only)
- ✅ Good isolation
- ❌ Windows-only
- ❌ More complex
- ❌ Still shares hardware kernel

### Bare Metal with Firewall/Antivirus
- ❌ No isolation — attacker still has access to your files
- ❌ Antivirus reacts *after* damage is done
- ❌ Firewall doesn't help if attack is from inside

**Docker hits the sweet spot:** Easy to use, good isolation, lightweight, works everywhere.

---

## Practical Implications

### What You Can Do in Docker (Same as Normal)
- Use Row-Bot normally via web interface
- Access your projects
- Connect to Ollama or cloud LLMs
- Create and modify projects
- Export and back up your data

### What Row-Bot Can't Do in Docker
- Delete files on your computer
- Access your SSH keys or credentials
- Connect to systems outside the container (unless you allow it)
- Modify applications you have installed
- Impersonate you to external websites

---

## Getting Started Safely

This setup uses **secure defaults:**

✅ **Localhost-only by default** — Row-Bot only accessible from your computer
✅ **No authentication required** — You don't need extra passwords, but on localhost only
✅ **Ollama support** — Run models locally, data never leaves your computer
✅ **Non-root user** — Even inside container, running as limited user
✅ **Easy backup** — Docker volumes are easy to backup and restore

**If you need network access:**
- See NETWORK_SETUP.md for safe ways to expose Row-Bot
- We recommend reverse proxy (Nginx/Caddy) with authentication

---

## Further Reading

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [NETWORK_SETUP.md](NETWORK_SETUP.md) — Network access and reverse proxy setup
- [LOCAL_LLM_OPTIONS.md](LOCAL_LLM_OPTIONS.md) — Privacy implications of different LLM providers
- [CLAUDE.md](CLAUDE.md) — Disaster recovery and backup procedures
