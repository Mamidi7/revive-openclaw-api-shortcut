# 🦞 OpenClaw Revive

**One command to fix OpenClaw when your API key quota is exhausted.**

When your API key runs out of quota, OpenClaw stops responding. This tool swaps your exhausted key with a new one and restarts the gateway — back online in seconds.

Supports **all OpenClaw providers** — Google, OpenAI, Anthropic, Groq, Mistral, xAI, Amazon Bedrock, OpenRouter, and more.

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

## Supported Providers

### Auto-Detected (just paste the key)

The script recognizes these key formats automatically:

| Key Prefix | Provider | Default Model |
|-----------|----------|---------------|
| `AIzaSy...` | Google Gemini | `google/gemini-3-pro-preview` |
| `sk-proj-...` / `sk-...` | OpenAI | `openai/gpt-4o` |
| `sk-ant-...` | Anthropic | `anthropic/claude-sonnet-4-20250514` |
| `sk-or-...` | OpenRouter | `openrouter/auto` |
| `gsk_...` | Groq | `groq/llama-3.3-70b-versatile` |
| `xai-...` | xAI (Grok) | `xai/grok-3` |
| `hf_...` | Hugging Face | `huggingface/meta-llama/Llama-3.3-70B-Instruct` |

### Manual Provider (use `--provider`)

For providers whose keys don't have a recognizable prefix, use the `--provider` flag:

```bash
./revive-openclaw.sh YOUR_API_KEY --provider mistral
./revive-openclaw.sh YOUR_API_KEY --provider amazon-bedrock
./revive-openclaw.sh YOUR_API_KEY --provider google-vertex
./revive-openclaw.sh YOUR_API_KEY --provider cerebras
```

**All OpenClaw providers:**

| Provider ID | Notes |
|-------------|-------|
| `google` | Google Gemini via AI Studio |
| `openai` | OpenAI API |
| `anthropic` | Anthropic Claude |
| `openrouter` | OpenRouter (multi-provider) |
| `groq` | Groq (fast inference) |
| `mistral` | Mistral AI |
| `xai` | xAI (Grok) |
| `amazon-bedrock` | AWS Bedrock |
| `google-vertex` | Google Vertex AI |
| `cerebras` | Cerebras |
| `minimax` | MiniMax |
| `huggingface` | Hugging Face |
| `github-copilot` | GitHub Copilot |
| `azure-openai-responses` | Azure OpenAI |

---

## How It Works

### Same Provider → Key Swap (Fast)

If your new key is from the **same provider** you're already using, only the key is swapped:

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

### Unknown Key → Helpful Error

If the key format isn't recognized, the script **stops safely** and tells you to use `--provider`:

```
✗ Could not auto-detect provider from key format
  Use --provider to specify it manually:
    ./revive-openclaw.sh YOUR_KEY --provider groq
```

---

## Where to Get a New API Key

| Provider | Where to Get |
|----------|-------------|
| **Google Gemini** | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com/) |
| **Groq** | [console.groq.com/keys](https://console.groq.com/keys) |
| **Mistral** | [console.mistral.ai/api-keys](https://console.mistral.ai/api-keys/) |
| **xAI** | [console.x.ai](https://console.x.ai/) |
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## Customizing the Model

After reviving, if you want a different model than the default:

```bash
# See available models
openclaw models list --all

# Set your preferred model
openclaw models set google/gemini-2.5-flash-preview
openclaw models set openai/gpt-4o-mini
openclaw models set anthropic/claude-haiku-4-5-20251001
openclaw models set groq/llama-3.3-70b-versatile
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

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `openclaw: command not found` | Make sure OpenClaw is installed and in your PATH |
| `Auth file not found` | Run `openclaw doctor` to fix your installation |
| `Could not detect provider` | Use `--provider` flag: `./revive-openclaw.sh KEY --provider groq` |
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

The script **rejects unrecognized key formats** (unless `--provider` is specified) to prevent accidentally breaking your setup with an incompatible key.

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
