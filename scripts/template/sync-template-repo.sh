#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
MANIFEST="${ROOT}/docs/template/template-manifest.yaml"
OUTPUT="/tmp/sirius-evolution-station-template-export"
REMOTE="git@github.com:sirius-coding/sirius-evolution-station-template.git"
PR_REPO="sirius-coding/sirius-evolution-station-template"
PUSH=false
CHECK=false
CREATE_PR=false
BRANCH_PREFIX="sync/from-mother"

usage() {
  cat <<'EOF'
Usage: scripts/template/sync-template-repo.sh [--output <dir>] [--remote <git-url>] [--repo <owner/name>] [--push] [--pr] [--check]

Generates the reusable template repository snapshot from the current root workspace.
Use --pr to create a template repository sync branch and pull request.
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
    --repo)
      PR_REPO="${2:-}"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --pr)
      CREATE_PR=true
      shift
      ;;
    --check)
      CHECK=true
      shift
      ;;
    --branch-prefix)
      BRANCH_PREFIX="${2:-}"
      shift 2
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

if [[ "${PUSH}" == true && "${CREATE_PR}" == true ]]; then
  echo "--push and --pr are mutually exclusive" >&2
  exit 2
fi

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Missing template manifest: ${MANIFEST}" >&2
  exit 1
fi

OUTPUT="$(mkdir -p "${OUTPUT}" && cd "${OUTPUT}" && pwd -P)"

read_manifest_list() {
  local expression="$1"
  ruby -ryaml -e '
    data = YAML.load_file(ARGV.fetch(0))
    keys = ARGV.fetch(1).split(".")
    value = keys.reduce(data) { |memo, key| memo.fetch(key, []) }
    Array(value).each { |item| puts item }
  ' "${MANIFEST}" "${expression}"
}

root_files=()
while IFS= read -r line; do
  root_files+=("${line}")
done < <(read_manifest_list "include.root_files")

directories=()
while IFS= read -r line; do
  directories+=("${line}")
done < <(read_manifest_list "include.directories")

exclude_paths=()
while IFS= read -r line; do
  exclude_paths+=("${line}")
done < <(read_manifest_list "exclude.paths")

if [[ "${CHECK}" == true ]]; then
  bash "${ROOT}/scripts/template/template-repo-audit.sh" "${OUTPUT}"
  bash "${ROOT}/scripts/root-repo-structure-audit.sh" "${OUTPUT}" --strict --profile template-release
  exit 0
fi

reset_dir() {
  local dir="$1"
  mkdir -p "${dir}"
  find "${dir}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

copy_path() {
  local rel="$1"
  [[ -e "${ROOT}/${rel}" ]] || return 0
  mkdir -p "${OUTPUT}/$(dirname "${rel}")"
  cp -R "${ROOT}/${rel}" "${OUTPUT}/${rel}"
}

reset_dir "${OUTPUT}"

for rel in "${root_files[@]}"; do
  copy_path "${rel}"
done

for rel in "${directories[@]}"; do
  copy_path "${rel}"
done

for rel in "${exclude_paths[@]}"; do
  rm -rf "${OUTPUT}/${rel}"
done

find "${OUTPUT}" -name ".DS_Store" -type f -delete

mkdir -p "${OUTPUT}/docs/template"
cat > "${OUTPUT}/docs/template/repository-role.yaml" <<'EOF'
role: "template"
description: "Reusable Sirius Evolution Station template snapshot. Adding projects/ makes audits run in adopter mode."
EOF

node "${ROOT}/scripts/template/sync-template-readme.mjs" "${ROOT}/README.md" "${OUTPUT}/README.md"

template_audit_output="$(bash "${ROOT}/scripts/template/template-repo-audit.sh" "${OUTPUT}")"
root_audit_output="$(bash "${ROOT}/scripts/root-repo-structure-audit.sh" "${OUTPUT}" --strict --profile template-release)"

print_summary() {
  echo "Included paths:"
  for rel in "${root_files[@]}"; do
    echo "- ${rel}"
  done
  for rel in "${directories[@]}"; do
    echo "- ${rel}"
  done

  echo "Excluded paths:"
  for rel in "${exclude_paths[@]}"; do
    echo "- ${rel}"
  done

  echo "Verification:"
  echo "- template audit: passed"
  echo "- root strict audit: passed"
}

print_summary

commit_snapshot() {
  local repo_dir="$1"
  git -C "${repo_dir}" add -A
  if git -C "${repo_dir}" diff --cached --quiet; then
    echo "No template changes to commit"
    return 1
  fi

  git -C "${repo_dir}" commit -m "release: sync evolution station template v$(tr -d '\n' < "${ROOT}/VERSION")"
  return 0
}

if [[ "${PUSH}" == true ]]; then
  git -C "${OUTPUT}" init
  git -C "${OUTPUT}" branch -M main
  git -C "${OUTPUT}" remote add origin "${REMOTE}"
  if commit_snapshot "${OUTPUT}"; then
    git -C "${OUTPUT}" push -u origin main
  fi
fi

if [[ "${CREATE_PR}" == true ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is required for --pr" >&2
    exit 1
  fi

  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' EXIT
  clone_dir="${workdir}/template"
  branch="${BRANCH_PREFIX}-$(date -u +%Y%m%d%H%M%S)"

  git clone "${REMOTE}" "${clone_dir}"
  git -C "${clone_dir}" checkout -b "${branch}"
  find "${clone_dir}" -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} +
  cp -R "${OUTPUT}/." "${clone_dir}/"

  bash "${ROOT}/scripts/template/template-repo-audit.sh" "${clone_dir}" >/dev/null
  bash "${ROOT}/scripts/root-repo-structure-audit.sh" "${clone_dir}" --strict --profile template-release >/dev/null

  git -C "${clone_dir}" add -A
  if git -C "${clone_dir}" diff --cached --quiet; then
    echo "No template changes detected; no PR created"
    exit 0
  fi

  changed_files="$(git -C "${clone_dir}" diff --cached --name-status)"
  git -C "${clone_dir}" commit -m "sync: update from mother repo"
  git -C "${clone_dir}" push -u origin "${branch}"

  body_file="${workdir}/pr-body.md"
  {
    echo "## Summary"
    echo
    echo "Auto sync from mother repository at version $(tr -d '\n' < "${ROOT}/VERSION")."
    echo
    echo "## Changed Files"
    echo
    echo '```text'
    echo "${changed_files}"
    echo '```'
    echo
    echo "## Sync Summary"
    echo
    print_summary
    echo
    echo "## Audit"
    echo
    echo '```text'
    echo "${template_audit_output}"
    echo "${root_audit_output}"
    echo '```'
  } > "${body_file}"

  gh pr create \
    --repo "${PR_REPO}" \
    --title "sync: update from mother repo" \
    --body-file "${body_file}" \
    --base main \
    --head "${branch}"
fi
