## Why

## Reusable Root Value

## Affected Paths

## Validation

```bash
./scripts/root-repo-structure-audit.sh --strict
```

## Boundary Check

- [ ] No secrets, credentials, private hosts, private IPs, or sensitive paths were added.
- [ ] No business implementation was added to template-bound assets.
- [ ] README, template manifest, and core assets map were updated if public assets changed.
