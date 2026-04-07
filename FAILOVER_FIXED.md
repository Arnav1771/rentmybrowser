# ✅ FAILOVER.SH - FIXED & SIMPLIFIED

## What Changed

The script has been **completely simplified** to use ONLY official OpenClaw CLI flags that actually exist.

### ❌ REMOVED
- Model rotation logic (not supported in non-interactive mode)
- All fake/non-existent custom provider flags
- Complex branching and failure handling

### ✅ ADDED
- Clean, minimal code
- Only documented flags: `--auth-choice apiKey`, `--gateway-port`, `--gateway-bind`, `--install-daemon`
- Clear step-by-step logging
- Proper error checking at each stage

## What It Does Now

1. ✅ Validates Gemini API key exists
2. ✅ Installs/verifies OpenClaw
3. ✅ Installs/verifies ClawHub
4. ✅ Cleans up any existing gateway
5. ✅ Runs `openclaw onboard` with **ONLY valid flags**
6. ✅ Starts gateway
7. ✅ Installs rent-my-browser skill
8. ✅ Monitors for 5h 45m, restarts if needed
9. ✅ Exits gracefully (cron auto-restarts)

## How to Test

**Trigger a new workflow run:**

1. Go to: https://github.com/Arnav1771/rentmybrowser/actions
2. Click: **🌐 Rent My Browser Node** (left sidebar)
3. Click: **Run workflow** (blue button)
4. Click: **Run workflow** (confirm)

**Watch the logs:**
- Click the new run number
- Click the **browser-node** job
- Watch real-time output

**Look for:**
- ✅ "OpenClaw ready"
- ✅ "ClawHub ready"
- ✅ "Setting up OpenClaw (Gemini API)"
- ✅ "Node is ONLINE and earning!"
- ❌ NO "error: unknown option" messages

## Expected Output

```
✅ Gemini API key found
✅ OpenClaw ready
✅ ClawHub ready
╔════════════════════════════════════════╗
║ Setting up OpenClaw (Gemini API)      ║
╚════════════════════════════════════════╝
✅ OpenClaw configured
🚀 Starting gateway...
📥 Installing rent-my-browser skill...

════════════════════════════════════════
✅ Node is ONLINE and earning!
💰 Expected: $0.04-0.12 per task
⏱️  Running for ~5h 45m
════════════════════════════════════════

[... health checks every 2 minutes ...]
```

## Why The Fix Works

The old script tried to use flags that **don't exist** in OpenClaw:
- `--custom-model-id`
- `--custom-api-key`
- `--custom-provider-id`

The new script uses **only flags from the official documentation**:
- https://docs.openclaw.ai/start/wizard-cli-automation

## Commit Info

- **Commit:** `041b552`
- **Branch:** `main`
- **Status:** ✅ Pushed to GitHub

---

**Ready to go! Trigger that workflow run now.** 🚀
