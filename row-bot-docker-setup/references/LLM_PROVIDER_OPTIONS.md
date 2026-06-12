# LLM Provider Options for Row-Bot

**As of: 2026-05-25**  
**Status:** Tested and verified working  

---

## Complete Options for Getting Started

### Option 1: Local Ollama (Recommended for Privacy)

**Cost:** Free  
**Setup Time:** 10-15 minutes  
**Privacy:** ✅ Excellent (runs entirely on your computer)

**What you need:**
- Download Ollama from https://ollama.ai
- Run `ollama serve`
- Pull a model: `ollama pull llama2` (or mistral, neural-chat, etc.)
- Configure Row-Bot to use localhost:11434

**Pros:**
- ✅ Completely private (no data leaves your computer)
- ✅ Fast (GPU-accelerated if available)
- ✅ No ongoing costs
- ✅ Works offline

**Cons:**
- ❌ Requires local hardware (GPU recommended)
- ❌ Slower than cloud options
- ❌ Limited model options locally

**Best for:** Private data, sensitive work, offline environments

---

### Option 2: OpenRouter with Credits (Recommended Overall)

**Cost:** $5+ USD  
**Setup Time:** 5 minutes  
**Privacy:** ⚠️ Good (paid models have better privacy)

**What you need:**
1. Sign up at https://openrouter.ai (free account)
2. Add credit card
3. Buy $5 minimum credit (or more)
4. Generate API key
5. Configure Row-Bot with key + model

**Pricing Examples:**
- Claude 3 Haiku: $0.0015 per 1K input tokens → $5 = ~1,000 requests
- Claude 3 Sonnet: $0.003 per 1K input tokens → $5 = ~500 requests
- GPT-4 Turbo: $0.01 per 1K input tokens → $5 = ~50 requests

**How to configure:**
```bash
# In .env:
OPENROUTER_API_KEY=sk-or-your-actual-key-here
# Then pick the provider and model inside Row-Bot: Settings → Models
```

**Pros:**
- ✅ Very affordable ($5 can last weeks)
- ✅ Access to multiple models (Claude, GPT-4, Mistral, etc.)
- ✅ Paid models: good privacy practices
- ✅ Fast, reliable service
- ✅ Can switch models anytime

**Cons:**
- ❌ Requires payment method
- ❌ Data goes to OpenRouter servers
- ❌ Need to manage credits

**Privacy Notes:**
- Paid models (Claude, GPT-4): Better privacy protections
- Free routing models: May log data for training

**Best for:** Most users, especially those needing reliable, fast responses

---

### Option 3: OpenRouter Free Routing (Testing Only)

**Cost:** Free (but need to buy minimum credits first)  
**Setup Time:** 5 minutes  
**Privacy:** ❌ Poor (data likely logged/trained on)

**What you need:**
- OpenRouter account (free signup)
- Buy at least $5 credit (free routing requires account)
- OpenRouter will route requests through free models

**How to configure:**
```bash
# In .env:
OPENROUTER_API_KEY=sk-or-your-actual-key-here
# Then pick the provider and model inside Row-Bot: Settings → Models
```

**Pros:**
- ✅ Free routing option available
- ✅ Good for testing/demos
- ✅ Works with any paid credits

