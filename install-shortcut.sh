#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  Creates a macOS app "Revive OpenClaw" accessible via Spotlight
#  Run once: ./install-shortcut.sh
#  Then: ⌘+Space → "Revive OpenClaw" → paste key → done
# ═══════════════════════════════════════════════════════════

OPENCLAW_BIN=$(which openclaw 2>/dev/null)

if [ -z "$OPENCLAW_BIN" ]; then
    echo "⚠ OpenClaw CLI not found in PATH."
    echo "  Make sure OpenClaw is installed: https://docs.openclaw.ai"
    echo "  Trying default location..."
    # Common locations
    for loc in "$HOME/.nvm/versions/node/"*/bin/openclaw /usr/local/bin/openclaw /opt/homebrew/bin/openclaw; do
        if [ -x "$loc" ]; then
            OPENCLAW_BIN="$loc"
            echo "  Found: $OPENCLAW_BIN"
            break
        fi
    done
    if [ -z "$OPENCLAW_BIN" ]; then
        echo "  ✗ Could not find openclaw binary. Install OpenClaw first."
        exit 1
    fi
fi

echo ""
echo "🦞 macOS Shortcut Setup for OpenClaw Revive"
echo "============================================"
echo ""

APP_DIR="$HOME/Applications/Revive OpenClaw.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Revive OpenClaw</string>
    <key>CFBundleDisplayName</key>
    <string>Revive OpenClaw</string>
    <key>CFBundleIdentifier</key>
    <string>com.openclaw.revive</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>revive</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

# Create the executable — uses $OPENCLAW_BIN dynamically
cat > "$APP_DIR/Contents/MacOS/revive" << SCRIPT
#!/bin/bash

AUTH_FILE="\$HOME/.openclaw/agents/main/agent/auth-profiles.json"

# Prompt for the new API key via macOS dialog
NEW_KEY=\$(osascript -e '
tell application "System Events"
    display dialog "🦞 Revive OpenClaw\n\nPaste your new Gemini API key:" default answer "" with title "Revive OpenClaw" buttons {"Cancel", "Revive!"} default button "Revive!"
    set theKey to text returned of result
    return theKey
end tell
' 2>/dev/null)

# User cancelled
if [ -z "\$NEW_KEY" ]; then
    exit 0
fi

# Swap the key
RESULT=\$(python3 -c "
import json, sys
try:
    with open('\$AUTH_FILE','r') as f: d=json.load(f)
    for p in d.get('profiles',{}).values():
        if 'key' in p: p['key']='\$NEW_KEY'
    for s in d.get('usageStats',{}).values(): s['errorCount']=0
    with open('\$AUTH_FILE','w') as f: json.dump(d,f,indent=2)
    print('OK')
except Exception as e:
    print(f'ERROR: {e}')
    sys.exit(1)
" 2>&1)

if [ "\$RESULT" != "OK" ]; then
    osascript -e "display notification \"❌ Failed: \$RESULT\" with title \"OpenClaw Revive\""
    exit 1
fi

# Restart gateway
$OPENCLAW_BIN gateway restart 2>/dev/null

# Success notification
osascript -e "display notification \"API key swapped & gateway restarted!\" with title \"🦞 OpenClaw Revived!\" sound name \"Glass\""
SCRIPT

chmod +x "$APP_DIR/Contents/MacOS/revive"

echo "✅ App installed: $APP_DIR"
echo ""
echo "How to use:"
echo "  1. Press ⌘+Space (Spotlight)"
echo "  2. Type 'Revive OpenClaw'"
echo "  3. Paste your new API key"
echo "  4. Click 'Revive!'"
echo ""
echo "🎉 Done!"
