# Complete Questionnaire Checklist

**What you should ask users before they start Thoth.**

---

## Tier 1: Essential (Must Ask)

These determine viability of the setup.

- [ ] **Q1: What LLM providers do you have access to?**
  - Ollama, LM Studio, OpenAI, Anthropic, OpenRouter, Groq, etc.
  - Determines what can be configured

- [ ] **Q2: Do you prefer local models or cloud APIs?**
  - Local only (privacy, no API keys)
  - Cloud only (better models)
  - Hybrid (local + cloud backup)
  - Determines primary vs fallback strategy

- [ ] **Q3: If using multiple providers, what's your priority?**
  - Primary (first choice)
  - Fallback 1 (if primary fails)
  - Fallback 2 (last resort)
  - Determines resilience strategy

**Output:** Provider configuration with fallback chain

---

## Tier 2: Important (Should Ask)

These optimize the setup significantly.

- [ ] **Q4: Do you have API keys for cloud providers?**
  - OpenAI API key
  - Anthropic API key
  - OpenRouter API key
  - Groq API key
  - Other
  - Determines which providers can actually be used

- [ ] **Q5: What's your primary use case?**
  - Chat/conversation
  - Code generation/analysis
  - Data analysis
  - Content creation
  - Other
  - Determines optimal model selection

- [ ] **Q6: What features do you need?**
  - Function calling (ability to use tools)
  - Streaming (real-time response)
  - Vision/images
  - Long-term memory
  - Determines model requirements

- [ ] **Q7: Privacy/data requirements?**
  - Data must stay local (no cloud)
  - OK with major providers (OpenAI, Anthropic)
  - OK with any provider
  - Determines what providers can be used

- [ ] **Q8: Monthly budget for APIs?**
  - Unlimited
  - $50-100
  - $10-50
  - Free only
  - Determines model selection (GPT-4 vs GPT-3.5 vs Ollama)

**Output:** Model recommendations, cost estimates, privacy settings

---

## Tier 3: Nice to Have (Could Ask)

These improve user experience.

- [ ] **Q9: What are your latency requirements?**
  - < 1 second (real-time)
  - 1-5 seconds (interactive)
  - 5-30 seconds (acceptable)
  - > 30 seconds (batch OK)
  - Determines local vs cloud, model size

- [ ] **Q10: Do you have a GPU?**
  - Yes (model/VRAM)
  - No (CPU only)
  - Enables vLLM, local model optimization

- [ ] **Q11: Network constraints?**
  - Unlimited bandwidth
  - Limited bandwidth (< 10 Mbps)
  - Inconsistent connection
  - Affects cloud vs local decision

- [ ] **Q12: Do you need multi-turn conversation memory?**
  - Yes (persistent history)
  - No (single-turn stateless)
  - Per-session only
  - Affects Thoth feature configuration

- [ ] **Q13: Preferred fallback behavior?**
  - Auto-switch (transparent)
  - Ask user
  - Error and stop
  - Affects user experience on failure

**Output:** Performance optimizations, feature enablement

---

## Tier 4: Advanced (Ask Power Users)

These enable advanced use cases.

- [ ] **Q14: Do you need monitoring/observability?**
  - Track API usage and costs
  - Log conversations
  - Performance metrics
  - Provider health checks
  - Affects logging configuration

- [ ] **Q15: Custom tools/functions needed?**
  - Web search
  - File processing
  - Code execution
  - Custom integrations
  - Affects model selection (needs function calling)

- [ ] **Q16: Output requirements?**
  - Text only
  - JSON
  - Markdown
  - Specific format
  - Affects prompt engineering

- [ ] **Q17: Compliance requirements?**
  - HIPAA (healthcare data)
  - GDPR (EU users)
  - SOC2 (security)
  - Industry-specific
  - Affects provider selection

- [ ] **Q18: Do you want cost optimization recommendations?**
  - Yes, minimize cost
  - Yes, find best value
  - No, use best models regardless
  - Affects provider and model recommendations

**Output:** Advanced configuration, compliance settings

---

## Tier 5: Context (Background Info)

These help personalize recommendations.

- [ ] **Q19: Have you used LLM APIs before?**
  - Yes, extensively
  - Yes, once or twice
  - No, first time
  - Affects documentation complexity

