# Mother Repository Relationship

The Sirius Evolution Station has two repository roles.

## Mother Repository

`sirius-coding/sirius-coding` is the live workstation. It contains the root control layer and may contain local project implementation under `projects/`.

The mother repository is where new workflow ideas are validated against real work before becoming template assets.

## Template Repository

`sirius-coding/sirius-evolution-station-template` is the reusable public baseline. It should contain root control layer assets only.

It must not contain:

- `projects/`
- root business aggregation build files such as `pom.xml`
- project-specific deployment checklists
- private overlays or real environment values

## Sync Rule

The template repository is updated from the mother repository through `scripts/template/sync-template-repo.sh`. The manifest at `docs/template/template-manifest.yaml` defines what may be copied.

For major versions, prefer PR-based sync:

```bash
./scripts/template/sync-template-repo.sh --pr
```

In GitHub Actions, cross-repository sync should use a repository secret named `SIRIUS_TEMPLATE_SYNC_TOKEN` when the default `GITHUB_TOKEN` cannot push branches to the template repository.

Direct template edits are reserved for emergency repairs or repository-administration changes that cannot originate in the mother repository.
