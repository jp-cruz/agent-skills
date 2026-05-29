# Docker Installation Guide for Non-Technical Users

Docker is a tool that safely isolates Thoth from the rest of your computer. You need to install it before running Thoth.

**Good news:** Installation is straightforward. Pick your operating system below.

---

## macOS (Recommended: Docker Desktop)

### Option A: Docker Desktop (Easiest)

**What it is:** Official containerization platform from Docker, Inc. Most people use this.

**Installation:**

1. Download from https://www.docker.com/products/docker-desktop
2. Choose the correct version for your Mac:
   - **Apple Silicon (M1/M2/M3/M4):** Download "Apple Silicon" version
   - **Intel Mac:** Download "Intel Chip" version
   > Not sure? Apple menu → About This Mac → Processor. If you see "Apple" (M1, M2, etc.), use Apple Silicon. If you see "Intel," use Intel version.
3. Open the `.dmg` file and drag Docker into Applications folder
4. Open Applications folder, double-click "Docker.app"
5. Allow permissions when prompted
6. Wait for Docker icon in menu bar (top-right) to say "Docker Desktop is running"

**Verify it worked:**
```bash
docker --version
# You should see: Docker version XX.X.X
```

---

### Option B: Rancher Desktop (Lighter Weight Alternative)

**What it is:** Free alternative to Docker Desktop. Uses less memory. Works just as well.

**Installation:**

1. Download from https://rancherdesktop.io
2. Choose "macOS" version
3. Open the `.dmg` file and drag Rancher Desktop into Applications
4. Open Applications folder, double-click "Rancher Desktop.app"
5. Allow permissions when prompted
6. Wait for startup (first time takes 2-3 minutes)

**Verify it worked:**
```bash
docker --version
# You should see: Docker version XX.X.X
```

---

## Windows 11 (Recommended: Docker Desktop)

> **You need WSL 2** (Windows Subsystem for Linux 2). Docker Desktop installs it automatically, but some older Windows setups may need an extra step.

### Option A: Docker Desktop (Recommended)

**Installation:**

1. Download from https://www.docker.com/products/docker-desktop
2. Click "Docker Desktop Installer.exe"
3. **Important:** When asked "Use WSL 2 instead of Hyper-V", select **YES**
   - This is required for Docker to work smoothly on Windows
4. Follow the installer prompts
5. Restart your computer (required)
6. Docker Desktop should launch automatically after restart
7. Allow permissions when prompted

**Verify it worked:**
Open PowerShell and run:
```powershell
docker --version
# You should see: Docker version XX.X.X
```

**Troubleshooting:** If you get "Docker daemon is not running," open the Docker Desktop application from Start menu.

---

### Option B: Rancher Desktop (Alternative)

1. Download from https://rancherdesktop.io
2. Choose "Windows" version (`.exe` file)
3. Run the installer
4. Follow prompts (WSL 2 setup is automatic)
5. Restart your computer
6. Launch Rancher Desktop from Start menu

**Verify it worked:**
```powershell
docker --version
```

---

## Linux (Ubuntu, Debian, Fedora, etc.)

### Official Installation (Recommended)

**For Ubuntu/Debian:**

```bash
# Update package manager
sudo apt update

# Install Docker
sudo apt install docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker  # Auto-start on boot

# Allow your user to run docker (no sudo needed)
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
```

**For Fedora/RHEL:**

```bash
sudo dnf install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

docker --version
```

### Alternative: Rancher Desktop (Lighter)

**Installation:**

1. Download from https://rancherdesktop.io
2. Choose your Linux distribution (AppImage or package format)
3. Follow installation prompts

**Verify:**
```bash
docker --version
```

---

## How to Know It Worked

**Quick test — run this command in your terminal:**

```bash
docker run hello-world
```

**Expected output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly...
```

If you see that message, Docker is installed and ready. You can now return to `./setup.sh` and continue.

---

## Troubleshooting

### "Docker: command not found"

**macOS:**
- Docker Desktop not running? Open Applications → Docker.app
- Or, Docker not in PATH? Try full path: `/Applications/Docker.app/Contents/Resources/bin/docker --version`

**Windows:**
- Docker Desktop not running? Search "Docker Desktop" in Start menu and click it
- PowerShell restart required? Close and reopen PowerShell

**Linux:**
- Did you run `newgrp docker`? Try this:
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker
  docker --version
  ```

### "Cannot connect to Docker daemon"

**macOS/Windows:**
- Docker Desktop/Rancher Desktop is not running
- Start it from Applications (macOS) or Start menu (Windows)
- Wait 30 seconds for it to fully start

**Linux:**
- Docker service not running:
  ```bash
  sudo systemctl start docker
  sudo systemctl enable docker
  ```

### "Permission denied while trying to connect to Docker daemon"

**Linux only:**
- You didn't add your user to the docker group
- Run this:
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker
  ```

### Memory/Performance Issues

If Docker feels slow or uses too much memory:

**macOS/Windows:**
- Docker Desktop/Rancher Desktop settings
- Increase CPU and memory allocation in Settings
- Recommended: 4+ CPU cores, 4+ GB RAM

**Linux:**
- Docker uses available system resources (no configuration needed)

---

## Next Steps

Once Docker is installed and verified:

1. Return to the setup directory
2. Run `./setup.sh` again
3. Follow the Quick or Advanced setup path

---

## Questions?

- Docker basics: https://docs.docker.com/get-started/
- Rancher Desktop docs: https://docs.rancherdesktop.io/
- Troubleshooting: https://docs.docker.com/desktop/troubleshoot/
