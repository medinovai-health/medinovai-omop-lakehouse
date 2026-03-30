#!/usr/bin/env bash
# init.sh — MedinovAI Harness 2.1
# Repo: medinovai-omop-lakehouse
# Tier: 2 (platform / data layer)
# Brings up PostgreSQL 15, Trino, and the Python API via Docker Compose.

set -euo pipefail

E_REPO_NAME="medinovai-omop-lakehouse"
mos_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${mos_root}"

echo "=== MedinovAI init.sh starting ==="
echo "Repo: ${E_REPO_NAME}"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "[1/3] Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. INIT_FAILED"
  exit 1
fi

echo "[2/3] Starting stack (docker compose up -d)..."
docker compose up -d --build

echo "[3/3] Waiting for API health (http://localhost:28000/health)..."
mos_healthUrl="http://localhost:28000/health"
for mos_i in $(seq 1 45); do
  if curl -sf "${mos_healthUrl}" >/dev/null 2>&1; then
    echo "API ready at ${mos_healthUrl}"
    mos_code="$(curl -s -o /dev/null -w "%{http_code}" "${mos_healthUrl}")"
    if [[ "${mos_code}" == "200" ]]; then
      echo "Smoke test PASSED (HTTP 200)"
      echo "INIT_SUCCESS"
      exit 0
    fi
  fi
  sleep 2
done

echo "API failed to become healthy in time. INIT_FAILED"
exit 1
