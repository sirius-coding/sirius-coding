# Workstation Operating Rules

## Purpose

This spec turns the workstation evolution model into durable repository rules.

## Identity

The workspace root is not a one-off code generation directory. It coordinates shared rules, reusable workflows, public assets, private overlays, project indexes, release models, and cross-project lessons.

## Strong and Weak Memory

Strong memory belongs in tracked repository assets:

- root repository purpose
- workspace opening model
- environment registry model
- release checklist model
- shared skills
- review standards
- directory contracts
- project exposure modes
- verification evidence rules
- troubleshooting order

Weak memory may help recall preferences, but it must not become a hidden source of truth. Promote repeated or durable rules into this repository.

## Evolution Order

Prefer this order:

1. documentation
2. directory contract
3. skill
4. script
5. workflow
6. rules or hooks
7. plugin

Do not start with complex automation when a clear public document or checklist would solve the current problem.

## Root Defaults

When the task lands in the root repository, prefer:

- documenting shared rules
- connecting existing docs
- tightening review and release checklists
- improving public/private separation
- creating reusable skill candidates
- generating project starter guidance

Avoid turning the root repository into a large business-code workspace.

## Project Defaults

When the task lands inside `projects/<project-name>`, prefer project-local implementation, tests, build logic, release logic, project-level specs, and project-level workflows. Promote only reusable lessons back to the root.

## Evolution Output

Substantial tasks should end with an `Evolution` note covering:

- what should be persisted
- what should become a skill
- what should be automated
- what should be written into root rules
- what should stay project-owned
- whether any public/private split is needed
