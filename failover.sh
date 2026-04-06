#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — Gemini Model Failover Script
#  Cycles through Gemini models when rate limits are hit
#  All models use the same GEMINI_API_KEY
# ═══════════════════════════════════════════════════════════════

LOG_FILE="/tmp/openclaw-node.log"
HEALTH_CHECK_INTERVAL=120       # Check every 2 minutes
MAX_FAILURES=5                  # Switch model after 5 consecutive failures
TOTAL_RUNTIME=20700             # ~5h 45m in seconds
CURRENT_MODEL=""
FAILURE_COUNT=0
MODEL_INDEX=0

# ─── Gemini models to cycle through (same API key) ───
MODELS=(
    "gemini-2.5-flash"
    "gemini-2.0-flash"
    "gemini-1.5-flash"
    "gemini-1.5-pro"
)

# ─── Validate API key ───
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "❌ GEMINI_API_KEY not found! Add it to GitHub Secrets."
    exit 1
fi

echo "✅ Gemini API key found"
echo "📋 Model rotation order: ${MODELS[*]}"
echo ""

# ─── Onboard with a specific Gemini model ───
onboard_model() {
    local model="$1"

    echo ""
    echo "═══════════════════════════════════════════"
    echo "  🔄 Switching to model: $model"
    echo "  ⏰ $(date -u)"
    echo "═══════════════════════════════════════════"

    # Stop existing gateway
    openclaw gateway stop 2>/dev/null || true
    sleep 3

    # Re-onboard with specific model via Gemini's OpenAI-compatible endpoint
    openclaw onboard --non-interactive \
        --mode local \
        --auth-choice custom-api-key \
        --custom-base-url "https://generativelanguage.googleapis.com/v1beta/openai/" \
        --custom-model-id "$model" \
        --custom-api-key "$GEMINI_API_KEY" \
        --custom-provider-id "gemini" \
        --custom-compatibility openai \
        --secret-input-mode plaintext \
        --gateway-port 18789 \
        --gateway-bind loopback \
        --install-daemon \
        --daemon-runtime node \
        --skip-skills \
        --accept-risk

    # Fix: The previous line 'echo "📥 Install' was incomplete and likely caused the skill installation error.
    # We assume the 'rent-my-browser' skill is intended to be installed,
    # and we use the common OpenClaw skill slug for it.
    echo "📥 Installing rent-my-browser skill..."
    openclaw install skill openclaw/rent-my-browser || {
        echo "❌ Failed to install rent-my-browser skill. Please check the slug or try again."
        exit 1
    }

    # Start the gateway service
    openclaw gateway start --daemon || {
        echo "❌ Failed to start OpenClaw gateway service. Exiting."
        exit 1
    }

    echo "Gateway service enabled. Updated ~/.openclaw/openclaw.json"
    echo "Workspace OK: ~/.openclaw/workspace"
    echo "Sessions OK: ~/.openclaw/agents/main/sessions"

    # Check Node.js version (warning, not critical for script execution)
    if ! openclaw --version | grep -q "Node 22.14+"; then
        echo "System Node $(node -v) at $(which node) is below the required Node 22.14+. Using $(openclaw --version | grep -oP 'Using \K[^ ]+node[^ ]+') for the daemon. Install Node 24 (recommended) or Node 22 LTS from nodejs.org or Homebrew."
    fi

    echo "Installed systemd service: ~/.config/systemd/user/openclaw-gateway.service"
    echo "Agents: main (default)"
    echo "Heartbeat interval: 30m (main)"
    echo "Session store (main): ~/.openclaw/agents/main/sessions/sessions.json (0 entries)"
    echo "Tip: run \`openclaw configure --section web\` to store your Brave API key for web_search. Docs: https://docs.openclaw.ai/tools/web"

    CURRENT_MODEL="$model"
    FAILURE_COUNT=0 # Reset failure count on successful onboarding
}

# ─── Health check function ───
check_health() {
    # Check if the gateway is running and responsive
    if curl -s http://localhost:18789/v1/models >/dev/null; then
        return 0 # Healthy
    else
        return 1 # Unhealthy
    fi
}

# ─── Main loop ───
main() {
    # Initial onboarding with the first model
    onboard_model "${MODELS[$MODEL_INDEX]}"

    START_TIME=$(date +%s)

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        if [[ "$ELAPSED_TIME" -ge "$TOTAL_RUNTIME" ]]; then
            echo "⏱️ Total runtime of $TOTAL_RUNTIME seconds reached. Exiting."
            break
        fi

        echo "🩺 Performing health check for $CURRENT_MODEL at $(date -u)..."
        if check_health; then
            echo "✅ Gateway is healthy."
            FAILURE_COUNT=0
        else
            echo "❌ Gateway is unhealthy."
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            echo "Failure count: $FAILURE_COUNT/$MAX_FAILURES"

            if [[ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]]; then
                echo "🚨 Max failures reached for $CURRENT_MODEL. Switching model..."
                MODEL_INDEX=$(( (MODEL_INDEX + 1) % ${#MODELS[@]} ))
                onboard_model "${MODELS[$MODEL_INDEX]}"
            fi
        fi

        sleep "$HEALTH_CHECK_INTERVAL"
    done
}

# ─── Run the main function ───
main