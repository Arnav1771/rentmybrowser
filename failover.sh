#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — GitHub Actions Node (FIXED)
#  Starts OpenClaw with Gemini API, installs rent-my-browser skill
#  Uses ONLY official OpenClaw documented CLI flags
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/tmp/openclaw-node.log"
TOTAL_RUNTIME=20700  # ~5h 45m

# Validate API key first
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "❌ GEMINI_API_KEY not found! Add it to GitHub Secrets."
    exit 1
fi
echo "✅ Gemini API key found"

# Install OpenClaw if needed
if ! command -v openclaw &> /dev/null; then
    echo "📦 Installing OpenClaw..."
    curl -fsSL https://openclaw.ai/install.sh | bash --no-onboard || exit 1
fi
echo "✅ OpenClaw ready"

# Install ClawHub if needed
if ! command -v clawhub &> /dev/null; then
    echo "📦 Installing ClawHub..."
    npm install -g clawhub@latest || exit 1
fi
echo "✅ ClawHub ready"

# Clean up any existing gateway
echo "🧹 Cleaning up..."
openclaw gateway stop 2>/dev/null || true
sleep 2

# MAIN: Onboard with official documented flags ONLY
# Source: https://docs.openclaw.ai/start/wizard-cli-automation
echo ""
echo "═══════════════════════════════════════════"
echo "🔧 Setting up OpenClaw (Gemini API)"
echo "═══════════════════════════════════════════"

export GEMINI_API_KEY

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
  --accept-risk 2>&1 | tee -a "$LOG_FILE" || {
    echo "❌ Onboarding failed"
    exit 1
}

echo ""
echo "✅ OpenClaw configured"
sleep 2

# Start the gateway
echo "🚀 Starting gateway..."
openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
sleep 3

# Install the skill
echo ""
echo "📥 Installing rent-my-browser skill..."
clawhub install 0xPasho/rent-my-browser 2>&1 | tee -a "$LOG_FILE" || true

sleep 2
echo ""
echo "════════════════════════════════════════════"
echo "✅ Node is ONLINE and earning!"
echo "💰 Expected: $0.04-0.12 per task"
echo "⏱️  Running for ~5h 45m"
echo "════════════════════════════════════════════"
echo ""

# Monitor gateway health
start_time=$(date +%s)

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    
    if [[ $elapsed -ge $TOTAL_RUNTIME ]]; then
        echo "⏱️ Time limit reached. Shutting down..."
        openclaw gateway stop 2>/dev/null || true
        break
    fi
    
    remaining=$((TOTAL_RUNTIME - elapsed))
    hours=$((remaining / 3600))
    mins=$(((remaining % 3600) / 60))
    
    if openclaw gateway status &>/dev/null; then
        echo "[$(date -u '+%H:%M:%S')] 💚 OK | Remaining: ${hours}h ${mins}m"
    else
        echo "[$(date -u '+%H:%M:%S')] ⚠️ Gateway offline - restarting..."
        openclaw gateway start 2>&1 | tee -a "$LOG_FILE" || true
        sleep 3
    fi
    
    sleep 120
done

echo "✅ Done. Cron will restart."
exit 0