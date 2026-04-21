# Why This Template

This template is a root control layer for AI-assisted software work. It is not a framework starter and not a business application scaffold.

## Compared With a Starter Template

A starter template usually gives you runnable application code. This template gives you the operating layer around future application code:

- durable rules
- review standards
- public/private guardrails
- reusable skills
- audit scripts
- release and template sync conventions

Use it before or around application starters when you want the workspace itself to improve over time.

## Compared With a Monorepo

A monorepo primarily organizes implementation. This template primarily organizes governance and reusable development behavior.

You may still use `projects/` for local projects, but project implementation should stay project-owned. The root layer stores only the reusable knowledge that should affect multiple projects.

## Compared With Chat-Only AI Work

Chat-only workflows lose decisions when the session ends. This template turns durable conclusions into repository assets:

- rules in `AGENTS.md` and `specs/`
- workflows in `skills/`
- checks in `scripts/`
- evidence and history in docs and release files

The goal is not more documentation. The goal is fewer repeated decisions and fewer unsafe public releases.
