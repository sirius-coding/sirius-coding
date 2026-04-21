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

| Project | Exposure | Alignment Status | Next Action |
| --- | --- | --- | --- |
| `sirius-xz-agent` | Independent backend candidate | Local README and project LICENSE aligned | Keep business implementation project-owned; promote reusable release lessons to root docs |
| `sirius-xz-agent-ui` | Independent frontend repository | Local README and project LICENSE aligned | Keep UI implementation project-owned; promote shared API/proxy lessons to root delivery skill |
| `sirius-cloud-starter` | Independent scaffold candidate | Local README and project LICENSE aligned | Keep Spring Cloud implementation project-owned; promote starter template rules to root |
| `sirius-web-toolkit` | Independent toolkit candidate | Local README and project LICENSE aligned | Keep library code project-owned; promote reusable review and release checks to root |

## Remote Inspection

Checked on 2026-04-21 with `gh repo view`:

| Repository | Visibility | Remote License Metadata | Alignment Need |
| --- | --- | --- | --- |
| `sirius-coding/sirius-coding` | public | `null` before this local license update is pushed | Push root `LICENSE` so GitHub detects Apache-2.0 |
| `sirius-coding/sirius-xz-agent` | public | `null` | Publish project `LICENSE` and README alignment when syncing the independent repo |
| `sirius-coding/sirius-xz-agent-ui` | public | `null` | Publish project `LICENSE` and README alignment when syncing the independent repo |
| `sirius-coding/sirius-cloud-starter` | public | `null` | Publish project `LICENSE` and README alignment when syncing the independent repo |
| `sirius-coding/sirius-web-toolkit` | public | `null` | Publish project `LICENSE` and README alignment when syncing the independent repo |

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
