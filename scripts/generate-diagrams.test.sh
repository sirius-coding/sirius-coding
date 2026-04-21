#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

bash "${ROOT_DIR}/scripts/diagram-pipeline.test.sh" >/dev/null

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

fixture="${TMP_ROOT}/sample.diagram.json"
cat > "${fixture}" <<'JSON'
{
  "id": "sample",
  "title": "示例进化流程",
  "description": "验证兼容入口会调用新 diagram pipeline。",
  "orientation": "vertical_center",
  "nodes": [
    { "id": "A", "title": "输入", "subtitle": "需求", "role": "main", "icon": "chat" },
    { "id": "B", "title": "分流", "subtitle": "规则, 文档", "role": "hub", "icon": "database" },
    { "id": "C", "title": "规则", "subtitle": "长期保存", "role": "branch", "icon": "shield" },
    { "id": "D", "title": "文档", "subtitle": "说明", "role": "branch", "icon": "book" },
    { "id": "E", "title": "护栏", "subtitle": "发布前检查", "role": "merge", "icon": "shield" },
    { "id": "F", "title": "输出", "subtitle": "主页展示", "role": "end", "icon": "home" }
  ],
  "main_chain": ["A", "B", "E", "F"],
  "parallel_groups": [
    { "id": "assets", "title": "资产", "source": "B", "merge": "E", "columns": ["C", "D"] }
  ],
  "merge_nodes": ["E"],
  "feedback_loops": [
    { "from": "F", "to": "A", "label": "反馈循环", "route": "outer-left" }
  ]
}
JSON

node "${ROOT_DIR}/scripts/generate-diagrams.mjs" "${fixture}" >/dev/null

for generated in sample.intent.json sample.layout.plan.json sample.svg sample.image-prompt.md; do
  if [[ ! -s "${TMP_ROOT}/${generated}" ]]; then
    echo "Expected generated file: ${generated}" >&2
    exit 1
  fi
done

node "${ROOT_DIR}/scripts/generate-diagrams.mjs" --check "${fixture}" >/dev/null

printf '\n<!-- stale -->\n' >> "${TMP_ROOT}/sample.svg"

set +e
stale_output="$(node "${ROOT_DIR}/scripts/generate-diagrams.mjs" --check "${fixture}" 2>&1)"
stale_status="$?"
set -e

if [[ "${stale_status}" -eq 0 ]]; then
  echo "Expected stale SVG to fail check mode" >&2
  exit 1
fi

if [[ "${stale_output}" != *"sample.svg"* ]]; then
  echo "Expected stale output to mention sample.svg" >&2
  echo "${stale_output}" >&2
  exit 1
fi

echo "generate-diagrams compatibility tests passed"
