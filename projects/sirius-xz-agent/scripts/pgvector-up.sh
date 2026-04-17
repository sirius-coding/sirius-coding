#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/docker/docker-compose.pgvector.yml"
PORT="${PGVECTOR_PORT:-5432}"

echo "Starting pgvector stack on port ${PORT}..."
docker compose -f "${COMPOSE_FILE}" up -d
docker compose -f "${COMPOSE_FILE}" ps
echo
echo "PostgreSQL is exposed on ${PORT}/tcp"
echo "Use ./scripts/pgvector-smoke.sh to verify the extension and vector queries"
