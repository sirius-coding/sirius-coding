# Workspace Opening Model

## Purpose

Standardize how projects under this workspace root are created, published, and operated as the workspace grows.

## Directory Contract

- `projects/`: all runnable projects live here
- `docs/`: cross-project documentation, runbooks, and architecture notes
- `skills/`: reusable execution skills for future delivery/ops tasks
- `specs/`: workspace rules, review standards, and reusable control-plane specs
- `.codex/`: local Codex configuration only

## Control Layer

- Root agent rules: `AGENTS.md`
- Codex local config: `.codex/config.toml`
- Evolution handbook: `specs/workspace/evolution-handbook.md`
- Workspace operating rules: `specs/workspace/workstation-operating-rules.md`
- Public/private boundary: `specs/workspace/public-private-boundary.md`
- Core assets map: `specs/workspace/core-assets-map.md`
- Independent repo alignment: `specs/workspace/independent-repo-alignment.md`
- Module roadmap: `specs/workspace/module-roadmap.md`
- Code review standard: `specs/review/code_review.md`
- Root repository audit: `scripts/root-repo-structure-audit.sh`

## Project Exposure Modes

Use one of these modes for each new project.

### Mode A: Monorepo-only

Use when the project is still incubating and no external repo is needed yet.

- Source path: `projects/<project-name>`
- Versioning: root repo only
- Deployment: optional

### Mode B: Monorepo + Independent GitHub repo (subtree)

Use when project should be independently consumable but still developed from this workspace.

- Source path: `projects/<project-name>`
- Root repo keeps full history/context
- Independent repo is synced via `git subtree`
- No nested `.git` inside `projects/<project-name>`

Reference commands:

```bash
# add independent remote once
git remote add <remote-name> git@github.com:<owner>/<repo>.git

# publish from workspace project path
git subtree push --prefix=projects/<project-name> <remote-name> main
```

### Mode C: Multi-environment deployment

Use when project is deployed to one or more servers.

- Keep deployment assets in project directory (`docker-compose`, nginx config, Dockerfile)
- Keep public environment inventory in `docs/ops/environment-registry.yaml`
- Keep real environment values in ignored private overlay `docs/ops/environment-registry.private.yaml`
- Use the same release checklist across environments

## Required Rules

1. No direct editing on server as source-of-truth; server only receives synced artifacts.
2. Release path must be reproducible from this workspace.
3. Every deployed project must have:
   - deploy command
   - smoke checks
   - rollback note
4. Any new server/environment must be recorded in `docs/ops/environment-registry.yaml`.
5. Public docs must not expose real server accounts, exact private hosts, credentials, or sensitive remote paths.

## Release Artifacts (Minimum)

For each deployable project:

1. Compose file for cloud target.
2. One-line start command.
3. Smoke test commands for:
   - service status
   - key business endpoint
   - health endpoint

## Current Baseline

- Template adopters should create implementation under `projects/<project-name>`.
- Deployed projects should keep project-specific deployment checklists under their own project directory or in a private, non-template operations area.
- Reusable skill: `skills/workspace-multi-env-delivery/SKILL.md`
- Root rules: `AGENTS.md`
- Evolution handbook: `specs/workspace/evolution-handbook.md`
- Core assets map: `specs/workspace/core-assets-map.md`
- Review standard: `specs/review/code_review.md`
