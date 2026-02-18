# 🦞 OpenClaw Revive

**One command to fix OpenClaw when your API key quota is exhausted.**

When your API key runs out of quota, OpenClaw stops responding. This tool swaps your exhausted key with a new one and restarts the gateway — back online in seconds.

**Works with any AI provider.** Auto-detects from your key format — no extra configuration needed.

---

## Quick Start

### Option 1: Terminal Command (Recommended)

```bash
# Install once
chmod +x install-alias.sh && ./install-alias.sh
source ~/.zshrc

# Use anytime — just paste your new key
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

## Auto-Detection: How It Knows Your Provider

The script automatically detects the provider from your key format — you don't need to specify anything:

| Key Starts With | Detected Provider | Default Model |
|----------------|------------------|---------------|
| `AIzaSy...` | Google Gemini | `google/gemini-2.5-pro-preview` |
| `sk-proj-...` or `sk-...` | OpenAI | `openai/gpt-4o` |
| `sk-ant-...` | Anthropic | `anthropic/claude-sonnet-4-20250514` |
| `sk-or-...` | OpenRouter | `openrouter/auto` |

### Same Provider → Key Swap (Fast)

If your new key is from the **same provider** you're already using, the script simply swaps the key. Nothing else changes.

```
Currently on Google → paste new Google key → ✅ instant swap
```

### Different Provider → Full Switch (Automatic)

If your new key is from a **different provider**, the script handles everything:

1. ✅ Swaps the API key
2. ✅ Updates the provider configuration
3. ✅ Sets a sensible default model for the new provider
4. ✅ Restarts the gateway

```
Currently on Google → paste OpenAI key → ✅ auto-switches to OpenAI + gpt-4o
```

No errors. No manual configuration. Just paste and go.

---

## Where to Get a New API Key

| Provider | Where to Get |
|----------|-------------|
| **Google Gemini** | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com/) |
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## What It Does

1. 🔍 **Detects** your provider automatically from the key format
2. 🔑 **Swaps** the old exhausted key with your new key
3. 🔄 **Switches** the provider and model if needed (auto)
4. 🧹 **Resets** error counts so OpenClaw accepts the new key
5. 🚀 **Restarts** the gateway so changes take effect
6. ✅ **Verifies** the new key is active

---

## Customizing the Model

After reviving, if you want a different model than the default:

```bash
# See available models
openclaw models list

# Set your preferred model
openclaw models set google/gemini-2.5-flash-preview
openclaw models set openai/gpt-4o-mini
openclaw models set anthropic/claude-haiku-3-20240307
```

---

## Files

```
revive-openclaw-api-shortcut/
├── revive-openclaw.sh     # Main swap script (all logic lives here)
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

OpenClaw stores its configuration across two files:

| File | What It Stores |
|------|---------------|
| `~/.openclaw/agents/main/agent/auth-profiles.json` | API key, provider, error counts |
| `~/.openclaw/openclaw.json` | Default model, auth mode |

When your key quota runs out, the `errorCount` goes up and OpenClaw stops calling the API. This tool:

1. Reads both config files
2. Detects the new key's provider
3. Updates the key (and provider + model if switching)
4. Resets `errorCount` to 0
5. Restarts the gateway

No manual JSON editing. No remembering file paths. Just one command.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `openclaw: command not found` | Make sure OpenClaw is installed and in your PATH |
| `Auth file not found` | Run `openclaw doctor` to fix your installation |
| `Could not detect provider` | Your key doesn't match a known format. See supported formats above |
| Key still not working | Verify your new key is valid at your provider's dashboard |
| Want a different model | Run `openclaw models set <provider>/<model>` |
| Gateway won't restart | Run `openclaw gateway stop && openclaw gateway start` |

---

## Security

### Your API key never leaves your machine

This tool is **100% local**. Here's what happens when you use it:

| Concern | Answer |
|---------|--------|
| Is my key sent anywhere? | **No.** Zero network calls. Only writes to local files on your machine. |
| Is my key logged? | **No.** Shown masked in terminal (e.g. `AIzaSyCo...zNWv0`). Never the full key. |
| Where is my key stored? | In `~/.openclaw/agents/main/agent/auth-profiles.json` — same file OpenClaw uses. |
| Is it encrypted? | Plain text JSON — this is how OpenClaw stores keys by default. This tool doesn't change that. |
| Any analytics/telemetry? | **None.** No tracking, no call-home, no data collection. |
| Can I audit the code? | **Yes.** Readable bash + python. No obfuscation. |

### Key validation

The script **rejects unrecognized key formats** to prevent accidentally breaking your setup with an incompatible key. Only keys matching supported providers are accepted.

### Spotlight vs Terminal

The **macOS Spotlight app** is more secure than the terminal command — dialog input is **not saved** to shell history (`~/.zsh_history`), while terminal commands are.

### Best practices

- Only paste keys you generated yourself
- Rotate keys regularly at your provider's dashboard
- Revoke old/exhausted keys after generating new ones
- Never share your API key publicly

---

## License

MIT — use it, share it, modify it.
