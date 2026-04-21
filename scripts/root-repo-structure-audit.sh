#!/usr/bin/env bash
set -euo pipefail

ROOT="."
STRICT=false
JSON_OUTPUT=false
PROFILE=""
failures=()
passes=()

usage() {
  cat <<'EOF'
Usage: scripts/root-repo-structure-audit.sh [root] [--strict] [--json] [--profile mother|template-release|adopter]

Audits the Sirius mother workspace, template snapshot, or adopted template workspace.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --strict)
      STRICT=true
      shift
      ;;
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      ROOT="$1"
      shift
      ;;
  esac
done

ROOT="$(cd "${ROOT}" && pwd -P)"

normalize_profile() {
  case "$1" in
    root|mother)
      printf '%s\n' "mother"
      ;;
    template|template-release)
      printf '%s\n' "template-release"
      ;;
    adopter)
      printf '%s\n' "adopter"
      ;;
    *)
      echo "Unknown audit profile: $1" >&2
      exit 2
      ;;
  esac
}

read_repository_role() {
  local role_file="${ROOT}/docs/template/repository-role.yaml"
  [[ -f "${role_file}" ]] || return 0

  awk -F: '
    /^[[:space:]]*role[[:space:]]*:/ {
      value=$2
      gsub(/[[:space:]"]/, "", value)
      print value
      exit
    }
  ' "${role_file}"
}

detect_profile() {
  local role
  role="$(read_repository_role)"

  case "${role}" in
    mother|root)
      printf '%s\n' "mother"
      return 0
      ;;
    template)
      if [[ -d "${ROOT}/projects" ]]; then
        printf '%s\n' "adopter"
      else
        printf '%s\n' "template-release"
      fi
      return 0
      ;;
  esac

  if [[ -f "${ROOT}/.github/workflows/sync-template.yml" ]]; then
    printf '%s\n' "mother"
  elif [[ -d "${ROOT}/projects" ]]; then
    printf '%s\n' "adopter"
  else
    printf '%s\n' "template-release"
  fi
}

if [[ -n "${PROFILE}" ]]; then
  PROFILE="$(normalize_profile "${PROFILE}")"
else
  PROFILE="$(detect_profile)"
fi

record_pass() {
  local message="$*"
  passes+=("${message}")
  if [[ "${JSON_OUTPUT}" != true ]]; then
    echo "OK: ${message}"
  fi
}

record_fail() {
  local message="$*"
  failures+=("${message}")
  if [[ "${JSON_OUTPUT}" != true ]]; then
    echo "FAIL: ${message}" >&2
  fi
}

require_path() {
  local rel="$1"
  if [[ -e "${ROOT}/${rel}" ]]; then
    record_pass "required path exists: ${rel}"
  else
    record_fail "missing required path: ${rel}"
  fi
}

forbid_path() {
  local rel="$1"
  if [[ -e "${ROOT}/${rel}" ]]; then
    record_fail "forbidden path exists: ${rel}"
  else
    record_pass "forbidden path absent: ${rel}"
  fi
}

