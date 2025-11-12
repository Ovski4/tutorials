#!/bin/bash

# configuration
ENV_FILE="/path/to/.env"
LOG_FILE="/tmp/ngrok.log"
APP_PAYPAL_WEBHOOK_PATH='/paypal-webhook'
APP_DOMAIN=my-application.local
EVENT_TYPES=(
  "PAYMENT.CAPTURE.REFUNDED"
  "PAYMENT.CAPTURE.DENIED"
  "PAYMENT.AUTHORIZATION.CREATED"
  "PAYMENT.AUTHORIZATION.VOIDED"
  "CHECKOUT.ORDER.APPROVED"
  # List the events you want to listen to here
)

# globals (populated at runtime)
NGROK_PID=""
NGROK_PUBLIC_URL=""
ACCESS_TOKEN=""
PAYPAL_WEBHOOK_URL=""
PAYPAL_WEBHOOK_ID=""
PAYPAL_API_CLIENT_ID=""
PAYPAL_API_SECRET=""
CLEANUP_DONE=0

checkForDependencies() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is not installed. Please install it first." >&2
    echo "macOS: brew install jq" >&2
    echo "Ubuntu/Debian: sudo apt install jq" >&2
    exit 1
  fi

  if ! command -v ngrok >/dev/null 2>&1; then
    echo "Error: 'ngrok' is not installed. Please install it first." >&2
    echo "Install it from https://ngrok.com/download" >&2
    exit 1
  fi
}

getPayPalEnvVars() {
  PAYPAL_API_CLIENT_ID=$(grep -E '^PAYPAL_API_CLIENT_ID=' "$ENV_FILE" | cut -d '=' -f2-)
  PAYPAL_API_SECRET=$(grep -E '^PAYPAL_API_SECRET=' "$ENV_FILE" | cut -d '=' -f2-)
  PAYPAL_WEBHOOK_ID=$(grep -E '^PAYPAL_WEBHOOK_ID=' "$ENV_FILE" | cut -d '=' -f2-)

  if [ -z "$PAYPAL_API_CLIENT_ID" ] || [ -z "$PAYPAL_API_SECRET" ]; then
    echo "Missing PAYPAL_API_CLIENT_ID or PAYPAL_API_SECRET in $ENV_FILE"
    exit 1
  fi

  if [ -z "${PAYPAL_WEBHOOK_ID:-}" ]; then
    echo "Missing PAYPAL_WEBHOOK_ID in $ENV_FILE"
    exit 1
  fi
}

getPayPalAccessToken() {
  ACCESS_TOKEN=$(curl -s -u "$PAYPAL_API_CLIENT_ID:$PAYPAL_API_SECRET" \
    -d "grant_type=client_credentials" \
    "https://api-m.sandbox.paypal.com/v1/oauth2/token" | jq -r '.access_token')

  if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Failed to retrieve PayPal access token. Check credentials or network."
    exit 1
  fi
}

startNgrok() {
  echo "Starting ngrok..."

  ngrok http --host-header=$APP_DOMAIN https://$APP_DOMAIN > "$LOG_FILE" 2>&1 &
  NGROK_PID=$!

  # Ensure we clean up ngrok when this script exits
  trap 'echo "Cleaning up: killing ngrok process (PID $NGROK_PID)..."; kill "$NGROK_PID" >/dev/null 2>&1 || true' EXIT

  # Wait until ngrok’s local API is up
  echo "Waiting for ngrok to start..."

  until curl -s -f http://127.0.0.1:4040/api/tunnels > /dev/null; do
    sleep 0.5
  done

  # Extra wait to ensure tunnels are ready
  sleep 0.5

  echo "ngrok is ready!"
}

getNgrokPublicUrl() {
  NGROK_PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -Eo 'https://[^"]+' | head -n 1)

  echo "Public URL: $NGROK_PUBLIC_URL"
}

createPayPalWebhook() {
  local paypal_webhook_url="${NGROK_PUBLIC_URL}${APP_PAYPAL_WEBHOOK_PATH}"
  echo "Creating PayPal webhook with URL: $paypal_webhook_url"

  local events_json
  events_json="$(printf '%s\n' "${EVENT_TYPES[@]}" | jq -R . | jq -s 'map({name:.})')"

  local body
  body=$(jq -n --arg url "$paypal_webhook_url" --argjson types "$events_json" '{url:$url, event_types:$types}')

  local response_file="$(mktemp)"
  local http_code=$(curl -sS -o "$response_file" -w "%{http_code}" -X POST \
    "https://api-m.sandbox.paypal.com/v1/notifications/webhooks" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "$body")

  if [[ "$http_code" != "201" && "$http_code" != "200" ]]; then
    echo "Failed to create webhook. HTTP $http_code" >&2
    echo "🔎 Server response:"
    rm -f "$response_file"
    exit 1
  fi

  PAYPAL_WEBHOOK_ID=$(jq -r '.id // empty' < "$response_file")
  rm -f "$response_file"

  if [[ -z "${PAYPAL_WEBHOOK_ID:-}" ]]; then
    echo "Webhook creation succeeded but no ID was returned." >&2
    exit 1
  fi

  echo "Webhook created: ${PAYPAL_WEBHOOK_ID}"
}

updatePayPalWebhookIdInEnvFile() {
  if sed --version >/dev/null 2>&1; then
    # GNU sed (Linux)
    sed -i -E "s|^PAYPAL_WEBHOOK_ID=.*|PAYPAL_WEBHOOK_ID=${PAYPAL_WEBHOOK_ID}|" "$ENV_FILE"
  else
    # BSD sed (macOS)
    sed -i '' -E "s|^PAYPAL_WEBHOOK_ID=.*|PAYPAL_WEBHOOK_ID=${PAYPAL_WEBHOOK_ID}|" "$ENV_FILE"
  fi

  echo "PAYPAL_WEBHOOK_ID updated in .env file"
}

deletePayPalWebhook() {
  if [[ -z "${PAYPAL_WEBHOOK_ID:-}" ]]; then
    return
  fi

  echo "- Deleting PayPal webhook: $PAYPAL_WEBHOOK_ID"

  local http_code=$(curl -sS -o /dev/null -w "%{http_code}" -X DELETE \
    "https://api-m.sandbox.paypal.com/v1/notifications/webhooks/$PAYPAL_WEBHOOK_ID" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

  if [[ "$http_code" != "204" ]]; then
    echo "Failed to delete existing webhook. HTTP $http_code" >&2
    exit 1
  fi
}

killNgrokProcess() {
  if [[ -n "${NGROK_PID:-}" ]]; then
    echo "- Killing ngrok process (PID $NGROK_PID)..."
    kill "$NGROK_PID" >/dev/null 2>&1 || true
  fi
}

cleanupOnExit() {
  if [[ "$CLEANUP_DONE" -eq 1 ]]; then
    return;
  fi

  CLEANUP_DONE=1

  echo "Cleaning up..."

  deletePayPalWebhook
  killNgrokProcess

  echo "All done. Exiting."
}

checkForDependencies
getPayPalEnvVars
getPayPalAccessToken
startNgrok
getNgrokPublicUrl
createPayPalWebhook
updatePayPalWebhookIdInEnvFile

trap 'cleanupOnExit' INT TERM EXIT

echo "Ready to receive webhook events. Press Ctrl+C to terminate."

wait "$NGROK_PID"
