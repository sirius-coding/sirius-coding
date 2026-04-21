#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${SCRIPT_DIR}/root-repo-structure-audit.sh"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

create_clean_fixture() {
  local root="$1"

  mkdir -p \
    "${root}/.codex" \
    "${root}/docs/diagrams" \
    "${root}/docs/ops" \
    "${root}/docs/releases" \
    "${root}/docs/template" \
    "${root}/assets" \
    "${root}/skills/workspace-multi-env-delivery" \
    "${root}/specs/review" \
    "${root}/specs/workspace" \
    "${root}/projects" \
    "${root}/scripts/github" \
    "${root}/scripts/template"

  cat > "${root}/README.md" <<'EOF'
# Fixture

- [Agent Rules](./AGENTS.md)
- [Opening Model](./docs/ops/workspace-opening-model.md)
EOF

  cat > "${root}/LICENSE" <<'EOF'
Apache License fixture
EOF

  cat > "${root}/VERSION" <<'EOF'
3.0.0
EOF

  cat > "${root}/CHANGELOG.md" <<'EOF'
# Changelog

## [3.0.0] - 2026-04-21

- Fixture release.
EOF

  cat > "${root}/NOTICE" <<'EOF'
Sirius Coding fixture notice
EOF

  cat > "${root}/COMMERCIALIZATION.md" <<'EOF'
# Commercialization
EOF

  cat > "${root}/assets/hero.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><title>Sirius fixture</title></svg>
EOF

  cat > "${root}/AGENTS.md" <<'EOF'
# Agent Rules
EOF

  cat > "${root}/.codex/config.toml" <<'EOF'
[features]
multi_agent = true
EOF

  cat > "${root}/docs/ops/workspace-opening-model.md" <<'EOF'
# Workspace Opening Model
EOF

  cat > "${root}/docs/ops/github-project-roadmap.md" <<'EOF'
# GitHub Project Roadmap
EOF

  cat > "${root}/docs/diagrams/README.md" <<'EOF'
# Diagram Capability
EOF

  cat > "${root}/docs/diagrams/evolution-workflow.diagram.json" <<'EOF'
{
  "id": "evolution-workflow",
  "title": "Evolution Workflow",
  "nodes": [
    { "id": "A", "title": "A", "subtitle": "Start", "role": "main" },
    { "id": "B", "title": "B", "subtitle": "Hub", "role": "hub" },
    { "id": "C", "title": "C", "subtitle": "Branch", "role": "branch" },
    { "id": "D", "title": "D", "subtitle": "Merge", "role": "merge" },
    { "id": "E", "title": "E", "subtitle": "End", "role": "end" }
  ],
  "main_chain": ["A", "B", "D", "E"],
  "parallel_groups": [
    { "id": "assets", "title": "Assets", "source": "B", "merge": "D", "columns": ["C"] }
  ],
  "merge_nodes": ["D"],
  "feedback_loops": [
    { "from": "E", "to": "A", "label": "Loop", "route": "outer-left" }
  ]
}
EOF

  for generated in intent.json layout.plan.json svg image-prompt.md; do
    echo "fixture" > "${root}/docs/diagrams/evolution-workflow.${generated}"
  done

  cat > "${root}/docs/ops/environment-registry.yaml" <<'EOF'
version: 1
visibility: "public"
environments: []
EOF

  cat > "${root}/docs/ops/environment-registry.private.example.yaml" <<'EOF'
version: 1
visibility: "private-example"
environments: []
EOF

  cat > "${root}/docs/releases/release-history.md" <<'EOF'
# Release History

Current version: 3.0.0
EOF

  cat > "${root}/docs/template/template-manifest.yaml" <<'EOF'
version: 1
current_version: "3.0.0"
include_paths: []
exclude_paths: []
EOF

  cat > "${root}/skills/workspace-multi-env-delivery/SKILL.md" <<'EOF'
---
name: workspace-multi-env-delivery
description: Test fixture skill.
---

# Skill
EOF

  cat > "${root}/specs/review/code_review.md" <<'EOF'
# Code Review Standard
EOF

  cat > "${root}/specs/workspace/workstation-operating-rules.md" <<'EOF'
# Workstation Operating Rules
EOF

  cat > "${root}/specs/workspace/public-private-boundary.md" <<'EOF'
# Public and Private Knowledge Boundary
EOF

  cat > "${root}/specs/workspace/evolution-handbook.md" <<'EOF'
# Evolution Handbook
EOF

  cat > "${root}/specs/workspace/core-assets-map.md" <<'EOF'
# Core Assets Map
EOF

  cat > "${root}/specs/workspace/independent-repo-alignment.md" <<'EOF'
# Independent Repository Alignment
EOF

  cat > "${root}/specs/workspace/module-roadmap.md" <<'EOF'
# Module Roadmap
EOF

  for project in sirius-xz-agent sirius-xz-agent-ui sirius-cloud-starter sirius-web-toolkit; do
    mkdir -p "${root}/projects/${project}"
    cat > "${root}/projects/${project}/README.md" <<'EOF'
# Fixture project

## Workspace alignment

This project inherits the root workspace rules.
EOF
    cat > "${root}/projects/${project}/LICENSE" <<'EOF'
Apache License fixture
EOF
  done

  cat > "${root}/scripts/root-repo-structure-audit.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/root-repo-structure-audit.test.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/template-repo.test.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/template/sync-template-readme.mjs" <<'EOF'
#!/usr/bin/env node
process.exit(0);
EOF

  cat > "${root}/scripts/template/sync-template-repo.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/template/template-repo-audit.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/generate-diagrams.mjs" <<'EOF'
#!/usr/bin/env node
process.exit(0);
EOF

  cat > "${root}/scripts/generate-diagrams.test.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  cat > "${root}/scripts/github/setup-root-project.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  mkdir -p "${root}/scripts/diagram"
  for script in build-all build-intent build-layout render-svg render-prompt; do
    cat > "${root}/scripts/diagram/${script}.mjs" <<'EOF'
#!/usr/bin/env node
process.exit(0);
EOF
  done

  cat > "${root}/scripts/diagram-pipeline.test.sh" <<'EOF'
#!/usr/bin/env bash
echo fixture
EOF

  mkdir -p "${root}/skills/diagram-pipeline"
  cat > "${root}/skills/diagram-pipeline/SKILL.md" <<'EOF'
---
name: diagram-pipeline
description: Fixture diagram skill.
---

# Diagram Pipeline
EOF

  cat > "${root}/specs/diagram-style.md" <<'EOF'
# Diagram Style
EOF
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "${haystack}" != *"${needle}"* ]]; then
    echo "Expected output to contain: ${needle}" >&2
    echo "Actual output:" >&2
    echo "${haystack}" >&2
    exit 1
  fi
}

