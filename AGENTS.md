# Workspace Agent Rules

## Repository Role

This repository is the workspace root for shared development assets. Treat it as:

- a workspace-level development station
- an asset organizer
- a rule evolution layer
- a cross-project orchestration surface

The root repository should prioritize shared documentation, reusable skills, environment models, release checklists, project indexes, and workstation rules. Business implementation belongs inside `projects/<project-name>`.

The complete workstation evolution handbook is persisted at `specs/workspace/evolution-handbook.md`. Treat that file as the durable source for the workspace's long-term operating model.

The root control plane is versioned through `VERSION`, `CHANGELOG.md`, and `docs/releases/release-history.md`. Version 4 and later treat the repository as a Control Layer OS: reusable governance, memory, skills, audit, adoption, and sync assets around project implementation. Major reusable root upgrades are synchronized to the template repository using `scripts/template/sync-template-repo.sh --pr`; business implementation under `projects/` must stay out of that template.

## Fact Source Priority

Use facts in this order:

1. Existing repository assets: `README.md`, `docs/`, `skills/`, `scripts/`, `projects/`, environment registries, release checklists, and runbooks.
2. Standard control assets: `AGENTS.md`, `.codex/config.toml`, `specs/`, `.github/`, `specs/review/`, and project-level override files.
3. Weak memory: only for recall of stable preferences or repeated collaboration patterns. Long-lived rules must be promoted into repository files.

Do not replace repository facts with chat-only explanations.

## Directory Contract

- `projects/`: independently runnable projects or subsystems.
- `docs/`: cross-project documentation, runbooks, environment models, and architecture notes.
- `skills/`: reusable execution workflows for recurring tasks.
- `specs/`: workspace rules, review standards, templates, and future control-plane specs.
- `scripts/`: local automation that is safe to run from the workspace root.
- `.codex/`: Codex-local configuration only. Shared behavior belongs in this file or under `specs/`.

Template sync is governed by `docs/template/template-manifest.yaml`. It may include shared rules, docs, skills, scripts, specs, and public assets, but must exclude `projects/`, root business build aggregation, private overlays, and project-specific deployment details.

Productized template assets include `CONTRIBUTING.md`, `SECURITY.md`, `.github/`, `docs/adoption/`, `examples/`, and `skills/template-adoption/`. When these assets change, update README links, the template manifest, and `specs/workspace/core-assets-map.md`.

## Root vs Project Boundary

Root repository work should focus on shared rules, reusable workflows, templates, documentation structure, public/private information boundaries, and cross-project navigation.

Project work should focus on implementation, tests, builds, packaging, deploy logic, smoke checks, project-specific specs, and project-level review quality.

Do not make broad implementation changes across multiple `projects/` children unless the user explicitly asks for a cross-project implementation pass.

## Public Repository Guardrails

This repository is public-facing. Keep public assets free of:

- real server accounts
- tokens, credentials, keys, certificates, and secret names
- exact sensitive hostnames or IP addresses
- exact sensitive remote paths
- private login details
- infrastructure details that would directly increase exposure risk

Use public templates in tracked files and keep real environment values in ignored private overlays such as `docs/ops/environment-registry.private.yaml`.

If real environment data is already coupled into public docs, prefer splitting it into public and private layers before extending it.

## Default Workflow

1. Read existing assets before proposing structure changes.
2. Decide whether the task belongs to the workspace root or a child project.
3. Reuse existing docs and skills before creating new mechanisms.
4. Make the smallest coherent, verifiable change.
5. Add or update cross-links so new assets are discoverable.
6. For root repository changes, run `./scripts/root-repo-structure-audit.sh` when available.
7. Verify changed assets with formatting, parsing, build, test, or targeted smoke checks. For root/productized template changes, prefer `./scripts/root-repo-structure-audit.sh --strict`.
8. End with an evolution note that says what should be documented, skilled, automated, or delegated to projects.

## Risk Gates

Explain the risk before changing:

- environment registry models
- release checklists
- shared skill scope
- public fact-source definitions
- multi-project directory rules
- release or sync scripts
- external GitHub publication strategy

## Standard Response Shape

Unless the user asks for a different format, summarize substantial workspace work with:

- `Understanding`: goal, root/project scope, constraints, known facts, unknowns.
- `Plan`: steps, impact, reused assets, verification, guardrails.
- `Execution`: files read, files changed, shared assets added, structural issues found.
- `Result`: completed work, remaining gaps, current risks, next suggestions.
- `Evolution`: what to persist, skill, automate, write into root rules, delegate to projects, or split into public/private layers.

Keep brief tasks brief. Use the full shape only when it improves clarity.

## Evolution Checklist

At the end of each task, ask:

1. Is this root governance work or project implementation work?
2. Should the new knowledge live in the root repository or a project?
3. Did any chat-only conclusion need to become a repository asset?
4. Is there a repeated flow worth turning into a shared skill?
5. Is there a repeated check worth automating?
6. Is there a public/private boundary problem?
7. Does this affect multiple projects?
8. Should workspace rules be updated?
