# Release History

This workspace treats major versions as reusable station capability milestones. The current main repository remains the primary iteration space, while the template repository receives only reusable root-workstation assets at major-version release points.

## Version Policy

- Use SemVer for the reusable evolution station: `MAJOR.MINOR.PATCH`.
- Increase `MAJOR` when the station direction, governance model, or reusable capability model changes substantially.
- Increase `MINOR` when adding reusable root capabilities without changing the operating model.
- Increase `PATCH` for documentation, audit, or script fixes that preserve behavior.
- Business implementation changes under `projects/` do not drive template versions unless they produce reusable root assets.

## Historical Milestones

| Version | Meaning |
| --- | --- |
| `v1.0.0` | Root evolution station formed: durable handbook, rules, root/project boundary, audit entrypoint. |
| `v2.0.0` | Public and template readiness: license, brand boundary, independent repo alignment, module roadmap. |
| `v3.0.0` | Template-ready evolution station: high-quality diagram pipeline, SemVer history, template sync, and GitHub Project roadmap. |

## Template Release Rule

The main repository is the live workstation. The template repository is a reusable baseline. Only major reusable upgrades should be synced to the template repository.

Template sync excludes:

- `projects/`
- root Maven project aggregation for business modules
- business deployment checklists
- project-specific design histories
- private overlays and real environment values

Template sync includes:

- root governance files
- root documentation and specs
- reusable skills
- reusable scripts
- public diagrams and visual assets
- license, notice, and commercialization boundary documents
