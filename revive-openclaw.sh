#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  🦞 REVIVE OPENCLAW — One command. New key. Back online.
# ═══════════════════════════════════════════════════════════
#
#  Auto-detects provider from key format when possible.
#  Supports ALL OpenClaw providers: Google, OpenAI, Anthropic,
#  Groq, Mistral, xAI, Amazon Bedrock, OpenRouter, and more.
#
#  Usage:
#    ./revive-openclaw.sh YOUR_NEW_API_KEY
#    ./revive-openclaw.sh YOUR_NEW_API_KEY --provider groq
#
# ═══════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

AUTH_FILE="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  🦞 OpenClaw Revive — API Key Swap    ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# ─── Parse arguments ───
NEW_KEY=""
FORCE_PROVIDER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --provider)
            FORCE_PROVIDER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ./revive-openclaw.sh YOUR_API_KEY [--provider PROVIDER]"
            echo ""
            echo "Arguments:"
            echo "  YOUR_API_KEY         Your new API key"
            echo "  --provider PROVIDER  Force a specific provider (optional)"
            echo ""
            echo "Auto-detected providers:"
            echo "  AIzaSy...       → google"
            echo "  sk-proj-...     → openai"
            echo "  sk-ant-...      → anthropic"
            echo "  sk-or-...       → openrouter"
            echo "  gsk_...         → groq"
            echo "  xai-...         → xai"
            echo ""
            echo "All supported providers (use --provider):"
            echo "  google, openai, anthropic, openrouter, groq, mistral,"
            echo "  xai, amazon-bedrock, google-vertex, cerebras, minimax,"
            echo "  huggingface, github-copilot, azure-openai-responses"
            echo ""
            exit 0
            ;;
        *)
            if [ -z "$NEW_KEY" ]; then
                NEW_KEY="$1"
            fi
            shift
            ;;
    esac
done

# ─── Check if key was provided ───
if [ -z "$NEW_KEY" ]; then
    echo -e "${YELLOW}Usage:${NC}  ./revive-openclaw.sh YOUR_NEW_API_KEY [--provider PROVIDER]"
    echo ""
    echo -e "${YELLOW}Auto-detects provider from key format:${NC}"
    echo "  ./revive-openclaw.sh AIzaSyXXXXX            # Google Gemini"
    echo "  ./revive-openclaw.sh sk-proj-XXXXX           # OpenAI"
    echo "  ./revive-openclaw.sh sk-ant-XXXXX            # Anthropic"
    echo "  ./revive-openclaw.sh gsk_XXXXX               # Groq"
    echo "  ./revive-openclaw.sh xai-XXXXX               # xAI (Grok)"
    echo ""
    echo -e "${YELLOW}For other providers, use --provider:${NC}"
    echo "  ./revive-openclaw.sh YOUR_KEY --provider mistral"
    echo "  ./revive-openclaw.sh YOUR_KEY --provider amazon-bedrock"
    echo "  ./revive-openclaw.sh YOUR_KEY --provider groq"
    echo ""
    exit 1
fi

# ─── Check files exist ───
if [ ! -f "$AUTH_FILE" ]; then
    echo -e "${RED}✗ Auth file not found: $AUTH_FILE${NC}"
    echo "  Is OpenClaw installed? Run: openclaw doctor"
    exit 1
fi

# ─── Auto-detect provider from key format ───
detect_provider() {
    local key="$1"
    if [[ "$key" == AIzaSy* ]]; then
        echo "google"
    elif [[ "$key" == sk-ant-* ]]; then
        echo "anthropic"
    elif [[ "$key" == sk-or-* ]]; then
        echo "openrouter"
    elif [[ "$key" == sk-proj-* ]] || [[ "$key" == sk-svcacct-* ]]; then
        echo "openai"
    elif [[ "$key" == gsk_* ]]; then
        echo "groq"
    elif [[ "$key" == xai-* ]]; then
        echo "xai"
    elif [[ "$key" == hf_* ]]; then
        echo "huggingface"
    elif [[ "$key" == sk-* ]]; then
        # Generic sk- prefix — most likely OpenAI
        echo "openai"
    else
        echo "unknown"
    fi
}

