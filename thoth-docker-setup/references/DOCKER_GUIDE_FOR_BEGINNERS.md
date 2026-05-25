# Docker Guide for Beginners

**Learn what Docker is, why it's essential for Thoth, and how to install it.**

---

## What is Docker? (Non-Technical Explanation)

### The Problem It Solves

Imagine you're giving someone instructions to bake a cake:

❌ **Without Docker:**
```
"Install flour, eggs, sugar, butter, baking powder, vanilla, and salt.
Make sure you have the right versions! 
Python 3.11, but not 3.12.
Ollama, but you need to compile it from source.
This works on MY Mac, but good luck on Windows..."
```

Result: Hours of troubleshooting, "works on my machine" problems, dependency conflicts.

✅ **With Docker:**
```
"Run this one command: docker-compose up -d
Everything is already set up inside the container.
Works exactly the same on Mac, Windows, and Linux."
```

Result: Works immediately, no troubleshooting.

### What Docker Actually Is

Think of Docker as a **lightweight virtual computer** that runs inside your real computer:

```
Your Mac/Windows/Linux
    ↓
Docker Engine (the interpreter)
    ↓
Container (lightweight virtual environment)
    ├─ Python 3.11
    ├─ Thoth application
    ├─ nano, jq, vim editors
    ├─ All dependencies
    └─ Pre-configured and ready to go
    ↓
Result: Thoth runs perfectly every time
```

**Key difference from Virtual Machines:**
- Virtual Machines: Entire operating system (10GB+, slow)
- Docker Containers: Just the application + minimal dependencies (300MB, fast)

---

## Why Docker is Essential for Thoth

### Problem 1: Dependency Hell

Thoth needs:
- Python 3.11 (not 3.10, not 3.12)
- Specific pip packages (keyring, keyrings.alt, etc.)
- System utilities (nano, jq, curl, ffmpeg, gcc)
- LLM provider support (Ollama, OpenAI, Anthropic, etc.)

**Without Docker:** "I have Python 3.12, can I use that?"
→ Maybe, maybe not. Broken things happen.

**With Docker:** Uses exactly Python 3.11, always.
→ Guaranteed to work.

### Problem 2: System Pollution

Thoth needs to modify your environment:
- Store config files
- Create data directories
- Install Python packages globally
- Set up secrets management

**Without Docker:** These changes persist on your machine forever.
→ If something breaks, hard to clean up.

**With Docker:** All changes are inside the container.
→ `docker-compose down` removes everything instantly.

### Problem 3: Multi-Provider Setup

You might want to run:
- Thoth with Ollama (local)
- Thoth with OpenAI (cloud)
- Thoth with Groq (cloud)
- All at the same time

**Without Docker:** Install each separately, manage versions, potential conflicts.

**With Docker:** Spin up multiple containers, each completely isolated.

### Problem 4: Portability

You want to use Thoth on:
- Your Mac
- Your Windows laptop
- Your Linux server
- A cloud VM

**Without Docker:** "Works on Mac but not Windows" is common.
→ Debug for hours.

**With Docker:** Same Docker image works everywhere.
→ Identical behavior on all platforms.

---

## Why Docker is Perfect for AI Agents

### Security & Isolation
- **Agent can't break your system** — If Thoth goes rogue, just delete the container
- **Limited filesystem access** — Agent only sees what you allow
- **No system-wide changes** — Agent can't modify your OS

### Reproducibility
- **Same setup for everyone** — No "works on my machine" problems
- **Version control** — Can run different versions of Thoth side-by-side
- **Easy testing** — Spin up, test, destroy in seconds

### Dependency Management
- **Everything bundled** — No "install this obscure package" steps
- **No conflicts** — Agent dependencies don't interfere with your system
- **Clean upgrades** — Delete old container, run new one

### Portability
- **Works anywhere** — Same container on Mac, Windows, Linux, cloud
- **Share with others** — Send someone your config, they run identical setup
- **Cloud deployment** — Deploy to AWS/Azure/Google Cloud without changes

---

## Docker Installation

### macOS

#### Option A: Docker Desktop (Recommended for Beginners)

**Download:**
1. Go to https://www.docker.com/products/docker-desktop
2. Click "Download for Mac"
3. Choose your architecture:
   - **Apple Silicon (M1/M2/M3)** → Download "Apple Silicon"
   - **Intel Mac** → Download "Intel Chip"
   
   Not sure which? Click Apple menu → About This Mac:
   ```
   If it says "Apple M1" or "M2" or "M3" → Apple Silicon
   If it says "Intel Core i7" or similar → Intel
   ```

**Install:**
1. Open the downloaded `.dmg` file
2. Drag "Docker.app" to Applications folder
3. Wait for copy to complete
4. Close the window

**Start Docker:**
1. Open Applications folder
2. Double-click "Docker.app"
3. Enter your password when prompted
4. Wait for "Docker is running" notification (2-3 minutes)

