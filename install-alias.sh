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
    echo "  Manually source the revive-openclaw.sh script from your shell config."
    exit 1
fi

# Check if already installed
if grep -q "# 🦞 OpenClaw Revive" "$SHELL_RC" 2>/dev/null; then
    echo "ℹ️  Found existing 'revive' command in $SHELL_RC"
    echo "  Removing old version and installing updated one..."
    # Remove old version (between the comment markers)
    sed -i '' '/# 🦞 OpenClaw Revive/,/^}$/d' "$SHELL_RC" 2>/dev/null
fi

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Add the function
cat >> "$SHELL_RC" << FUNC

# 🦞 OpenClaw Revive — swap API key from anywhere
revive() {
  if [ -z "\$1" ]; then
    echo "Usage: revive YOUR_NEW_API_KEY"
    echo "  Auto-detects provider from key format."
    return 1
  fi
  bash "$SCRIPT_DIR/revive-openclaw.sh" "\$1"
}
FUNC

echo "✅ 'revive' command added to $SHELL_RC"
echo ""
echo "To use now, run:  source $SHELL_RC"
echo "Then:             revive YOUR_NEW_API_KEY"