check_required_paths() {
  local common_paths=(
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
    "docs/template/repository-role.yaml"
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

  local strict_paths=(
    "CONTRIBUTING.md"
    "SECURITY.md"
    ".github/workflows/root-audit.yml"
    ".github/ISSUE_TEMPLATE/bug_report.md"
    ".github/ISSUE_TEMPLATE/adoption_feedback.md"
    ".github/ISSUE_TEMPLATE/reusable-capability-proposal.md"
    ".github/pull_request_template.md"
    "docs/adoption/quick-start.md"
    "docs/adoption/why-this-template.md"
    "docs/adoption/mother-repo-relationship.md"
    "examples/minimal-project-layout/README.md"
    "examples/minimal-project-layout/tree.txt"
    "examples/minimal-project-layout/evolution-sample.md"
    "skills/template-adoption/SKILL.md"
    "specs/workspace/control-layer-os.md"
  )

  local mother_paths=(
    "projects"
    "docs/mother/project-inventory.yaml"
  )
  local mother_strict_paths=(".github/workflows/sync-template.yml")
  local template_forbidden_paths=(
    "pom.xml"
    ".github/workflows/sync-template.yml"
    "docs/mother"
    "docs/superpowers"
    "docs/ops/environment-registry.private.yaml"
  )

  for path in "${common_paths[@]}"; do
    require_path "${path}"
  done

  if [[ "${PROFILE}" == "mother" ]]; then
    for path in "${mother_paths[@]}"; do
      require_path "${path}"
    done
  else
    if [[ "${PROFILE}" == "template-release" ]]; then
      forbid_path "projects"
    fi

    for path in "${template_forbidden_paths[@]}"; do
      forbid_path "${path}"
    done
  fi

  if [[ "${STRICT}" == true ]]; then
    for path in "${strict_paths[@]}"; do
      require_path "${path}"
    done

    if [[ "${PROFILE}" == "mother" ]]; then
      for path in "${mother_strict_paths[@]}"; do
        require_path "${path}"
      done
    fi
  fi
}

check_private_overlay_not_tracked() {
  if [[ -d "${ROOT}/.git" ]] || git -C "${ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
    if git -C "${ROOT}" ls-files --error-unmatch docs/ops/environment-registry.private.yaml >/dev/null 2>&1; then
      record_fail "private environment overlay is tracked: docs/ops/environment-registry.private.yaml"
    else
      record_pass "private environment overlay is not tracked"
    fi
  else
    record_pass "git metadata not present; skipped private overlay tracking check"
  fi
}

check_skill_frontmatter() {
  local skills=(
    "skills/workspace-multi-env-delivery/SKILL.md"
    "skills/diagram-pipeline/SKILL.md"
  )

  if [[ "${STRICT}" == true ]]; then
    skills+=("skills/template-adoption/SKILL.md")
  fi

  local skill
  for rel in "${skills[@]}"; do
    skill="${ROOT}/${rel}"
    [[ -f "${skill}" ]] || continue
    if head -n 1 "${skill}" | grep -qx -- "---" \
      && grep -q '^name: ' "${skill}" \
      && grep -q '^description: ' "${skill}"; then
      record_pass "skill has frontmatter: ${rel}"
    else
      record_fail "skill is missing required frontmatter: ${rel}"
    fi
  done
}

check_yaml() {
  local files=(
    "docs/ops/environment-registry.yaml"
    "docs/ops/environment-registry.private.example.yaml"
    "docs/template/template-manifest.yaml"
    "docs/template/repository-role.yaml"
  )

  if [[ "${STRICT}" == true ]]; then
    files+=(
      ".github/workflows/root-audit.yml"
    )
    if [[ "${PROFILE}" == "mother" ]]; then
      files+=(".github/workflows/sync-template.yml")
    fi
  fi

  if command -v ruby >/dev/null 2>&1; then
    local rel
    for rel in "${files[@]}"; do
      [[ -f "${ROOT}/${rel}" ]] || continue
      if ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "${ROOT}/${rel}" >/dev/null 2>&1; then
        record_pass "YAML parses: ${rel}"
      else
        record_fail "YAML does not parse: ${rel}"
      fi
    done
  else
    record_pass "ruby not found; skipped YAML parsing"
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
      record_pass "TOML parses: ${rel}"
    else
      record_fail "TOML does not parse: ${rel}"
    fi
  else
    record_pass "python3 not found; skipped TOML parsing"
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
    record_pass "VERSION uses SemVer: ${version}"
  else
    record_fail "VERSION is not SemVer: ${version}"
  fi

  if [[ -f "${changelog}" ]] && grep -q "^## \\[${version}\\]" "${changelog}"; then
    record_pass "CHANGELOG contains current version: ${version}"
  else
    record_fail "CHANGELOG is missing current version: ${version}"
  fi

  if [[ -f "${release_history}" ]] && grep -q "${version}" "${release_history}"; then
    record_pass "release history references current version: ${version}"
  else
    record_fail "release history is missing current version: ${version}"
  fi

  if [[ -f "${manifest}" ]] && grep -q "current_version: \"${version}\"" "${manifest}"; then
    record_pass "template manifest current_version matches VERSION"
  else
    record_fail "template manifest current_version does not match VERSION"
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
      record_pass "diagram JSON parses: ${spec}"
    else
      record_fail "diagram JSON does not parse: ${spec}"
    fi
  else
    record_pass "python3 not found; skipped diagram JSON parsing"
  fi

  if [[ -f "${ROOT}/${generator}" ]] && command -v node >/dev/null 2>&1; then
    if node "${ROOT}/${generator}" --check "${ROOT}/${spec}" >/dev/null 2>&1; then
      record_pass "diagram pipeline outputs are current"
    else
      record_fail "diagram pipeline outputs are stale"
    fi
  else
    record_pass "node or diagram pipeline not found; skipped diagram drift check"
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
        print(f"missing README link target: {raw}", file=sys.stderr)
        failed = True

sys.exit(1 if failed else 0)
PY
    then
      record_pass "README local links resolve"
    else
      record_fail "README contains missing local links"
    fi
  else
    record_pass "python3 not found; skipped README link check"
  fi
}

collect_project_paths() {
  if [[ "${PROFILE}" == "mother" && -f "${ROOT}/docs/mother/project-inventory.yaml" ]]; then
    if command -v ruby >/dev/null 2>&1; then
      ruby -ryaml -e '
        data = YAML.load_file(ARGV.fetch(0)) || {}
        Array(data["projects"]).each do |project|
          path = project.fetch("path", nil)
          puts path if path
        end
      ' "${ROOT}/docs/mother/project-inventory.yaml"
    else
      awk -F: '
        /^[[:space:]]*path[[:space:]]*:/ {
          value=$2
          gsub(/^[[:space:]"]+|[[:space:]"]+$/, "", value)
          print value
        }
      ' "${ROOT}/docs/mother/project-inventory.yaml"
    fi
    return 0
  fi

  if [[ -d "${ROOT}/projects" ]]; then
    find "${ROOT}/projects" -mindepth 1 -maxdepth 1 -type d -print \
      | sed "s#^${ROOT}/##" \
      | sort
  fi
}

check_project_alignment_sections() {
  if [[ "${PROFILE}" == "template-release" ]]; then
    return 0
  fi

  local project
  while IFS= read -r project; do
    [[ -n "${project}" ]] || continue
    local rel="${project}/README.md"

    if [[ ! -f "${ROOT}/${rel}" ]]; then
      record_fail "missing project README: ${rel}"
      continue
    fi

    if grep -q '^## Workspace alignment$' "${ROOT}/${rel}"; then
      record_pass "project README has workspace alignment section: ${rel}"
    else
      record_fail "missing workspace alignment section: ${rel}"
    fi
  done < <(collect_project_paths)
}

check_project_licenses() {
  if [[ "${PROFILE}" == "template-release" ]]; then
    return 0
  fi

  local project
  while IFS= read -r project; do
    [[ -n "${project}" ]] || continue
    local rel="${project}/LICENSE"

    if [[ -f "${ROOT}/${rel}" ]]; then
      record_pass "project license exists: ${rel}"
    else
      record_fail "missing project license: ${rel}"
    fi
  done < <(collect_project_paths)
}

scan_sensitive_patterns() {
  local ip_pattern="223\\.109\\.140\\.60"
  local ssh_alias_pattern="sirius-cloud"'-root'
  local workspace_path_pattern="${HOME}/Code/tests"
  local root_user_pattern='user: "'root'"'
  local root_at_pattern='root''@'
  local private_key_pattern='BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY'
  local pattern="${ip_pattern}|${ssh_alias_pattern}|${workspace_path_pattern}|${root_user_pattern}|${root_at_pattern}|${private_key_pattern}"
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
    [[ "${JSON_OUTPUT}" == true ]] || echo "${output}" >&2
    record_fail "Sensitive pattern found"
  elif [[ "${status}" -eq 1 ]]; then
    record_pass "no known sensitive patterns found"
  else
    record_fail "sensitive pattern scan failed"
  fi
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "${value}"
}

emit_json_array() {
  local array_name="$1"
  local first=true
  printf '['
  local item
  local items=()
  set +u
  case "${array_name}" in
    passes)
      items=("${passes[@]}")
      ;;
    failures)
      items=("${failures[@]}")
      ;;
  esac
  for item in "${items[@]}"; do
    if [[ "${first}" == true ]]; then
      first=false
    else
      printf ','
    fi
    printf '"%s"' "$(json_escape "${item}")"
  done
  set -u
  printf ']'
}

