# Pre-Installation Questionnaire System

**Purpose:** Ask users intelligent questions to auto-configure Thoth with optimal settings.

**Scope:** LLM providers, fallback strategy, local vs cloud, API keys, use cases, etc.

---

## Core Questions to Ask

### Section 1: LLM Providers (Critical)

#### Q1.1: Which LLM providers do you have access to?

**Options:**
- [ ] Ollama (local)
- [ ] LM Studio (local)
- [ ] vLLM (local)
- [ ] llama.cpp (local)
- [ ] Groq (cloud, free tier available)
- [ ] OpenAI (GPT-3.5, GPT-4) (cloud, paid)
- [ ] Anthropic Claude (cloud, paid)
- [ ] OpenRouter (cloud, aggregator, paid)
- [ ] Mistral AI (cloud, paid)
- [ ] Cohere (cloud, paid)
- [ ] Together AI (cloud, paid)
- [ ] Replicate (cloud, paid)
- [ ] Hugging Face Inference (cloud, paid)
- [ ] Kimi (cloud, paid)
- [ ] Other: ________

**Why:** Determines what can be configured

#### Q1.2: Do you prefer local models or cloud APIs?

**Options:**
- Local only (privacy, no API keys needed)
- Cloud only (better models, pay-per-use)
- Hybrid (local primary, cloud fallback)
- Hybrid (cloud primary, local fallback)

**Why:** Affects architecture and fallback strategy

#### Q1.3: Local Model Preference (if using local)

**Options:**
- [ ] Ollama (easiest setup)
- [ ] LM Studio (good UI, slower)
- [ ] vLLM (best performance with GPU)
- [ ] llama.cpp (optimized C++)
- [ ] Other: ________

**Why:** Different providers have different characteristics

#### Q1.4: Favorite Cloud Providers (in order of preference)

**Rank these (1 = most preferred):**
1. _____ OpenAI (best models, most expensive)
2. _____ Anthropic Claude (reasoning, best for analysis)
3. _____ OpenRouter (cheapest access to many models)
4. _____ Groq (fastest inference, free tier)
5. _____ Mistral (good value)
6. _____ Other: ________

**Why:** Determines primary and fallback configuration

---

### Section 2: Primary/Fallback Strategy

#### Q2.1: Configure Provider Priority

**Scenario:** "You're setting up Thoth. What's your preference if a provider fails?"

**Three-tier model:**

```
PRIMARY (First Choice):
  Provider: [Ollama / OpenAI / Claude / OpenRouter / etc.]
  Why: [Fastest / Cheapest / Best quality / Most reliable]

SECONDARY/FALLBACK 1 (If primary unavailable):
  Provider: [Alternative]
  Why: [Has same models / Good fallback / Cost effective]

TERTIARY/FALLBACK 2 (If primary AND secondary fail):
  Provider: [Last resort]
  Why: [Last resort / Always available / Free tier]
```

**Example configurations:**

**Example A: Privacy-first Local User**
```
PRIMARY: Ollama (local, private)
FALLBACK 1: vLLM (local, alternative)
FALLBACK 2: None (offline only)
```

**Example B: Cloud-first with Cost Control**
```
PRIMARY: OpenRouter (aggregator, cheapest)
FALLBACK 1: Groq (fast, free tier)
FALLBACK 2: Claude (fallback, quality)
```

**Example C: Performance-focused**
```
PRIMARY: GPT-4 via OpenAI (best quality)
FALLBACK 1: Claude via Anthropic (good alternative)
FALLBACK 2: OpenRouter (backup)
```

**Example D: Hybrid Local+Cloud**
```
PRIMARY: Ollama (local, free)
FALLBACK 1: Groq (cloud, free tier)
FALLBACK 2: OpenRouter (cloud, paid)
```

**Why:** Helps build resilient configuration with automatic failover

#### Q2.2: Fallback Strategy

**How should Thoth behave if primary provider fails?**

