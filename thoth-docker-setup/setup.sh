#!/bin/bash

# Thoth Docker Smart Setup
# Asks intelligent questions about your needs: privacy, cost, hardware
# Creates optimized .env configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

echo "🐳 Thoth Docker Setup"
echo "===================="
echo ""

# Check if .env exists already
if [ -f "$ENV_FILE" ]; then
    echo "✓ .env already exists (skipping creation)"
    echo ""
    # Still run basic checks
else
    echo "Creating .env configuration..."
    echo ""

    # === NETWORK QUESTION ===
    echo "Q1: How do you want to access Thoth?"
    echo "   a) Just on this computer (most secure) [DEFAULT]"
    echo "   b) From other machines on my home network"
    echo "   c) From the internet (requires reverse proxy)"
    read -p "Choose [a/b/c]: " network_choice
    network_choice=${network_choice:-a}

    case "$network_choice" in
        b)
            THOTH_BIND="0.0.0.0"
            echo "   ℹ️ Warning: Network-accessible without authentication"
            echo "      See references/NETWORK_SETUP.md for security hardening"
            ;;
        c)
            THOTH_BIND="127.0.0.1"
            echo "   ℹ️ Internet access requires reverse proxy (Nginx, Cloudflare, etc.)"
            echo "      See references/NETWORK_SETUP.md for detailed setup"
            ;;
        *)
            THOTH_BIND="127.0.0.1"
            echo "   ✓ Localhost only (most secure)"
            ;;
    esac
    echo ""

    # === PRIVACY/LLM QUESTION ===
    echo "Q2: What matters most for language models?"
    echo "   a) Privacy & local processing (use Ollama locally)"
    echo "   b) Cost savings (cloud provider is cheaper)"
    echo "   c) Quality & speed (best models available)"
    echo "   d) Don't know / show me the options [DEFAULT]"
    read -p "Choose [a/b/c/d]: " llm_choice
    llm_choice=${llm_choice:-d}

    echo ""

    # Check hardware capability for Ollama
    RAM_GB=$(free -g 2>/dev/null | awk 'NR==2 {print $2}' || \
             vm_stat 2>/dev/null | grep "Pages free:" | awk '{print int($3/256000)}' || \
             echo "unknown")

    case "$llm_choice" in
        a)
            echo "Privacy & Local Processing"
            echo ""
            echo "Ollama runs on your machine — data never leaves your computer"
            echo "Model selection depends on your hardware:"

            if [ "$RAM_GB" != "unknown" ] && [ "$RAM_GB" -lt 8 ]; then
                echo "⚠️ Your system has ~${RAM_GB}GB RAM (tight for local models)"
                echo "   Minimum: 8GB for reliable local LLM"
                echo "   Recommended: 16GB+ for fast inference"
                echo ""
                echo "   Consider: Use small model (mistral) or cloud provider"
                SETUP_OLLAMA="yes"
            elif [ "$RAM_GB" != "unknown" ] && [ "$RAM_GB" -ge 16 ]; then
                echo "✓ Your system has ~${RAM_GB}GB RAM (good for local models)"
                SETUP_OLLAMA="yes"
            else
                echo "ℹ️ Unable to detect RAM, assuming adequate"
                SETUP_OLLAMA="yes"
            fi

            USE_OLLAMA=true
            LLM_PROVIDER="ollama"
            ;;

        b)
            echo "Cost Savings"
            echo ""
            echo "Cloud providers with good prices:"
            echo "  • OpenRouter (cheap models: Mistral, Llama 2)"
            echo "  • OpenAI (GPT-4 Turbo is $0.03/$0.06 per 1K tokens)"
            echo ""
            echo "Estimate: $5-20/month for moderate use"
            USE_OLLAMA=false
            LLM_PROVIDER="openrouter"
            ;;

        c)
            echo "Quality & Speed"
            echo ""
            echo "Best models available:"
            echo "  • Claude 3 Opus (via OpenRouter or Anthropic)"
            echo "  • GPT-4 Turbo (via OpenAI)"
            echo ""
            echo "Cost: $10-50/month depending on usage"
            USE_OLLAMA=false
            LLM_PROVIDER="openrouter"
            ;;

        *)
            echo "Options Available:"
            echo ""
            echo "1. OLLAMA (Local, Private, Free)"
            echo "   • Runs on your computer"
            echo "   • All data stays private"
            echo "   • Cost: Free (uses your hardware)"
            echo "   • Requirement: 8GB+ RAM, decent CPU"
            echo ""
            echo "2. OPENROUTER (Cloud, Cheap, Fast)"
            echo "   • Hosted models (no setup needed)"
            echo "   • Pay per token (~$0.01-0.50 per use)"
            echo "   • Best for cost-conscious users"
            echo "   • Requires API key from openrouter.ai"
            echo ""
            echo "3. OPENAI (Cloud, Quality, Higher Cost)"
            echo "   • GPT-4 Turbo (best quality)"
            echo "   • Cost: $0.03-0.06 per 1K tokens (~$10-50/month typical)"
            echo "   • Requires API key from openai.com"
            echo ""
            echo "4. ANTHROPIC (Cloud, High Quality)"
            echo "   • Claude 3 models (best at reasoning)"
            echo "   • Cost: $0.08+ per 1K tokens"
            echo "   • Requires API key from anthropic.com"
            echo ""

            read -p "Which sounds best for you? [ollama/openrouter/openai/anthropic]: " llm_choice2
            case "$llm_choice2" in
                openrouter)
                    USE_OLLAMA=false
                    LLM_PROVIDER="openrouter"
                    ;;
                openai)
                    USE_OLLAMA=false
                    LLM_PROVIDER="openai"
                    ;;
                anthropic)
                    USE_OLLAMA=false
                    LLM_PROVIDER="anthropic"
                    ;;
                *)
                    USE_OLLAMA=true
                    LLM_PROVIDER="ollama"
                    ;;
            esac
            echo ""
            ;;
    esac

    # === CREATE .ENV ===
    cp "$ENV_EXAMPLE" "$ENV_FILE"

    # Update Thoth bind
    sed -i.bak "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE" || \
    sed -i '' "s/^THOTH_BIND=.*/THOTH_BIND=$THOTH_BIND/" "$ENV_FILE"

    # Update LLM provider in .env (if commented out, uncomment and set)
    if [ "$USE_OLLAMA" = true ]; then
        echo "✓ Configured for Ollama (local LLM)"
        # Ollama should be default, just ensure OLLAMA_BASE_URL is set
        if ! grep -q "^OLLAMA_BASE_URL=" "$ENV_FILE"; then
            echo "OLLAMA_BASE_URL=http://host.docker.internal:11434" >> "$ENV_FILE"
        fi
    else
        echo "✓ Configured for cloud provider: $LLM_PROVIDER"
        # Ask for API key
        echo ""
        echo "To complete setup, you'll need an API key from $LLM_PROVIDER"

        case "$LLM_PROVIDER" in
            openrouter)
                echo "Get one at: https://openrouter.ai (free sign-up, need $5+ credits)"
                echo ""
                read -sp "Enter your OpenRouter API key (sk-or-...): " api_key
                echo ""
                if [ ! -z "$api_key" ]; then
                    # Uncomment and set OpenRouter lines
                    sed -i.bak '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# OPENROUTER_API_KEY/s/^# //' "$ENV_FILE"

                    # Insert actual key (carefully to avoid special chars)
                    sed -i.bak "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE" || \
                    sed -i '' "s|sk-or-your-actual-key-here|$api_key|" "$ENV_FILE"

                    sed -i.bak '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE" || \
                    sed -i '' '/^# THOTH_LLM_PROVIDER=openrouter/s/^# //' "$ENV_FILE"

                    echo "✓ API key saved to .env"
                fi
                ;;
        esac
    fi

    rm -f "$ENV_FILE.bak"
    echo "✓ Created .env from .env.example"
    echo ""
