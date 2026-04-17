#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/docker/docker-compose.pgvector.yml"

docker compose -f "${COMPOSE_FILE}" up -d

cleanup() {
  docker compose -f "${COMPOSE_FILE}" down -v
}

trap cleanup EXIT

for _ in $(seq 1 30); do
  if docker compose -f "${COMPOSE_FILE}" exec -T postgres pg_isready -U sirius -d sirius_xz_agent >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker compose -f "${COMPOSE_FILE}" exec -T postgres psql -U sirius -d sirius_xz_agent -c "select extname from pg_extension where extname = 'vector';"
docker compose -f "${COMPOSE_FILE}" exec -T postgres psql -U sirius -d sirius_xz_agent -c "select '[1,0,0]'::vector <-> '[1,0,0]'::vector as distance;"
