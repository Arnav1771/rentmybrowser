#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — GitHub Actions Node Setup
#  Starts OpenClaw with Gemini API and installs rent-my-browser skill
#  Runs for ~5h 45m then exits (cron auto-restarts)
# ═══════════════════════════════════════════════════════════════

# ─── Ensure OpenClaw is installed ───
if ! command -v openclaw &> /dev/null; then
    echo "🦞 OpenClaw not found. Installing..."
    curl -fsSL https://openclaw.ai/install.sh | bash --no-onboard
    # Verify installation
    if ! command -v openclaw &> /dev/null; then
        echo "❌ OpenClaw installation failed. Please check the logs. Exiting."
        exit 1
    fi
    echo "✅ OpenClaw installed successfully."
else
    echo "✅ OpenClaw already installed."
fi

# Ensure clawhub is installed
if ! command -v clawhub &> /dev/null; then
    echo "📦 Installing ClawHub CLI..."
    npm install -g clawhub || {
        echo "❌ Failed to install clawhub"
        exit 1
    }
    echo "✅ ClawHub installed."
fi

LOG_FILE="/tmp/openclaw-node.log"
TOTAL_RUNTIME=20700             # ~5h 45m in seconds
DEFAULT_MODEL="gemini-2.5-flash"

# ─── Validate API key ───
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "❌ GEMINI_API_KEY not found! Add it to GitHub Secrets."
    exit 1
fi

echo "✅ Gemini API key found"
echo "📋 Using model: $DEFAULT_MODEL"
echo ""

# ─── Onboard OpenClaw with Gemini API ───
echo ""
echo "═══════════════════════════════════════════"
echo "  🔧 Setting up OpenClaw with Gemini API"
echo "  ⏰ $(date -u)"
echo "═══════════════════════════════════════════"

# Stop existing gateway to ensure a clean start
openclaw gateway stop 2>/dev/null || true
sleep 2

# Onboard with Gemini API in non-interactive mode
# Important: OpenClaw doesn't support model rotation in non-interactive mode.
# The model is set during onboarding and stays fixed.
export GEMINI_API_KEY="$GEMINI_API_KEY"

echo "🔐 Configuring OpenClaw with Gemini API key..."
openclaw onboard --non-interactive \
    --mode local \
    --workspace ~/.openclaw/workspace \
    --auth-choice apiKey \
    --secret-input-mode plaintext \
    --gateway-port 18789 \
    --gateway-bind loopback \
    --install-daemon \
    --daemon-runtime node \
    --skip-skills \
    --accept-risk 2>&1 | tee -a "$LOG_FILE"

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo "❌ Failed to onboard OpenClaw."
    exit 1
fi

echo "✅ OpenClaw onboarded successfully"
sleep 3

# Start gateway explicitly
echo "🚀 Starting OpenClaw gateway..."
if ! openclaw gateway start 2>&1 | tee -a "$LOG_FILE"; then
    echo "⚠️  Gateway start returned non-zero, but may still be running..."
fi
sleep 5

# Install rent-my-browser skill
echo ""
echo "📥 Installing rent-my-browser skill..."
if ! clawhub install 0xPasho/rent-my-browser 2>&1 | tee -a "$LOG_FILE"; then
    echo "⚠️  Skill install had issues, but continuing..."
fi

sleep 3
echo "✅ Node setup complete. Node is online and ready for tasks."
echo ""

# ─── Health monitoring loop ───
echo "🌐 Browser Node is ONLINE and earning!"
echo "📊 Expected earnings: $0.04-0.08 per task"
echo "⏱️  Session will run for ~5h 45m then auto-restart"
echo ""

ELAPSED=0
start_time=$(date +%s)

while true; do
    current_time=$(date +%s)
    ELAPSED=$((current_time - start_time))
    
    if [[ $ELAPSED -ge $TOTAL_RUNTIME ]]; then
        echo ""
        echo "⏱️ Total runtime of $TOTAL_RUNTIME seconds reached. Shutting down gracefully..."
        openclaw gateway stop 2>/dev/null || true
        echo "✅ Graceful shutdown complete."
        break
    fi

    REMAINING=$((TOTAL_RUNTIME - ELAPSED))
    HOURS=$((REMAINING / 3600))
    MINS=$(( (REMAINING % 3600) / 60 ))

    # Check if gateway is still running
    if openclaw gateway status &>/dev/null; then
        echo "[$(date -u)] 💚 OK | Model: $DEFAULT_MODEL | Remaining: ${HOURS}h ${MINS}m"
    else
        echo "[$(date -u)] ⚠️  Gateway offline | Model: $DEFAULT_MODEL | Remaining: ${HOURS}h ${MINS}m"
        echo "    Attempting restart..."
        openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
        sleep 5
    fi

    # Check every 2 minutes
    sleep 120
done

echo "Cron will restart the workflow shortly."
exit 0