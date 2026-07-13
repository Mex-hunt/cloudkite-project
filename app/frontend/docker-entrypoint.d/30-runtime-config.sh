#!/bin/sh
set -eu

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

CONFIG_JS_PATH="${CLOUDKITE_CONFIG_PATH:-/usr/share/nginx/html/config.js}"

cat > "$CONFIG_JS_PATH" <<EOF
window.__CLOUDKITE_CONFIG__ = {
  apiBaseUrl: "$(json_escape "${VITE_API_BASE_URL:-http://localhost:8000}")",
  appVersion: "$(json_escape "${VITE_APP_VERSION:-0.1.0}")",
  environment: "$(json_escape "${VITE_ENVIRONMENT:-local}")"
};
EOF