fi

# Source the .env file
set -a
source "$ENV_FILE"
set +a

# === SETUP DIRECTORIES ===
echo "Setting up directories..."

THOTH_DATA_DIR="${THOTH_DATA_DIR:-.}"
THOTH_WORKSPACE_DIR="${THOTH_WORKSPACE_DIR:-.}"

# Make paths absolute
if [[ "$THOTH_DATA_DIR" != /* ]]; then
    THOTH_DATA_DIR="$SCRIPT_DIR/$THOTH_DATA_DIR"
fi
if [[ "$THOTH_WORKSPACE_DIR" != /* ]]; then
    THOTH_WORKSPACE_DIR="$SCRIPT_DIR/$THOTH_WORKSPACE_DIR"
fi

mkdir -p "$THOTH_DATA_DIR"
mkdir -p "$THOTH_WORKSPACE_DIR"

echo "✓ Created data directory"
echo "✓ Created workspace directory"
echo ""

# === CHECK OLLAMA (if configured) ===
if grep -q "OLLAMA_BASE_URL" "$ENV_FILE"; then
    echo "Checking Ollama connectivity..."
    OLLAMA_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"

    if curl -s "$OLLAMA_URL/api/tags" > /dev/null 2>&1; then
        echo "✓ Ollama is reachable"
    else
        echo "⚠️ Warning: Ollama is not reachable at $OLLAMA_URL"
        echo "   Start Ollama before starting Thoth, or use a cloud provider"
        echo "   See TROUBLESHOOTING.md for Ollama setup help"
    fi
    echo ""
fi

# === FINAL SUMMARY ===
echo "✅ Setup complete!"
echo ""
echo "Summary:"
echo "  • Thoth binding: ${THOTH_BIND:-127.0.0.1} (edit .env to change)"
echo "  • LLM provider: $(grep 'THOTH_LLM_PROVIDER=' "$ENV_FILE" | cut -d= -f2 || echo 'ollama (default)')"
echo ""
echo "Next steps:"
echo "  1. Review your .env file (optional edits)"
echo "  2. Start Thoth: docker-compose up -d"
echo "  3. Access at: http://localhost:8080"
echo ""
echo "For network access help, see: references/NETWORK_SETUP.md"
echo "For troubleshooting, see: TROUBLESHOOTING.md"
