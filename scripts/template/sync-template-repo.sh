#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
OUTPUT=""
REMOTE="git@github.com:sirius-coding/sirius-evolution-station-template.git"
PUSH=false
CHECK=false

usage() {
  cat <<'EOF'
Usage: scripts/template/sync-template-repo.sh --output <dir> [--remote <git-url>] [--push] [--check]

Generates the reusable template repository snapshot from the current root workspace.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    --remote)
      REMOTE="${2:-}"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --check)
      CHECK=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${OUTPUT}" ]]; then
  echo "--output is required" >&2
  usage >&2
  exit 2
fi

OUTPUT="$(mkdir -p "${OUTPUT}" && cd "${OUTPUT}" && pwd -P)"

if [[ "${CHECK}" == true ]]; then
  if [[ ! -d "${OUTPUT}" ]]; then
    echo "Template output does not exist: ${OUTPUT}" >&2
    exit 1
  fi
  bash "${ROOT}/scripts/template/template-repo-audit.sh" "${OUTPUT}"
  exit 0
fi

rm -rf "${OUTPUT:?}/"*
find "${OUTPUT}" -mindepth 1 -maxdepth 1 -name ".*" -exec rm -rf {} +

copy_path() {
  local rel="$1"
  [[ -e "${ROOT}/${rel}" ]] || return 0
  mkdir -p "${OUTPUT}/$(dirname "${rel}")"
  cp -R "${ROOT}/${rel}" "${OUTPUT}/${rel}"
}

include_paths=(
  ".codex"
  ".gitignore"
  "AGENTS.md"
  "CHANGELOG.md"
  "COMMERCIALIZATION.md"
  "LICENSE"
  "NOTICE"
  "VERSION"
  "assets"
  "docs"
  "scripts"
  "skills"
  "specs"
)

for rel in "${include_paths[@]}"; do
  copy_path "${rel}"
done

rm -rf \
  "${OUTPUT}/projects" \
  "${OUTPUT}/pom.xml" \
  "${OUTPUT}/docs/sirius-xz-agent-cloud-deploy-checklist.md" \
  "${OUTPUT}/docs/superpowers" \
  "${OUTPUT}/docs/ops/environment-registry.private.yaml" \
  "${OUTPUT}/.worktrees"

node "${ROOT}/scripts/template/sync-template-readme.mjs" "${ROOT}/README.md" "${OUTPUT}/README.md"

bash "${ROOT}/scripts/template/template-repo-audit.sh" "${OUTPUT}"

if [[ "${PUSH}" == true ]]; then
  if [[ ! -d "${OUTPUT}/.git" ]]; then
    git -C "${OUTPUT}" init
    git -C "${OUTPUT}" branch -M main
    git -C "${OUTPUT}" remote add origin "${REMOTE}"
  elif ! git -C "${OUTPUT}" remote get-url origin >/dev/null 2>&1; then
    git -C "${OUTPUT}" remote add origin "${REMOTE}"
  else
    git -C "${OUTPUT}" remote set-url origin "${REMOTE}"
  fi

  git -C "${OUTPUT}" add -A
  if git -C "${OUTPUT}" diff --cached --quiet; then
    echo "No template changes to commit"
  else
    git -C "${OUTPUT}" commit -m "release: sync evolution station template v$(tr -d '\n' < "${ROOT}/VERSION")"
  fi
  git -C "${OUTPUT}" push -u origin main
fi
