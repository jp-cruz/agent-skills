# Agent Questionnaire Implementation Guide

**How to implement the comprehensive questionnaire as a Claude Code agent skill.**

---

## Overview

The agent skill will:
1. Ask users a series of intelligent questions
2. Understand their setup and preferences
3. Generate optimal Thoth configuration
4. Create customized .env and config.yaml files
5. Provide setup instructions specific to their needs
6. Test configuration before saving

---

## Recommended Agent Workflow

### Phase 1: Discovery (Questions 1-3)

```
Agent: "Let's set up your LLM providers for Thoth!

First, tell me what you have access to:
  □ Ollama (local, free)
  □ LM Studio (local, free)
  □ OpenAI (cloud, paid)
  □ Anthropic Claude (cloud, paid)
  □ OpenRouter (cloud, paid, many models)
  □ Groq (cloud, free tier, fast)
  □ Others?

Select all that apply, then I'll ask follow-ups."

User: "Ollama, OpenAI, and Groq"

Agent: "Great! You have local (Ollama) and cloud (OpenAI, Groq) options.

Do you prefer:
  A) Local-first (use Ollama, fall back to cloud)
  B) Cloud-first (use OpenAI, fall back to Groq)
  C) Hybrid-optimized (different use cases use different providers)"

User: "A - Local first"

Agent: "Perfect! Local-first setup provides privacy and low cost.

Which should be your priority:
  1) Ollama (free, private)
  2) Groq (cloud, free tier, very fast)
  3) OpenAI (cloud, expensive, best quality)"

User: "Ollama primary, Groq fallback1, OpenAI fallback2"
```

### Phase 2: Configuration (Questions 4-7)

```
Agent: "Excellent primary/fallback setup!

Now for specifics:

Your OpenAI API key?"
User: "sk-..."

Agent: "✓ Saved. Your Groq API key?"
User: "gsk-..."

Agent: "✓ Saved. And your use case?"
User: "Mostly code analysis and content writing"

Agent: "Code analysis benefits from function calling and fast response.
Content writing benefits from streaming output.

Should I enable:
  □ Function calling (ability to execute tools)
  □ Streaming (real-time response)
  □ Vision (image analysis)
  □ Long-term memory"

User: "Yes to all except Vision"
```

### Phase 3: Optimization (Questions 8-9)

```
Agent: "For code analysis + content + streaming, 
I recommend:

Ollama model: neural-chat:7b (good for both tasks)
Groq model: mixtral-8x7b-32768 (fast, capable)
OpenAI model: gpt-3.5-turbo (fallback, quality)

Is that OK?"

User: "Yes, but prefer gpt-4 if budget allows"

Agent: "Understood. Using gpt-4 for fallback.

Your monthly API budget?"
User: "$20-30"

Agent: "⚠️ Warning: gpt-4 may exceed your budget.
Alternative: Use gpt-3.5-turbo ($1-2/month for moderate use)
or Groq free tier + Ollama (free).

Recommend: Ollama + Groq + gpt-3.5-turbo
Estimated cost: $0-2/month

Accept?"

User: "Yes"
```

### Phase 4: Privacy & Security (Questions 10-11)

```
Agent: "Privacy and security check:

Ollama: All data stays local ✓ Private
Groq: Data sent to Groq servers ⚠️ Cloud
OpenAI: Data sent to OpenAI servers ⚠️ Cloud

Is this acceptable?"

User: "Yes"

Agent: "API keys will be stored in your system's secure keyring:
- macOS: Keychain
- Windows: Credential Manager
- Linux: Secret Service

Never stored in plain text. OK?"

User: "Yes"
```

### Phase 5: Generation (Auto-generate)

```
Agent: "Perfect! Generating your configuration...

🔧 Creating config files...
📝 Creating setup instructions...
✅ Validating configuration...

GENERATED CONFIGURATION:
═════════════════════════════════════════════

PRIMARY: Ollama
  Model: neural-chat:7b
  Endpoint: http://host.docker.internal:11434
  Status: Will verify after Ollama starts

FALLBACK 1: Groq
  Model: mixtral-8x7b-32768
  API Key: gsk-[hidden]
  Cost: ~$0/month (free tier)

FALLBACK 2: OpenAI
  Model: gpt-3.5-turbo
  API Key: sk-[hidden]
  Cost: ~$2/month (conservative estimate)

FEATURES ENABLED:
  ✓ Streaming
  ✓ Function calling
  ✓ Long-term memory
  ✗ Vision (not needed)

ESTIMATED COST: $2/month (mostly Groq free tier)
FALLBACK BEHAVIOR: Auto-switch if primary fails

SECURITY:
  API keys stored in: System Keyring (Credential Manager)
  Data privacy: Local for Ollama, cloud for Groq/OpenAI
  Audit logging: Disabled

ACCEPTANCE: Ready to apply?"

User: "Yes"
```

