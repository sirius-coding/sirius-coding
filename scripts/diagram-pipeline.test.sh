#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

source_file="${TMP_ROOT}/sample.diagram.json"
intent_file="${TMP_ROOT}/sample.intent.json"
layout_file="${TMP_ROOT}/sample.layout.plan.json"
svg_file="${TMP_ROOT}/sample.svg"
prompt_file="${TMP_ROOT}/sample.image-prompt.md"

cat > "${source_file}" <<'JSON'
{
  "id": "sample",
  "title": "示例进化流程",
  "description": "验证主链、并列分支、汇聚和反馈回路。",
  "orientation": "vertical_center",
  "nodes": [
    { "id": "A", "title": "人与 AI 对话", "subtitle": "目标, 约束, 决策", "role": "main", "icon": "chat" },
    { "id": "B", "title": "读取仓库事实", "subtitle": "README, AGENTS, docs", "role": "main", "icon": "folder" },
    { "id": "C", "title": "执行改造", "subtitle": "代码, 文档, 脚本", "role": "main", "icon": "code" },
    { "id": "D", "title": "收集证据", "subtitle": "测试, 审计, 构建", "role": "main", "icon": "check" },
    { "id": "E", "title": "进化问题", "subtitle": "什么需要长期保存?", "role": "main", "icon": "trend" },
    { "id": "F", "title": "知识分流", "subtitle": "规则, skill, 脚本, 文档, 项目", "role": "hub", "icon": "database" },
    { "id": "G", "title": "specs + AGENTS.md", "subtitle": "目标, 边界, 运行规则", "role": "branch", "icon": "shield" },
    { "id": "H", "title": "skills", "subtitle": "可复用协作流程", "role": "branch", "icon": "flow" },
    { "id": "I", "title": "scripts", "subtitle": "审计, 生成, 检查", "role": "branch", "icon": "terminal" },
    { "id": "J", "title": "docs + diagrams", "subtitle": "运行手册, 环境模型, 流程图", "role": "branch", "icon": "book" },
    { "id": "K", "title": "projects", "subtitle": "实现, 测试, 部署资产", "role": "branch", "icon": "cube" },
    { "id": "L", "title": "公开/私有护栏", "subtitle": "发布前脱敏", "role": "merge", "icon": "shield" },
    { "id": "M", "title": "主页 README", "subtitle": "公开入口与导航", "role": "end", "icon": "home" },
    { "id": "N", "title": "下一次会话更强", "subtitle": "Vibe coding 进化为资产", "role": "end", "icon": "brain" }
  ],
  "main_chain": ["A", "B", "C", "D", "E", "F", "L", "M", "N"],
  "parallel_groups": [
    {
      "id": "durable-assets",
      "title": "长期资产",
      "source": "F",
      "merge": "L",
      "columns": ["G", "H", "I", "J", "K"]
    }
  ],
  "merge_nodes": ["L"],
  "feedback_loops": [
    { "from": "N", "to": "A", "label": "反馈循环", "route": "outer-left" }
  ]
}
JSON

node "${ROOT_DIR}/scripts/diagram/build-intent.mjs" "${source_file}" "${intent_file}"
node "${ROOT_DIR}/scripts/diagram/build-layout.mjs" "${intent_file}" "${layout_file}"
node "${ROOT_DIR}/scripts/diagram/render-svg.mjs" "${layout_file}" "${svg_file}"
node "${ROOT_DIR}/scripts/diagram/render-prompt.mjs" "${intent_file}" "${layout_file}" "${prompt_file}"

node -e '
const fs = require("node:fs");
const intent = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const layout = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (intent.main_chain.join(",") !== "A,B,C,D,E,F,L,M,N") throw new Error("main_chain not preserved");
if (intent.parallel_groups[0].columns.length !== 5) throw new Error("parallel group columns missing");
if (intent.merge_nodes[0] !== "L") throw new Error("merge node missing");
if (intent.feedback_loops[0].route !== "outer-left") throw new Error("feedback route missing");
if (layout.axis !== "vertical_center") throw new Error("layout axis mismatch");
if (!layout.centered_nodes.includes("A") || !layout.centered_nodes.includes("N")) throw new Error("centered nodes missing");
if (layout.parallel_groups[0].columns.length !== 5) throw new Error("layout columns missing");
if (layout.quality_checks.arrow_crossings !== false) throw new Error("expected no arrow crossings");
' "${intent_file}" "${layout_file}"

grep -q '<svg' "${svg_file}"
grep -q 'data-diagram-stage="main-chain"' "${svg_file}"
grep -q 'data-diagram-stage="parallel-group"' "${svg_file}"
grep -q 'data-route="outer-left"' "${svg_file}"
grep -q '人与 AI 对话' "${svg_file}"

grep -q 'ProcessOn' "${prompt_file}"
grep -q '主链垂直居中' "${prompt_file}"
grep -q '分支横向排列' "${prompt_file}"
grep -q '反馈回路走外围' "${prompt_file}"

echo "diagram-pipeline tests passed"
