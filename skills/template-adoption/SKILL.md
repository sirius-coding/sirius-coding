---
name: template-adoption
description: Use when helping someone create, evaluate, or adapt a workspace from the Sirius Evolution Station template.
---

# Template Adoption

## Overview

Use this skill to help a team adopt the Sirius Evolution Station as a reusable root control layer without importing business implementation or private operational data.

## Workflow

1. Confirm the target repository is a new workspace or a root control layer, not a business implementation repo.
2. Read `AGENTS.md`, `docs/adoption/quick-start.md`, and `specs/workspace/control-layer-os.md`.
3. Create or verify a private environment overlay from `docs/ops/environment-registry.private.example.yaml`.
4. Run `./scripts/root-repo-structure-audit.sh --strict`.
5. Add project implementation under `projects/<project-name>` or link to independent repositories.
6. Persist the first durable lesson in `docs/`, `specs/`, `skills/`, or `scripts/`.

## Guardrails

- Do not add secrets, real hostnames, private IPs, exact sensitive paths, or credentials to tracked files.
- Do not copy business implementation into the template repository.
- Do not weaken `AGENTS.md` or public/private rules to make adoption easier.
- Promote repeated workflows to skills only when they are reusable across projects.

## Output

Return an adoption summary with:

- Root assets read.
- Private overlay status.
- Audit result.
- Project boundary decision.
- First evolution candidate.
