# Independent Repository Alignment

## Purpose

Keep independent project repositories aligned with the root evolution station without turning the root repository into a business-code monolith.

## Alignment Standard

Every independent or potentially independent project should have:

1. A clear README purpose statement.
2. A `Workspace alignment` section that points back to the root rules.
3. A `.gitignore`.
4. A build or smoke-test command.
5. A project-level CI workflow when it is published independently.
6. A note about which responsibilities stay project-owned.
7. No committed private environment values.
8. A clear decision about whether reusable lessons belong back in the root Control Layer OS.

## Current Projects

Template adopters should maintain their own project inventory outside reusable template assets. Use this shape for each project:

| Project | Exposure | Alignment Status | Next Action |
| --- | --- | --- | --- |
| `projects/<project-name>` | Monorepo-only, independent repo, or deployed service | README, license, verification, and public/private boundary status | Keep implementation project-owned; promote reusable lessons to root docs or skills |

The mother repository may keep a concrete project inventory in `docs/mother/project-inventory.yaml`, which is excluded from template sync.

## Remote Inspection

For each independently published project, inspect the remote repository before release:

| Repository | Visibility | Remote License Metadata | Alignment Need |
| --- | --- | --- | --- |
| `<owner>/<repo>` | public or private | expected SPDX license metadata | Publish project `LICENSE`, README alignment, CI, and public-safe docs |

## Synchronization Rule

When a project is published to an independent GitHub repository, use the exposure model in `docs/ops/workspace-opening-model.md`. Do not create nested `.git` directories under `projects/`.

Independent project repository updates do not automatically drive template releases. Only reusable root control layer improvements should flow from the mother repository into the template repository.

## Review Questions

Before publishing or updating an independent repository, ask:

1. Does the README explain its relationship to the root evolution station?
2. Does the project expose only public-safe information?
3. Does the project have a repeatable local verification command?
4. Does the independent repo need its own issue, PR, or CI templates?
5. Did any project-specific lesson deserve promotion to root docs or skills?
6. Would this change belong in `docs/adoption/`, `skills/`, `scripts/`, or `specs/workspace/control-layer-os.md` instead of project code?
