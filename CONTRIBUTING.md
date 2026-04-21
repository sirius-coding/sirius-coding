# Contributing

This repository accepts contributions that improve the reusable root control layer. It is not the place for business implementation changes.

## Welcome Contributions

- Root documentation that improves adoption, review quality, public/private boundaries, or workspace governance.
- Reusable skills under `skills/`.
- Safe automation under `scripts/`.
- Template synchronization and audit improvements.
- Diagram pipeline improvements that stay reusable.
- Adoption feedback from teams using the template.

## Out of Scope

- Business code under `projects/` unless the change is explicitly about root-level alignment documentation.
- Real environment values, credentials, private hostnames, exact private IPs, sensitive remote paths, tokens, keys, or certificates.
- Project-specific deployment details that do not belong in a reusable template.
- Changes that reintroduce root business build aggregation into the template repository.

## Mother Repository vs Template Repository

The mother repository `sirius-coding/sirius-coding` is the primary iteration workspace. It validates real workflows and owns the source of truth for reusable assets.

The template repository `sirius-coding/sirius-evolution-station-template` is the public reusable baseline. Template changes should come from mother-repo sync unless a maintainer explicitly asks for an emergency template-only fix.

## Local Validation

Run these checks before opening a PR:

```bash
./scripts/root-repo-structure-audit.sh --strict
bash scripts/template-repo.test.sh
git diff --check
```

If you changed the diagram pipeline, also run:

```bash
bash scripts/diagram-pipeline.test.sh
bash scripts/generate-diagrams.test.sh
node scripts/diagram/build-all.mjs --check docs/diagrams/evolution-workflow.diagram.json
```

## PR Description

Include:

- Why the change is reusable.
- Which root assets changed.
- Whether template sync is affected.
- Validation commands and results.
- Confirmation that no private values or business implementation were added.
