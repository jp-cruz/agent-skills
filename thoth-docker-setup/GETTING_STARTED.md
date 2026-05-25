# Getting Started with Thoth Docker Setup

**Complete guide for users new to Docker, command line, and LLM APIs.**

---

## Before You Start: Do You Have These?

### ✅ Required
- [ ] A Mac, Windows, or Linux computer
- [ ] Internet connection (for downloads)
- [ ] 5-10 GB free disk space

### ❓ You Might Not Have Yet (Don't Worry!)
- [ ] Docker (we'll help you install)
- [ ] Experience with terminal/command line
- [ ] LLM API keys (optional, we'll explain)

---

## Quick 5-Minute Checklist

**Done before you start:**

1. [ ] Clone or download this repository
2. [ ] Have Docker Desktop ready (download if needed)
3. [ ] Know what LLM providers you want (Ollama, OpenAI, etc.)

**Then run:**

```bash
# Check that Docker is installed
./check-docker.sh

# Run the setup wizard
./setup.sh

# Start Thoth
docker-compose up -d

# Access
open http://localhost:8080
```

**Done!** 🎉

---

## Step-by-Step for Complete Beginners

### Step 1: Download/Clone This Repository

**Option A: Using Git (if you have it)**
```bash
git clone <repository-url>
cd thoth-docker-setup
```

**Option B: Download as ZIP**
1. Go to the repository on GitHub
2. Click green "Code" button
3. Click "Download ZIP"
4. Extract the ZIP file
5. Open terminal and navigate to the folder:
   ```bash
   cd ~/Downloads/thoth-docker-setup  # Adjust path as needed
   ```

### Step 2: Install Docker (If You Don't Have It)

**Don't know if you have Docker?** Open terminal and run:
```bash
docker --version
```

If it shows a version number, you have Docker! Skip to Step 3.

If it says "command not found," see [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md):

**Quick Installation:**

**macOS:**
1. Download: https://www.docker.com/products/docker-desktop
2. Open the .dmg file
3. Drag "Docker.app" to Applications folder
4. Open Docker.app
5. Enter your password when prompted
6. Wait 2-3 minutes for "Docker is running" notification

**Windows:**
1. Download: https://www.docker.com/products/docker-desktop
2. Run the installer
3. Select "Enable WSL 2" option
4. Restart computer when done
5. Docker will auto-start

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
```
Then log out and log back in.

### Step 3: Verify Docker is Working

In terminal, run:
```bash
./check-docker.sh
```

You should see:
```
✓ Docker is installed
✓ Docker daemon is running
✓ Docker Compose is installed
✓ Docker is working correctly

ALL CHECKS PASSED - READY TO PROCEED!
```

If you see errors, see [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md#common-installation-issues) troubleshooting section.

### Step 4: Choose Your LLM Provider(s)

**What's an LLM Provider?**
It's where the AI models come from. Think of it like choosing between:
- Local pizza restaurant (Ollama)
- Delivery from a restaurant across town (OpenAI, Anthropic)
- Food court with many options (OpenRouter)

**Quick Recommendation:**
```
IF you want free and private:
  → Use Ollama (local, no API key needed)

IF you want the best quality:
  → Use OpenAI GPT-4 or Claude (cloud, paid ~$0.01-0.05 per request)

IF you want free cloud (with limitations):
  → Use Groq (cloud, free tier)

IF you're not sure:
  → Use Ollama + Groq (free local + free cloud backup)
```

See [QUESTIONNAIRE_SUMMARY.md](QUESTIONNAIRE_SUMMARY.md) for detailed comparison.

### Step 5: Get API Keys (If Using Cloud)

**If you chose Ollama only:** Skip this step!

**If you chose OpenAI:**
1. Go to https://platform.openai.com/api-keys
2. Sign up or log in with OpenAI account
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)
5. Keep this secret! Don't share it!
6. You can keep this handy for Step 7

**If you chose Anthropic Claude:**
1. Go to https://console.anthropic.com
2. Sign up or log in
3. Go to API keys section
4. Create new key
5. Copy the key

**If you chose Groq (free):**
1. Go to https://groq.com
2. Sign up with email or Google account
3. Go to API keys
4. Create new key
5. Copy the key

### Step 6: Run the Setup

In terminal:
```bash
./setup.sh
```

This will:
1. ✓ Create a `.env` file with defaults
2. ✓ Create data directories
3. ✓ Verify Docker is installed
4. ✓ Check if Ollama is running (if you're using it)
5. ✓ Show you next steps

**If you see "Ollama not reachable":**
- This is OK! You need to start Ollama separately
- Download from https://ollama.ai if you haven't
- Run `ollama serve` in a separate terminal

### Step 7: Configure LLM Providers (Optional but Recommended)

After running `./setup.sh`, you'll have a `.env` file.

**If you want to use cloud providers**, add your API keys:

**Edit the .env file:**
```bash
nano .env
```

Add your API keys:
```bash
# If using OpenAI:
OPENAI_API_KEY=sk-your-key-here

# If using Anthropic:
ANTHROPIC_API_KEY=sk-your-key-here

# If using Groq:
GROQ_API_KEY=gsk-your-key-here
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter` in nano).

### Step 8: Start Thoth

```bash
docker-compose up -d
```

This will:
1. Download Thoth image (~5 min, first time only)
2. Start Thoth container
3. Show you it's running

Verify it's running:
```bash
docker-compose ps
```

You should see `thoth-app` with status `Up`.

### Step 9: Access Thoth

Open your web browser and go to:
```
http://localhost:8080
```

You should see the Thoth interface! 🎉

---

## Common First Questions

### Q: Is Thoth running? How do I check?

**Method 1: Check in terminal**
```bash
docker-compose ps
```

Should show `thoth-app` with status `Up`.

**Method 2: Try opening it in browser**
http://localhost:8080

If it loads, it's running!

**Method 3: Check logs**
```bash
docker-compose logs thoth
```

### Q: How do I stop Thoth?

```bash
docker-compose stop
```

### Q: How do I start it again after stopping?

```bash
docker-compose up -d
```

### Q: I added a new API key, how do I update Thoth?

```bash
# Stop Thoth
docker-compose stop

# Restart with new config
docker-compose up -d
```

### Q: How do I edit config files?

**Option 1: Edit on your computer**
```bash
# .env file
nano .env

# Thoth config
nano ~/.thoth/config.yaml
```

**Option 2: Edit inside the container**
```bash
# Open shell in container
docker-compose exec thoth bash

# Then edit
nano /home/thoth/.thoth/config.yaml
```

### Q: How much storage does Thoth use?

- Image: ~300 MB
- Data per model: 3-40 GB (depends on model)
- Your conversations: ~1 MB per 100k tokens

Total: 300 MB to 50 GB depending on your models.

### Q: Can I run multiple Thoth instances?

Yes! Change the port in `.env`:
```bash
# Instance 1
THOTH_PORT=8080

# Instance 2 (in a different folder)
THOTH_PORT=8081
```

### Q: How do I uninstall/remove Thoth?

```bash
# Stop it
docker-compose stop

# Remove container
docker-compose down

# Delete data (optional)
rm -rf ./thoth-data ./thoth-workspace

# Delete the folder (optional)
cd ..
rm -rf thoth-docker-setup
```

### Q: I'm getting an error, what do I do?

Check these in order:

1. **Is Docker running?**
   ```bash
   docker ps
   ```
   If nothing shows, start Docker.

2. **Check Thoth logs**
   ```bash
   docker-compose logs thoth | tail -20
   ```

3. **Check the README.md troubleshooting section**
   See [README.md#troubleshooting](README.md#troubleshooting)

4. **Search online for the error message**
   Most Docker errors have solutions on Stack Overflow.

### Q: Can I use Thoth on other computers?

Yes! The same folder works on Mac, Windows, and Linux. Just:
1. Copy the folder to the new computer
2. Install Docker on the new computer
3. Run `docker-compose up -d`

It works identically everywhere! That's the power of Docker.

---

## Advanced: Understanding What's Happening

### What does `docker-compose up -d` do?

1. **Reads docker-compose.yml** — Instructions for setting up Thoth
2. **Downloads Thoth image** — The pre-built Thoth application (~300 MB)
3. **Creates container** — A lightweight virtual environment for Thoth
4. **Starts Thoth** — Runs the Thoth application
5. **Sets up networking** — Makes it accessible at localhost:8080
6. **Mounts volumes** — Connects your data folders to the container
7. **Detaches** — The `-d` means it runs in background

**Result:** Thoth is running, ready to use.

### What's in the container?

```
Python 3.11
├─ Thoth application
├─ pip packages (keyring, anthropic, openai, etc.)
└─ System utilities (nano, jq, curl, vim, etc.)
```

### Where does my data live?

```
Your Computer
├─ ./thoth-data/          ← Thoth configuration and cache
│   └─ mounted to /home/thoth/.thoth in container
└─ ./thoth-workspace/     ← Your projects and files
    └─ mounted to /app/workspace in container
```

Data lives on your computer, just accessed through the container.

### Can Thoth access my files outside these folders?

No. Docker isolates the container. It can only see:
- /home/thoth/.thoth (your data folder)
- /app/workspace (your workspace folder)
- /home/thoth (Thoth's home directory)

This is a **security feature** — Thoth can't accidentally mess with your system.

---

## Next Steps

1. **Read:** [QUESTIONNAIRE_SYSTEM.md](QUESTIONNAIRE_SYSTEM.md)
   → Understand how to optimize your setup

2. **Read:** [SETUP_WORKFLOW.md](SETUP_WORKFLOW.md)
   → Compare three setup methods

3. **Try:** Ask Thoth questions!
   → Experiment with your LLM provider

4. **Learn:** [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md)
   → Understand Docker better

5. **Integrate:** Use Thoth in your workflows
   → See [README.md](README.md) for API documentation

---

## Still Stuck?

### Common Issues

**"Command not found" errors:**
- Make sure you're in the `thoth-docker-setup` folder
- Try full path: `./setup.sh` instead of `setup.sh`

**"Port 8080 already in use":**
- Change port in `.env`: `THOTH_PORT=8081`
- Restart: `docker-compose up -d`

**"Ollama not found":**
- Download from https://ollama.ai
- Start in separate terminal: `ollama serve`
- Then run `./setup.sh` again

**"Docker not found":**
- See [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md)
- Install Docker Desktop for your OS
- Run `./check-docker.sh` to verify

### Get Help

1. Check [README.md#troubleshooting](README.md#troubleshooting)
2. Check [DOCKER_GUIDE_FOR_BEGINNERS.md](DOCKER_GUIDE_FOR_BEGINNERS.md)
3. Search error message on Google
4. Ask in the GitHub issues

---

## You're All Set!

You now have a fully functional Thoth setup with:
✅ Docker containerization  
✅ LLM provider support  
✅ Data persistence  
✅ Easy configuration  
✅ Cross-platform compatibility  

Welcome to the future of AI agents! 🚀

---

## FAQ Summary

| Q | A |
|---|---|
| Do I need to know Docker? | No! We handle the Docker for you. |
| Is Docker hard to install? | No! 5-10 minutes, just download and install. |
| Will this break my computer? | No! Docker isolates Thoth from your system. |
| Can I uninstall easily? | Yes! Just delete the folder. |
| Can I use multiple providers? | Yes! We support Ollama, OpenAI, Anthropic, Groq, etc. |
| How much does this cost? | Free (Ollama) to $0.01/request (cloud APIs). |
| Is my data private? | Yes! Ollama stays local. Cloud APIs go to those services. |
| Can I run on different computers? | Yes! Same setup works on Mac, Windows, Linux. |
| What if I get stuck? | Check README troubleshooting or contact support. |

---

**Happy prompting! 🎉**
