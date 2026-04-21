#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

snapshot="${TMP_ROOT}/template-snapshot"

node --check "${ROOT_DIR}/scripts/template/sync-template-readme.mjs"
bash "${ROOT_DIR}/scripts/template/sync-template-repo.sh" --output "${snapshot}"
bash "${ROOT_DIR}/scripts/template/template-repo-audit.sh" "${snapshot}"

for required in \
  README.md \
  VERSION \
  CHANGELOG.md \
  AGENTS.md \
  docs/releases/release-history.md \
  docs/template/template-manifest.yaml \
  specs/diagram-style.md \
  skills/diagram-pipeline/SKILL.md \
  scripts/diagram/build-all.mjs; do
  if [[ ! -e "${snapshot}/${required}" ]]; then
    echo "Expected template snapshot to contain ${required}" >&2
    exit 1
  fi
done

for forbidden in \
  projects \
  pom.xml \
  docs/sirius-xz-agent-cloud-deploy-checklist.md \
  docs/superpowers; do
  if [[ -e "${snapshot}/${forbidden}" ]]; then
    echo "Template snapshot must not contain ${forbidden}" >&2
    exit 1
  fi
done

grep -q "Sirius Evolution Station Template" "${snapshot}/README.md"

leaky="${TMP_ROOT}/leaky-template"
cp -R "${snapshot}" "${leaky}"
mkdir -p "${leaky}/projects/example"
echo "leak" > "${leaky}/projects/example/README.md"

set +e
leaky_output="$(bash "${ROOT_DIR}/scripts/template/template-repo-audit.sh" "${leaky}" 2>&1)"
leaky_status="$?"
set -e

if [[ "${leaky_status}" -eq 0 ]]; then
  echo "Expected template audit to fail when projects/ is present" >&2
  exit 1
fi

if [[ "${leaky_output}" != *"forbidden path exists: projects"* ]]; then
  echo "Expected template audit to report projects/ leak" >&2
  echo "${leaky_output}" >&2
  exit 1
fi

echo "template repo tests passed"
