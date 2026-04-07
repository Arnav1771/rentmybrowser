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

    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to onboard with model $model. Retrying with next model."
        return 1
    fi

    echo "📥 Installing rent-my-browser skill..."
    clawhub install 0xPasho/rent-my-browser

    sleep 5
    CURRENT_MODEL="$model"
    FAILURE_COUNT=0 # Reset failure count on successful onboard and skill install
    return 0 # Indicate success
}

# ─── Main loop ───
start_time=$(date +%s)

# Initial onboarding
onboard_model "${MODELS[$MODEL_INDEX]}" || exit 1

while true; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [[ "$elapsed_time" -ge "$TOTAL_RUNTIME" ]]; then
        echo "⏱️ Total runtime of $TOTAL_RUNTIME seconds reached. Exiting."
        break
    fi

    echo "🩺 Performing health check for $CURRENT_MODEL at $(date -u)..."
    # Check if the OpenClaw gateway is running and responsive
    # We can use `openclaw status` or try a simple command.
    # For now, let's assume the gateway is managed by systemd and check its status.
    # A more robust check would involve trying to use the model.

    # Check if the gateway service is active
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        echo "✅ OpenClaw gateway service is active."
        FAILURE_COUNT=0 # Reset failure count if gateway is active
    else
        echo "❌ OpenClaw gateway service is not active."
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo "Failure count: $FAILURE_COUNT/$MAX_FAILURES"

        if [[ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]]; then
            echo "🚨 Max failures reached for $CURRENT_MODEL. Switching model."
            MODEL_INDEX=$(( (MODEL_INDEX + 1) % ${#MODELS[@]} ))
            if ! onboard_model "${MODELS[$MODEL_INDEX]}"; then
                echo "Fatal: Failed to onboard with all models. Exiting."
                exit 1
            fi
        fi
    fi

    sleep "$HEALTH_CHECK_INTERVAL"
done

echo "Script finished."
exit 0