clean_fixture="${TMP_ROOT}/clean"
create_clean_fixture "${clean_fixture}"

clean_output="$("${SCRIPT}" "${clean_fixture}")"
assert_contains "${clean_output}" "Audit passed"

sensitive_fixture="${TMP_ROOT}/sensitive"
create_clean_fixture "${sensitive_fixture}"
ip_part_a="223"
ip_part_b="109"
ip_part_c="140"
ip_part_d="60"
echo "http://${ip_part_a}.${ip_part_b}.${ip_part_c}.${ip_part_d}:26100" > "${sensitive_fixture}/docs/leaked.md"

set +e
sensitive_output="$("${SCRIPT}" "${sensitive_fixture}" 2>&1)"
sensitive_status="$?"
set -e

if [[ "${sensitive_status}" -eq 0 ]]; then
  echo "Expected sensitive fixture to fail audit" >&2
  exit 1
fi

assert_contains "${sensitive_output}" "Sensitive pattern found"

missing_license_fixture="${TMP_ROOT}/missing-license"
create_clean_fixture "${missing_license_fixture}"
rm "${missing_license_fixture}/LICENSE"

set +e
missing_license_output="$("${SCRIPT}" "${missing_license_fixture}" 2>&1)"
missing_license_status="$?"
set -e

if [[ "${missing_license_status}" -eq 0 ]]; then
  echo "Expected missing license fixture to fail audit" >&2
  exit 1
fi

assert_contains "${missing_license_output}" "missing required path: LICENSE"

missing_alignment_fixture="${TMP_ROOT}/missing-alignment"
create_clean_fixture "${missing_alignment_fixture}"
perl -0pi -e 's/\n## Workspace alignment\n\nThis project inherits the root workspace rules\.\n//' "${missing_alignment_fixture}/projects/sirius-xz-agent/README.md"

set +e
missing_alignment_output="$("${SCRIPT}" "${missing_alignment_fixture}" 2>&1)"
missing_alignment_status="$?"
set -e

if [[ "${missing_alignment_status}" -eq 0 ]]; then
  echo "Expected missing alignment fixture to fail audit" >&2
  exit 1
fi

assert_contains "${missing_alignment_output}" "missing workspace alignment section"

echo "root-repo-structure-audit tests passed"
