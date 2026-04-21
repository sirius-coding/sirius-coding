#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${SCRIPT_DIR}/generate-diagrams.mjs"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

readme="${TMP_ROOT}/README.md"
cat > "${readme}" <<'EOF'
# Fixture README

<!-- diagram:sample:start -->
```mermaid
flowchart TB
  stale["stale"]
```
<!-- diagram:sample:end -->
EOF

fixture="${TMP_ROOT}/sample.diagram.json"
cat > "${fixture}" <<JSON
{
  "id": "sample",
  "title": "Sample Diagram",
  "description": "A small conversion fixture.",
  "direction": "LR",
  "readmeSync": {
    "path": "${readme}",
    "marker": "sample"
  },
  "layers": [
    { "id": "input", "title": "Input" },
    { "id": "output", "title": "Output" }
  ],
  "nodes": [
    { "id": "start", "label": "Start", "kind": "input", "layer": "input" },
    { "id": "done", "label": "Done", "kind": "output", "layer": "output" }
  ],
  "edges": [
    { "from": "start", "to": "done", "label": "convert" }
  ]
}
JSON

node "${SCRIPT}" "${fixture}" >/dev/null

for generated in sample.mmd sample.drawio sample.excalidraw sample.ai-drawio.md; do
  if [[ ! -s "${TMP_ROOT}/${generated}" ]]; then
    echo "Expected generated file: ${generated}" >&2
    exit 1
  fi
done

node "${SCRIPT}" --check "${fixture}" >/dev/null

if ! grep -q 'flowchart LR' "${readme}"; then
  echo "Expected README diagram block to be synchronized" >&2
  exit 1
fi

printf '\n%% stale\n' >> "${TMP_ROOT}/sample.mmd"

set +e
stale_output="$(node "${SCRIPT}" --check "${fixture}" 2>&1)"
stale_status="$?"
set -e

if [[ "${stale_status}" -eq 0 ]]; then
  echo "Expected stale generated output to fail check mode" >&2
  exit 1
fi

if [[ "${stale_output}" != *"sample.mmd"* ]]; then
  echo "Expected stale output to mention sample.mmd" >&2
  echo "${stale_output}" >&2
  exit 1
fi

node "${SCRIPT}" "${fixture}" >/dev/null
perl -0pi -e 's/flowchart LR/flowchart TB/' "${readme}"

set +e
readme_stale_output="$(node "${SCRIPT}" --check "${fixture}" 2>&1)"
readme_stale_status="$?"
set -e

if [[ "${readme_stale_status}" -eq 0 ]]; then
  echo "Expected stale README diagram block to fail check mode" >&2
  exit 1
fi

if [[ "${readme_stale_output}" != *"README.md#sample"* ]]; then
  echo "Expected stale README output to mention README.md#sample" >&2
  echo "${readme_stale_output}" >&2
  exit 1
fi

echo "generate-diagrams tests passed"
