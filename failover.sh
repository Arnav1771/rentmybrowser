#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Rent My Browser — Gemini Model Failover Script
#  Cycles through Gemini models when rate limits are hit
#  All models use the same GEMINI_API_KEY
# ═══════════════════════════════════════════════════════════════

# ─── Ensure OpenClaw is installed ───
if ! command -v openclaw &> /dev/null; then
    echo "🦞 OpenClaw not found. Installing..."
    curl -fsSL https://openclaw.ai/install.sh | bash
    # Verify installation
    if ! command -v openclaw &> /dev/null; then
        echo "❌ OpenClaw installation failed. Please check the logs. Exiting."
        exit 1
    fi
    echo "✅ OpenClaw installed successfully."
else
    echo "✅ OpenClaw already installed."
fi

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

    # Stop existing gateway to ensure a clean start
    openclaw gateway stop 2>/dev/null || true
    sleep 3

    # Re-onboard with specific model via Gemini's OpenAI-compatible endpoint
    # The --install-daemon flag should handle starting the gateway.
    if ! openclaw onboard --non-interactive \
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
        --accept-risk \
        --log-file "$LOG_FILE"; then
        echo "❌ OpenClaw onboarding failed for model $model."
        return 1 # Indicate failure
    fi

    # Verify gateway status after onboarding
    if ! openclaw gateway status &>/dev/null; then
        echo "❌ OpenClaw gateway for model $model is not running after onboarding. Attempting to start explicitly..."
        if ! openclaw gateway start --daemon-runtime node --log-file "$LOG_FILE"; then
            echo "❌ Failed to start OpenClaw gateway for model $model."
            return 1 # Indicate failure to the calling function/loop
        fi
    fi

    echo "✅ OpenClaw gateway for model $model started successfully."
    CURRENT_MODEL="$model"
    FAILURE_COUNT=0 # Reset failure count on successful model switch
    return 0
}

# ─── Main loop ───
start_time=$(date +%s)
end_time=$((start_time + TOTAL_RUNTIME))

# Initial onboarding
echo "🚀 Starting initial onboarding with model: ${MODELS[MODEL_INDEX]}..."
if ! onboard_model "${MODELS[MODEL_INDEX]}"; then
    echo "Fatal: Initial onboarding failed. Exiting."
    exit 1
fi

while true; do
    current_time=$(date +%s)
    if [[ "$current_time" -ge "$end_time" ]]; then
        echo "⏱️ Total runtime reached. Exiting."
        break
    fi

    echo "💖 Health check for model $CURRENT_MODEL at $(date -u)"
    # Perform a health check by checking the gateway status.
    # For a more robust check, consider making a dummy API request through the gateway.
    if openclaw gateway status &>/dev/null; then
        echo "✅ Gateway is healthy."
        FAILURE_COUNT=0
    else
        echo "❌ Gateway for model $CURRENT_MODEL is unhealthy or not running."
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo "  Consecutive failures: $FAILURE_COUNT / $MAX_FAILURES"

        if [[ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]]; then
            echo "🚨 Max failures reached for model $CURRENT_MODEL. Switching model..."
            MODEL_INDEX=$(( (MODEL_INDEX + 1) % ${#MODELS[@]} ))
            if ! onboard_model "${MODELS[MODEL_INDEX]}"; then
                echo "Fatal: Failed to onboard new model ${MODELS[MODEL_INDEX]}. Exiting."
                exit 1
            fi
        fi
    fi

    sleep "$HEALTH_CHECK_INTERVAL"
done

echo "👋 Script finished. Stopping OpenClaw gateway."
openclaw gateway stop 2>/dev/null || true