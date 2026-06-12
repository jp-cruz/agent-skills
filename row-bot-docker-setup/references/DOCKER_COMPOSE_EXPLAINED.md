# docker-compose.yml — Line-by-Line Explanation

This document explains every part of the `docker-compose.yml` file and why it's there.

> **Note:** The snippets and line numbers below may lag behind the current
> `docker-compose.yml` (e.g., older revisions used configurable bind-mount
> `device:` paths; current releases use plain named volumes, mount the
> workspace at `/home/rowbot/Documents/Row-Bot`, and add `stop_signal: SIGINT`).
> The concepts explained here still apply — treat the real
> `docker-compose.yml` as the source of truth.

---

## Complete File with Line Numbers

```yaml
 1  services:
 2    rowbot:
 3      build:
 4        context: .
 5        dockerfile: Dockerfile
 6      container_name: rowbot-app
 7      ports:
 8        - "${ROW_BOT_PORT:-8080}:8080"
 9      environment:
10        OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-http://host.docker.internal:11434}
11      volumes:
12        - rowbot-data:/home/rowbot/.row-bot
13        - rowbot-workspace:/home/rowbot/Documents/Row-Bot
14      restart: ${RESTART_POLICY:-unless-stopped}
15      # On Linux, uncomment the line below and comment out the one above to use host network
16      # networks:
17      #   - host
18
19  volumes:
20    rowbot-data:
21      driver: local
22      driver_opts:
23        type: none
24        o: bind
25        device: ${ROW_BOT_DATA_DIR:-./rowbot-data}
26    rowbot-workspace:
27      driver: local
28      driver_opts:
29        type: none
30        o: bind
31        device: ${ROW_BOT_WORKSPACE_DIR:-./rowbot-workspace}
```

---

## Section-by-Section Explanation

### Top Level: `services:` (Line 1)

```yaml
services:
```

**What:** Declares the start of service definitions.

**Why:** Docker Compose can orchestrate multiple services (database, cache, web server, etc.). Here we have just one service: `rowbot`.

---

### Service Definition: `rowbot:` (Line 2)

```yaml
  rowbot:
```

**What:** Names this service `rowbot`.

**Why:** 
- Used in commands: `docker-compose exec rowbot bash`
- Shows up in `docker-compose ps` as the service name
- Referenced in volume mounts and networking
- Allows multiple services to reference each other

---

### Build Configuration (Lines 3-5)

```yaml
    build:
      context: .
      dockerfile: Dockerfile
```

**What:** Tells Docker how to build the image for this service.

**Why:** 
- `context: .` — Build context is the current directory (where docker-compose.yml is)
  - Docker sends all files in this directory to the Docker daemon
  - Respects .dockerignore to avoid unnecessary files
  - Keeps build faster and cleaner

- `dockerfile: Dockerfile` — Use the `Dockerfile` file (in the same directory)
  - Could be named differently (e.g., `Dockerfile.prod`)
  - But in this case, it's the standard `Dockerfile`

**Example commands:**
```bash
docker-compose build              # Uses this configuration
docker-compose build --no-cache   # Rebuild without using cached layers
```

---

### Container Name (Line 6)

```yaml
    container_name: rowbot-app
```

**What:** Names the running container `rowbot-app`.

**Why:**
- Makes it easier to reference: `docker exec rowbot-app bash`
- Shows up clearly in `docker ps`
- Easier to remember than a random container ID
- Must be unique (only one container with this name at a time)

**Example:**
```bash
$ docker ps
CONTAINER ID   IMAGE            NAMES
abc123def456   python:3.11-slim rowbot-app    ← This is the container name
```

---

### Port Mapping (Lines 7-8)

```yaml
    ports:
      - "${ROW_BOT_PORT:-8080}:8080"
```

**What:** Maps a port from the container to the host machine.

**Syntax:** `HOST_PORT:CONTAINER_PORT`
- Left side (before colon) — Port on your machine
- Right side (after colon) — Port inside the container

**Why:** 
- The Row-Bot application listens on port 8080 inside the container
- To access it from your browser, it needs to be mapped to a port on your machine
- The container doesn't know about your host's network directly

**The `${ROW_BOT_PORT:-8080}` Syntax:**
- `${VAR_NAME}` — Use environment variable `ROW_BOT_PORT`
- `:-8080` — If `ROW_BOT_PORT` is not set, default to `8080`

**Examples:**

If `.env` has `ROW_BOT_PORT=8080`:
```yaml
- "8080:8080"    # Access at http://localhost:8080
```

