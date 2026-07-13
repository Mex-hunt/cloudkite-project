#!/usr/bin/env bash
set -euo pipefail

APP_VERSION="${APP_VERSION:?APP_VERSION is required}"
DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-obachimex}"
FRONTEND_VALUES="${FRONTEND_VALUES:-deploy/production/values/cloudkite/frontend.yaml}"
BACKEND_VALUES="${BACKEND_VALUES:-deploy/production/values/cloudkite/backend.yaml}"

update_image_values() {
  local values_file="$1"
  local repository="$2"
  local tag="$3"
  local tmp_file

  tmp_file="$(mktemp)"
  awk -v repository="$repository" -v tag="$tag" '
    /^  image:[[:space:]]*$/ {
      in_image = 1
      print
      next
    }
    in_image && /^  [^[:space:]-][^:]*:/ {
      in_image = 0
    }
    in_image && /^    repository:/ {
      print "    repository: " repository
      next
    }
    in_image && /^    tag:/ {
      print "    tag: " tag
      next
    }
    { print }
  ' "$values_file" > "$tmp_file"
  mv "$tmp_file" "$values_file"
}

update_env_value() {
  local values_file="$1"
  local env_name="$2"
  local env_value="$3"
  local tmp_file

  tmp_file="$(mktemp)"
  awk -v env_name="$env_name" -v env_value="$env_value" '
    $0 ~ "^    - name: " env_name "[[:space:]]*$" {
      in_env = 1
      print
      next
    }
    in_env && /^      value:/ {
      print "      value: " env_value
      in_env = 0
      next
    }
    in_env && /^    - name:/ {
      in_env = 0
    }
    { print }
  ' "$values_file" > "$tmp_file"
  mv "$tmp_file" "$values_file"
}

update_image_values \
  "$FRONTEND_VALUES" \
  "${DOCKERHUB_NAMESPACE}/cloudkite-frontend" \
  "$APP_VERSION"

update_env_value "$FRONTEND_VALUES" VITE_APP_VERSION "$APP_VERSION"

update_image_values \
  "$BACKEND_VALUES" \
  "${DOCKERHUB_NAMESPACE}/cloudkite-backend" \
  "$APP_VERSION"

echo "Prepared Cloudkite deployment values for ${APP_VERSION}"