- [ ] Auto-failover to secondary (transparent to user)
- [ ] Notify user, ask which provider to use
- [ ] Error and stop (don't failover)
- [ ] Queue request and retry primary periodically
- [ ] Try all providers in order until one works

**Why:** Affects user experience and reliability

---

### Section 3: API Keys & Credentials

#### Q3.1: Do you have API keys for cloud providers?

**Checklist:**
- [ ] OpenAI API key
- [ ] Anthropic API key
- [ ] OpenRouter API key
- [ ] Groq API key
- [ ] Other: ________

**Where to get them:**
- OpenAI: https://platform.openai.com/api-keys
- Anthropic: https://console.anthropic.com
- OpenRouter: https://openrouter.ai
- Groq: https://groq.com

**Why:** Determines which cloud providers can be used

#### Q3.2: How should API keys be stored?

**Options:**
- Keyring (secure, OS-native storage) ✓ Recommended
- Environment variables
- `.env` file (less secure, not recommended)
- Config file (not recommended, security risk)

**Why:** Security and convenience trade-off

#### Q3.3: Should Thoth persist API keys between sessions?

- Yes (stored in keyring)
- No (ask each time)
- Ask me on startup

**Why:** Usability vs security

---

### Section 4: Model Selection

#### Q4.1: What model capabilities do you need?

**Required:**
- [ ] Text generation (chat)
- [ ] Code generation/analysis
- [ ] Function calling (tool use)
- [ ] Vision/image understanding
- [ ] Streaming responses
- [ ] Fine-tuning capability
- [ ] Cost optimization
- [ ] Speed/latency critical

**Why:** Determines which models are viable

#### Q4.2: Preferred Model Families

**Rank your preferences:**
1. _____ GPT-4 / GPT-3.5 (best quality, expensive)
2. _____ Claude (best reasoning, good quality)
3. _____ Llama (open source, free if local)
4. _____ Mistral (open source, good balance)
5. _____ Other: ________

**Why:** Affects model selection within each provider

#### Q4.3: Model Quality vs Speed Trade-off

**Choose your priority:**
- [ ] Quality (GPT-4, Claude, better accuracy)
- [ ] Speed (Groq, vLLM, faster responses)
- [ ] Cost (Groq free tier, Ollama, cheapest)
- [ ] Balance (OpenRouter, good mix)

**Why:** Determines which models are recommended

---

### Section 5: Use Cases

#### Q5.1: What's your primary use case for Thoth?

**Select all that apply:**
- [ ] Interactive chat/conversation
- [ ] Code generation and analysis
- [ ] Data analysis and research
- [ ] Content creation/writing
- [ ] Question answering
- [ ] Task automation
- [ ] Brainstorming/ideation
- [ ] Other: ________

**Why:** Affects model recommendations and feature suggestions

#### Q5.2: Do you need multi-turn memory/context?

- Yes (persistent conversation history)
- No (single-turn, stateless)
- Per-session only
- Long-term memory needed

**Why:** Affects Thoth configuration and feature enablement

#### Q5.3: Do you need these Thoth features?

**Capabilities:**
- [ ] File upload/processing
- [ ] Web search capability
- [ ] Code execution
- [ ] Image analysis
- [ ] Custom tools/plugins
- [ ] RAG (document search)
- [ ] Streaming responses
- [ ] Webhook integrations

**Why:** Determines required Thoth configuration

---

### Section 6: Performance & Constraints

#### Q6.1: What are your latency requirements?

- < 1 second (real-time, very demanding)
- 1-5 seconds (interactive, responsive)
- 5-30 seconds (acceptable for complex tasks)
- > 30 seconds (batch processing OK)

**Why:** Determines local vs cloud, model size

#### Q6.2: Do you have a GPU available?

- Yes (NVIDIA/AMD/Apple)
  - Model: ________
  - VRAM: ________
- No (CPU only)
- Not sure

**Why:** Enables vLLM, local model recommendations

#### Q6.3: Network bandwidth for cloud APIs

- Unlimited (no constraints)
- Limited (< 10 Mbps, use local models)
- Inconsistent (need offline fallback)
- Metered/expensive (minimize API calls)

**Why:** Affects cloud vs local decision

---

### Section 7: Privacy & Security

#### Q7.1: What are your privacy requirements?

- All data must stay local (no cloud APIs)
- OK to send to major providers (OpenAI, Anthropic, Google)
- OK to use any cloud provider
- Doesn't matter (fully cloud OK)

**Why:** Determines what providers can be used

#### Q7.2: Do you need audit logging?

- Yes (track all requests)
- Yes (track only sensitive requests)
- No (not needed)

**Why:** Affects Thoth configuration

#### Q7.3: Data retention requirements

- Delete immediately (no persistence)
- Session-only
- Configurable retention
- Keep indefinitely

**Why:** Affects storage and compliance requirements

---

### Section 8: Budget

#### Q8.1: Monthly API budget

- Unlimited (use best models, no cost consideration)
- $50-100 (careful with expensive models)
- $10-50 (use free tiers or cheap providers)
- Free only (Ollama local only)

**Why:** Affects provider and model recommendations

#### Q8.2: Preferred pricing model

- [ ] Pay-per-token (fine-grained control)
- [ ] Subscription (predictable cost)
- [ ] Free tier (Groq, Replicate free tier)
- [ ] Open source only (Ollama, vLLM)

**Why:** Affects provider selection

---

### Section 9: Integration

#### Q9.1: Will Thoth integrate with other services?

- No (standalone)
- Yes, webhooks needed
- Yes, API access needed
- Yes, function calling needed
- Yes, custom tools needed

**Why:** Affects Thoth configuration

#### Q9.2: Output requirements

- Text only
- JSON
- Markdown
- Specific format: ________

**Why:** Affects prompt configuration

---

### Section 10: Expertise

#### Q10.1: How technical are you?

- Non-technical (need wizards/defaults)
- Basic (follow instructions)
- Advanced (can edit configs)
- Expert (custom setup)

**Why:** Affects documentation and complexity level

#### Q10.2: Have you used LLM APIs before?

- Yes, extensively
- Yes, once or twice
- No, first time

**Why:** Affects onboarding complexity

---

## Generated Configuration

After answering all questions, generate:

### 1. Thoth Config File
```yaml
# auto-generated ~/.thoth/config.yaml
providers:
  primary:
    name: "ollama"
    endpoint: "http://host.docker.internal:11434"
    model: "neural-chat:7b"
    timeout: 30
  
  fallback:
    - name: "openrouter"
      api_key_env: "OPENROUTER_API_KEY"
      model: "mistralai/mistral-7b"
      timeout: 20
    
    - name: "groq"
      api_key_env: "GROQ_API_KEY"
      model: "mixtral-8x7b-32768"
      timeout: 15

features:
  streaming: true
  function_calling: true
  vision: false
  context_size: 8192

security:
  store_api_keys: "keyring"
  log_requests: false
  persist_history: true
  retention_days: 30
```

### 2. .env File
```bash
# Auto-generated .env
THOTH_PORT=8080
THOTH_DATA_DIR=/Users/jp/thoth-data
THOTH_WORKSPACE_DIR=/Users/jp/thoth-workspace

# LLM Configuration
LLM_PRIMARY="ollama"
LLM_PRIMARY_ENDPOINT="http://host.docker.internal:11434"
LLM_PRIMARY_MODEL="neural-chat:7b"

LLM_FALLBACK1="openrouter"
LLM_FALLBACK1_KEY_ENV="OPENROUTER_API_KEY"

LLM_FALLBACK2="groq"
LLM_FALLBACK2_KEY_ENV="GROQ_API_KEY"

# Features
ENABLE_STREAMING=true
ENABLE_FUNCTION_CALLING=true
ENABLE_VISION=false

# Security
API_KEY_STORAGE="keyring"
ENABLE_AUDIT_LOG=false
HISTORY_RETENTION_DAYS=30
```

### 3. Setup Instructions
```
SETUP INSTRUCTIONS
═══════════════════════════════════════════════════════════════

1. LOCAL MODEL SETUP (Primary: Ollama)
   
   Download Ollama: https://ollama.ai
   Start Ollama: ollama serve
   Pull model: ollama pull neural-chat:7b
   
   Verify: curl http://localhost:11434/api/tags

2. CLOUD API SETUP (Fallbacks)
   
   OpenRouter:
     Get API key: https://openrouter.ai
     Store: OPENROUTER_API_KEY=<your-key>
     Command: export OPENROUTER_API_KEY=sk-...
   
   Groq:
     Get API key: https://groq.com
     Store: GROQ_API_KEY=<your-key>
     Command: export GROQ_API_KEY=gsk-...

3. STORE API KEYS IN KEYRING
   
   macOS:
     keyring set thoth openrouter sk-...
     keyring set thoth groq gsk-...
   
   Linux:
     secret-tool store --label="Thoth OpenRouter" \
       app thoth provider openrouter
   
   Windows:
     (Stored automatically in Credential Manager)

4. START THOTH
   
   docker-compose up -d
   open http://localhost:8080

5. TEST CONFIGURATION
   
   Primary (Ollama): Should work immediately
   Fallback 1 (OpenRouter): Test after API key setup
   Fallback 2 (Groq): Test after API key setup
```

### 4. FAQ Answers (Auto-generated)
```
Q: What happens if Ollama goes down?
A: Thoth automatically switches to OpenRouter with Mistral-7B.

Q: Will this cost me money?
A: Primary (Ollama) is free. Fallbacks cost ~$0.001-0.01 per request.

Q: Can I switch providers later?
A: Yes! Edit ~/.thoth/config.yaml and restart Thoth.

Q: Is my data private?
A: Ollama is local. Cloud fallbacks send data to OpenRouter/Groq servers.

Q: How do I change the model?
A: Edit ~/.thoth/config.yaml, update the model field, restart.

Q: How much will this cost per month?
A: Estimate based on usage: [calculation based on answers]
```

---

## Questions You're Missing (Additional)

### A. Monitoring & Observability
- Do you want to track API usage/costs?
- Do you need performance metrics?
- Do you want to log conversations?
- Do you need alerts for provider failures?

### B. Customization
- Do you have custom system prompts?
- Do you need custom tools/functions?
- Do you need prompt templates?
- Do you want to fine-tune models?

### C. Testing & Validation
- Do you want automatic provider health checks?
- Do you want benchmarking between providers?
- Do you want to test configuration before going live?
- Do you want dry-run mode?

### D. Scaling
- Do you expect high concurrency?
- Do you need rate limiting?
- Do you need load balancing between providers?
- Do you need request queuing?

### E. Updates & Maintenance
- How often should models be updated?
- Do you want automatic model updates?
- Do you want to receive provider status notifications?
- Do you want cost optimization recommendations?

### F. Compliance
- Do you need SOC2/ISO certification compliance?
- Do you need data residency (specific country)?
- Do you need data encryption at rest?
- Do you need DLP (data loss prevention)?

### G. Backup & Disaster Recovery
- What's your RTO (Recovery Time Objective)?
- What's your RPO (Recovery Point Objective)?
- Do you need multi-region setup?
- Do you need automatic backup of conversations?

### H. Cost Management
- Do you want cost alerts (e.g., $50/day)?
- Do you want provider comparison (which is cheapest)?
- Do you want rate limiting by budget?
- Do you want cost forecasting?

---

## Questionnaire Delivery Methods

### Method 1: Interactive CLI (Simple)
```bash
$ ./preflight-setup.sh --interactive

? Which LLM providers do you have access to?
  ○ Ollama
  ○ OpenAI
  ○ Anthropic
  ○ Multiple (let me choose each)

? Do you prefer local or cloud?
  ○ Local only
  ○ Cloud only
  ○ Hybrid

...
```

### Method 2: Web Form (Medium)
```
Interactive web form at http://localhost:8080/setup
- Check boxes for providers
- Drag-to-rank for preferences
- Paste API keys securely
- Test configuration before saving
```

### Method 3: Claude Code Agent (Advanced)
```
Interactive conversation with Claude Code:
  "Set up my LLM providers for Thoth"
  
Agent guides you through:
  1. Questions about what you have access to
  2. Recommendations based on your answers
  3. Automatic config generation
  4. Testing and validation
```

### Method 4: YAML Config File (Expert)
```yaml
# Copy and edit this YAML
llm_config.yaml:
  providers:
    primary: ollama
    fallback:
      - openrouter
      - groq
  models:
    ollama: neural-chat:7b
    openrouter: mistralai/mistral-7b
    groq: mixtral-8x7b-32768
  features:
    streaming: true
    function_calling: true
```

---

## Implementation Roadmap

**Phase 1 (MVP):**
- [ ] Interactive CLI questionnaire
- [ ] Basic config generation
- [ ] Primary/fallback setup
- [ ] .env generation

**Phase 2 (Enhanced):**
- [ ] Web form UI
- [ ] API key management
- [ ] Configuration testing
- [ ] Provider health checks

**Phase 3 (Advanced):**
- [ ] Claude Code agent integration
- [ ] Cost tracking and forecasting
- [ ] Multi-provider load balancing
- [ ] Compliance checking

**Phase 4 (Enterprise):**
- [ ] Audit logging
- [ ] Fine-tuning support
- [ ] Multi-region deployment
- [ ] Team management

---

## Summary: What to Ask

**Essential (Must Ask):**
1. What providers do you have access to?
2. Do you prefer local or cloud?
3. Which is primary, fallback1, fallback2?
4. Do you have API keys for cloud providers?
5. What's your primary use case?

**Important (Should Ask):**
6. Privacy requirements (local vs cloud)?
7. Budget constraints?
8. Latency requirements?
9. Do you have a GPU?
10. What features do you need?

**Nice to Have (Could Ask):**
11. Do you need audit logging?
12. Cost monitoring/alerts?
13. Provider health checks?
14. Compliance requirements?

**Bonus (Advanced Users):**
15. Custom prompts/tools?
16. Multi-region setup?
17. Team collaboration?
18. Fine-tuning models?

---

## What You Were Missing

✅ **Now covered:**
- Provider detection (detect what users have access to)
- Local vs cloud decision tree
- Primary/fallback configuration strategy
- API key management and storage
- Cost estimation and budgeting
- Privacy and compliance requirements
- Use case-driven recommendations
- Automatic config generation
- Testing and validation workflow

🎯 **This enables:**
- Smart fallback chains (auto-switch if primary fails)
- Cost-optimized provider selection
- Privacy-respecting configuration
- Resilient multi-provider setup
- Personalized recommendations
- Expert-level configuration capabilities
