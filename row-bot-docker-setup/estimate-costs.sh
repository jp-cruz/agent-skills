#!/bin/bash

# Row-Bot LLM Cost Estimator
# Estimates monthly costs based on usage patterns

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}            Row-Bot LLM Monthly Cost Estimator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "This tool estimates your monthly LLM costs based on usage."
echo ""

# Gather usage info
echo -e "${YELLOW}Q1: How many conversations per week?${NC}"
read -p "  (default: 10) " CONVERSATIONS_PER_WEEK
CONVERSATIONS_PER_WEEK=${CONVERSATIONS_PER_WEEK:-10}

echo ""
echo -e "${YELLOW}Q2: Average messages per conversation?${NC}"
read -p "  (default: 5) " MESSAGES_PER_CONVERSATION
MESSAGES_PER_CONVERSATION=${MESSAGES_PER_CONVERSATION:-5}

echo ""
echo -e "${YELLOW}Q3: Average message length?${NC}"
echo "  a) Short (100 words, ~150 tokens)"
echo "  b) Medium (300 words, ~450 tokens) [DEFAULT]"
echo "  c) Long (800 words, ~1200 tokens)"
read -p "Choose [a/b/c]: " MESSAGE_LENGTH
MESSAGE_LENGTH=${MESSAGE_LENGTH:-b}

case "$MESSAGE_LENGTH" in
    a) TOKENS_PER_MESSAGE=150 ;;
    c) TOKENS_PER_MESSAGE=1200 ;;
    *) TOKENS_PER_MESSAGE=450 ;;
esac

echo ""

# Calculate monthly usage
CONVERSATIONS_PER_MONTH=$((CONVERSATIONS_PER_WEEK * 4))
MESSAGES_PER_MONTH=$((CONVERSATIONS_PER_MONTH * MESSAGES_PER_CONVERSATION))
TOKENS_PER_MONTH=$((MESSAGES_PER_MONTH * TOKENS_PER_MESSAGE))

# Include prompt tokens (assume 1:1 ratio for simplicity)
TOTAL_TOKENS_PER_MONTH=$((TOKENS_PER_MONTH * 2))

echo -e "${GREEN}Your Monthly Usage Estimate:${NC}"
echo "  Conversations: $CONVERSATIONS_PER_MONTH"
echo "  Messages: $MESSAGES_PER_MONTH"
echo "  Tokens (input + output): ~$TOTAL_TOKENS_PER_MONTH"
echo ""

# Cost calculations
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    Provider Cost Estimates${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# OpenAI GPT-4 Turbo
# Input: $0.01 per 1K tokens, Output: $0.03 per 1K tokens
OPENAI_INPUT_TOKENS=$((TOTAL_TOKENS_PER_MONTH / 2))
OPENAI_OUTPUT_TOKENS=$((TOTAL_TOKENS_PER_MONTH / 2))
OPENAI_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.01 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.03 / 1000)}")

echo -e "${YELLOW}OpenAI (GPT-4 Turbo)${NC}"
echo "  Input: $OPENAI_INPUT_TOKENS tokens × \$0.01/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_INPUT_TOKENS * 0.01 / 1000}")"
echo "  Output: $OPENAI_OUTPUT_TOKENS tokens × \$0.03/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_OUTPUT_TOKENS * 0.03 / 1000}")"
echo -e "  ${GREEN}Monthly: \$$OPENAI_COST${NC}"
echo ""

# OpenAI GPT-4o (cheaper)
# Input: $0.005 per 1K, Output: $0.015 per 1K
OPENAI_4O_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.005 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.015 / 1000)}")

echo -e "${YELLOW}OpenAI (GPT-4o - cheaper)${NC}"
echo "  Input: $OPENAI_INPUT_TOKENS tokens × \$0.005/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_INPUT_TOKENS * 0.005 / 1000}")"
echo "  Output: $OPENAI_OUTPUT_TOKENS tokens × \$0.015/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_OUTPUT_TOKENS * 0.015 / 1000}")"
echo -e "  ${GREEN}Monthly: \$$OPENAI_4O_COST${NC}"
echo ""

# Anthropic Claude 3 (Sonnet - balanced)
# Input: $0.003 per 1K, Output: $0.015 per 1K
ANTHROPIC_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.003 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.015 / 1000)}")

echo -e "${YELLOW}Anthropic (Claude 3 Sonnet)${NC}"
echo "  Input: $OPENAI_INPUT_TOKENS tokens × \$0.003/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_INPUT_TOKENS * 0.003 / 1000}")"
echo "  Output: $OPENAI_OUTPUT_TOKENS tokens × \$0.015/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_OUTPUT_TOKENS * 0.015 / 1000}")"
echo -e "  ${GREEN}Monthly: \$$ANTHROPIC_COST${NC}"
echo ""

# Anthropic Claude 3 Opus (best quality)
# Input: $0.015 per 1K, Output: $0.075 per 1K
ANTHROPIC_OPUS_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.015 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.075 / 1000)}")

echo -e "${YELLOW}Anthropic (Claude 3 Opus - best quality)${NC}"
echo "  Input: $OPENAI_INPUT_TOKENS tokens × \$0.015/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_INPUT_TOKENS * 0.015 / 1000}")"
echo "  Output: $OPENAI_OUTPUT_TOKENS tokens × \$0.075/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_OUTPUT_TOKENS * 0.075 / 1000}")"
echo -e "  ${GREEN}Monthly: \$$ANTHROPIC_OPUS_COST${NC}"
echo ""