If `.env` has `ROW_BOT_PORT=9000`:
```yaml
- "9000:8080"    # Access at http://localhost:9000
```

If `.env` is missing `ROW_BOT_PORT`:
```yaml
- "8080:8080"    # Defaults to 8080
```

**Real-world use:**
```bash
# User 1 (default)
ROW_BOT_PORT=8080
docker-compose up -d
# Access at http://localhost:8080

# User 2 (different machine, port taken)
ROW_BOT_PORT=9000
docker-compose up -d
# Access at http://localhost:9000 (same docker-compose.yml!)
```

---

### Environment Variables (Lines 9-10)

```yaml
    environment:
      OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-http://host.docker.internal:11434}
```

**What:** Sets environment variables inside the running container.

**Why:** The Row-Bot application needs to know where Ollama is located. This is passed as an environment variable.

**How it works:**
1. Read from `.env` file (or command line)
2. If set, use that value
3. If not set, use the default
4. Pass into container as `OLLAMA_BASE_URL` environment variable
5. Row-Bot application reads this environment variable to connect to Ollama

**Examples:**

**macOS/Windows (Docker Desktop):**
```bash
# .env
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Inside container
$ echo $OLLAMA_BASE_URL
http://host.docker.internal:11434

# Row-Bot uses this to connect
curl http://host.docker.internal:11434/api/tags
```

**Linux (with Ollama on host):**
```bash
# .env
OLLAMA_BASE_URL=http://<local-ip>:11434

# Inside container
$ echo $OLLAMA_BASE_URL
http://<local-ip>:11434
```

**Default fallback:**
```bash
# If .env doesn't have OLLAMA_BASE_URL:
# Uses: http://host.docker.internal:11434

# Inside container (without .env setting)
$ echo $OLLAMA_BASE_URL
http://host.docker.internal:11434
```

---

### Volumes (Lines 11-13)

```yaml
    volumes:
      - rowbot-data:/home/rowbot/.row-bot
      - rowbot-workspace:/home/rowbot/Documents/Row-Bot
```

**What:** Mounts storage volumes so data persists across container restarts.

**Syntax:** `VOLUME_NAME:CONTAINER_PATH`
- Left side — Named volume (defined later)
- Right side — Where it's mounted inside the container

**Why:** Without volumes:
- ❌ When container stops, all data is deleted
- ❌ Container can't access host files
- ❌ Can't easily back up or edit data

With volumes:
- ✅ Data persists forever (even if you delete the container)
- ✅ Can access files from host machine
- ✅ Multiple containers can share data
- ✅ Easy to backup by copying the folder

**What These Two Volumes Do:**

**1. `rowbot-data:/home/rowbot/.row-bot`**
- **Purpose:** Application state, configuration, cache
- **Inside container:** `/home/rowbot/.row-bot`
- **On your host:** `${ROW_BOT_DATA_DIR}` (default: `./rowbot-data`)
- **Example:**
  ```bash
  # On your machine
  ls ./rowbot-data/
  → contains: config.yaml, logs, cache, etc.
  
  # Inside container
  ls /home/rowbot/.row-bot/
  → same files!
  ```

**2. `rowbot-workspace:/home/rowbot/Documents/Row-Bot`**
- **Purpose:** User workspace, projects, files
- **Inside container:** `/home/rowbot/Documents/Row-Bot`
- **On your host:** `${ROW_BOT_WORKSPACE_DIR}` (default: `./rowbot-workspace`)
- **Example:**
  ```bash
  # Edit a file on your host machine
  echo "test content" > ./rowbot-workspace/myfile.txt
  
  # It's immediately visible in the container
  docker-compose exec rowbot cat /home/rowbot/Documents/Row-Bot/myfile.txt
  → test content
  ```

---

### Restart Policy (Line 14)

```yaml
    restart: ${RESTART_POLICY:-unless-stopped}
```

**What:** Tells Docker when to automatically restart the container.

**The `${RESTART_POLICY:-unless-stopped}` Syntax:**
- If `.env` has `RESTART_POLICY=value` → use that
- Otherwise → use `unless-stopped` (default)

**What `unless-stopped` means:**
- ✅ Restart if container crashes
- ✅ Restart if the host machine reboots
- ❌ Don't restart if you explicitly stopped it

**Restart Policy Options:**

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `no` | Never restart | Development (manual control) |
| `always` | Always restart, even if you stopped it | Critical services |
| `unless-stopped` | Restart unless explicitly stopped | ✅ **Default for Row-Bot** |
| `on-failure` | Restart only if it crashed with error | Testing specific failures |
| `on-failure:3` | Restart up to 3 times on failure | Limit restart attempts |

