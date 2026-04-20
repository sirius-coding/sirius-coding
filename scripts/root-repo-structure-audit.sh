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

check_required_paths() {
  local paths=(
    "README.md"
    "AGENTS.md"
    ".codex/config.toml"
    "docs"
    "docs/ops/workspace-opening-model.md"
    "docs/ops/environment-registry.yaml"
    "docs/ops/environment-registry.private.example.yaml"
    "projects"
    "scripts"
    "scripts/root-repo-structure-audit.sh"
    "scripts/root-repo-structure-audit.test.sh"
    "skills"
    "skills/workspace-multi-env-delivery/SKILL.md"
    "specs"
    "specs/review/code_review.md"
    "specs/workspace/workstation-operating-rules.md"
    "specs/workspace/public-private-boundary.md"
    "specs/workspace/evolution-handbook.md"
    "specs/workspace/core-assets-map.md"
  )

  for path in "${paths[@]}"; do
    require_path "${path}"
  done
}

check_private_overlay_not_tracked() {
  if [[ -d "${ROOT}/.git" ]] || git -C "${ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
    if git -C "${ROOT}" ls-files --error-unmatch docs/ops/environment-registry.private.yaml >/dev/null 2>&1; then
      fail "private environment overlay is tracked: docs/ops/environment-registry.private.yaml"
    else
      pass "private environment overlay is not tracked"
    fi
  else
    pass "git metadata not present; skipped private overlay tracking check"
  fi
}

check_skill_frontmatter() {
  local skill="${ROOT}/skills/workspace-multi-env-delivery/SKILL.md"

  if [[ ! -f "${skill}" ]]; then
    return
  fi

  if head -n 1 "${skill}" | grep -qx -- "---" \
    && grep -q '^name: ' "${skill}" \
    && grep -q '^description: ' "${skill}"; then
    pass "workspace delivery skill has frontmatter"
  else
    fail "workspace delivery skill is missing required frontmatter"
  fi
}

check_yaml() {
  local files=(
    "docs/ops/environment-registry.yaml"
    "docs/ops/environment-registry.private.example.yaml"
  )

  if command -v ruby >/dev/null 2>&1; then
    for rel in "${files[@]}"; do
      [[ -f "${ROOT}/${rel}" ]] || continue
      if ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "${ROOT}/${rel}" >/dev/null 2>&1; then
        pass "YAML parses: ${rel}"
      else
        fail "YAML does not parse: ${rel}"
      fi
    done
  else
    echo "WARN: ruby not found; skipped YAML parsing"
  fi
}

check_toml() {
  local rel=".codex/config.toml"

  [[ -f "${ROOT}/${rel}" ]] || return

  if command -v python3 >/dev/null 2>&1; then
    if python3 - "${ROOT}/${rel}" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as fh:
    tomllib.load(fh)
PY
    then
      pass "TOML parses: ${rel}"
    else
      fail "TOML does not parse: ${rel}"
    fi
  else
    echo "WARN: python3 not found; skipped TOML parsing"
  fi
}

check_readme_links() {
  local readme="${ROOT}/README.md"

  [[ -f "${readme}" ]] || return

  if command -v python3 >/dev/null 2>&1; then
    if python3 - "${ROOT}" <<'PY'
from pathlib import Path
from urllib.parse import unquote
import re
import sys

root = Path(sys.argv[1])
readme = root / "README.md"
text = readme.read_text(encoding="utf-8")
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

    target = target.split("#", 1)[0]
    target = unquote(target)
    if not (root / target).exists():
        print(f"missing README link target: {raw}", file=sys.stderr)
        failed = True

sys.exit(1 if failed else 0)
PY
    then
      pass "README local links resolve"
    else
      fail "README contains missing local links"
    fi
  else
    echo "WARN: python3 not found; skipped README link check"
  fi
}

scan_sensitive_patterns() {
  local ip_pattern="223\\.109\\.140\\.60"
  local ssh_alias_pattern="sirius-cloud"'-root'
  local remote_root_pattern="/root/"'sirius-xz-agent-it'
  local workspace_path_pattern="${HOME}/Code/tests"
  local root_user_pattern='user: "'root'"'
  local root_at_pattern='root''@'
  local private_key_pattern='BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY'
  local pattern="${ip_pattern}|${ssh_alias_pattern}|${remote_root_pattern}|${workspace_path_pattern}|${root_user_pattern}|${root_at_pattern}|${private_key_pattern}"
  local output

  set +e
  output="$(
    grep -RInI -E "${pattern}" "${ROOT}" \
      --exclude-dir=.git \
      --exclude-dir=.worktrees \
      --exclude-dir=node_modules \
      --exclude-dir=target \
      --exclude-dir=dist \
      --exclude=application-local.yml \
      --exclude=.env.local 2>/dev/null
  )"
  local status="$?"
  set -e

  if [[ "${status}" -eq 0 ]]; then
    echo "${output}" >&2
    fail "Sensitive pattern found"
  elif [[ "${status}" -eq 1 ]]; then
    pass "no known sensitive patterns found"
  else
    fail "sensitive pattern scan failed"
  fi
}

main() {
  echo "Auditing root repository: ${ROOT}"
  check_required_paths
  check_private_overlay_not_tracked
  check_skill_frontmatter
  check_yaml
  check_toml
  check_readme_links
  scan_sensitive_patterns

  if [[ "${failures}" -gt 0 ]]; then
    echo "Audit failed with ${failures} issue(s)" >&2
    exit 1
  fi

  echo "Audit passed"
}

main "$@"
