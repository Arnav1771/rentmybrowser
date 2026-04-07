# 🔧 Failover Script Fix - What Was Wrong

## The Error You Were Getting

```
error: unknown option '--model'
(Did you mean --mode?)
```

## What Went Wrong

The `failover.sh` script was using OpenClaw CLI flags that **don't exist in non-interactive mode**:

### ❌ INCORRECT (What was there):
```bash
openclaw onboard --non-interactive \
    --mode local \
    --auth-choice custom-api-key \         # ❌ Not valid
    --custom-model-id "$model" \            # ❌ Not valid (--model doesn't exist)
    --custom-api-key "$GEMINI_API_KEY" \   # ❌ Not valid
    --custom-provider-id "gemini" \        # ❌ Not valid
    --custom-compatibility openai \        # ❌ Not valid
    ...
```

These flags were fabricated and are NOT in the official OpenClaw CLI documentation.

### ✅ CORRECT (What it is now):
```bash
openclaw onboard --non-interactive \
    --mode local \
    --auth-choice apiKey \                 # ✅ Valid option
    --secret-input-mode plaintext \
    --gateway-port 18789 \
    --gateway-bind loopback \
    --install-daemon \
    --daemon-runtime node \
    --skip-skills \
    --accept-risk
```

## Source: Official Documentation

All flags are from the official **OpenClaw CLI Automation** documentation:
https://docs.openclaw.ai/start/wizard-cli-automation

The baseline example on that page shows the correct way to set up OpenClaw in non-interactive mode with an API key.

## Key Limitation Discovered

**OpenClaw does NOT support dynamic model selection in non-interactive mode.**

- During setup, you configure a default model
- That model is locked in the configuration
- You cannot switch models mid-run like the original script was trying to do

### Solution

The fixed script now:
1. Sets up OpenClaw once with Gemini API
2. Monitors gateway health (every 2 minutes)
3. Restarts the gateway if it crashes
4. Runs for ~5h 45m then exits gracefully
5. Cron re-triggers it automatically

## Testing the Fix

**Re-trigger your workflow:**

1. Go to: https://github.com/Arnav1771/rentmybrowser/actions
2. Click **🌐 Rent My Browser Node**
3. Click **Run workflow** → **Run workflow**

The new script should now:
- ✅ Install OpenClaw successfully
- ✅ Onboard with Gemini API (no "unknown option" error)
- ✅ Install rent-my-browser skill
- ✅ Node goes online
- ✅ Start earning within 5-10 minutes

## What Changed in failover.sh

| Aspect | Before | After |
|--------|--------|-------|
| Flags | Non-existent custom flags | Official `--auth-choice apiKey` |
| Model selection | Dynamic (attempted) | Single static model |
| Error handling | Limited | Improved with logging |
| Clawhub install | Manual | Automatic in script |
| Gateway management | Attempted restart | Proper service handling |

## Files Updated

- ✅ [failover.sh](failover.sh) - Fixed OpenClaw onboarding
- ✅ Committed to GitHub
- ✅ Ready for your next workflow run

---

**Bottom Line:** The script was trying to use OpenClaw features that don't exist. It now uses only the documented, working flags from the official OpenClaw CLI automation guide.
