# Local LLM Options: Comparing Privacy, Speed, and Hardware

This guide helps you choose between different local LLM backends for Row-Bot.

---

## Quick Comparison

| Tool | Hardware | Speed | Privacy | Setup | Best For |
|------|----------|-------|---------|-------|----------|
| **Ollama** | M-series Macs, good GPUs | Medium | ✅ Full | 5 min | Mac/Linux, easy start |
| **LM Studio** | Most GPUs, Windows/Mac | Fast | ✅ Full | 15 min | Windows, GUI lovers |
| **llama.cpp** | CPU-only, all systems | Slow | ✅ Full | 10 min | Old computers |
| **oMLX** | Apple Silicon only | Fast | ✅ Full | 10 min | M-series Macs (advanced) |
| **vLLM** | High-end GPUs | Fast | ✅ Full | 30 min | Production setups, scale |

---

## Detailed Comparison

### Option 1: Ollama (Recommended for Most Users)

**What it is:** Lightweight LLM server. Download a model, run it, connect apps.

**Hardware Requirements:**
- **Mac (M1+):** 8GB RAM minimum, 16GB+ recommended
- **Linux:** 8GB RAM, any GPU or CPU
- **Windows:** WSL2 + GPU, or CPU-only (slow)

**Speed:**
- M-series Mac (16GB): ~15-50 tokens/sec depending on model
- GPU (RTX 4080): ~100+ tokens/sec
- CPU-only: 1-5 tokens/sec (very slow)

**Privacy:** ✅ **Full — All data stays on your machine**

**Setup:**
1. Download from https://ollama.ai
2. Run: `ollama serve`
3. In another terminal: `ollama pull mistral` (or another model)
4. Row-Bot connects automatically

**Models Available:**
- **Small & Fast:** mistral (7B), neural-chat (7B)
- **Balanced:** llama2 (7B-70B), openchat (3.5B-8B)
- **Large & Slow:** llama2 (70B), code-llama (34B)

**Cost:** Free (uses your hardware)

**Best for:** Mac users, Linux, privacy-focused, don't want to pay

**Downsides:**
- Slower than cloud (depends on hardware)
- Uses your computer's CPU/GPU (slows other work)
- Requires enough RAM (8GB+)

**Popular Models:**
```bash
ollama pull mistral          # Fast, good quality
ollama pull neural-chat      # Optimized for chat
ollama pull llama2           # Balanced
ollama pull openchat         # Small and fast
ollama pull deepseek-coder   # Best for coding
```

---

### Option 2: LM Studio

**What it is:** GUI app for running local LLMs (similar to Ollama but with interface).

**Hardware Requirements:**
- **Windows:** GPU recommended (4GB+ VRAM), works on CPU
- **Mac:** M1+ with 8GB+ RAM
- **Linux:** Via Docker only

**Speed:** Similar to Ollama, depends on hardware and model

**Privacy:** ✅ **Full — All data stays on your machine**

**Setup:**
1. Download from https://lmstudio.ai
2. Launch app
3. Choose a model from the library
4. Click "Download"
5. Start server
6. Configure Row-Bot to use `http://localhost:1234/v1`

**Cost:** Free

**Best for:** Windows users, want a GUI, prefer clicking over terminal

**Downsides:**
- Another app to run (takes memory)
- Windows support is better than Ollama on Windows
- Harder to automate

**Popular Models:** Same as Ollama

---

### Option 3: llama.cpp

**What it is:** C++ implementation of Llama inference (very fast, CPU-only).

**Hardware Requirements:**
- **CPU-only:** Any computer (old Macs, old Linux)
- **M-series Mac:** 8GB+ (excellent performance)
- **GPU:** Supported but less common than Ollama

**Speed:**
- M-series Mac (optimized): 30-80 tokens/sec
- CPU (old machine): 2-8 tokens/sec
- Intel Mac: 5-20 tokens/sec

**Privacy:** ✅ **Full — All data stays on your machine**

**Setup:**
```bash
# Install
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make

# Download a model (in GGUF format)
wget https://huggingface.co/...model.gguf

# Run server
./server -m model.gguf -ngl 32
```

**Cost:** Free

**Best for:** Old computers, CPU-only, advanced users, M-series Macs

**Downsides:**
- More technical (command-line only)
- Fewer models available (need GGUF format)
- Setup takes longer

**Advantages over Ollama:**
- Faster on CPU
- Works on older Macs
- Lower memory footprint

---

### Option 4: oMLX

**What it is:** Machine Learning framework optimized for Apple Silicon (M1, M2, M3, M4).

**Hardware Requirements:**
- **Apple Silicon only** (M1, M2, M3, M4)
- 8GB+ RAM
- Requires Xcode command-line tools

**Speed:** Excellent on M-series (often faster than Ollama)

**Privacy:** ✅ **Full — All data stays on your machine**

**Setup:**
```bash
# Install (requires Xcode)
pip install mlx-lm

# Download model
mlx_lm download mistral  # or another model

# Run server
mlx_lm server --model mistral
```

**Cost:** Free

**Best for:** M-series Mac users who want maximum performance

**Downsides:**
- Apple Silicon only
- Newer/less mature than Ollama
- Fewer pre-built models
- More technical setup

**Advantages:**
- Often faster than Ollama
- Lower power usage
- Memory-efficient

---

### Option 5: vLLM

**What it is:** Production-grade LLM inference engine (used by large-scale deployments).

