#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  Adds the 'revive' command to your shell
#  Run once: ./install-alias.sh
#  Then from any terminal: revive YOUR_NEW_API_KEY
# ═══════════════════════════════════════════════════════════

SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
else
    echo "⚠ Could not find .zshrc or .bashrc"
    echo "  Add the following manually to your shell config:"
    echo ""
    cat << 'FUNC'
# 🦞 OpenClaw Revive — swap API key from anywhere
revive() {
  if [ -z "$1" ]; then echo "Usage: revive YOUR_NEW_API_KEY"; return 1; fi
  local AUTH="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
  python3 -c "
import json
with open('$AUTH','r') as f: d=json.load(f)
for p in d.get('profiles',{}).values():
  if 'key' in p: p['key']='$1'
for s in d.get('usageStats',{}).values(): s['errorCount']=0
with open('$AUTH','w') as f: json.dump(d,f,indent=2)
print('✅ Key swapped')
"
  openclaw gateway restart 2>&1 | tail -1
  echo "🦞 OpenClaw is back online!"
}
FUNC
    exit 1
fi

# Check if already installed
if grep -q "# 🦞 OpenClaw Revive" "$SHELL_RC" 2>/dev/null; then
    echo "✅ 'revive' command already installed in $SHELL_RC"
    echo "   Usage: revive YOUR_NEW_API_KEY"
    exit 0
fi

# Add the function
cat >> "$SHELL_RC" << 'FUNC'

# 🦞 OpenClaw Revive — swap API key from anywhere
revive() {
  if [ -z "$1" ]; then echo "Usage: revive YOUR_NEW_API_KEY"; return 1; fi
  local AUTH="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
  python3 -c "
import json
with open('$AUTH','r') as f: d=json.load(f)
for p in d.get('profiles',{}).values():
  if 'key' in p: p['key']='$1'
for s in d.get('usageStats',{}).values(): s['errorCount']=0
with open('$AUTH','w') as f: json.dump(d,f,indent=2)
print('✅ Key swapped')
"
  openclaw gateway restart 2>&1 | tail -1
  echo "🦞 OpenClaw is back online!"
}
FUNC

echo "✅ 'revive' command added to $SHELL_RC"
echo ""
echo "To use now, run:  source $SHELL_RC"
echo "Then:             revive YOUR_NEW_API_KEY"