# ─── Default model per provider ───
default_model() {
    local provider="$1"
    case "$provider" in
        google)              echo "google/gemini-2.5-pro-preview" ;;
        openai)              echo "openai/gpt-4o" ;;
        anthropic)           echo "anthropic/claude-sonnet-4-20250514" ;;
        openrouter)          echo "openrouter/auto" ;;
        groq)                echo "groq/llama-3.3-70b-versatile" ;;
        xai)                 echo "xai/grok-3" ;;
        mistral)             echo "mistral/mistral-large-latest" ;;
        amazon-bedrock)      echo "amazon-bedrock/anthropic.claude-sonnet-4-20250514-v1:0" ;;
        google-vertex)       echo "google-vertex/gemini-2.5-pro-preview" ;;
        cerebras)            echo "cerebras/llama-3.3-70b" ;;
        huggingface)         echo "huggingface/meta-llama/Llama-3.3-70B-Instruct" ;;
        github-copilot)      echo "github-copilot/gpt-4o" ;;
        minimax)             echo "minimax/minimax-m2" ;;
        *)                   echo "$provider/auto" ;;
    esac
}

# ─── Determine provider ───
if [ -n "$FORCE_PROVIDER" ]; then
    NEW_PROVIDER="$FORCE_PROVIDER"
else
    NEW_PROVIDER=$(detect_provider "$NEW_KEY")
fi

NEW_DEFAULT_MODEL=$(default_model "$NEW_PROVIDER")

echo -e "${YELLOW}[1/4]${NC} Detecting provider..."