### Phase 6: Setup (Auto-generate setup commands)

```
Agent: "🚀 SETUP INSTRUCTIONS

Step 1: Start Ollama (Local Primary)
───────────────────────────────────────
Download: https://ollama.ai
Start: ollama serve
Pull model: ollama pull neural-chat:7b
Test: curl http://localhost:11434/api/tags

Step 2: Store Cloud API Keys
───────────────────────────────────────
Groq API key (from https://groq.com):
  $ export GROQ_API_KEY=gsk-...

OpenAI API key (from https://platform.openai.com):
  $ export OPENAI_API_KEY=sk-...

Store securely:
  $ keyring set thoth groq gsk-...
  $ keyring set thoth openai sk-...

Step 3: Deploy Thoth
───────────────────────────────────────
$ cd thoth-docker-setup
$ docker-compose up -d

Step 4: Verify Setup
───────────────────────────────────────
Access: http://localhost:8080
Test primary (Ollama): <built-in test>
Test fallback 1 (Groq): <built-in test>
Test fallback 2 (OpenAI): <built-in test>

Step 5: Optional - Run Tests
───────────────────────────────────────
$ docker-compose exec thoth python -m tests.providers

Expected: All three providers test successfully

If Ollama fails: That's OK, fallbacks will work
If Groq fails: Check API key
If OpenAI fails: Check API key and budget

═════════════════════════════════════════════

Ready to start? Here are your files:

Generated files:
  ✓ ~/.thoth/config.yaml (provider configuration)
  ✓ .env (environment variables)
  ✓ setup_instructions.txt (this, saved)
  
Next: Follow steps 1-5 above"

User: "Can you save these to files?"

Agent: "✓ Saving configuration files...
  ~/.thoth/config.yaml
  .env
  setup_instructions.sh

✓ Saved! You can now:
  1. Run: cat setup_instructions.sh
  2. Follow the steps
  3. Or manually run each step

Need help with any step?"
```

---

## Agent Skill Definition

```json
{
  "name": "setup-thoth-llm-providers",
  "description": "Intelligent questionnaire to configure Thoth with optimal LLM provider setup including primary, fallback1, fallback2, API keys, and cost optimization",
  "category": "setup",
  "access_level": "interactive",
  "capabilities": [
    "Ask interactive questions",
    "Generate configuration files",
    "Store API keys securely (keyring)",
    "Create setup instructions",
    "Cost estimation",
    "Fallback strategy planning",
    "Privacy assessment"
  ],
  "inputs": {
    "user_preferences": "string (optional, pre-filled preferences)",
    "fast_mode": "boolean (optional, use defaults)",
    "use_cases": "array (optional, pre-selected)"
  },
  "outputs": {
    "config_yaml": "string (provider configuration)",
    "env_file": "string (environment variables)",
    "setup_instructions": "string (step-by-step guide)",
    "cost_estimate": "object (monthly cost breakdown)",
    "test_commands": "array (provider test commands)",
    "troubleshooting_guide": "string (FAQ and solutions)"
  },
  "questions": 20,
  "estimated_time": "3-5 minutes",
  "generates": [
    "~/.thoth/config.yaml",
    ".env",
    "setup_instructions.txt",
    "test_providers.sh"
  ]
}
```

---

## Specific Implementations Needed

### 1. Config Generator Function

```python
def generate_thoth_config(user_answers: Dict) -> Dict:
    """
    Generate optimal Thoth configuration based on user answers.
    
    Inputs:
      user_answers: {
        'primary_provider': 'ollama',
        'fallback1_provider': 'groq',
        'fallback2_provider': 'openai',
        'primary_model': 'neural-chat:7b',
        'fallback1_model': 'mixtral-8x7b-32768',
        'enable_streaming': True,
        'enable_function_calling': True,
        'use_cases': ['code_analysis', 'content_writing'],
        ...
      }
    
    Outputs:
      {
        'config_yaml': <generated YAML>,
        'env_file': <generated .env>,
        'estimated_cost': '$2/month',
        'setup_steps': [...],
        'tests': [...]
      }
    """
    # Implementation would:
    # 1. Validate provider availability
    # 2. Check model compatibility
    # 3. Estimate costs
    # 4. Generate config with proper defaults
    # 5. Create setup instructions
    # 6. Return generated files
```

### 2. API Key Storage Handler

