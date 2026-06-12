# OpenRouter Setup Guide for Row-Bot

**For users without a local LLM provider**

---

## Quick Options Summary

**Don't know what to choose? Pick one:**

| Option | Cost | Setup Time | Privacy | Best For |
|--------|------|-----------|---------|----------|
| **Local Ollama** | Free | 10 min | ✅ Excellent | Private data, offline work |
| **OpenRouter + $5 credit** | $5 | 5 min | ⚠️ Good (paid models) | Quick start, most users |
| **OpenRouter Free** | Free | 5 min | ❌ Poor | Testing only, demos |
| **OpenAI ChatGPT Plus** | $20/mo | 5 min | ⚠️ Good | If already subscriber |

**Recommendation for most users:** OpenRouter with $5+ credit + Claude 3 Haiku

---

## What is OpenRouter?

OpenRouter is a **proxy service** that provides unified access to multiple LLM models:
- Claude (Anthropic)
- GPT-4 (OpenAI)
- Llama (Meta)
- Mistral
- And many others

**Key advantage:** Choose different models, compare speeds and costs, all through one API.

---

## Privacy & Data Considerations ⚠️

### ⚠️ CRITICAL WARNING — Data Usage

**Free and Pay-as-You-Go Models:**

OpenRouter offers two pricing tiers:
1. **Free Models** (Llama 2, Mistral, etc.)
2. **Paid Models** (Claude, GPT-4, etc.)

**If using FREE models:**
- ⚠️ **Your prompts MAY be used for provider training**
- ⚠️ **Your conversations MAY be logged by the provider**
- ⚠️ **Sensitive data could be exposed** (credentials, personal info, proprietary code)

**Recommendation:** Use paid models if handling sensitive data.

### 📊 What Gets Sent

When using OpenRouter with Row-Bot:
- ✅ Your prompts/questions
- ✅ Your conversation context
- ⚠️ **May be logged** (depends on model)
- ⚠️ **May be used for training** (free models often are)

**NOT sent:**
- Your local files (unless you paste them)
- Your identity (just API key)
- Your Row-Bot configuration

---

## Quick Setup (5 minutes)

### Step 1: Create OpenRouter Account

1. Go to https://openrouter.ai
2. Sign up with email or Google account
3. Verify your email

⚠️ **Important:** Free signup has VERY limited usage. Add credits for practical use.

### Step 2: Add Payment Method (Recommended)

OpenRouter free signup alone is too limited. Add credits for real usage:

**Option A: Pay-as-You-Go (Recommended)**

1. Click "Billing" or "Account Settings"
2. Add credit card
3. **Recommended:** Add $5 USD credit minimum
   - Sufficient for ~1,000 requests with Claude 3 Haiku
   - ~500 requests with Claude 3 Sonnet
   - ~50 requests with GPT-4
4. Set up spending alerts if available

**Option B: Free Routing (Limited, Testing Only)**

OpenRouter offers a free routing option: `openrouter/openrouter:free`
- ⚠️ **Use only for testing**, not production or private data
- ⚠️ **Much slower** than paid models
- ⚠️ **Data logging likely** — free tier models usually train on data
- ✅ Good for: Trying Row-Bot, non-sensitive work, demos

To use free routing:
```bash
```

**Recommended:** Combine both — $5 credits + free routing fallback

**Cost Examples:**
- Claude 3 Haiku: $0.0015 per 1K input tokens
- Claude 3 Sonnet: $0.003 per 1K input tokens
- GPT-4 Turbo: $0.01 per 1K input tokens

### Step 3: Generate API Key

1. Click on your profile (top right)
2. Select "Keys"
3. Click "Create Key"
4. Copy the key (starts with `sk-or-...`)
5. Keep it secret!

### Step 4: Configure Row-Bot

**Edit `.env`:**

```bash
# OpenRouter Configuration
OPENROUTER_API_KEY=sk-or-your-key-here

# Set Row-Bot to use OpenRouter
# Then pick the provider and model inside Row-Bot: Settings → Models
```

**Or update in Row-Bot UI:**
- Settings → LLM Provider → OpenAI (OpenRouter compatible)
- API Key: Your OpenRouter key
- Base URL: `https://openrouter.ai/api/v1`

---

## Model Recommendations

### ✅ Best for Privacy (Paid)

