#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  🦞 REVIVE OPENCLAW — One command. New key. Back online.
# ═══════════════════════════════════════════════════════════
#
#  Auto-detects your provider from the key format.
#  Handles same-provider swaps AND full provider switches.
#
#  Usage:  ./revive-openclaw.sh YOUR_NEW_API_KEY
#
#  Examples:
#    ./revive-openclaw.sh AIzaSyXXXXXXX        (Google Gemini)
#    ./revive-openclaw.sh sk-proj-XXXXX         (OpenAI)
#    ./revive-openclaw.sh sk-ant-XXXXX          (Anthropic)
#    ./revive-openclaw.sh sk-or-XXXXX           (OpenRouter)
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

# ─── Check if key was provided ───
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage:${NC}  ./revive-openclaw.sh YOUR_NEW_API_KEY"
    echo ""
    echo -e "${YELLOW}Auto-detects your provider from the key format:${NC}"
    echo "  ./revive-openclaw.sh AIzaSyXXXXX        # Google Gemini"
    echo "  ./revive-openclaw.sh sk-proj-XXXXX       # OpenAI"
    echo "  ./revive-openclaw.sh sk-ant-XXXXX        # Anthropic"
    echo "  ./revive-openclaw.sh sk-or-XXXXX         # OpenRouter"
    echo ""
    exit 1
fi

NEW_KEY="$1"

# ─── Check files exist ───
if [ ! -f "$AUTH_FILE" ]; then
    echo -e "${RED}✗ Auth file not found: $AUTH_FILE${NC}"
    echo "  Is OpenClaw installed? Run: openclaw doctor"
    exit 1
fi

# ─── Auto-detect provider and assign default model ───
detect_provider() {
    local key="$1"
    if [[ "$key" == AIzaSy* ]]; then
        echo "google"
    elif [[ "$key" == sk-ant-* ]]; then
        echo "anthropic"
    elif [[ "$key" == sk-or-* ]]; then
        echo "openrouter"
    elif [[ "$key" == sk-* ]]; then
        echo "openai"
    else
        echo "unknown"
    fi
}

default_model() {
    local provider="$1"
    case "$provider" in
        google)     echo "google/gemini-2.5-pro-preview" ;;
        openai)     echo "openai/gpt-4o" ;;
        anthropic)  echo "anthropic/claude-sonnet-4-20250514" ;;
        openrouter) echo "openrouter/auto" ;;
        *)          echo "" ;;
    esac
}

NEW_PROVIDER=$(detect_provider "$NEW_KEY")
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
    echo -e "${RED}  ✗ Could not detect provider from key format${NC}"
    echo ""
    echo -e "${YELLOW}  This key doesn't match any known provider:${NC}"
    echo "    Google Gemini  → key starts with AIzaSy..."
    echo "    OpenAI         → key starts with sk-proj-... or sk-..."
    echo "    Anthropic      → key starts with sk-ant-..."
    echo "    OpenRouter     → key starts with sk-or-..."
    echo ""
    echo -e "${YELLOW}  Make sure you're pasting the correct API key.${NC}"
    echo -e "${YELLOW}  The key must be from a supported provider above.${NC}"
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
    key = profile.get('key', '')
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
current_provider = "$CURRENT_PROVIDER"
switching = "$SWITCHING_PROVIDER" == "true"
new_model = "$NEW_DEFAULT_MODEL"

# ── Update auth-profiles.json ──
with open(auth_file, 'r') as f:
    auth = json.load(f)

if switching:
    # Remove old profile, create new one
    old_profiles = dict(auth.get('profiles', {}))
    auth['profiles'] = {}
    
    new_profile_id = f"{new_provider}:default"
    auth['profiles'][new_profile_id] = {
        "type": "api_key",
        "provider": new_provider,
        "key": new_key
    }
    
    # Update lastGood
    auth['lastGood'] = {new_provider: new_profile_id}
    
    # Reset usageStats
    auth['usageStats'] = {
        new_profile_id: {
            "lastUsed": 0,
            "errorCount": 0
        }
    }
else:
    # Same provider — just swap the key
    for name, profile in auth.get('profiles', {}).items():
        if 'key' in profile:
            profile['key'] = new_key
    
    # Reset error counts
    for name in auth.get('usageStats', {}):
        auth['usageStats'][name]['errorCount'] = 0

with open(auth_file, 'w') as f:
    json.dump(auth, f, indent=2)

# ── Update openclaw.json if switching providers ──
if switching and new_model:
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        # Update auth section
        config.setdefault('auth', {})['profiles'] = {
            f"{new_provider}:default": {
                "provider": new_provider,
                "mode": "api_key"
            }
        }
        
        # Update default model
        config.setdefault('agents', {}).setdefault('defaults', {}).setdefault('model', {})['primary'] = new_model
        
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"SWITCHED to {new_provider} with model {new_model}")
    except Exception as e:
        print(f"KEY_ONLY: {e}")
        sys.exit(0)  # Key was swapped, config update failed but not fatal
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

CURRENT=$(openclaw models status 2>/dev/null | grep -oE '[a-z]+:default=\S+')
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