**Verify Installation:**
```bash
docker --version
# Should show: Docker version 24.0.0 (or higher)

docker run hello-world
# Should show: "Hello from Docker!"
```

#### Option B: Homebrew (For Advanced Users)

```bash
# Install Docker via Homebrew
brew install docker docker-compose

# Start Docker daemon
brew services start docker

# Verify
docker --version
```

#### Option C: OrbStack (Modern Alternative)

OrbStack is newer, faster, uses less resources than Docker Desktop.

```bash
brew install orbstack

# Verify
docker --version
```

---

### Windows

#### Option A: Docker Desktop with WSL 2 (Recommended)

**Prerequisites:**
- Windows 10 (version 2004 or later) or Windows 11
- WSL 2 (Windows Subsystem for Linux 2)

**Step 1: Enable WSL 2**

Open PowerShell as Administrator:
```powershell
# Enable WSL 2
wsl --install

# Restart computer when prompted
```

**Step 2: Install Docker Desktop**

1. Download: https://www.docker.com/products/docker-desktop
2. Run the installer
3. Follow wizard, ensure "Install required Windows components" is checked
4. Restart computer
5. Docker will auto-start

**Step 3: Verify**

Open PowerShell:
```powershell
docker --version
# Should show: Docker version 24.0.0 (or higher)

docker run hello-world
# Should show: "Hello from Docker!"
```

#### Option B: Docker with Git Bash

If you don't want to enable WSL 2:

```bash
# Install with Chocolatey
choco install docker-desktop

# Or install manually from https://www.docker.com/products/docker-desktop
```

Note: May have performance issues without WSL 2, but works.

---

### Linux

#### Ubuntu/Debian

```bash
# Update package manager
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Start Docker
sudo systemctl start docker

# Add current user to docker group (so you don't need sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
# Or run:
newgrp docker

# Verify
docker --version
```

#### CentOS/RHEL

```bash
# Install Docker
sudo dnf install -y docker

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker  # Auto-start on boot

# Add current user to docker group
sudo usermod -aG docker $USER

# Log out and back in

# Verify
docker --version
```

#### Fedora

```bash
# Install Docker
sudo dnf install -y docker

# Start and enable
sudo systemctl start docker
sudo systemctl enable docker

# Add to docker group
sudo usermod -aG docker $USER

# Log out and back in

# Verify
docker --version
```

---

## Verify Docker Installation

Run this on any platform:

```bash
# 1. Check Docker version
docker --version

# 2. Check Docker Compose version
docker-compose --version

# 3. Test with hello-world image
docker run hello-world

# You should see:
# "Hello from Docker!
#  This message shows that your installation appears to be working correctly."
```

If all three work, you're ready! ✅

---

## Common Installation Issues

### Issue 1: "docker: command not found"

**Cause:** Docker is not in your PATH

**Fix:**
- **macOS:** Docker Desktop not running → Open Docker.app
- **Windows:** Restart computer → Docker should auto-start
- **Linux:** Run `sudo systemctl start docker`

### Issue 2: "Permission denied" (Linux)

**Cause:** Your user isn't in the docker group

**Fix:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Then restart your terminal.

### Issue 3: "Cannot connect to Docker daemon"

**Cause:** Docker service isn't running

**Fix:**
- **macOS:** Open Docker.app and wait for it to fully start (2-3 minutes)
- **Windows:** Restart Docker Desktop from system tray
- **Linux:** `sudo systemctl start docker`

### Issue 4: Low disk space warning

**Cause:** Docker images/containers taking up space

**Fix:**
```bash
# Clean up unused images and containers
docker system prune

# Or more aggressive
docker system prune -a
```

### Issue 5: WSL 2 requires update (Windows)

**Message:** "WSL 2 installation is incomplete"

**Fix:**
```powershell
# Update WSL 2
wsl --update

# Restart Docker Desktop
```

---

## What Gets Installed

When you install Docker:

**Docker Engine** (~100 MB)
- The core Docker system
- Runs containers
- On macOS/Windows: runs in lightweight Linux VM

**Docker Compose** (~20 MB)
- Tool to run multiple containers
- Used for Thoth (defines: network, ports, volumes, environment)

**Docker CLI** (~50 MB)
- Command-line interface
- Used for: `docker run`, `docker build`, etc.

**Total:** ~200 MB, plus space for container images (~300 MB for Thoth)

---

## After Installation: First Steps

### 1. Verify Everything Works

```bash
# Test Docker
docker run hello-world

# Test Docker Compose
docker-compose --version

# Test image download (might take 1-2 minutes)
docker run hello-world
```

### 2. Configure Docker Resources (Optional)

Docker Desktop can use a lot of RAM by default.