```python
def store_api_key(provider: str, api_key: str):
    """
    Securely store API keys in system keyring.
    
    Supports:
      - macOS: Keychain
      - Windows: Credential Manager (via keyrings.alt)
      - Linux: Secret Service (GNOME/KDE)
    """
    # Implementation would use keyring library
    keyring.set_password('thoth', f'{provider}_api_key', api_key)
```

### 3. Provider Detection (Auto-run)

```python
def detect_providers() -> Dict[str, bool]:
    """
    Auto-detect what providers are accessible.
    
    Returns:
      {
        'ollama': True,      # Found locally running
        'lm_studio': True,   # Found installed
        'openai': False,     # No API key set
        'anthropic': False,  # No API key set
        'groq': False,       # No API key set
        ...
      }
    """
    # Check locally running services
    # Check installed tools
    # Check environment variables for API keys
    # Report findings to user
```

### 4. Cost Estimator

```python
def estimate_monthly_cost(config: Dict, usage_pattern: str) -> Dict:
    """
    Estimate monthly cost based on usage patterns.
    
    Usage patterns:
      - 'minimal': 10 requests/day
      - 'moderate': 100 requests/day
      - 'heavy': 1000 requests/day
    
    Returns:
      {
        'primary': '$0.00',  # Ollama (local, free)
        'fallback1': '$0.00',  # Groq free tier
        'fallback2': '$2.50',  # GPT-3.5-turbo
        'total': '$2.50/month'
      }
    """
    # Use known pricing:
    # Groq: $0.0005-0.02 per 1K tokens
    # OpenAI: $0.0005-0.03 per 1K tokens
    # etc.
```

### 5. Configuration Validator

```python
def validate_configuration(config: Dict) -> Tuple[bool, List[str]]:
    """
    Validate configuration before saving.
    
    Checks:
      - All providers exist and are accessible
      - API keys are present for cloud providers
      - Models are supported by each provider
      - Fallback chain makes sense
      - No circular dependencies
    
    Returns:
      (is_valid, [list of warnings])
    """
```

### 6. Setup Instruction Generator

```python
def generate_setup_instructions(config: Dict, os_type: str) -> str:
    """
    Generate OS-specific setup instructions.
    
    For each provider:
      1. Download/install link
      2. Configuration steps
      3. API key setup
      4. Verification commands
      5. Troubleshooting tips
    
    OS-specific variations:
      - macOS: Use Keychain, host.docker.internal
      - Windows: Use Credential Manager, WSL2 paths
      - Linux: Use Secret Service, local IP
    """
```

---

## Integration with Existing Setup

```bash
# Option 1: After setup.sh
./setup.sh
./setup-llm-providers.sh
docker-compose up -d

# Option 2: Integrated into Claude Code
"Set up Thoth with my LLM providers"
Agent: [runs full questionnaire workflow]

# Option 3: Web UI (Phase 2)
http://localhost:8080/setup/providers
[interactive form with all questions]
```

---

## Testing the Questionnaire

```bash
# Run in dry-run mode
python agent_questionnaire.py --dry-run

# Run with example answers
python agent_questionnaire.py --scenario "code_analyst_budget_conscious"

# Test specific provider combination
python agent_questionnaire.py --providers ollama,groq,openai

# Generate test report
python agent_questionnaire.py --test > report.txt
```

---

## Success Criteria

✅ User gets specific setup instructions for their chosen providers
✅ Configuration is optimal for their use case and budget
✅ API keys are stored securely
✅ Fallback chain works as expected
✅ Cost is clearly communicated upfront
✅ Privacy/security aligned with their needs
✅ Setup can be completed in 3-5 minutes
✅ All generated files are correct YAML/env format

---

## Next Steps to Implement

1. [ ] Create `agent_questionnaire.py` with core logic
2. [ ] Implement provider detection
3. [ ] Implement config generation
4. [ ] Implement cost estimation
5. [ ] Integrate with Claude Code agent skill
6. [ ] Test on all three platforms (macOS, Windows, Linux)
7. [ ] Create web UI (Phase 2)
8. [ ] Add telemetry to understand user choices

---

## Summary: What This Enables

✅ **For Users:**
- Smart recommendations (don't have to figure it out)
- Cost transparency upfront
- Automatic API key management
- Multi-provider resilience
- Privacy-respecting setup
- Step-by-step instructions

✅ **For Thoth:**
- Optimal provider selection
- Intelligent fallback configuration
- Cost-effective resource usage
- Privacy and security by default
- Automatic testing and validation

✅ **For Operations:**
- Reduced setup time (5 min vs 30-60 min manual)
- Fewer support questions
- Consistent configurations
- Better cost predictability
- Secure key management
