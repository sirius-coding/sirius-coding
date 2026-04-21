# Changelog

All notable workspace-level changes are tracked here.

This repository uses SemVer for the reusable evolution station. Business implementation changes under `projects/` are not template-version drivers unless they create reusable root assets.

## [4.0.1] - 2026-04-21

### Fixed

- Decoupled template adoption audits from mother-repository project checks.
- Added explicit repository-role detection for mother, template release, and adopted-template profiles.
- Prevented template exports from carrying mother-only project inventory, deployment checklists, local `.DS_Store` files, and stale GitHub helper folders.
- Generalized template-bound docs, skills, and environment examples so adopted workspaces can add their own `projects/<project-name>` without inheriting Sirius mother-project requirements.

## [4.0.0] - 2026-04-21

### Added

- Promoted the reusable station into a Control Layer OS product baseline.
- Added adoption docs, minimal project layout examples, contribution guidance, and security guidance.
- Added GitHub issue templates, PR template, root audit workflow, and template sync workflow.
- Added template adoption skill and Control Layer OS workspace specification.
- Added strict and JSON audit targets for productized template checks.

### Changed

- Upgraded template synchronization toward manifest-driven export and PR-based mother-to-template sync.
- Expanded template boundaries so public community assets are synchronized while business implementation remains excluded.

## [3.0.0] - 2026-04-21

### Added

- Introduced the diagram intent-layout-render pipeline for high-quality workflow diagrams.
- Added ProcessOn-style diagram visual rules and a reusable `diagram-pipeline` skill.
- Promoted the evolution workflow diagram to an SVG built from intent and layout assets.
- Added `VERSION`, release history, template manifest, template sync, and template audit scripts.
- Added a GitHub Projects roadmap model and setup script for root-workstation iteration.

### Changed

- Replaced the earlier mechanical Mermaid/draw.io/Excalidraw diagram output with intent, layout, SVG, and image prompt outputs.

## [2.0.0] - 2026-04-21

### Added

- Added Apache-2.0 licensing, notice, and commercialization boundary documents.
- Added independent repository alignment rules and module roadmap.
- Reworked Sirius visual branding and public-facing homepage positioning.

### Changed

- Aligned child project READMEs with the root workspace goal.
- Hardened root public/private boundary checks.

## [1.0.0] - 2026-04-21

### Added

- Established the Sirius Coding Evolution Station as a durable root workspace.
- Persisted the evolution handbook as the workspace's long-term operating model.
- Added root governance assets, audit scripts, environment registry, and reusable delivery skill.

[4.0.1]: https://github.com/sirius-coding/sirius-coding/releases/tag/v4.0.1
[4.0.0]: https://github.com/sirius-coding/sirius-coding/releases/tag/v4.0.0
[3.0.0]: https://github.com/sirius-coding/sirius-coding/releases/tag/v3.0.0
[2.0.0]: https://github.com/sirius-coding/sirius-coding/releases/tag/v2.0.0
[1.0.0]: https://github.com/sirius-coding/sirius-coding/releases/tag/v1.0.0
