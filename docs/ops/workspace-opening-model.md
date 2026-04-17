# Workspace Opening Model

## Purpose

Standardize how projects under `<workspace-root>` are created, published, and operated as the workspace grows.

## Directory Contract

- `projects/`: all runnable projects live here
- `docs/`: cross-project documentation, runbooks, and architecture notes
- `skills/`: reusable execution skills for future delivery/ops tasks

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
- Keep environment inventory in `docs/ops/environment-registry.yaml`
- Use the same release checklist across environments

## Required Rules

1. No direct editing on server as source-of-truth; server only receives synced artifacts.
2. Release path must be reproducible from this workspace.
3. Every deployed project must have:
   - deploy command
   - smoke checks
   - rollback note
4. Any new server/environment must be recorded in `docs/ops/environment-registry.yaml`.

## Release Artifacts (Minimum)

For each deployable project:

1. Compose file for cloud target.
2. One-line start command.
3. Smoke test commands for:
   - service status
   - key business endpoint
   - health endpoint

## Current Baseline

- Backend: `projects/sirius-xz-agent`
- Frontend: `projects/sirius-xz-agent-ui`
- Cross-project checklist: `docs/sirius-xz-agent-cloud-deploy-checklist.md`
- Reusable skill: `skills/workspace-multi-env-delivery/SKILL.md`
