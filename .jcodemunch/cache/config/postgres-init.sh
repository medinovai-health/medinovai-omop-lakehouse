#!/usr/bin/env bash
# Applies OMOP CDM v5.4 core schema to PostgreSQL.
# Use after stack is up for manual re-apply, CI, or non-Docker hosts.
# Docker Compose applies schema automatically via docker-entrypoint-initdb.d.
#
# Environment (defaults match docker-compose dev profile):
#   POSTGRES_HOST, POSTGRES_PORT, POSTGRES_USER, POSTGRES_DB, POSTGRES_PASSWORD
set -euo pipefail

E_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mos_repoRoot="$(cd "${E_SCRIPT_DIR}/.." && pwd)"
mos_schemaFile="${mos_repoRoot}/schema/omop_cdm_v54_core.sql"

mos_host="${POSTGRES_HOST:-localhost}"
mos_port="${POSTGRES_PORT:-25432}"
mos_user="${POSTGRES_USER:-omop}"
mos_db="${POSTGRES_DB:-omop}"

if [[ -z "${POSTGRES_PASSWORD:-}" ]]; then
  echo "postgres-init.sh: POSTGRES_PASSWORD is required" >&2
  exit 1
fi

export PGPASSWORD="${POSTGRES_PASSWORD}"
psql -h "${mos_host}" -p "${mos_port}" -U "${mos_user}" -d "${mos_db}" \
  -v ON_ERROR_STOP=1 -f "${mos_schemaFile}"
echo "postgres-init.sh: schema applied from ${mos_schemaFile}"
