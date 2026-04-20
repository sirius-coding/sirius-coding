# Public and Private Knowledge Boundary

## Purpose

Keep this public repository useful without exposing real operational details.

## Public Assets

Tracked public assets may contain:

- directory structure
- workflow descriptions
- checklists
- anonymized topology
- reusable templates
- public project names
- generic ports when they are part of project code
- abstract environment models
- verification categories

## Private Assets

Do not commit:

- credentials, tokens, keys, or certificates
- real server accounts
- exact private hostnames or IP addresses
- exact sensitive remote paths
- private login details
- secret manager paths
- infrastructure details that directly increase exposure risk

## Environment Registry Model

Use `docs/ops/environment-registry.yaml` as the public model. Keep real values in `docs/ops/environment-registry.private.yaml`, which must stay ignored by git.

When writing public docs or skills, reference placeholders such as:

- `<private-ssh-alias>`
- `<private-host-or-ip>`
- `<remote-workspace-root>`
- `<backend-public-port>`
- `<frontend-public-port>`

## Sanitization Rule

Before committing root docs that mention deployment, scan for real environment values and replace them with placeholders unless the user explicitly asks to publish them.

Use `./scripts/root-repo-structure-audit.sh` as the default local check before committing root repository changes.
