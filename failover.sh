#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — GitHub Actions Node
#  Uses ONLY verified, documented commands from method.md
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/tmp/openclaw-node.log"
TOTAL_RUNTIME=20700  # ~5h 45m
SKILL_DIR="$HOME/.openclaw/skills/rent-my-browser"
GATEWAY_PID_FILE="/tmp/openclaw-gateway.pid"

# ── Helper: kill existing background gateway process ────────
stop_gateway_process() {
    if [[ -f "$GATEWAY_PID_FILE" ]]; then
        OLD_PID=$(cat "$GATEWAY_PID_FILE")
        kill "$OLD_PID" 2>/dev/null || true
        rm -f "$GATEWAY_PID_FILE"
    fi
    pkill -f "openclaw gateway" 2>/dev/null || true
}

# ── Helper: start gateway in background and record PID ──────
start_gateway_background() {
    nohup openclaw gateway >> "$LOG_FILE" 2>&1 &
    GATEWAY_PID=$!
    echo "$GATEWAY_PID" > "$GATEWAY_PID_FILE"
    echo "🚀 Gateway started in background (PID: $GATEWAY_PID)"
}

echo "════════════════════════════════════════════"
echo "🚀 Starting Rent My Browser Node"
echo "⏰ $(date -u)"
echo "════════════════════════════════════════════"

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "❌ GEMINI_API_KEY not set in GitHub Secrets. Aborting."
    exit 1
fi
echo "✅ Gemini API key found"

if [[ -z "${RMB_API_KEY:-}" ]]; then
    echo "❌ RMB_API_KEY not set in GitHub Secrets. Aborting."
    exit 1
fi
echo "✅ RMB API key found"

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
stop_gateway_process
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

openclaw onboard \
  --non-interactive \
  --mode local \
  --workspace ~/.openclaw/workspace \
  --auth-choice apiKey \
  --secret-input-mode plaintext \
  --gateway-port 18789 \
  --gateway-bind loopback \
  --skip-skills \
  --skip-health \
  --accept-risk \
  2>&1 | tee -a "$LOG_FILE"

ONBOARD_EXIT=${PIPESTATUS[0]}
if [[ $ONBOARD_EXIT -ne 0 ]]; then
    echo "❌ Onboarding failed (exit $ONBOARD_EXIT). Check $LOG_FILE."
    exit 1
fi
echo "✅ Onboarding complete"

# ── Start gateway explicitly (CI-safe — no systemd) ──────────
echo ""
echo "🚀 Starting gateway (manual CI-safe)..."
# Run gateway directly in background (systemd is not available in GitHub Actions)
start_gateway_background

# Ensure netcat is available for port check
if ! command -v nc >/dev/null 2>&1; then
    echo "📦 Installing netcat-openbsd..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq netcat-openbsd
fi

# Wait up to 60 seconds for TCP port 18789 to be listening
echo "⏳ Waiting for gateway port 18789..."
gateway_ready=false
for i in {1..60}; do
    if nc -z 127.0.0.1 18789 2>/dev/null; then
        echo "✅ Gateway is listening on 127.0.0.1:18789 (after ${i}s)"
        gateway_ready=true
        break
    fi
    sleep 1
done

if [[ $gateway_ready == false ]]; then
    echo "❌ Gateway failed to listen on 127.0.0.1:18789 after 60s"
    echo "---- gateway status ----"
    openclaw gateway status 2>&1 | tee -a "$LOG_FILE" || true
    echo "---- recent log ----"
    tail -n 200 "$LOG_FILE" || true
    exit 1
fi

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
openclaw skills add --local "$SKILL_DIR" 2>&1 | tee -a "$LOG_FILE" || {
    echo "⚠️  Skill registration had issues — check $LOG_FILE. Continuing..."
}
sleep 3

echo "🌐 Connecting node to Rent My Browser marketplace..."
export RMB_API_KEY
bash "$SKILL_DIR/scripts/connect.sh" 2>&1 | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to connect to marketplace. Check $LOG_FILE."
    exit 1
fi
echo "✅ Node connected to marketplace — cron job registered"

# ── 6. Gateway already started and verified above ────────────
echo ""
echo "✅ Gateway is ready (verified via port check)"

echo ""
echo "════════════════════════════════════════════"
echo "✅ NODE IS ONLINE"
echo "💰 Expected: \$0.04–0.12 per task"
echo "⏱️  Will run for ~5h 45m then exit for cron restart"
echo "════════════════════════════════════════════"
echo ""

# ── 7. Keep-alive loop (cron handles task polling) ──────────
start_time=$(date +%s)
echo "💤 Node is live. Cron polls every 10s for tasks automatically."

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [[ $elapsed -ge $TOTAL_RUNTIME ]]; then
        echo "⏱️  Time limit reached. Disconnecting..."
        bash "$SKILL_DIR/scripts/disconnect.sh" 2>/dev/null || true
        stop_gateway_process
        openclaw gateway stop 2>/dev/null || true
        echo "✅ Done. Cron will restart this job."
        exit 0
    fi

    remaining=$((TOTAL_RUNTIME - elapsed))
    echo "[$(date -u '+%H:%M:%S')] 💚 Running | Remaining: $((remaining/3600))h $(((remaining%3600)/60))m"
    sleep 300
done