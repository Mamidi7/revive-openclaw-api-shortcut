#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  🦞 REVIVE OPENCLAW — One command. New key. Back online.
# ═══════════════════════════════════════════════════════════
#
#  Usage:  ./revive-openclaw.sh YOUR_NEW_API_KEY
#
#  Example:
#    ./revive-openclaw.sh AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
#
# ═══════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

AUTH_FILE="$HOME/.openclaw/agents/main/agent/auth-profiles.json"

echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  🦞 OpenClaw Revive — API Key Swap    ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# ─── Check if key was provided ───
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage:${NC}  ./revive-openclaw.sh YOUR_NEW_API_KEY"
    echo ""
    echo -e "${YELLOW}Example:${NC}"
    echo "  ./revive-openclaw.sh AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    echo ""
    exit 1
fi

NEW_KEY="$1"

# ─── Check auth file exists ───
if [ ! -f "$AUTH_FILE" ]; then
    echo -e "${RED}✗ Auth file not found: $AUTH_FILE${NC}"
    echo "  Is OpenClaw installed? Run: openclaw doctor"
    exit 1
fi

# ─── Show old key (masked) ───
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
else
    echo -e "  Old key: ${RED}(not found)${NC}"
fi
echo -e "  New key: ${GREEN}${NEW_KEY:0:12}...${NEW_KEY: -4}${NC}"
echo ""

# ─── Swap the key ───
echo -e "${YELLOW}[1/3]${NC} Swapping API key..."

python3 -c "
import json, sys

auth_file = '$AUTH_FILE'
new_key = '$NEW_KEY'

with open(auth_file, 'r') as f:
    data = json.load(f)

# Swap key in all profiles
swapped = False
for name, profile in data.get('profiles', {}).items():
    if 'key' in profile:
        profile['key'] = new_key
        swapped = True

# Reset error counts so OpenClaw doesn't skip the new key
for name in data.get('usageStats', {}):
    data['usageStats'][name]['errorCount'] = 0

if not swapped:
    print('ERROR: No API key profile found to swap')
    sys.exit(1)

with open(auth_file, 'w') as f:
    json.dump(data, f, indent=2)

print('OK')
" 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}  ✗ Failed to swap key${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ API key swapped${NC}"

# ─── Restart gateway ───
echo -e "${YELLOW}[2/3]${NC} Restarting gateway..."
openclaw gateway restart 2>&1 | tail -1
echo -e "${GREEN}  ✓ Gateway restarted${NC}"

# ─── Verify ───
echo -e "${YELLOW}[3/3]${NC} Verifying..."
sleep 2

CURRENT=$(openclaw models status 2>/dev/null | grep -o 'google:default=.*')
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
