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
    "VERSION"
    "CHANGELOG.md"
    "LICENSE"
    "NOTICE"
    "COMMERCIALIZATION.md"
    "AGENTS.md"
    ".codex/config.toml"
    "docs"
    "docs/diagrams/README.md"
    "docs/diagrams/evolution-workflow.diagram.json"
    "docs/diagrams/evolution-workflow.intent.json"
    "docs/diagrams/evolution-workflow.layout.plan.json"
    "docs/diagrams/evolution-workflow.svg"
    "docs/diagrams/evolution-workflow.image-prompt.md"
    "docs/ops/workspace-opening-model.md"
    "docs/ops/github-project-roadmap.md"
    "docs/ops/environment-registry.yaml"
    "docs/ops/environment-registry.private.example.yaml"
    "docs/releases/release-history.md"
    "docs/template/template-manifest.yaml"
    "projects"
    "scripts"
    "scripts/diagram/build-all.mjs"
    "scripts/diagram/build-intent.mjs"
    "scripts/diagram/build-layout.mjs"
    "scripts/diagram/render-svg.mjs"
    "scripts/diagram/render-prompt.mjs"
    "scripts/diagram-pipeline.test.sh"
    "scripts/generate-diagrams.mjs"
    "scripts/generate-diagrams.test.sh"
    "scripts/github/setup-root-project.sh"
    "scripts/root-repo-structure-audit.sh"
    "scripts/root-repo-structure-audit.test.sh"
    "scripts/template-repo.test.sh"
    "scripts/template/sync-template-readme.mjs"
    "scripts/template/sync-template-repo.sh"
    "scripts/template/template-repo-audit.sh"
    "skills"
    "skills/diagram-pipeline/SKILL.md"
    "skills/workspace-multi-env-delivery/SKILL.md"
    "specs"
    "specs/diagram-style.md"
    "specs/review/code_review.md"
    "specs/workspace/workstation-operating-rules.md"
    "specs/workspace/public-private-boundary.md"
    "specs/workspace/evolution-handbook.md"
    "specs/workspace/core-assets-map.md"
    "specs/workspace/independent-repo-alignment.md"
    "specs/workspace/module-roadmap.md"
    "assets/hero.svg"
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
    "docs/template/template-manifest.yaml"
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

check_release_assets() {
  local version_file="${ROOT}/VERSION"
  local changelog="${ROOT}/CHANGELOG.md"
  local release_history="${ROOT}/docs/releases/release-history.md"
  local manifest="${ROOT}/docs/template/template-manifest.yaml"
  local version

  [[ -f "${version_file}" ]] || return
  version="$(tr -d '[:space:]' < "${version_file}")"

  if [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    pass "VERSION uses SemVer: ${version}"
  else
    fail "VERSION is not SemVer: ${version}"
  fi

  if [[ -f "${changelog}" ]] && grep -q "^## \\[${version}\\]" "${changelog}"; then
    pass "CHANGELOG contains current version: ${version}"
  else
    fail "CHANGELOG is missing current version: ${version}"
  fi

  if [[ -f "${release_history}" ]] && grep -q "${version}" "${release_history}"; then
    pass "release history references current version: ${version}"
  else
    fail "release history is missing current version: ${version}"
  fi

  if [[ -f "${manifest}" ]] && grep -q "current_version: \"${version}\"" "${manifest}"; then
    pass "template manifest current_version matches VERSION"
  else
    fail "template manifest current_version does not match VERSION"
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

check_diagram_assets() {
  local spec="docs/diagrams/evolution-workflow.diagram.json"
  local generator="scripts/diagram/build-all.mjs"

  [[ -f "${ROOT}/${spec}" ]] || return

  if command -v python3 >/dev/null 2>&1; then
    if python3 - "${ROOT}/${spec}" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)

required = ("id", "title", "nodes", "main_chain", "parallel_groups", "merge_nodes", "feedback_loops")
missing = [key for key in required if key not in data]
if missing:
    raise SystemExit(f"missing diagram keys: {', '.join(missing)}")
PY
    then
      pass "diagram JSON parses: ${spec}"
    else
      fail "diagram JSON does not parse: ${spec}"
    fi
  else
    echo "WARN: python3 not found; skipped diagram JSON parsing"
  fi

  if [[ -f "${ROOT}/${generator}" ]] && command -v node >/dev/null 2>&1; then
    if node "${ROOT}/${generator}" --check "${ROOT}/${spec}" >/dev/null 2>&1; then
      pass "diagram pipeline outputs are current"
    else
      fail "diagram pipeline outputs are stale"
    fi
  else
    echo "WARN: node or diagram pipeline not found; skipped diagram drift check"
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

check_project_alignment_sections() {
  local projects=(
    "projects/sirius-xz-agent/README.md"
    "projects/sirius-xz-agent-ui/README.md"
    "projects/sirius-cloud-starter/README.md"
    "projects/sirius-web-toolkit/README.md"
  )

  for rel in "${projects[@]}"; do
    if [[ ! -f "${ROOT}/${rel}" ]]; then
      fail "missing project README: ${rel}"
      continue
    fi

    if grep -q '^## Workspace alignment$' "${ROOT}/${rel}"; then
      pass "project README has workspace alignment section: ${rel}"
    else
      fail "missing workspace alignment section: ${rel}"
    fi
  done
}

check_project_licenses() {
  local licenses=(
    "projects/sirius-xz-agent/LICENSE"
    "projects/sirius-xz-agent-ui/LICENSE"
    "projects/sirius-cloud-starter/LICENSE"
    "projects/sirius-web-toolkit/LICENSE"
  )

  for rel in "${licenses[@]}"; do
    if [[ -f "${ROOT}/${rel}" ]]; then
      pass "project license exists: ${rel}"
    else
      fail "missing project license: ${rel}"
    fi
  done
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
  check_release_assets
  check_diagram_assets
  check_readme_links
  check_project_alignment_sections
  check_project_licenses
  scan_sensitive_patterns

  if [[ "${failures}" -gt 0 ]]; then
    echo "Audit failed with ${failures} issue(s)" >&2
    exit 1
  fi

  echo "Audit passed"
}

main "$@"
