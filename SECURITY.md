# Security Policy

This repository is public-facing. Treat every tracked file as visible to strangers.

## Public / Private Boundary

Tracked files may contain reusable structures, anonymized workflows, checklists, public project names, public-safe examples, and placeholder environment models.

Tracked files must not contain:

- Credentials, tokens, keys, certificates, or secret names.
- Real server accounts.
- Exact private hostnames or private IP addresses.
- Exact sensitive remote paths.
- Private login details.
- Infrastructure details that directly increase exposure risk.

## Private Overlay

Use `docs/ops/environment-registry.yaml` for public shape and placeholders.

Use a local ignored file for real values:

```bash
cp docs/ops/environment-registry.private.example.yaml docs/ops/environment-registry.private.yaml
```

Do not commit `docs/ops/environment-registry.private.yaml`.

## If Sensitive Data Is Found

1. Stop extending the affected public document.
2. Move the real value into the private overlay or a secret manager.
3. Replace the public value with a placeholder such as `<private-host-or-ip>`.
4. Run `./scripts/root-repo-structure-audit.sh --strict`.
5. If the value was already pushed, rotate the exposed secret or credential and rewrite or remove public history according to repository policy.

## Reporting

Open a private maintainer channel when possible. If only public GitHub Issues are available, describe the category of exposure without posting the sensitive value.