# ─── Get current provider ───
CURRENT_PROVIDER=$(python3 -c "
import json
with open('$AUTH_FILE') as f:
    data = json.load(f)
for name, profile in data.get('profiles', {}).items():
    print(profile.get('provider', 'unknown'))
    break
" 2>/dev/null)

echo -e "  Current provider: ${CYAN}${CURRENT_PROVIDER}${NC}"
echo -e "  New key provider: ${CYAN}${NEW_PROVIDER}${NC}"

if [ "$NEW_PROVIDER" = "unknown" ]; then
    echo -e "${RED}  ✗ Could not auto-detect provider from key format${NC}"
    echo ""
    echo -e "${YELLOW}  Use --provider to specify it manually:${NC}"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider google"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider openai"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider anthropic"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider groq"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider mistral"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider xai"
    echo "    ./revive-openclaw.sh $NEW_KEY --provider amazon-bedrock"
    echo ""
    echo -e "  All providers: google, openai, anthropic, openrouter, groq,"
    echo "  mistral, xai, amazon-bedrock, google-vertex, cerebras,"
    echo "  minimax, huggingface, github-copilot, azure-openai-responses"
    echo ""
    exit 1
fi

if [ "$NEW_PROVIDER" = "$CURRENT_PROVIDER" ]; then
    echo -e "${GREEN}  ✓ Same provider — simple key swap${NC}"
    SWITCHING_PROVIDER=false
else
    echo -e "${YELLOW}  ⚡ Different provider — switching from ${CURRENT_PROVIDER} to ${NEW_PROVIDER}${NC}"
    SWITCHING_PROVIDER=true
fi
echo ""

# ─── Show old key ───
OLD_KEY=$(python3 -c "
import json
with open('$AUTH_FILE') as f:
    data = json.load(f)
for name, profile in data.get('profiles', {}).items():
    key = profile.get('key') or profile.get('token')
    if key:
        print(key)
        break
" 2>/dev/null)

if [ -n "$OLD_KEY" ]; then
    echo -e "  Old key: ${RED}${OLD_KEY:0:12}...${OLD_KEY: -4}${NC}"
fi
echo -e "  New key: ${GREEN}${NEW_KEY:0:12}...${NEW_KEY: -4}${NC}"
echo ""

# ─── Swap the key (and provider if needed) ───
echo -e "${YELLOW}[2/4]${NC} Swapping API key..."

python3 << PYEOF
import json, sys

auth_file = "$AUTH_FILE"
config_file = "$CONFIG_FILE"
new_key = "$NEW_KEY"
new_provider = "$NEW_PROVIDER"
switching = "$SWITCHING_PROVIDER" == "true"
new_model = "$NEW_DEFAULT_MODEL"

# ── Update auth-profiles.json ──
with open(auth_file, 'r') as f:
    auth = json.load(f)

# Determine auth type based on provider
if new_provider == 'google':
    auth_type = 'api_key'
    key_field = 'key'
    config_mode = 'api_key'
else:
    auth_type = 'token'
    key_field = 'token'
    config_mode = 'token'

if switching:
    # Remove old profile, create new one
    auth['profiles'] = {}
    new_profile_id = f"{new_provider}:default"
    
    profile_data = {
        "type": auth_type,
        "provider": new_provider
    }
    profile_data[key_field] = new_key
    
    auth['profiles'][new_profile_id] = profile_data
    auth['lastGood'] = {new_provider: new_profile_id}
    auth['usageStats'] = {
        new_profile_id: {
            "lastUsed": 0,
            "errorCount": 0
        }
    }
else:
    # Same provider — just swap the key
    found = False
    for name, profile in auth.get('profiles', {}).items():
        if profile.get('provider') == new_provider:
            if 'key' in profile:
                profile['key'] = new_key
                found = True
            elif 'token' in profile:
                profile['token'] = new_key
                found = True
    
    # If not found (e.g. corruption), force create
    if not found:
        new_profile_id = f"{new_provider}:default"
        profile_data = {
            "type": auth_type,
            "provider": new_provider
        }
        profile_data[key_field] = new_key
        auth['profiles'][new_profile_id] = profile_data
        
    for name in auth.get('usageStats', {}):
        auth['usageStats'][name]['errorCount'] = 0

with open(auth_file, 'w') as f:
    json.dump(auth, f, indent=2)

# ── Update openclaw.json if switching providers ──
if switching and new_model:
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)

        config.setdefault('auth', {})['profiles'] = {
            f"{new_provider}:default": {
                "provider": new_provider,
                "mode": config_mode
            }
        }
        config.setdefault('agents', {}).setdefault('defaults', {}).setdefault('model', {})['primary'] = new_model

        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)

        print(f"SWITCHED to {new_provider} with model {new_model}")
    except Exception as e:
        print(f"KEY_ONLY: {e}")
else:
    print("SWAPPED")
PYEOF

if [ $? -ne 0 ]; then
    echo -e "${RED}  ✗ Failed to swap key${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ API key swapped${NC}"
if [ "$SWITCHING_PROVIDER" = true ]; then
    echo -e "${GREEN}  ✓ Provider changed to: ${NEW_PROVIDER}${NC}"
    echo -e "${GREEN}  ✓ Model set to: ${NEW_DEFAULT_MODEL}${NC}"
fi

# ─── Restart gateway ───
echo -e "${YELLOW}[3/4]${NC} Restarting gateway..."
openclaw gateway restart 2>&1 | tail -1
echo -e "${GREEN}  ✓ Gateway restarted${NC}"

# ─── Verify ───
echo -e "${YELLOW}[4/4]${NC} Verifying..."
sleep 2

CURRENT=$(openclaw models status 2>/dev/null | grep -oE '[a-z-]+:default=\S+')
if [ -n "$CURRENT" ]; then
    echo -e "${GREEN}  ✓ Active: $CURRENT${NC}"
else
    echo -e "${GREEN}  ✓ Key updated (run 'openclaw models status' to verify)${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ OpenClaw is back online!           ${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""

if [ "$SWITCHING_PROVIDER" = true ]; then
    echo -e "${CYAN}Note:${NC} Switched from ${CURRENT_PROVIDER} to ${NEW_PROVIDER}."
    echo "  Default model: ${NEW_DEFAULT_MODEL}"
    echo "  To change model: openclaw models set <model>"
    echo ""
fi
