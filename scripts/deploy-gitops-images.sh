#!/usr/bin/env bash
set -euo pipefail

APP_VERSION="${APP_VERSION:?APP_VERSION is required}"
DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-obachimex}"
FRONTEND_VALUES="${FRONTEND_VALUES:-deploy/production/values/cloudkite/frontend.yaml}"
BACKEND_VALUES="${BACKEND_VALUES:-deploy/production/values/cloudkite/backend.yaml}"

update_image() {
  local path="$1"
  local repository="$2"
  local version="$3"
  local tmp

  tmp="$(mktemp)"

  awk -v repository="$repository" -v version="$version" '
    /^  image:[[:space:]]*$/ {
      in_image = 1
      print
      next
    }

    in_image && /^  [A-Za-z0-9_-]+:/ {
      in_image = 0
    }

    in_image && /^    repository:/ {
      sub(/repository:.*/, "repository: " repository)
      updated_repository = 1
    }

    in_image && /^    tag:/ {
      sub(/tag:.*/, "tag: " version)
      updated_tag = 1
    }

    { print }

    END {
      if (!updated_repository) {
        print "Could not update image.repository in " FILENAME > "/dev/stderr"
        exit 1
      }
      if (!updated_tag) {
        print "Could not update image.tag in " FILENAME > "/dev/stderr"
        exit 1
      }
    }
  ' "$path" > "$tmp"

  mv "$tmp" "$path"
}

update_env_value() {
  local path="$1"
  local name="$2"
  local value="$3"
  local tmp

  tmp="$(mktemp)"

  awk -v name="$name" -v value="$value" '
    $0 ~ "^[[:space:]]*- name: " name "[[:space:]]*$" {
      pending_value_update = 1
      print
      next
    }

    pending_value_update && /^[[:space:]]+value:/ {
      sub(/value:.*/, "value: " value)
      updated = 1
      pending_value_update = 0
      print
      next
    }

    pending_value_update && /^[[:space:]]*- name:/ {
      pending_value_update = 0
    }

    { print }

    END {
      if (!updated) {
        print "Could not update env " name " in " FILENAME > "/dev/stderr"
        exit 1
      }
    }
  ' "$path" > "$tmp"

  mv "$tmp" "$path"
}

update_image "$FRONTEND_VALUES" "${DOCKERHUB_NAMESPACE}/cloudkite-frontend" "$APP_VERSION"
update_env_value "$FRONTEND_VALUES" "VITE_APP_VERSION" "$APP_VERSION"
update_image "$BACKEND_VALUES" "${DOCKERHUB_NAMESPACE}/cloudkite-backend" "$APP_VERSION"

echo "Prepared Cloudkite deployment values for ${APP_VERSION}"
