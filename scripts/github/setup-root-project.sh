#!/usr/bin/env bash
set -euo pipefail

OWNER="@me"
REPO="sirius-coding/sirius-coding"
TITLE="Sirius Evolution Station Roadmap"

usage() {
  cat <<'EOF'
Usage: scripts/github/setup-root-project.sh [--owner <login|@me>] [--repo <owner/name>] [--title <project-title>]

Creates or reuses the GitHub Project that tracks root-workstation evolution, adds reusable planning fields,
and seeds the initial root governance issues.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --owner)
      OWNER="${2:-}"
      shift 2
      ;;
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
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

require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh is required" >&2
    exit 1
  fi
}

jq_string() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

find_project_number() {
  local escaped_title
  escaped_title="$(jq_string "${TITLE}")"
  gh project list --owner "${OWNER}" --limit 100 --format json \
    --jq ".projects[] | select(.title == \"${escaped_title}\") | .number"
}

ensure_project() {
  local number
  number="$(find_project_number | head -n 1)"

  if [[ -n "${number}" ]]; then
    echo "${number}"
    return
  fi

  gh project create --owner "${OWNER}" --title "${TITLE}" --format json --jq ".number"
}

field_exists() {
  local project_number="$1"
  local field_name="$2"
  local escaped_name
  escaped_name="$(jq_string "${field_name}")"

  gh project field-list "${project_number}" --owner "${OWNER}" --limit 100 --format json \
    --jq ".fields[] | select(.name == \"${escaped_name}\") | .name" | grep -qx "${field_name}"
}

ensure_single_select_field() {
  local project_number="$1"
  local field_name="$2"
  local options="$3"

  if field_exists "${project_number}" "${field_name}"; then
    echo "Project field exists: ${field_name}"
    return
  fi

  gh project field-create "${project_number}" \
    --owner "${OWNER}" \
    --name "${field_name}" \
    --data-type SINGLE_SELECT \
    --single-select-options "${options}" >/dev/null
  echo "Project field created: ${field_name}"
}

ensure_text_field() {
  local project_number="$1"
  local field_name="$2"

  if field_exists "${project_number}" "${field_name}"; then
    echo "Project field exists: ${field_name}"
    return
  fi

  gh project field-create "${project_number}" \
    --owner "${OWNER}" \
    --name "${field_name}" \
    --data-type TEXT >/dev/null
  echo "Project field created: ${field_name}"
}

find_issue_url() {
  local title="$1"
  local escaped_title
  escaped_title="$(jq_string "${title}")"

  gh issue list --repo "${REPO}" --state all --limit 100 --search "${title} in:title" --json title,url \
    --jq ".[] | select(.title == \"${escaped_title}\") | .url"
}

ensure_issue() {
  local project_number="$1"
  local title="$2"
  local body="$3"
  local url

  url="$(find_issue_url "${title}" | head -n 1)"
  if [[ -z "${url}" ]]; then
    url="$(gh issue create --repo "${REPO}" --title "${title}" --body "${body}")"
    echo "Issue created: ${title}"
  else
    echo "Issue exists: ${title}"
  fi

  gh project item-add "${project_number}" --owner "${OWNER}" --url "${url}" >/dev/null || true
}

main() {
  require_gh

  local project_number
  project_number="$(ensure_project)"

  ensure_single_select_field "${project_number}" "Track" "Template,Versioning,Diagram Capability,Project Alignment,Security,Automation"
  ensure_text_field "${project_number}" "Release"
  ensure_single_select_field "${project_number}" "Risk" "Low,Medium,High"

  ensure_issue "${project_number}" "Root template release v3.0.0" \
    "Track template synchronization from the main workspace to the reusable template repository after major releases."
  ensure_issue "${project_number}" "Backfill version history and release tags" \
    "Keep VERSION, CHANGELOG.md, docs/releases/release-history.md, and Git tags aligned."
  ensure_issue "${project_number}" "Harden public repository sanitization" \
    "Extend root and template audits when new public/private boundary risks appear."
  ensure_issue "${project_number}" "Promote diagram pipeline into reusable plugin" \
    "Evaluate whether the drawing pipeline should become a standalone reusable plugin or stay as a root skill and scripts."
  ensure_issue "${project_number}" "Review independent repositories against workstation goals" \
    "Keep independent project repositories aligned with root goals without copying business implementation into the template."

  echo "GitHub Project ready: ${TITLE} (#${project_number})"
}

main "$@"