- [ ] **Q20: How technical are you?**
  - Expert (custom YAML config OK)
  - Advanced (can edit configs)
  - Basic (follow instructions)
  - Non-technical (need wizards)
  - Affects UI and documentation

**Output:** Appropriate guidance level

---

## Generated Outputs

For each set of answers, generate:

### File 1: `~/.thoth/config.yaml`
```yaml
providers:
  primary: [provider_name]
  fallback:
    - [fallback1_name]
    - [fallback2_name]

models:
  primary: [model_name]
  fallback1: [model_name]
  fallback2: [model_name]

features:
  streaming: [true/false]
  function_calling: [true/false]
  vision: [true/false]
  memory: [true/false]

security:
  store_api_keys: keyring
  log_requests: [true/false]
  privacy_mode: [true/false]
```

### File 2: `.env`
```
THOTH_PORT=8080
LLM_PRIMARY=[provider]
LLM_FALLBACK1=[provider]
LLM_FALLBACK2=[provider]
ENABLE_STREAMING=[true/false]
ENABLE_FUNCTION_CALLING=[true/false]
API_BUDGET_MONTHLY=[amount]
```

### File 3: `setup_instructions.txt`
```
Step 1: Install/Start Primary Provider
  [provider-specific instructions]

Step 2: Set Up Cloud API Keys
  [key setup for each cloud provider]

Step 3: Store API Keys Securely
  [keyring/Credential Manager setup]

Step 4: Deploy Thoth
  [docker-compose commands]

Step 5: Test Configuration
  [validation commands]
```

### File 4: `cost_estimate.txt`
```
Monthly Cost Estimate
═════════════════════════════════

Primary: Ollama (local)
  Cost: $0/month
  Models: [list]

Fallback 1: Groq
  Cost: $0/month (free tier)
  Models: [list]

Fallback 2: OpenAI
  Cost: $2-5/month (estimated)
  Models: [list]

TOTAL: $2-5/month
```

### File 5: `troubleshooting.txt`
```
FAQ & Troubleshooting
═════════════════════════════════

Q: What if Ollama goes down?
A: Thoth automatically uses Groq

Q: How much will this actually cost?
A: [detailed breakdown based on usage]

Q: How do I switch providers?
A: Edit config.yaml and restart

Q: Is my data private?
A: [explanation of what stays local vs cloud]

Q: How do I add more providers?
A: [instructions for extending config]
```

---

## Question Decision Tree

```
START
  │
  ├─→ Q1: What providers do you have?
  │   └─→ Q2: Local or cloud preference?
  │       ├─→ Local only
  │       │   └─→ Q3: Primary/fallback chain
  │       │       └─→ Q4: (skip cloud keys)
  │       │
  │       ├─→ Cloud only
  │       │   └─→ Q3: Primary/fallback chain
  │       │       └─→ Q4: Ask for all API keys
  │       │
  │       └─→ Hybrid
  │           └─→ Q3: Primary/fallback chain
  │               └─→ Q4: Ask for relevant API keys
  │
  ├─→ Q5: Primary use case?
  │   ├─→ Code → Q6: Function calling required
  │   ├─→ Chat → Q6: Streaming preferred
  │   └─→ Analysis → Q6: Vision needed?
  │
  ├─→ Q7: Privacy requirements?
  │   ├─→ Must be local → Filter to local providers only
  │   ├─→ Cloud OK → All providers available
  │   └─→ (affects provider recommendations)
  │
  ├─→ Q8: Budget?
  │   ├─→ Free only → Recommend Ollama + Groq free
  │   ├─→ $10-50 → Recommend Groq + Ollama
  │   └─→ Unlimited → Can recommend GPT-4
  │
  ├─→ Q9-12: (Optional advanced)
  │   └─→ Latency/GPU/Network/Memory
  │       └─→ (fine-tune model selection)
  │
  └─→ Generate Configuration
      ├─→ config.yaml
      ├─→ .env
      ├─→ setup_instructions.txt
      ├─→ cost_estimate.txt
      └─→ troubleshooting.txt
```

---

## Recommended Questionnaire Flow

### Fast Mode (3 minutes)
Ask only: Q1, Q2, Q3, Q5, Q8
→ Good default configuration

### Standard Mode (5 minutes)
Ask: Q1-8, Q12
→ Optimized for use case and budget

