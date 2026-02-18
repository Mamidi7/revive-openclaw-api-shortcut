# 🦞 OpenClaw Revive

**One command to fix OpenClaw when your API key quota is exhausted.**

When your Gemini API key runs out of quota, OpenClaw stops working. This tool swaps your exhausted key with a new one and restarts the gateway — in seconds.

---

## Quick Start

### Option 1: Terminal Command (Recommended)

```bash
# Install once
chmod +x install-alias.sh && ./install-alias.sh
source ~/.zshrc

# Use anytime
revive YOUR_NEW_API_KEY
```

### Option 2: macOS Spotlight

```bash
# Install once
chmod +x install-shortcut.sh && ./install-shortcut.sh

# Use anytime
# ⌘+Space → type "Revive OpenClaw" → paste key → click "Revive!"
```

### Option 3: Direct Script

```bash
chmod +x revive-openclaw.sh
./revive-openclaw.sh YOUR_NEW_API_KEY
```

---

## How to Get a New API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Click **"Create API Key"**
3. Copy it (starts with `AIzaSy...`)
4. Use it with any method above

---

## What It Does

1. 🔑 **Swaps** the old key with your new key in OpenClaw's auth config
2. 🔄 **Resets** error counts so OpenClaw accepts the new key
3. 🚀 **Restarts** the gateway so changes take effect
4. ✅ **Verifies** the new key is active

---

## Files

```
openclaw-revive/
├── revive-openclaw.sh     # Main swap script
├── install-alias.sh       # Adds 'revive' command to your terminal
├── install-shortcut.sh    # Creates macOS Spotlight app
├── LICENSE
└── README.md
```

---

## Requirements

- [OpenClaw](https://openclaw.ai) installed and configured
- macOS (for Spotlight shortcut) or any Unix shell (for terminal alias)
- Python 3 (pre-installed on macOS)

---

## How It Works

OpenClaw stores API keys in `~/.openclaw/agents/main/agent/auth-profiles.json`. When your key's quota runs out, OpenClaw can't call the AI model and stops responding.

This tool:
- Reads the auth profile JSON
- Replaces the old API key with your new one
- Resets the `errorCount` so OpenClaw doesn't skip the key
- Restarts the gateway service

No manual JSON editing. No guessing file paths. Just one command.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `openclaw: command not found` | Make sure OpenClaw is installed and in your PATH |
| `Auth file not found` | Run `openclaw doctor` to fix your OpenClaw installation |
| Key still not working | Verify your new key at [AI Studio](https://aistudio.google.com/apikey) |
| Gateway won't restart | Run `openclaw gateway stop && openclaw gateway start` |

---

## License

MIT — use it, share it, modify it.
