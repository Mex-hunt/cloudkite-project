#!/usr/bin/env bash
set -euo pipefail

APP_VERSION="${APP_VERSION:?APP_VERSION is required}"
DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-obachimex}"
FRONTEND_VALUES="${FRONTEND_VALUES:-deploy/production/values/cloudkite/frontend.yaml}"
BACKEND_VALUES="${BACKEND_VALUES:-deploy/production/values/cloudkite/backend.yaml}"

# Ensure yq is installed (if not already handled in your cloudbuild.yaml)
if ! command -v yq &> /dev/null; then
  echo "Installing yq..."
  apk add --no-cache yq
fi

#!/usr/bin/env bash
set -euo pipefail

APP_VERSION="${APP_VERSION:?APP_VERSION is required}"
DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-obachimex}"
FRONTEND_VALUES="${FRONTEND_VALUES:-deploy/production/values/cloudkite/frontend.yaml}"
BACKEND_VALUES="${BACKEND_VALUES:-deploy/production/values/cloudkite/backend.yaml}"

# Ensure yq is installed (if not already handled in your cloudbuild.yaml)
if ! command -v yq &> /dev/null; then
  echo "Installing yq..."
  apk add --no-cache yq
fi

#Update Frontend Image and Version
yq eval "
  .image.repository = \"${DOCKERHUB_NAMESPACE}/cloudkite-frontend\" |
  .image.tag = \"${APP_VERSION}\"
" -i "$FRONTEND_VALUES"

# Update the environment variable array element matching VITE_APP_VERSION
yq eval "
  (.env[] | select(.name == \"VITE_APP_VERSION\")).value = \"${APP_VERSION}\"
" -i "$FRONTEND_VALUES"

# 2. Update Backend Image
yq eval "
  .image.repository = \"${DOCKERHUB_NAMESPACE}/cloudkite-backend\" |
  .image.tag = \"${APP_VERSION}\"
" -i "$BACKEND_VALUES"

echo "Prepared Cloudkite deployment values for ${APP_VERSION}"
yq eval "
  .image.repository = \"${DOCKERHUB_NAMESPACE}/cloudkite-frontend\" |
  .image.tag = \"${APP_VERSION}\"
" -i "$FRONTEND_VALUES"

# Update the environment variable array element matching VITE_APP_VERSION
yq eval "
  (.env[] | select(.name == \"VITE_APP_VERSION\")).value = \"${APP_VERSION}\"
" -i "$FRONTEND_VALUES"

#  Update Backend Image
yq eval "
  .image.repository = \"${DOCKERHUB_NAMESPACE}/cloudkite-backend\" |
  .image.tag = \"${APP_VERSION}\"
" -i "$BACKEND_VALUES"

echo "Prepared Cloudkite deployment values for ${APP_VERSION}"