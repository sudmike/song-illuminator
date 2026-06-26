#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GITHUB_TOKEN:-}" || -z "${GITHUB_OWNER:-}" || -z "${GITHUB_REPO:-}" ]]; then
  echo "GITHUB_TOKEN, GITHUB_OWNER, and GITHUB_REPO must be set."
  exit 1
fi

REPO_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"
API_URL="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners"

registration_token() {
  curl -fsSL -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "${API_URL}/registration-token" | jq -r .token
}

remove_token() {
  curl -fsSL -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "${API_URL}/remove-token" | jq -r .token
}

RUNNER_NAME="cloud-run-$(date +%s)"

echo "Registering GitHub runner as ${RUNNER_NAME}"

TOKEN="$(registration_token)"

./config.sh \
  --url "${REPO_URL}" \
  --token "${TOKEN}" \
  --unattended \
  --ephemeral \
  --name "${RUNNER_NAME}" \
  --labels "cloud-run"

cleanup() {
  echo "Removing GitHub runner registration..."
  REMOVE_TOKEN="$(remove_token || true)"
  if [[ -n "${REMOVE_TOKEN}" && "${REMOVE_TOKEN}" != "null" ]]; then
    ./config.sh remove --token "${REMOVE_TOKEN}" || true
  fi
}

trap cleanup EXIT INT TERM

exec ./run.sh
