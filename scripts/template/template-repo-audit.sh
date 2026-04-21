#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "${ROOT}" && pwd -P)"
failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

pass() {
  echo "OK: $*"
}

require_path() {
  local rel="$1"
  if [[ -e "${ROOT}/${rel}" ]]; then
    pass "required path exists: ${rel}"
  else
    fail "missing required path: ${rel}"
  fi
}

forbid_path() {
  local rel="$1"
  if [[ -e "${ROOT}/${rel}" ]]; then
    fail "forbidden path exists: ${rel}"
  else
    pass "forbidden path absent: ${rel}"
  fi
}

required_paths=(
  "README.md"
  "VERSION"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  "LICENSE"
  "NOTICE"
  "COMMERCIALIZATION.md"
  "AGENTS.md"
  ".github/workflows/root-audit.yml"
  ".github/ISSUE_TEMPLATE/bug_report.md"
  ".github/ISSUE_TEMPLATE/adoption_feedback.md"
  ".github/ISSUE_TEMPLATE/reusable-capability-proposal.md"
  ".github/pull_request_template.md"
  ".codex/config.toml"
  "docs/adoption/quick-start.md"
  "docs/adoption/why-this-template.md"
  "docs/adoption/mother-repo-relationship.md"
  "docs/releases/release-history.md"
  "docs/template/template-manifest.yaml"
  "docs/template/repository-role.yaml"
  "docs/diagrams/README.md"
  "docs/ops/github-project-roadmap.md"
  "docs/ops/workspace-opening-model.md"
  "docs/ops/environment-registry.yaml"
  "docs/ops/environment-registry.private.example.yaml"
  "scripts/root-repo-structure-audit.sh"
  "scripts/github/setup-root-project.sh"
  "scripts/template/template-repo-audit.sh"
  "scripts/template/sync-template-repo.sh"
  "scripts/diagram/build-all.mjs"
  "examples/minimal-project-layout/README.md"
  "examples/minimal-project-layout/tree.txt"
  "examples/minimal-project-layout/evolution-sample.md"
  "skills/diagram-pipeline/SKILL.md"
  "skills/template-adoption/SKILL.md"
  "skills/workspace-multi-env-delivery/SKILL.md"
  "specs/diagram-style.md"
  "specs/workspace/control-layer-os.md"
  "specs/workspace/evolution-handbook.md"
  "specs/workspace/public-private-boundary.md"
  "specs/workspace/core-assets-map.md"
  "assets/hero.svg"
)

forbidden_paths=(
  "projects"
  "pom.xml"
  ".github/workflows/sync-template.yml"
  ".github/java-upgrade"
  "docs/mother"
  "docs/superpowers"
  "docs/ops/environment-registry.private.yaml"
)

for rel in "${required_paths[@]}"; do
  require_path "${rel}"
done

for rel in "${forbidden_paths[@]}"; do
  forbid_path "${rel}"
done

if grep -q '^role: "template"$' "${ROOT}/docs/template/repository-role.yaml"; then
  pass "repository role is template"
else
  fail "repository role must be template"
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 - "${ROOT}" <<'PY'
from pathlib import Path
from urllib.parse import unquote
import re
import sys

root = Path(sys.argv[1])
text = (root / "README.md").read_text(encoding="utf-8")
failed = False

for raw in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", text):
    target = raw.strip()
    if (
        not target
        or target.startswith("#")
        or target.startswith("http://")
        or target.startswith("https://")
        or target.startswith("mailto:")
    ):
        continue

    target = unquote(target.split("#", 1)[0])
    if not (root / target).exists():
        print(f"missing template README link target: {raw}", file=sys.stderr)
        failed = True

sys.exit(1 if failed else 0)
PY
  then
    pass "template README local links resolve"
  else
    fail "template README contains missing local links"
  fi
else
  echo "WARN: python3 not found; skipped template README link check"
fi

ip_pattern="223\\.109"
ssh_alias_pattern="sirius-cloud"'-root'
root_at_pattern='root''@'
private_key_pattern='BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY'
sensitive_pattern="${ip_pattern}|${ssh_alias_pattern}|${root_at_pattern}|${private_key_pattern}"

if grep -RInI -E "${sensitive_pattern}" "${ROOT}" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=target >/tmp/sirius-template-audit-sensitive.$$ 2>/dev/null; then
  cat /tmp/sirius-template-audit-sensitive.$$ >&2
  rm -f /tmp/sirius-template-audit-sensitive.$$
  fail "sensitive pattern found"
else
  rm -f /tmp/sirius-template-audit-sensitive.$$
  pass "no known sensitive patterns found"
fi

if [[ "${failures}" -gt 0 ]]; then
  echo "Template audit failed with ${failures} issue(s)" >&2
  exit 1
fi

echo "Template audit passed"
