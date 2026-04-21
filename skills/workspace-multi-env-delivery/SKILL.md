---
name: workspace-multi-env-delivery
description: Use when adding projects under this workspace, publishing subprojects independently, or deploying/releasing across multiple servers and environments.
---

# Workspace Multi-env Delivery

## Overview

This skill standardizes three things:

1. How new projects are exposed from this workspace.
2. How independent repos are managed without nested git.
3. How multi-environment server release and verification are executed.

## When to Use

Use when any of these happen:

- A new project is added under `projects/`.
- A project needs an independent GitHub repo while keeping monorepo development.
- A project is deployed to a new server or environment.
- Existing deployment fails and needs structured diagnosis.

## Source of Truth

- Workspace opening model:
  - `docs/ops/workspace-opening-model.md`
- Server/environment registry:
  - public model: `docs/ops/environment-registry.yaml`
  - private local overlay: `docs/ops/environment-registry.private.yaml`
- Deploy/release checklist:
  - project-owned checklist under `projects/<project-name>/docs/` or a mother-only checklist under `docs/mother/`
- Public/private boundary:
  - `specs/workspace/public-private-boundary.md`
- Root repository audit:
  - `scripts/root-repo-structure-audit.sh`

## Core Workflow

### Step 1: Choose project exposure mode

Pick one:

- `Mode A`: monorepo-only
- `Mode B`: monorepo + independent repo via subtree
- `Mode C`: deployed service with environment registration

### Step 2: Register/Update environment

Before first deploy to any server:

1. Add or update the public environment item in `docs/ops/environment-registry.yaml` with placeholders when values are sensitive.
2. Add real `ssh alias`, `host`, `paths`, `ports`, and service names to ignored `docs/ops/environment-registry.private.yaml`.
3. Never commit the private overlay.

### Step 3: Release using checklist

Follow the project-owned or mother-only release checklist strictly:

1. Local build passes.
2. Sync artifacts to server.
3. Start DB -> backend -> frontend.
4. Run smoke tests and negative checks.
5. Keep release evidence free of real private host details when committing public notes.
6. Run `./scripts/root-repo-structure-audit.sh` before committing root delivery docs.

### Step 4: Evidence capture

Store release evidence in commit message or release note:

1. Container status line.
2. Backend business endpoint result.
3. Health endpoint result.
4. Frontend API proxy endpoint result.

## Independent Repo Rule (Critical)

For projects published independently:

- Keep source under `projects/<name>`.
- Do not create nested `.git`.
- Publish with subtree only:

```bash
git subtree push --prefix=projects/<name> <remote> main
```

## Failure Triage Order

Always diagnose in this order:

1. Network reachability (`ssh`, public port).
2. Container status (`docker ps`).
3. Dependency readiness (DB/container health).
4. Backend direct endpoint.
5. Frontend proxy endpoint.
6. CORS/content-type/path details.

## Common Mistakes

1. Prefix duplication in URL join (`/api/api/...`).
2. Health endpoint incorrectly routed through `/api`.
3. Service healthy locally but not published on expected public port.
4. Backend restarting because database container is down.
5. Treating 502/timeout as CORS first instead of connectivity first.