emit_json() {
  local status="passed"
  set +u
  local failure_count="${#failures[@]}"
  set -u
  if [[ "${failure_count}" -gt 0 ]]; then
    status="failed"
  fi

  printf '{'
  printf '"status":"%s",' "${status}"
  printf '"profile":"%s",' "${PROFILE}"
  printf '"strict":%s,' "${STRICT}"
  printf '"root":"%s",' "$(json_escape "${ROOT}")"
  printf '"passes":'
  emit_json_array passes
  printf ',"failures":'
  emit_json_array failures
  printf '}\n'
}

main() {
  if [[ "${JSON_OUTPUT}" != true ]]; then
    echo "Auditing root repository: ${ROOT}"
    echo "Audit profile: ${PROFILE}"
  fi

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

  if [[ "${JSON_OUTPUT}" == true ]]; then
    emit_json
  fi

  set +u
  local failure_count="${#failures[@]}"
  set -u
  if [[ "${failure_count}" -gt 0 ]]; then
    if [[ "${JSON_OUTPUT}" != true ]]; then
      echo "Audit failed with ${failure_count} issue(s)" >&2
    fi
    exit 1
  fi

  if [[ "${JSON_OUTPUT}" != true ]]; then
    echo "Audit passed"
  fi
}

main "$@"
