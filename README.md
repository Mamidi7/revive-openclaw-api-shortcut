# 🦞 OpenClaw Revive

**One command to fix OpenClaw when your API key quota is exhausted.**

When your API key runs out of quota, OpenClaw stops responding. This tool swaps your exhausted key with a new one and restarts the gateway — in seconds. Works with **any AI provider** (OpenAI, Google Gemini, Anthropic, and more).

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

### Option 2: macOS Spotlight (No Terminal Needed)

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

## Supported Providers

Works with **any** API key. Just paste your key and go:

| Provider | Key Format | Example |
|----------|-----------|---------|
| **OpenAI** | `sk-proj-...` | `revive sk-proj-XXXXXX` |
| **Google Gemini** | `AIzaSy...` | `revive AIzaSyXXXXXX` |
| **Anthropic** | `sk-ant-...` | `revive sk-ant-XXXXXX` |
| **OpenRouter** | `sk-or-...` | `revive sk-or-XXXXXX` |
| **Any other** | Any format | `revive YOUR_KEY` |

---

## How to Get a New API Key

| Provider | Where to Get |
|----------|-------------|
| **Google Gemini** | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com/) |
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## What It Does

1. 🔑 **Swaps** the old exhausted key with your new key in OpenClaw's auth config
2. 🔄 **Resets** error counts so OpenClaw accepts the new key immediately
3. 🚀 **Restarts** the gateway so changes take effect
4. ✅ **Verifies** the new key is active

---

## Files

```
revive-openclaw-api-shortcut/
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
| `Auth file not found` | Run `openclaw doctor` to fix your installation |
| Key still not working | Verify your new key is valid at your provider's dashboard |
| Gateway won't restart | Run `openclaw gateway stop && openclaw gateway start` |

---

## License

MIT — use it, share it, modify it.