### Complete Mode (8 minutes)
Ask: Q1-20
→ Comprehensive setup with advanced options

### Expert Mode (Custom)
Ask user to provide YAML directly
→ For power users who know exactly what they want

---

## What You Were Missing (Complete Checklist)

✅ **Provider Management:**
- [ ] Detect what providers are available
- [ ] Ask for API keys for each
- [ ] Securely store keys (keyring)
- [ ] Suggest optimal provider choice
- [ ] Configure primary/fallback chain
- [ ] Cost estimation per provider
- [ ] Cost comparison across options

✅ **LLM Model Selection:**
- [ ] Detect models available in each provider
- [ ] Recommend based on use case
- [ ] Check model capabilities (function calling, vision, streaming)
- [ ] Estimate token costs per model
- [ ] Track model performance/quality

✅ **Use Case Optimization:**
- [ ] Ask primary use case
- [ ] Ask required features
- [ ] Recommend optimal model for use case
- [ ] Suggest feature enablement
- [ ] Warn about incompatibilities

✅ **Privacy & Security:**
- [ ] Ask privacy requirements
- [ ] Filter providers by privacy needs
- [ ] Suggest secure key storage (keyring)
- [ ] Explain data handling for each provider
- [ ] Document compliance implications

✅ **Budget Management:**
- [ ] Ask monthly budget
- [ ] Estimate cost for each provider
- [ ] Compare total costs
- [ ] Suggest cost optimization
- [ ] Provide usage-based projections
- [ ] Set cost alerts/limits

✅ **Configuration Generation:**
- [ ] Generate provider config (config.yaml)
- [ ] Generate environment file (.env)
- [ ] Generate setup instructions (OS-specific)
- [ ] Generate cost breakdown
- [ ] Generate troubleshooting guide

✅ **Fallback Strategy:**
- [ ] Explain fallback benefits
- [ ] Ask for primary/secondary/tertiary
- [ ] Validate chain makes sense
- [ ] Test all providers work
- [ ] Document switch instructions

✅ **Features & Capabilities:**
- [ ] Ask what features needed
- [ ] Check model support
- [ ] Enable/disable appropriately
- [ ] Warn about trade-offs
- [ ] Document capabilities

---

## Summary: Complete Question List

**You should ask:**

1. ✅ What providers do you have access to?
2. ✅ Local vs cloud preference?
3. ✅ Primary/fallback1/fallback2 ranking?
4. ✅ Do you have API keys?
5. ✅ Primary use case?
6. ✅ Required features (streaming, function calling, vision)?
7. ✅ Privacy/data requirements?
8. ✅ Monthly budget?
9. ⭕ Latency requirements? (optional)
10. ⭕ Have GPU available? (optional)
11. ⭕ Network constraints? (optional)
12. ⭕ Need persistent memory? (optional)
13. ⭕ Fallback behavior preference? (optional)
14. ⭕ Need monitoring/logging? (optional)
15. ⭕ Custom tools needed? (optional)
16. ⭕ Specific output format? (optional)
17. ⭕ Compliance requirements? (optional)
18. ⭕ Want cost optimization help? (optional)
19. ⭕ Prior LLM API experience? (optional)
20. ⭕ Technical level? (optional)

✅ = Essential
⭕ = Optional/Advanced

---

## Implementation Priority

**Phase 1 (MVP):**
- Q1-8 (essential questions)
- Basic config generation
- .env file
- Setup instructions
- Cost estimate

**Phase 2 (Enhanced):**
- Q9-13 (performance/features)
- Interactive validation
- Provider health checks
- Cost tracking

**Phase 3 (Advanced):**
- Q14-20 (advanced/context)
- Web UI
- Multi-provider testing
- Compliance checking

---

## Files Created So Far

You now have:
1. ✅ QUESTIONNAIRE_SYSTEM.md — Complete question list
2. ✅ AGENT_QUESTIONNAIRE_IMPLEMENTATION.md — How to build the agent
3. ✅ This file — Summary and checklist
4. ✅ Environment assessment scripts (preflight-check.sh/bat)
5. ✅ Three-tier setup workflow documentation
6. ✅ Docker-compose explanation
7. ✅ 16+ documentation files total

**Ready to implement Phase 1 of the questionnaire system!**