| Model | Cost | Speed | Quality | Privacy |
|-------|------|-------|---------|---------|
| Claude 3 Haiku | $0.25/M tokens | ⚡⚡ Fast | Good | ✅ Best |
| Claude 3 Sonnet | $0.75/M tokens | ⚡⚡ Fast | Excellent | ✅ Best |
| GPT-4 Turbo | $1.50/M tokens | ⚡ Medium | Excellent | ⚠️ Good |

### ⚠️ Free Options (Not Recommended for Private Data)

| Model | Cost | Speed | Quality | Privacy | Use Case |
|-------|------|-------|---------|---------|----------|
| openrouter/openrouter:free | Free (with credits) | ⚡ Slow | Fair | ❌ Data likely logged | Testing only |
| Llama 2 13B | Free | ⚡⚡⚡ Fast | Fair | ❌ Data may be logged | Demos, non-sensitive |
| Mistral 7B | Free | ⚡⚡⚡ Fast | Fair | ❌ Data may be logged | Demos, non-sensitive |
| Neural Chat | Free | ⚡⚡⚡ Fast | Fair | ❌ Data may be logged | Demos, non-sensitive |

**Note:** OpenRouter free routing (`openrouter:free`) routes requests through free models. Very slow but good for testing if you've bought credits.

---

## How Much Will It Cost?

### Example Usage Patterns

**Light Use (1 hour/day):**
- ~50,000 tokens/day
- Claude 3 Haiku: ~$0.06/day = ~$2/month
- Budget: $5 credit = ~3 months

**Medium Use (4 hours/day):**
- ~200,000 tokens/day
- Claude 3 Haiku: ~$0.25/day = ~$7/month
- Budget: $5 credit = ~3 weeks

**Heavy Use (8+ hours/day):**
- ~500,000+ tokens/day
- Claude 3 Sonnet: ~$0.75/day = ~$22/month
- Budget: $5 credit = ~1 week

---

## Step-by-Step Configuration

### Option A: Use Row-Bot Web UI

1. Start Row-Bot: `docker-compose up -d`
2. Open http://localhost:8080
3. Settings → LLM Provider
4. Select: **OpenAI** (this works with OpenRouter)
5. Configure:
   - **API Key:** Your OpenRouter key
   - **Base URL:** `https://openrouter.ai/api/v1`
   - **Model:** `anthropic/claude-3-haiku`
6. Test connection
7. Done!

### Option B: Edit .env File

```bash
# Edit .env
nano .env

# Add or update:
OPENROUTER_API_KEY=sk-or-your-actual-key-here
# Then pick the provider and model inside Row-Bot: Settings → Models

# Save (Ctrl+X, Y, Enter)

# Restart Row-Bot
docker-compose restart
```

### Option C: Edit in Container

```bash
docker-compose exec rowbot nano /home/rowbot/.row-bot/config.yaml

# Update the provider section to point to OpenRouter
# Save and exit

docker-compose restart rowbot
```

---

## Verify It's Working

