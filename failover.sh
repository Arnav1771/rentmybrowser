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

    echo "📥 Installing rent-my-browser skill..."
    clawhub install 0xPasho/rent-my-browser

    sleep 5
    CURRENT_MODEL="$model"
    FAILURE_COUNT=0
    echo "✅ Now running on: $model"
}

# ─── Switch to next Gemini model ───
switch_model() {
    MODEL_INDEX=$(( (MODEL_INDEX + 1) % ${#MODELS[@]} ))
    local next_model="${MODELS[$MODEL_INDEX]}"

    echo ""
    echo "⚠️  Rate limit hit on $CURRENT_MODEL → switching to $next_model"
    echo ""

    onboard_model "$next_model"
}

# ─── Check gateway health ───
check_health() {
    if ! openclaw gateway status &>/dev/null; then
        return 1
    fi

    # Check logs for rate limit signals
    if [[ -f "$LOG_FILE" ]]; then
        local recent_errors
        recent_errors=$(tail -50 "$LOG_FILE" 2>/dev/null | grep -ci "rate.limit\|429\|quota\|exceeded\|too.many.requests\|resource.exhausted" || true)
        if [[ "$recent_errors" -gt 3 ]]; then
            echo "⚠️  Rate limit errors detected ($recent_errors in recent logs)"
            return 1
        fi
    fi

    return 0
}

# ═══════════════════════════════════════════
#  START: Begin with first model
# ═══════════════════════════════════════════

onboard_model "${MODELS[0]}"

echo ""
echo "============================================"
echo "  🌐 Browser Node is ONLINE and earning!"
echo "  🤖 Model: $CURRENT_MODEL"
echo "  🔄 Failover: ${#MODELS[@]} Gemini models"
echo "  ⏰ $(date -u)"
echo "============================================"
echo ""

# ─── Health monitoring loop ───
ELAPSED=0

while [[ $ELAPSED -lt $TOTAL_RUNTIME ]]; do
    sleep $HEALTH_CHECK_INTERVAL
    ELAPSED=$((ELAPSED + HEALTH_CHECK_INTERVAL))

    REMAINING=$((TOTAL_RUNTIME - ELAPSED))
    HOURS=$((REMAINING / 3600))
    MINS=$(( (REMAINING % 3600) / 60 ))

    if check_health; then
        FAILURE_COUNT=0
        echo "[$(date -u)] 💚 OK | Model: $CURRENT_MODEL | Remaining: ${HOURS}h ${MINS}m"
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo "[$(date -u)] 🔴 FAIL ($FAILURE_COUNT/$MAX_FAILURES) | Model: $CURRENT_MODEL | Remaining: ${HOURS}h ${MINS}m"

        if [[ $FAILURE_COUNT -ge $MAX_FAILURES ]]; then
            switch_model
        fi
    fi
done

echo "⏰ Graceful shutdown — cron restarts shortly."
openclaw gateway stop 2>/dev/null || true