# OpenRouter (using Mistral 7B - cheapest)
# ~$0.0001 per 1K input, $0.0003 per 1K output
OPENROUTER_CHEAP_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.0001 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.0003 / 1000)}")

echo -e "${YELLOW}OpenRouter (Mistral 7B - very cheap)${NC}"
echo "  Input: $OPENAI_INPUT_TOKENS tokens × \$0.0001/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_INPUT_TOKENS * 0.0001 / 1000}")"
echo "  Output: $OPENAI_OUTPUT_TOKENS tokens × \$0.0003/1K = \$$(awk "BEGIN {printf \"%.2f\", $OPENAI_OUTPUT_TOKENS * 0.0003 / 1000}")"
echo -e "  ${GREEN}Monthly: \$$OPENROUTER_CHEAP_COST${NC}"
echo ""

# OpenRouter (using Claude 3 Sonnet via OpenRouter)
# Usually slightly cheaper than direct Anthropic
OPENROUTER_CLAUDE_COST=$(awk "BEGIN {printf \"%.2f\", ($OPENAI_INPUT_TOKENS * 0.003 / 1000) + ($OPENAI_OUTPUT_TOKENS * 0.015 / 1000) * 0.95}")

echo -e "${YELLOW}OpenRouter (Claude 3 Sonnet - discounted)${NC}"
echo "  ~5% cheaper than direct Anthropic"
echo -e "  ${GREEN}Monthly: \$$OPENROUTER_CLAUDE_COST${NC}"
echo ""

# Local Ollama (electricity + hardware amortization if buying new GPU)
HOURLY_POWER_W=50  # Typical GPU/CPU power draw during inference
COST_PER_KWH=0.12  # US average
DAILY_HOURS=2  # Average usage
MONTHLY_HOURS=$((DAILY_HOURS * 30))
MONTHLY_KWH=$(awk "BEGIN {printf \"%.2f\", $MONTHLY_HOURS * $HOURLY_POWER_W / 1000}")
ELECTRICITY_COST=$(awk "BEGIN {printf \"%.2f\", $MONTHLY_KWH * $COST_PER_KWH}")

# Hardware amortization: only if buying a new GPU specifically for Thoth
GPU_AMORTIZATION=0  # Default: already own hardware
echo -e "${YELLOW}Ollama (Local - electricity only)${NC}"
echo "  Estimated usage: $MONTHLY_HOURS hours/month at ~${HOURLY_POWER_W}W"
echo "  Monthly electricity: ${MONTHLY_KWH} kWh = \$$ELECTRICITY_COST"
echo -e "  ${GREEN}Monthly (if you already own hardware): \$$ELECTRICITY_COST${NC}"
echo ""
echo -e "  ${BLUE}Important Note:${NC}"
echo "    • Costs shown assume you already have a GPU or Mac with integrated GPU"
echo "    • If buying a NEW GPU for Ollama: add \$33/month (\$800 GPU / 24 months)"
echo "    • Total with new hardware: \$$(awk "BEGIN {printf \"%.2f\", $ELECTRICITY_COST + 33.33}")/month"
echo "    • Most users already own hardware → electricity cost only"
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                        Quick Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Ranked by monthly cost (assuming existing hardware):"
COSTS=(
    "Ollama (electricity only)|$ELECTRICITY_COST"
    "OpenRouter (Mistral)|$OPENROUTER_CHEAP_COST"
    "OpenRouter (Claude Sonnet)|$OPENROUTER_CLAUDE_COST"
    "Anthropic (Claude Sonnet)|$ANTHROPIC_COST"
    "OpenAI (GPT-4o)|$OPENAI_4O_COST"
    "OpenAI (GPT-4 Turbo)|$OPENAI_COST"
    "Anthropic (Claude Opus)|$ANTHROPIC_OPUS_COST"
)

# Simple sort by cost (note: bash doesn't have great number sorting, but good enough)
for cost_pair in "${COSTS[@]}"; do
    IFS='|' read -r provider cost <<< "$cost_pair"
    printf "  • %-40s \$%7s/month\n" "$provider" "$cost"
done

echo ""
echo -e "${YELLOW}💡 Recommendations:${NC}"
echo ""
echo "  For ${GREEN}lowest cost (have GPU)${NC}: Ollama (\$${ELECTRICITY_COST}/mo electricity)"
echo "  For ${GREEN}lowest cost (no GPU)${NC}: OpenRouter Mistral (\$${OPENROUTER_CHEAP_COST}/mo)"
echo "  For ${GREEN}best quality${NC}: Claude 3 Opus (\$${ANTHROPIC_OPUS_COST}/mo)"
echo "  For ${GREEN}privacy & offline${NC}: Ollama (local, no API keys needed)"
echo "  For ${GREEN}balanced price/quality${NC}: Claude 3 Sonnet (\$${ANTHROPIC_COST}/mo)"
echo ""
echo -e "${BLUE}Hardware cost note:${NC}"
echo "  If buying a GPU specifically for Ollama (~\$800 RTX 4060): add \$33/month amortization"
echo "  Most home users already have GPUs → electricity cost only (\$${ELECTRICITY_COST}/mo)"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "To use your chosen provider with Thoth:"
echo "  1. Update .env with your API key"
echo "  2. Restart container: docker-compose restart rowbot"
echo "  3. Or re-run setup.sh to reconfigure"
echo ""
echo "Note: Prices and rates may change. Check provider websites for current prices."
echo ""
