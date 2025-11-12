#!/bin/bash

# configuration
LOG_FILE="/tmp/ngrok.log"
PAYPAL_API_CLIENT_ID=xxxx
PAYPAL_API_SECRET=xxxx
PAYPAL_WEBHOOK_ID=xxxx
APP_PAYPAL_WEBHOOK_PATH='/paypal-webhook'
APP_DOMAIN=my-application.local

# globals (populated at runtime)
NGROK_PID=""
NGROK_PUBLIC_URL=""
ACCESS_TOKEN=""
PAYPAL_WEBHOOK_URL=""
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

updatePayPalWebhookUrl() {
  local paypal_webhook_url="${NGROK_PUBLIC_URL}${APP_PAYPAL_WEBHOOK_PATH}"
  echo "Updating PayPal webhook ($PAYPAL_WEBHOOK_ID) to: $paypal_webhook_url"

  local body=$(jq -n --arg url "$paypal_webhook_url" '[{op:"replace", path:"/url", value:$url}]')

  local response_file="$(mktemp)"
  local http_code=$(curl -sS -o "$response_file" -w "%{http_code}" -X PATCH \
    "https://api-m.sandbox.paypal.com/v1/notifications/webhooks/$PAYPAL_WEBHOOK_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "$body")

  if [ "$http_code" = "200" ]; then
    echo "Webhook updated successfully. Run Ctrl+C to terminate."
  elif [ "$http_code" = "204" ]; then
    echo "Webhook updated successfully (no content returned)."
  else
    echo "Failed to update webhook. HTTP $http_code"
    echo "Server response:"
    jq . < "$response_file" || cat "$response_file"
    rm -f "$response_file"
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

  killNgrokProcess

  echo "All done. Exiting."
}

checkForDependencies
getPayPalAccessToken
startNgrok
getNgrokPublicUrl
updatePayPalWebhookUrl

trap 'cleanupOnExit' INT TERM EXIT

wait "$NGROK_PID"
