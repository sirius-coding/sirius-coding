#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${SIRIUS_CLOUD_SSH_HOST:?SIRIUS_CLOUD_SSH_HOST is required}"
: "${SIRIUS_CLOUD_REMOTE_ROOT:?SIRIUS_CLOUD_REMOTE_ROOT is required}"

SSH_HOST="${SIRIUS_CLOUD_SSH_HOST}"
REMOTE_ROOT="${SIRIUS_CLOUD_REMOTE_ROOT}"
LOCAL_PORT="${SIRIUS_CLOUD_TUNNEL_PORT:-15432}"
REMOTE_PORT="${SIRIUS_CLOUD_REMOTE_PG_PORT:-5432}"
MAVEN_REPO_LOCAL="${MAVEN_REPO_LOCAL:-${TMPDIR:-/tmp}/sirius-m2}"

cleanup() {
  if [[ -n "${TUNNEL_PID:-}" ]]; then
    kill "${TUNNEL_PID}" >/dev/null 2>&1 || true
    wait "${TUNNEL_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT

remote_root_quoted="$(printf "%q" "${REMOTE_ROOT}")"
ssh "${SSH_HOST}" "cd ${remote_root_quoted} && ./scripts/pgvector-up.sh"
ssh -o ExitOnForwardFailure=yes -N -L "${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT}" "${SSH_HOST}" &
TUNNEL_PID=$!

for _ in $(seq 1 30); do
  if bash -c ">/dev/tcp/127.0.0.1/${LOCAL_PORT}" 2>/dev/null; then
    break
  fi
  sleep 1
done

if ! bash -c ">/dev/tcp/127.0.0.1/${LOCAL_PORT}" 2>/dev/null; then
  echo "SSH tunnel to pgvector did not become ready on 127.0.0.1:${LOCAL_PORT}" >&2
  exit 1
fi

cd "${ROOT_DIR}"
SIRIUS_CLOUD_IT_ENABLED=true \
SIRIUS_CLOUD_IT_PORT="${LOCAL_PORT}" \
mvn -q -Dmaven.repo.local="${MAVEN_REPO_LOCAL}" -Dtest=CloudApiIntegrationTest,CloudPgVectorIntegrationTest test
