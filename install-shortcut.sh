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

# Get absolute path to revive script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REVIVE_SCRIPT="$SCRIPT_DIR/revive-openclaw.sh"

if [ ! -f "$REVIVE_SCRIPT" ]; then
    echo "✗ revive-openclaw.sh not found in $SCRIPT_DIR"
    exit 1
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

# Create the executable
cat > "$APP_DIR/Contents/MacOS/revive" << SCRIPT
#!/bin/bash

# Prompt for the new API key via macOS dialog
NEW_KEY=\$(osascript -e '
tell application "System Events"
    display dialog "🦞 Revive OpenClaw\n\nPaste your new API key (any provider):\n\nAuto-detects: Google, OpenAI, Anthropic, OpenRouter" default answer "" with title "Revive OpenClaw" buttons {"Cancel", "Revive!"} default button "Revive!"
    set theKey to text returned of result
    return theKey
end tell
' 2>/dev/null)

# User cancelled
if [ -z "\$NEW_KEY" ]; then
    exit 0
fi

# Run the main revive script
RESULT=\$("$REVIVE_SCRIPT" "\$NEW_KEY" 2>&1)

if [ \$? -eq 0 ]; then
    osascript -e "display notification \"API key swapped & gateway restarted!\" with title \"🦞 OpenClaw Revived!\" sound name \"Glass\""
else
    osascript -e "display notification \"❌ Something went wrong. Check terminal.\" with title \"OpenClaw Revive\""
fi
SCRIPT

chmod +x "$APP_DIR/Contents/MacOS/revive"

echo "✅ App installed: $APP_DIR"
echo ""
echo "How to use:"
echo "  1. Press ⌘+Space (Spotlight)"
echo "  2. Type 'Revive OpenClaw'"
echo "  3. Paste your new API key (any provider)"
echo "  4. Click 'Revive!'"
echo ""
echo "🎉 Done!"