```bash
# Check logs
docker-compose logs rowbot | grep -i "provider\|openrouter"

# Test in Row-Bot UI
# Settings → Test Connection

# Or from command line
docker-compose exec rowbot curl -X POST https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer sk-or-your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-haiku",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## FAQ

### Q: Is OpenRouter Safe?

**A:** OpenRouter itself is legitimate, but:
- ✅ Traffic is encrypted (HTTPS)
- ✅ Your key is not stored in Row-Bot
- ⚠️ Your prompts go to OpenRouter's servers
- ⚠️ Free models may log/train on data
- ✅ Paid models typically have better privacy (see provider policies)

### Q: Which Provider Should I Use?

**Best Privacy:** Anthropic Claude (paid, best privacy practices)  
**Best Value:** Claude 3 Haiku (cheapest Claude option)  
**Fastest Free:** Mistral 7B (but data may be logged)

### Q: Can I Switch Models Later?

**Yes!** Change in `.env` or Row-Bot UI anytime. Just restart Row-Bot.

### Q: What If I Run Out of Credit?

OpenRouter will refuse requests. Add more credit in your account.

### Q: Can I Use Multiple Providers?

**Yes!** Row-Bot supports fallback chains:
- Primary: OpenRouter (Claude 3 Haiku)
- Fallback: Groq Free (Mixtral)
- Fallback: Local Ollama (if available)

---

## Privacy Best Practices

### ✅ DO

- [x] Use paid models for sensitive/proprietary data
- [x] Review OpenRouter's privacy policy
- [x] Keep your API key secret
- [x] Rotate keys periodically
- [x] Monitor your OpenRouter usage/costs

### ❌ DON'T

- [ ] Use free models for sensitive data
- [ ] Share your API key
- [ ] Paste credentials or API keys in prompts
- [ ] Use free models with proprietary code
- [ ] Trust that prompts aren't logged

---

## Provider Privacy Policies

**Before using, review:**

| Provider | Policy Link | Notes |
|----------|------------ |-------|
| Anthropic | https://www.anthropic.com/privacy | Strong privacy protections |
| OpenAI | https://openai.com/privacy | May use data for training (check terms) |
| Meta (Llama) | https://www.meta.com/privacy | Depends on free vs paid |

---

## Troubleshooting

### Issue: "Invalid API Key"

- Check key is copied correctly
- Verify it's from OpenRouter, not another service
- Ensure it starts with `sk-or-`

### Issue: "Rate Limited"

- OpenRouter has rate limits on free tier
- Add payment method for higher limits
- Switch to paid model for more requests

### Issue: "Model Not Found"

- Check model name is correct
- List available models: https://openrouter.ai/models
- Use format: `provider/model-name`

### Issue: "Quota Exceeded"

- You've used your monthly budget
- Add more credit in OpenRouter dashboard
- Or switch to a cheaper model

---

## Alternative Cloud Providers

### OpenAI ChatGPT Plus ($20/month)

⚠️ **Important Note (2026-05-25):** OpenAI currently allows ChatGPT Plus subscribers to access API without separate API credits. **This offering may change or be discontinued.** Verify current status at https://openai.com

**If still available:**
- $20/month ChatGPT Plus membership
- No separate API credit required
- Access to GPT-4 and latest models
- Configuration similar to standard OpenAI API

**⚠️ Caveats:**
- May not be supported in future OpenAI versions
- Check OpenAI documentation before relying on this
- Data goes to OpenAI servers (review their privacy policy)
- Monthly subscription vs pay-as-you-go

---

## Local LLM (Free, Private)

**Best:** Install Ollama
```bash
# Download from https://ollama.ai
# Run: ollama serve
# Pull a model: ollama pull llama2
# Configure Row-Bot to use local Ollama
```

**Other options:**
- LM Studio (GUI for local models)
- vLLM (fast inference server)
- llama.cpp (lightweight)

### Other Cloud Providers

| Provider | Cost | Privacy | Setup |
|----------|------|---------|-------|
| Groq (Free) | Free | Medium | Simple |
| Hugging Face | Pay-as-you-go | Good | Simple |
| Replicate | Pay-as-you-go | Good | Simple |

---

## Cost Control Tips

1. **Start Small**
   - Buy $5 credit
   - Test with Haiku (cheapest Claude)
   - Monitor usage daily

2. **Set Alerts**
   - OpenRouter dashboard shows spending
   - Set budget limits if available
   - Check costs weekly

3. **Use Efficient Models**
   - Haiku for simple tasks (~$0.06 per 1M tokens)
   - Sonnet for complex tasks (~$0.18 per 1M tokens)
   - GPT-4 only when needed (~$0.30 per 1M tokens)

4. **Cache When Possible**
   - Row-Bot caches responses
   - Reusing cached results is free
   - Reduces API calls

---

## Summary

✅ **OpenRouter is a good bridge solution** if you don't have a local LLM

⚠️ **Privacy Warning:**
- Free models: Data may be logged/trained on
- Paid models: Better privacy (but check provider policy)
- **Recommendation:** Use paid models for sensitive work

💰 **Cost Estimate:**
- $5 credit = ~3 months light use with Haiku
- Best value: Claude 3 Haiku at $0.0015 per 1K tokens

🎯 **Best Choice:**
- Light/casual use → Claude 3 Haiku (affordable, private)
- Sensitive data → Claude 3 Sonnet (excellent quality + privacy)
- Free tier → Groq (actually free, no credit card needed)

---

**Next Step:** Set up your OpenRouter account and add your key to Row-Bot!

For more info: https://openrouter.ai/docs
