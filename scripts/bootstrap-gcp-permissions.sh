#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/bootstrap-gcp-permissions.sh PROJECT_ID [PRINCIPAL]

Examples:
  scripts/bootstrap-gcp-permissions.sh chimezie-interview-project
  scripts/bootstrap-gcp-permissions.sh chimezie-interview-project user:name@example.com
  scripts/bootstrap-gcp-permissions.sh chimezie-interview-project serviceAccount:terraform@example.iam.gserviceaccount.com

Notes:
  - PRINCIPAL defaults to the active gcloud account.
  - The caller must already have permission to enable APIs and edit project IAM,
    usually Project Owner during bootstrap.
USAGE
}

PROJECT_ID="${1:-${PROJECT_ID:-}}"
PRINCIPAL="${2:-${PRINCIPAL:-}}"

if [[ -z "${PROJECT_ID}" || "${PROJECT_ID}" == "-h" || "${PROJECT_ID}" == "--help" ]]; then
  usage
  exit 1
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: gcloud CLI is required." >&2
  exit 1
fi

if [[ -z "${PRINCIPAL}" ]]; then
  GCLOUD_ACCOUNT="$(gcloud config get-value account 2>/dev/null || true)"
  if [[ -z "${GCLOUD_ACCOUNT}" ]]; then
    echo "ERROR: No PRINCIPAL passed and no active gcloud account found." >&2
    echo "Run: gcloud auth login" >&2
    exit 1
  fi
  PRINCIPAL="user:${GCLOUD_ACCOUNT}"
elif [[ "${PRINCIPAL}" != *:* ]]; then
  PRINCIPAL="user:${PRINCIPAL}"
fi

BOOTSTRAP_APIS=(
  cloudresourcemanager.googleapis.com
  serviceusage.googleapis.com
)

PROJECT_APIS=(
  artifactregistry.googleapis.com
  cloudbuild.googleapis.com
  compute.googleapis.com
  container.googleapis.com
  dns.googleapis.com
  iam.googleapis.com
  iamcredentials.googleapis.com
  logging.googleapis.com
  monitoring.googleapis.com
  secretmanager.googleapis.com
  servicenetworking.googleapis.com
  sqladmin.googleapis.com
)

TERRAFORM_BOOTSTRAP_ROLES=(
  roles/artifactregistry.admin
  roles/cloudbuild.builds.editor
  roles/cloudbuild.connectionAdmin
  roles/cloudsql.admin
  roles/compute.networkAdmin
  roles/compute.securityAdmin
  roles/container.admin
  roles/dns.admin
  roles/iam.serviceAccountAdmin
  roles/iam.serviceAccountUser
  roles/logging.admin
  roles/monitoring.admin
  roles/resourcemanager.projectIamAdmin
  roles/secretmanager.admin
  roles/servicenetworking.networksAdmin
  roles/serviceusage.serviceUsageAdmin
  roles/storage.admin
)

echo "Project:   ${PROJECT_ID}"
echo "Principal: ${PRINCIPAL}"
echo

echo "Enabling bootstrap APIs..."
gcloud services enable "${BOOTSTRAP_APIS[@]}" \
  --project="${PROJECT_ID}"

echo "Enabling project APIs..."
gcloud services enable "${PROJECT_APIS[@]}" \
  --project="${PROJECT_ID}"

echo "Granting Terraform bootstrap IAM roles..."
for role in "${TERRAFORM_BOOTSTRAP_ROLES[@]}"; do
  echo "  ${role}"
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="${PRINCIPAL}" \
    --role="${role}" \
    --condition=None \
    --quiet >/dev/null
done

echo
echo "Done. Wait 1-3 minutes for IAM/API propagation, then run:"
echo "  terraform -chdir=infra-modules plan"
