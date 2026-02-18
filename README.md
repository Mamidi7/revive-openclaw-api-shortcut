# 🦞 OpenClaw Revive

**One command to fix OpenClaw when your API key quota is exhausted.**

When your API key runs out of quota, OpenClaw stops responding. This tool swaps your exhausted key with a fresh one from the **same provider** and restarts the gateway — back online in seconds.

---

## Quick Start

### Option 1: Terminal Command (Recommended)

```bash
# Install once
chmod +x install-alias.sh && ./install-alias.sh
source ~/.zshrc

# Use anytime — just paste your new key from the same provider
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

## How It Works

OpenClaw ties three things together:

| Config | What it stores |
|--------|---------------|
| **Auth Profile** | Your API key + provider (e.g. `google`) |
| **Model** | Which model to use (e.g. `google/gemini-3-pro-preview`) |
| **Gateway** | Runs locally and routes requests |

When your key's quota runs out, OpenClaw can't call the AI model and stops responding. This tool swaps the **API key** while keeping the provider and model the same.

### ✅ What this tool does:
- Replaces the old API key with your new one
- Resets the `errorCount` so OpenClaw doesn't skip the key
- Restarts the gateway service

### ⚠️ Important: Same Provider Only

This tool swaps your key for a **new key from the same provider**. For example:

| Your Setup | Swap With | Works? |
|-----------|-----------|--------|
| Google Gemini key → New Google Gemini key | ✅ Yes |
| OpenAI key → New OpenAI key | ✅ Yes |
| Anthropic key → New Anthropic key | ✅ Yes |
| Google Gemini key → OpenAI key | ❌ No — different provider |

**Why?** Because OpenClaw's model config (e.g. `google/gemini-3-pro-preview`) must match the API key's provider. Swapping a Google key with an OpenAI key won't work — the model would still try to call Google's API.

**To switch providers entirely**, use OpenClaw's built-in commands:
```bash
openclaw models auth paste-token --provider openai
openclaw models set openai/gpt-4o
```

---

## Where to Get a New API Key

| Provider | Where to Get |
|----------|-------------|
| **Google Gemini** | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com/) |
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) |

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

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `openclaw: command not found` | Make sure OpenClaw is installed and in your PATH |
| `Auth file not found` | Run `openclaw doctor` to fix your installation |
| Key still not working | Make sure the new key is from the **same provider** as your current setup |
| Gateway won't restart | Run `openclaw gateway stop && openclaw gateway start` |
| Want to switch providers | Use `openclaw models auth paste-token --provider <name>` + `openclaw models set <model>` |

---

## License

MIT — use it, share it, modify it.