**Hardware Requirements:**
- **GPU:** NVIDIA (8GB VRAM minimum, 16GB+ recommended)
- **CPU-only:** Possible but not recommended
- Linux or Mac with Docker

**Speed:** Very fast (100+ tokens/sec on good GPU)

**Privacy:** ✅ **Full — All data stays on your machine**

**Setup:**
```bash
# Requires: NVIDIA GPU + CUDA installed
pip install vllm

# Run server
python -m vllm.entrypoints.openai_api_server \
  --model mistral-7b \
  --tensor-parallel-size 1
```

**Cost:** Free (uses your hardware)

**Best for:** High-performance setups, scale testing, large models

**Downsides:**
- Complex setup
- NVIDIA GPU required
- Overkill for most users
- Requires understanding of GPU memory/CUDA

**Advantages:**
- Industry-standard (what OpenAI-compatible APIs use)
- Excellent performance
- Production-proven

---

## Privacy Comparison: Local vs. Cloud

### Local LLMs (All Options Above)
```
Your Computer
├─ Input: Prompt stays on your machine
├─ Processing: Computation happens locally
└─ Output: Response stays on your machine
```
✅ **Full privacy — Nothing leaves your computer**

### Cloud LLMs (OpenAI, OpenRouter, Anthropic)
```
Your Computer → Internet → Cloud API → Their servers → Internet → Your Computer
```
⚠️ **Privacy trade-off:** Your data goes to their servers (but they have privacy policies)

**When to use cloud:**
- Don't have GPU (local too slow)
- Want best model quality (GPT-4, Claude)
- Need specific capabilities (image gen, web search)

**When to use local:**
- Privacy is critical
- Working with sensitive data
- Want to avoid API costs
- Want to own your data

---

## Cost Comparison (Monthly)

### Local LLMs
- **Ollama:** $0 (free) + electricity cost (~$5-10/month for power)
- **LM Studio:** $0 (free)
- **llama.cpp:** $0 (free)
- **oMLX:** $0 (free)
- **vLLM:** $0 (free)

**One-time cost:** GPU (if buying) — $200-2000+

### Cloud LLMs
- **OpenRouter (cheap):** $5-10/month
- **OpenAI (GPT-4):** $10-50/month (varies by usage)
- **Anthropic (Claude):** $5-20/month
- **Ollama (local GPU power):** $5-15/month in electricity

---

## Decision Tree: Which Local LLM?

```
Do you have an NVIDIA GPU?
├─ Yes, RTX 3090+ → Use vLLM (production-grade)
└─ No
   │
   Do you have a Mac?
   ├─ Yes (M1/M2/M3/M4)
   │  ├─ Want easiest setup? → Use Ollama
   │  └─ Want maximum speed? → Use oMLX
   │
   └─ No (Linux/Windows)
      ├─ Windows?
      │  ├─ Have GPU? → Use LM Studio
      │  └─ No GPU? → Cloud LLM (local too slow)
      │
      └─ Linux
         ├─ Good CPU/GPU? → Use Ollama
         └─ Old/weak? → Use llama.cpp
```

---

## Model Size Guide (Depends on Your RAM)

| RAM | Recommended Model | Speed | Quality |
|-----|------------------|-------|---------|
| 4GB | Can't run local | — | — |
| 8GB | mistral-7b, neural-chat-7b | Slow | Good |
| 16GB | llama2-7b, mistral-7b | Medium | Good |
| 16GB+ | llama2-13b, mixtral-8x7b | Medium | Excellent |
| 32GB+ | llama2-70b, code-llama-34b | Slow-Medium | Excellent |
| GPU (4GB+) | Any model (tokenize by VRAM) | Fast | Excellent |

---

## Troubleshooting Local LLMs

### "Too slow to be usable"

**Cause:** Model too large for hardware

**Solutions:**
1. Use smaller model: `mistral-7b` instead of `llama2-70b`
2. Use faster backend: `llama.cpp` instead of `Ollama`
3. Add GPU acceleration
4. Consider cloud LLM instead

### "Out of memory"

**Cause:** Model doesn't fit in RAM

**Solutions:**
1. Use smaller model (`mistral-7b` instead of `llama2-13b`)
2. Reduce `n_gpu_layers` in config (offload to CPU)
3. Add more RAM
4. Use quantized version (smaller file)

### "Connection refused"

**Cause:** Local LLM server isn't running

**Solutions:**
```bash
# Start Ollama
ollama serve

# Or check if it's running
curl http://localhost:11434/api/tags
```

### "Model not found"

**Cause:** Haven't downloaded the model yet

**Solutions:**
```bash
# List available models
ollama list

# Download a model
ollama pull mistral
```

---

## Recommended Setup (This Package)

**For most users:** Start with **Ollama**
- Easy to install
- Good balance of privacy, speed, and simplicity
- Default in setup.sh
- Works on Mac and Linux

**If you want something faster:** Try **LM Studio** (Windows/Mac) or **oMLX** (M-series Mac)

**If privacy is critical:** Any local option works — data never leaves your computer

**If you have hardware constraints:** See decision tree above

---

## Next Steps

1. **Choose your backend** (default is Ollama)
2. **Install and start it** on your machine
3. **Download a model** (default is `mistral-7b`)
4. **Test connection** from Row-Bot

For setup instructions, see CLAUDE.md "Testing Individual Components" section.
