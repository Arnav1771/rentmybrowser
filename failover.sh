#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — GitHub Actions Node
#  Uses ONLY verified, documented commands from method.md
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/tmp/openclaw-node.log"
GATEWAY_LOG="/tmp/openclaw-gateway.log"
TOTAL_RUNTIME=20700  # ~5h 45m
SKILL_DIR="$HOME/.openclaw/skills/rent-my-browser"

# ── Diagnostic helper ────────────────────────────────────────
dump_gateway_diagnostics() {
    echo ""
    echo "════════ GATEWAY DIAGNOSTICS ════════"
    echo "--- Gateway log (${GATEWAY_LOG}) ---"
    cat "$GATEWAY_LOG" 2>/dev/null || echo "(no gateway log found)"
    echo ""
    echo "--- openclaw gateway status ---"
    openclaw gateway status 2>&1 || true
    echo ""
    echo "--- Running openclaw/node processes ---"
    ps aux | grep -i -E 'openclaw|gateway' | grep -v grep | head -n 30 || true
    echo "════════════════════════════════════"
    echo ""
}

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
# OpenClaw onboarding currently defaults to Anthropic authentication
# We pass GEMINI_API_KEY as ANTHROPIC_API_KEY to satisfy onboarding
# The rent-my-browser skill will use GEMINI_API_KEY from environment for actual requests
export ANTHROPIC_API_KEY="${GEMINI_API_KEY}"

echo "🔑 Using Gemini API key for authentication..."

# NOTE: --install-daemon is intentionally omitted.
# GitHub Actions runners do not support user-level systemd services reliably;
# the gateway is started explicitly below instead.
openclaw onboard \
  --non-interactive \
  --mode local \
  --workspace ~/.openclaw/workspace \
  --auth-choice apiKey \
  --secret-input-mode plaintext \
  --gateway-port 18789 \
  --gateway-bind loopback \
  --skip-skills \
  --accept-risk \
  2>&1 | tee -a "$LOG_FILE"

ONBOARD_EXIT=${PIPESTATUS[0]}
if [[ $ONBOARD_EXIT -ne 0 ]]; then
    echo "❌ Onboarding failed (exit $ONBOARD_EXIT). Check $LOG_FILE."
    exit 1
fi
echo "✅ Onboarding complete"
sleep 2

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

# ── 6. Start gateway explicitly and wait for it ──────────────
echo ""
echo "🚀 Starting gateway explicitly (no systemd)..."

# Kill any stale gateway process first
openclaw gateway stop 2>/dev/null || true
sleep 1

# Start gateway in background, capturing output to GATEWAY_LOG
nohup openclaw gateway start > "$GATEWAY_LOG" 2>&1 &
echo "   Gateway started in background"

# Wait for port 18789 to accept connections (up to 60 seconds)
echo "⏳ Waiting for gateway on 127.0.0.1:18789 (up to 60s)..."
gateway_ready=false
for i in $(seq 1 60); do
    if (echo >/dev/tcp/127.0.0.1/18789) >/dev/null 2>&1; then
        echo "✅ Gateway is up (${i}s)"
        gateway_ready=true
        break
    fi
    sleep 1
done

if [[ "$gateway_ready" == false ]]; then
    echo "❌ Gateway did not become reachable within 60 seconds."
    dump_gateway_diagnostics
    exit 1
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
    if (echo >/dev/tcp/127.0.0.1/18789) >/dev/null 2>&1; then
        echo "[$(date -u '+%H:%M:%S')] 💚 Gateway OK | Remaining: ${hours}h ${mins}m"
    else
        echo "[$(date -u '+%H:%M:%S')] ⚠️  Gateway offline — restarting..."
        openclaw gateway start >> "$GATEWAY_LOG" 2>&1 &
        sleep 5

        if (echo >/dev/tcp/127.0.0.1/18789) >/dev/null 2>&1; then
            echo "[$(date -u '+%H:%M:%S')] ✅ Gateway restarted"
        else
            echo "[$(date -u '+%H:%M:%S')] ❌ Restart failed — retrying in 2 min"
            dump_gateway_diagnostics
        fi
    fi

    sleep 120
done