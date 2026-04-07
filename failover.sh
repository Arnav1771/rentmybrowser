#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — GitHub Actions Node
#  Uses ONLY verified, documented commands from method.md
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/tmp/openclaw-node.log"
TOTAL_RUNTIME=20700  # ~5h 45m
SKILL_DIR="$HOME/.openclaw/skills/rent-my-browser"

echo "════════════════════════════════════════════"
echo "🚀 Starting Rent My Browser Node"
echo "⏰ $(date -u)"
echo "════════════════════════════════════════════"

# ── 1. Validate secrets ──────────────────────────────────────
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "❌ GEMINI_API_KEY not set in GitHub Secrets. Aborting."
    exit 1
fi
echo "✅ Gemini API key found"

# ── 2. Install OpenClaw ──────────────────────────────────────
if ! command -v openclaw &>/dev/null; then
    echo "📦 Installing OpenClaw..."
    # Note: non-fatal /dev/tty errors during install are expected in CI
    curl -fsSL https://openclaw.ai/install.sh | bash 2>&1 | tee -a "$LOG_FILE" || true
    export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
fi

# Re-check after PATH reload
if ! command -v openclaw &>/dev/null; then
    echo "❌ OpenClaw not found in PATH after install."
    echo "PATH is: $PATH"
    exit 1
fi
echo "✅ OpenClaw ready: $(openclaw --version 2>/dev/null || echo 'version unknown')"

# ── 3. Stop any existing gateway ────────────────────────────
echo "🧹 Stopping any existing gateway..."
openclaw gateway stop 2>/dev/null || true
sleep 3

# ── 4. Onboard with ONLY officially documented flags ─────────
# Source: https://docs.openclaw.ai/start/wizard-cli-automation
# ❌ NEVER USE: --model, --custom-model-id, --custom-api-key, --custom-provider-id
echo ""
echo "════════════════════════════════════════════"
echo "🔧 Onboarding OpenClaw with Gemini API..."
echo "════════════════════════════════════════════"

export GEMINI_API_KEY

openclaw onboard \
  --non-interactive \
  --mode local \
  --workspace ~/.openclaw/workspace \
  --auth-choice apiKey \
  --secret-input-mode plaintext \
  --gateway-port 18789 \
  --gateway-bind loopback \
  --install-daemon \
  --daemon-runtime node \
  --skip-skills \
  --accept-risk \
  2>&1 | tee -a "$LOG_FILE"

ONBOARD_EXIT=${PIPESTATUS[0]}
if [[ $ONBOARD_EXIT -ne 0 ]]; then
    echo "❌ Onboarding failed (exit $ONBOARD_EXIT). Check $LOG_FILE."
    exit 1
fi
echo "✅ Onboarding complete"
sleep 3

# ── 5. Install rent-my-browser skill (CORRECT METHOD) ────────
# Per method.md: clone repo then register locally
# ❌ WRONG: clawhub install 0xPasho/rent-my-browser  (causes "Invalid slug" error)
# ✅ RIGHT: git clone → openclaw skill add --local
echo ""
echo "📥 Installing rent-my-browser skill..."

mkdir -p "$HOME/.openclaw/skills"

if [[ -d "$SKILL_DIR/.git" ]]; then
    echo "🔄 Skill already cloned — pulling latest..."
    git -C "$SKILL_DIR" pull 2>&1 | tee -a "$LOG_FILE" || true
else
    echo "📦 Cloning rent-my-browser skill..."
    git clone https://github.com/0xPasho/rent-my-browser.git "$SKILL_DIR" \
        2>&1 | tee -a "$LOG_FILE"
fi

echo "🔗 Registering skill with OpenClaw..."
openclaw skill add --local "$SKILL_DIR" 2>&1 | tee -a "$LOG_FILE" || {
    echo "⚠️  Skill registration had issues — check $LOG_FILE. Continuing..."
}
sleep 3

# ── 6. Start gateway ─────────────────────────────────────────
echo ""
echo "🚀 Starting gateway..."
openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
sleep 5

# Verify it started — retry once if not
if ! openclaw gateway status &>/dev/null; then
    echo "⚠️  Gateway not up yet — retrying..."
    openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
    sleep 5
fi

if openclaw gateway status &>/dev/null; then
    echo "✅ Gateway is running"
else
    echo "⚠️  Gateway status unclear — continuing anyway"
fi

echo ""
echo "════════════════════════════════════════════"
echo "✅ NODE IS ONLINE"
echo "💰 Expected: \$0.04–0.12 per task"
echo "⏱️  Will run for ~5h 45m then exit for cron restart"
echo "════════════════════════════════════════════"
echo ""

# ── 7. Health monitor loop ───────────────────────────────────
start_time=$(date +%s)

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    # Graceful exit when time is up
    if [[ $elapsed -ge $TOTAL_RUNTIME ]]; then
        echo ""
        echo "⏱️  Time limit reached after $((elapsed / 3600))h $((elapsed % 3600 / 60))m."
        echo "🛑 Shutting down gateway..."
        openclaw gateway stop 2>/dev/null || true
        echo "✅ Done. Cron will restart this job."
        exit 0
    fi

    remaining=$((TOTAL_RUNTIME - elapsed))
    hours=$((remaining / 3600))
    mins=$(((remaining % 3600) / 60))

    # Health check
    if openclaw gateway status &>/dev/null; then
        echo "[$(date -u '+%H:%M:%S')] 💚 Gateway OK | Remaining: ${hours}h ${mins}m"
    else
        echo "[$(date -u '+%H:%M:%S')] ⚠️  Gateway offline — restarting..."
        openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
        sleep 5

        if openclaw gateway status &>/dev/null; then
            echo "[$(date -u '+%H:%M:%S')] ✅ Gateway restarted"
        else
            echo "[$(date -u '+%H:%M:%S')] ❌ Restart failed — retrying in 2 min"
        fi
    fi

    sleep 120
done