**Examples:**

```bash
# Container crashes
docker-compose up -d
# ... something goes wrong ...
CONTAINER CRASHED

# Docker automatically restarts it (unless-stopped)
docker-compose logs rowbot
# → shows crash, then clean restart

# You explicitly stop it
docker-compose stop
# Container stays stopped (unless-stopped respected)

# You start it again
docker-compose up -d
# Container is running again
```

**Why `unless-stopped` for Row-Bot:**
- If Row-Bot crashes, we want it to auto-restart
- If you stop it intentionally (`docker-compose stop`), stay stopped
- Perfect for production deployments that should be resilient

---

### Network Configuration (Lines 15-17) — Optional

```yaml
      # On Linux, uncomment the line below and comment out the one above to use host network
      # networks:
      #   - host
```

**What:** Currently commented out. Could enable host network mode on Linux.

**Why this exists:**
- Docker networking works differently on different platforms
- **macOS/Windows:** Use `host.docker.internal` to access host services
- **Linux:** Direct host network access with `--network=host`

**Default (commented out):**
```yaml
# Linux users would set this to:
networks:
  - host
```

**Effect:**
- Container uses host's network interface directly
- Can access `localhost:11434` instead of `192.168.x.x:11434`
- Better performance on Linux
- **Not needed** on macOS/Windows (use `host.docker.internal` instead)

**If you uncomment on macOS/Windows:**
- ❌ Breaks `host.docker.internal` references
- ❌ Container can't reach Ollama
- ❌ Not the right configuration for those platforms

**Current design:** Uses bridge network (default) which works on all platforms with `host.docker.internal` fallback for Linux users who set IP in `.env`.

---

## Volume Definitions (Lines 19-31)

```yaml
volumes:
  rowbot-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${ROW_BOT_DATA_DIR:-./rowbot-data}
  rowbot-workspace:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${ROW_BOT_WORKSPACE_DIR:-./rowbot-workspace}
```

**What:** Defines the two named volumes referenced earlier.

**Why:** Named volumes must be defined at the end of the compose file.

### Volume `rowbot-data` (Lines 20-25)

```yaml
  rowbot-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${ROW_BOT_DATA_DIR:-./rowbot-data}
```

**Breaking it down:**

- **`driver: local`** — Use local filesystem (not cloud storage, not NFS)

- **`type: none`** — Don't auto-create; use exact path specified

- **`o: bind`** — Bind mount (direct filesystem binding)
  - vs. `type: tmpfs` (in-memory)
  - vs. `type: nfs` (network filesystem)

- **`device: ${ROW_BOT_DATA_DIR:-./rowbot-data}`** — Physical location on host
  - If `.env` has `ROW_BOT_DATA_DIR=/Users/<user>/rowbot-data` → use that
  - Otherwise → use `./rowbot-data` (relative to docker-compose.yml)

**What happens:**

```bash
# On your host machine
./rowbot-data/
  ├── config.yaml
  ├── logs/
  ├── cache/
  └── models/

# Inside container
/home/rowbot/.row-bot/
  ├── config.yaml    ← same files!
  ├── logs/
  ├── cache/
  └── models/
```

**Why bind mounts (not Docker volumes):**
- ✅ Files are directly on your host filesystem
- ✅ Can edit with any editor (nano, vim, VS Code)
- ✅ Easy to backup (just copy the folder)
- ✅ Works across platforms (with path customization)
- ❌ Requires explicit path configuration
- ❌ Permissions need manual management

**Alternatives:**

**Option 1: Docker-managed volume (not used here)**
```yaml
volumes:
  rowbot-data:
    driver: local
    # Docker manages the location automatically
    # You don't know where files actually are
```

**Option 2: tmpfs (not used here)**
```yaml
driver_opts:
  type: tmpfs
# Data disappears when container stops
```

### Volume `rowbot-workspace` (Lines 26-31)

```yaml
  rowbot-workspace:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${ROW_BOT_WORKSPACE_DIR:-./rowbot-workspace}
```

**Identical to rowbot-data, just different path.**

Maps:
- `./rowbot-workspace` (default) → `/home/rowbot/Documents/Row-Bot` in container
- Or `${ROW_BOT_WORKSPACE_DIR}` (from .env) → `/home/rowbot/Documents/Row-Bot` in container

---

## Environment Variable Expansion Summary

The file uses `${VAR:-default}` syntax throughout:

