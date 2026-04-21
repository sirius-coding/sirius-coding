# Control Layer OS

## Purpose

Control Layer OS is the reusable operating layer around AI-assisted software development. It makes project memory, rules, review quality, release checks, diagrams, and template sync explicit in repository assets.

## Core Layers

| Layer | Responsibility |
| --- | --- |
| Memory | Persist long-lived decisions in `AGENTS.md`, `specs/`, `docs/`, and `skills/`. |
| Governance | Define root/project boundaries, public/private rules, review standards, and release policy. |
| Automation | Use scripts and workflows to audit structure, sanitize public assets, and sync template snapshots. |
| Adoption | Provide quick-start docs, examples, contribution rules, and security guidance. |
| Evolution | Promote repeated work into reusable skills, scripts, templates, or specs. |

## Root Boundary

The root layer owns shared rules, reusable workflows, documentation, release models, template sync, and cross-project navigation.

The project layer owns implementation, tests, builds, packaging, project-specific deployment, and domain behavior.

## Template Boundary

The template repository is a productized export of the root control layer. It excludes business implementation and private operational data. Template sync must be governed by `docs/template/template-manifest.yaml`.

## Operating Loop

1. Discuss or implement a project task.
2. Verify behavior with tests, builds, audits, or smoke checks.
3. Identify durable knowledge.
4. Persist durable knowledge in the root layer.
5. Promote repeated patterns into skills or scripts.
6. Sync major reusable upgrades to the template repository through PR.
