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

Use `./scripts/root-repo-structure-audit.sh --strict` as the default local check before committing root repository or template-bound changes.

## Community Boundary

Issue templates, PR templates, adoption docs, and examples are public entry points. They should ask for categories, symptoms, reusable context, and validation output, but must not ask users to paste secrets, private hostnames, private IP addresses, credentials, or sensitive remote paths.

When a report needs sensitive evidence, ask for a private maintainer channel and keep the public issue limited to the exposure category.

## Template Boundary

The template repository may include public rules, docs, examples, workflows, and reusable skills. It must exclude `projects/`, root business build aggregation, project-specific deployment checklists, private overlays, and real environment values.
