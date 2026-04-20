# Module Roadmap

## Purpose

Track what "continue improving all modules" means for the root evolution station. This file keeps module work explicit without forcing broad business-code changes across `projects/`.

## Root Governance Modules

| Module | Current Asset | Next Capability |
| --- | --- | --- |
| Strong memory | `AGENTS.md`, `specs/workspace/evolution-handbook.md` | Keep root rules concise and move long-form policies into `specs/` |
| Public/private boundary | `specs/workspace/public-private-boundary.md`, audit script | Add CI for root repository sanitization |
| Project exposure | `docs/ops/workspace-opening-model.md` | Add a reusable new-project checklist or skill |
| Delivery reuse | `skills/workspace-multi-env-delivery/SKILL.md` | Split delivery, sanitization, and repo-publish skills when repetition justifies it |
| Review quality | `specs/review/code_review.md` | Add PR template and review checklist |
| Brand system | `assets/hero.svg`, `NOTICE` | Extract a compact Sirius icon and brand usage guide |
| Licensing | `LICENSE`, `NOTICE`, `COMMERCIALIZATION.md` | Add per-project license notices when publishing independent repos |
| Audit automation | `scripts/root-repo-structure-audit.sh` | Run from GitHub Actions after the workflow layer is introduced |

## Project Modules

| Project | Root-Owned Improvement | Project-Owned Improvement |
| --- | --- | --- |
| `sirius-xz-agent` | Release checklist, environment model, public/private boundary | RAG implementation, model providers, vector store, API behavior |
| `sirius-xz-agent-ui` | Repo exposure mode, public-safe docs, proxy lessons | UI workflows, API client behavior, visual polish |
| `sirius-cloud-starter` | Starter template rules and publication checklist | Spring Cloud integrations, service discovery, config center |
| `sirius-web-toolkit` | Reusable toolkit positioning and publication checklist | Response model, exception handling, request context, starter packaging |

## Next Iteration Candidates

1. Add `.github/workflows/root-audit.yml` for the root repository.
2. Add `skills/public-repo-sanitization/SKILL.md`.
3. Add `skills/workspace-repo-bootstrap/SKILL.md`.
4. Add issue and PR templates aligned with `specs/review/code_review.md`.
5. Extract `assets/sirius-icon.svg` from the hero mark.