**macOS/Windows Docker Desktop:**
1. Open Docker Desktop settings
2. Go to "Resources"
3. Set:
   - CPU: 4-8 cores (leave some for your computer)
   - Memory: 4-8 GB (leave some for your computer)
4. Click "Apply & Restart"

**Linux:**
No configuration needed, Docker uses what's available.

### 3. Test with Thoth

```bash
cd /path/to/thoth-docker-setup

# Run preflight check
./preflight-check.sh

# Quick setup
./setup.sh

# Build Thoth image
docker-compose build

# Start Thoth
docker-compose up -d

# Verify it's running
docker-compose ps
```

---

## Docker Commands You'll Use

### Basic Commands

```bash
# Start Thoth
docker-compose up -d

# Stop Thoth
docker-compose stop

# See what's running
docker-compose ps

# View logs
docker-compose logs -f

# Open shell in Thoth container
docker-compose exec thoth bash

# Stop and remove everything
docker-compose down
```

### Cleanup Commands

```bash
# Remove unused images
docker image prune

# Remove unused containers
docker container prune

# Remove unused volumes
docker volume prune

# Clean everything
docker system prune -a

# See disk usage
docker system df
```

---

## Alternative: Without Docker (Not Recommended)

If you absolutely cannot use Docker, you can install Thoth locally, but:

❌ **Disadvantages:**
- Requires Python 3.11 exactly (not 3.10, not 3.12)
- Manual dependency installation
- Python package conflicts likely
- Multiple LLM backends hard to manage
- Different behavior on each platform
- Hard to uninstall cleanly
- Updates might break things

✅ **If you insist:**

```bash
# Clone Thoth
git clone https://github.com/siddsachar/Thoth.git
cd Thoth

# Install Python 3.11
# (platform-specific, not detailed here)

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt
pip install keyring keyrings.alt

# Run Thoth
python launcher.py --server --port 8080

# Access at http://localhost:8080
```

**But:** This approach has many gotchas. Docker is strongly recommended.

---

## Why This Setup Uses Docker

The Thoth Docker setup includes:
- **Python 3.11** (exact version, guaranteed)
- **All dependencies** (pip packages, system utilities)
- **Development tools** (nano, jq, vim for debugging)
- **LLM provider support** (Ollama, OpenAI, etc.)
- **Persistent volumes** (your data survives container restarts)
- **Automated setup** (one command: `docker-compose up -d`)

**Result:** 5-minute setup vs 30-60 minute manual installation.

---

## Still Have Questions?

### Debugging Docker Issues

```bash
# See what's wrong
docker-compose logs

# See detailed logs
docker-compose logs --follow thoth

# Check if container is healthy
docker ps

# Inspect container
docker inspect thoth-app

# Test connectivity
docker-compose exec thoth curl http://localhost:8080
```

### Common Questions

**Q: Does Docker slow things down?**
A: Negligible. Docker has <5% performance overhead on modern systems.

**Q: Can I run multiple instances of Thoth?**
A: Yes! Change THOTH_PORT in .env and run another docker-compose.

**Q: What if Docker updates break things?**
A: Your container uses a specific base image (Python 3.11-slim), so updates don't affect you.

**Q: Can I edit files in the container?**
A: Yes! Use `docker-compose exec thoth nano /path/to/file` or edit host-mounted volumes directly.

**Q: Does Docker work offline?**
A: Yes! Once the image is built, you don't need internet (except for cloud API providers).

**Q: Can I inspect what's inside the container?**
A: Yes! `docker-compose exec thoth bash` opens a shell.

---

## Summary

**Docker is essential for Thoth because it:**
1. ✅ Guarantees identical setup on all machines
2. ✅ Eliminates "works on my machine" problems
3. ✅ Provides isolation and security
4. ✅ Makes cleanup trivial
5. ✅ Enables multi-provider/multi-instance setups
6. ✅ Simplifies updates and version management

**Installation is quick:**
- **macOS:** Download Docker Desktop (~5 min)
- **Windows:** Enable WSL 2 + Docker Desktop (~10 min)
- **Linux:** `apt-get install docker.io` (~3 min)

**Verification is simple:**
```bash
docker run hello-world
```

**You're ready to use Thoth when:**
```bash
docker-compose up -d
# Access at http://localhost:8080
```

**Next:** Follow the [SETUP_WORKFLOW.md](SETUP_WORKFLOW.md) for intelligent Thoth configuration.

---

## Learn More

**Official Resources:**
- Docker Documentation: https://docs.docker.com
- Docker Tutorial: https://docs.docker.com/get-started
- Docker Compose: https://docs.docker.com/compose

**Quick References:**
- Docker Cheat Sheet: https://github.com/wsargent/docker-cheat-sheet
- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices

**YouTube:**
- "What is Docker?" (Fireship, 10 min): https://youtu.be/Gjdww0mJEzA
- Docker for Beginners: https://youtu.be/fqMOX6JJhGo