| Line | Syntax | Meaning |
|------|--------|---------|
| 8 | `${ROW_BOT_PORT:-8080}` | Use ROW_BOT_PORT from .env, or 8080 |
| 10 | `${OLLAMA_BASE_URL:-http://host.docker.internal:11434}` | Use OLLAMA_BASE_URL from .env, or default Ollama endpoint |
| 25 | `${ROW_BOT_DATA_DIR:-./rowbot-data}` | Use ROW_BOT_DATA_DIR from .env, or ./rowbot-data |
| 31 | `${ROW_BOT_WORKSPACE_DIR:-./rowbot-workspace}` | Use ROW_BOT_WORKSPACE_DIR from .env, or ./rowbot-workspace |

**Why this pattern:**
- ✅ Works without .env (uses sensible defaults)
- ✅ Customizable via .env
- ✅ Same docker-compose.yml works for everyone
- ✅ No need to edit the compose file

---

## Example: How It All Works Together

**User Setup (macOS):**

```bash
# 1. Create .env
ROW_BOT_PORT=8080
ROW_BOT_DATA_DIR=/Users/<user>/rowbot-data
ROW_BOT_WORKSPACE_DIR=/Users/<user>/rowbot-workspace
OLLAMA_BASE_URL=http://host.docker.internal:11434
RESTART_POLICY=unless-stopped

# 2. Run docker-compose up -d
docker-compose up -d

# 3. Docker reads docker-compose.yml and substitutes variables:
```

**What docker-compose actually sees:**

```yaml
services:
  rowbot:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: rowbot-app
    ports:
      - "8080:8080"                           # ← substituted
    environment:
      OLLAMA_BASE_URL: http://host.docker.internal:11434  # ← substituted
    volumes:
      - rowbot-data:/home/rowbot/.row-bot
      - rowbot-workspace:/home/rowbot/Documents/Row-Bot
    restart: unless-stopped                   # ← substituted

volumes:
  rowbot-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /Users/<user>/rowbot-data            # ← substituted
  rowbot-workspace:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /Users/<user>/rowbot-workspace       # ← substituted
```

**What happens at runtime:**

```
1. Docker builds image from Dockerfile
2. Starts container named "rowbot-app"
3. Maps host port 8080 → container port 8080
4. Sets OLLAMA_BASE_URL environment variable in container
5. Mounts /Users/<user>/rowbot-data to /home/rowbot/.row-bot
6. Mounts /Users/<user>/rowbot-workspace to /home/rowbot/Documents/Row-Bot
7. Sets restart policy to "unless-stopped"
8. Row-Bot application reads OLLAMA_BASE_URL and connects to Ollama
```

---

## Why This Design Is Good

✅ **Single file works everywhere** — No need to maintain separate files for macOS/Windows/Linux

✅ **Customizable without editing** — Users just customize .env

✅ **Defaults are sensible** — Works out-of-box if no .env exists

✅ **Flexible paths** — Works whether you want to store data in:
- Current directory (`./rowbot-data`)
- Home directory (`~`)
- Custom location (`/mnt/data/rowbot`)

✅ **Production safe** — Auto-restart, persistent volumes, proper isolation

✅ **Security** — Ports explicitly mapped, network isolation, non-root user

---

## Potential Issues & Solutions

### Issue: "Port 8080 already in use"

**Cause:** Another service using port 8080

**Solution:** Change in .env
```bash
ROW_BOT_PORT=9000
docker-compose up -d
# Access at http://localhost:9000
```

### Issue: "Can't connect to Ollama"

**Cause:** OLLAMA_BASE_URL incorrect

**Linux example:**
```bash
# Wrong (default macOS/Windows)
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Right (Linux with local Ollama)
OLLAMA_BASE_URL=http://192.168.1.100:11434
# or http://localhost:11434 if using --network=host
```

### Issue: "Permission denied" on volume

**Cause:** Host and container user IDs don't match

**Solution:** Docker usually handles this, but if issues:
```bash
chmod 755 ./rowbot-data
chmod 755 ./rowbot-workspace
```

### Issue: "Can't find .env file"

**Fix:** docker-compose.yml will use defaults
```bash
# This still works, just uses defaults:
docker-compose up -d
# ROW_BOT_PORT=8080
# OLLAMA_BASE_URL=http://host.docker.internal:11434
# etc.
```

---

## Summary

The docker-compose.yml is designed to be:

1. **Simple** — One service definition (Row-Bot)
2. **Portable** — Works on macOS, Windows, Linux
3. **Configurable** — All settings via .env, no file editing needed
4. **Persistent** — Data survives container restarts
5. **Resilient** — Auto-restart on failure
6. **Secure** — Non-root user, explicit port mapping, proper networking

Every line serves a purpose and follows Docker best practices.
