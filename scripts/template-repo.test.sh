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
  CONTRIBUTING.md \
  SECURITY.md \
  .github/workflows/root-audit.yml \
  .github/pull_request_template.md \
  docs/adoption/quick-start.md \
  docs/adoption/why-this-template.md \
  docs/adoption/mother-repo-relationship.md \
  examples/minimal-project-layout/README.md \
  AGENTS.md \
  docs/releases/release-history.md \
  docs/template/template-manifest.yaml \
  specs/workspace/control-layer-os.md \
  specs/diagram-style.md \
  skills/template-adoption/SKILL.md \
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
  docs/mother \
  docs/superpowers \
  .github/workflows/sync-template.yml \
  .github/java-upgrade \
  docs/.DS_Store; do
  if [[ -e "${snapshot}/${forbidden}" ]]; then
    echo "Template snapshot must not contain ${forbidden}" >&2
    exit 1
  fi
done

for forbidden_text in \
  "projects/"'sirius-' \
  "sirius-xz-"'agent' \
  "sirius-xz-"'agent-ui' \
  "sirius-cloud-"'starter' \
  "sirius-web-"'toolkit'; do
  if grep -RInI --exclude-dir=.git "${forbidden_text}" "${snapshot}" >/tmp/sirius-template-forbidden-text.$$ 2>/dev/null; then
    cat /tmp/sirius-template-forbidden-text.$$ >&2
    rm -f /tmp/sirius-template-forbidden-text.$$
    echo "Template snapshot must not contain mother repository text: ${forbidden_text}" >&2
    exit 1
  fi
  rm -f /tmp/sirius-template-forbidden-text.$$
done

grep -q "Sirius Evolution Station Template" "${snapshot}/README.md"
grep -q "Control Layer OS" "${snapshot}/README.md"

sync_output="$(bash "${ROOT_DIR}/scripts/template/sync-template-repo.sh" --output "${TMP_ROOT}/summary-snapshot")"
if [[ "${sync_output}" != *"Included paths:"* ]] || [[ "${sync_output}" != *"Excluded paths:"* ]] || [[ "${sync_output}" != *"Verification:"* ]]; then
  echo "Expected sync output to include included/excluded/verification summary" >&2
  echo "${sync_output}" >&2
  exit 1
fi

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

adopter="${TMP_ROOT}/adopter"
cp -R "${snapshot}" "${adopter}"
mkdir -p "${adopter}/projects/fruits-card"
cat > "${adopter}/projects/fruits-card/README.md" <<'EOF'
# Fruits Card

## Workspace alignment

This project adopts the reusable workspace rules.
EOF
cat > "${adopter}/projects/fruits-card/LICENSE" <<'EOF'
Apache License fixture
EOF

adopter_output="$(bash "${ROOT_DIR}/scripts/root-repo-structure-audit.sh" "${adopter}" --strict)"
if [[ "${adopter_output}" != *"Audit profile: adopter"* ]] || [[ "${adopter_output}" != *"Audit passed"* ]]; then
  echo "Expected adopted template with a user project to pass as adopter" >&2
  echo "${adopter_output}" >&2
  exit 1
fi

echo "template repo tests passed"