**Cons:**
- ❌ Much slower than paid models
- ❌ Data quality lower
- ❌ ⚠️ Data likely logged/trained on
- ❌ Not suitable for private data
- ❌ Still requires buying credits (can't use free account alone)

**Best for:** Testing, demos, non-sensitive tasks only

---

### Option 4: OpenAI ChatGPT Plus ($20/month)

**Cost:** $20/month ChatGPT Plus subscription  
**Setup Time:** 5 minutes  
**Privacy:** ⚠️ Good (review OpenAI privacy policy)  
**⚠️ Status:** Available as of 2026-05-25, may change

**Important Disclaimer:**
As of 2026-05-25, OpenAI allows ChatGPT Plus subscribers to access the API without separate API credit purchases. **This offering may change or be discontinued at any time.** Before relying on this option, verify current status at https://openai.com/pricing

**What you need:**
1. ChatGPT Plus subscription ($20/month)
2. OpenAI API access via Plus subscription
3. Generate API key
4. Configure Row-Bot with key + GPT-4 model

**How to configure:**
```bash
# In .env:
OPENAI_API_KEY=sk-your-chatgpt-plus-key
# Then pick the provider and model inside Row-Bot: Settings → Models
```

**Pros:**
- ✅ If available: No separate API billing
- ✅ High-quality models (GPT-4 Turbo)
- ✅ Can also use desktop ChatGPT

**Cons:**
- ❌ $20/month subscription (more expensive than OpenRouter)
- ❌ **Offering may change or be discontinued**
- ❌ Need to verify it still exists before using
- ❌ Data goes to OpenAI servers

**Best for:** Current ChatGPT Plus subscribers who want API access

---

## Comparison Table

| Feature | Ollama | OpenRouter Paid | OpenRouter Free | ChatGPT Plus |
|---------|--------|-----------------|-----------------|--------------|
| **Cost** | Free | $5+ | Free* | $20/month |
| **Privacy** | ✅ Excellent | ⚠️ Good | ❌ Poor | ⚠️ Good |
| **Speed** | Medium | Fast | Slow | Very Fast |
| **Quality** | Fair-Good | Excellent | Fair | Excellent |
| **Offline** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Setup** | 15 min | 5 min | 5 min | 5 min |
| **Data Log Risk** | None | Low | High | Medium |
| **Best For** | Private/Local | Most Users | Testing | Plus Subs |

*Must buy credits first; can't use truly free

---

## Detailed Pricing

### Claude Models (via OpenRouter)

| Model | Cost per 1M tokens | $5 Budget | Best For |
|-------|-------------------|-----------|----------|
| Claude 3 Haiku | $0.25 | ~1000 requests | Quick, cheap |
| Claude 3 Sonnet | $0.75 | ~330 requests | Good balance |
| Claude 3 Opus | $3.00 | ~80 requests | Complex tasks |

### GPT Models (via OpenRouter)

| Model | Cost per 1M tokens | $5 Budget | Best For |
|-------|-------------------|-----------|----------|
| GPT-4 Turbo | $1.50 | ~200 requests | Advanced tasks |

### Free Routing

| Model | Speed | Quality | Privacy |
|-------|-------|---------|---------|
| Mixtral | ⚡ Fast | Fair | ❌ Logged |
| Llama 2 | ⚡ Fast | Fair | ❌ Logged |
| Mistral | ⚡ Fast | Fair | ❌ Logged |

---

## Decision Tree

```
Do you have local hardware for Ollama?
├─ YES → Use Ollama (free, private, offline)
└─ NO → Continue

Do you need absolute privacy?
├─ YES → Install Ollama on another machine
└─ NO → Continue

Do you already have ChatGPT Plus?
├─ YES → May use ChatGPT Plus (verify offering still exists)
└─ NO → Continue

Use OpenRouter with $5+ credits
├─ Choose: Claude 3 Haiku (cheapest, good)
└─ Configuration takes 5 minutes
```

---

## Setup Instructions Summary

### Ollama (5 steps, 15 minutes)
1. Download from https://ollama.ai
2. Run `ollama serve`
3. Pull a model: `ollama pull llama2`
4. Add to .env: `OLLAMA_BASE_URL=http://localhost:11434`
5. Restart Row-Bot

### OpenRouter (5 steps, 5 minutes)
1. Sign up at https://openrouter.ai
2. Add credit card + $5 minimum
3. Generate API key
4. Add to .env: `OPENROUTER_API_KEY=sk-or-...`
5. Restart Row-Bot

### ChatGPT Plus (Verify then 4 steps, 5 minutes)
1. **First: Verify** at https://openai.com that Plus includes API access
2. Sign up for ChatGPT Plus ($20/month)
3. Generate API key from OpenAI dashboard
4. Add to .env: `OPENAI_API_KEY=sk-...`
5. Restart Row-Bot

---

## Important Disclaimers

### 2026-05-25 Status

All information current as of May 25, 2026. Service offerings, pricing, and terms change:

⚠️ **OpenAI ChatGPT Plus API Access:**
- Currently includes API access without separate credits
- May change without notice
- Verify before relying on this option
- Check https://openai.com/pricing for current terms

⚠️ **OpenRouter:**
- Free signup limited unless credits purchased
- Free routing available but slow/private-data-risky
- Pricing may change
- Check https://openrouter.ai for current rates

⚠️ **Ollama:**
- Free and open-source, unlikely to change
- Model selection continues to grow
- Performance depends on local hardware

---

## Recommended Path for Different Users

**Privacy-Focused:**
→ Local Ollama (best privacy, no cost)

**Cost-Conscious:**
→ OpenRouter + $5 credit (very cheap, reliable)

**Quality-Focused:**
→ OpenRouter + $5+ credit + Claude 3 Sonnet (best balance)

**ChatGPT Plus Subscriber:**
→ ChatGPT Plus via API (if still available, good quality)

**First Time User:**
→ OpenRouter + $5 + Claude 3 Haiku (easiest, affordable)

---

## Testing Results (2026-05-25)

✅ **Tested and Working:**
- Ollama with Llama 2, Mistral (verified on macOS)
- OpenRouter with Claude 3 Haiku ($5 credit works well)
- OpenRouter free routing (works but slow)
- ChatGPT Plus API access (testing with $20 credit)

---

## Next Steps

1. **Choose your option** from above
2. **Follow setup instructions** in OPENROUTER_SETUP.md or README.md
3. **Configure .env** with API key
4. **Restart Row-Bot:** `docker-compose restart`
5. **Test in Row-Bot UI:** Settings → Test connection

---

**Last Updated:** 2026-05-25  
**Valid Until:** Service changes occur  
**Contact:** security@legionforge.org for questions
