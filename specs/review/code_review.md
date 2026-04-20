# Code Review Standard

## Purpose

Define the default review bar for this workspace and its child projects.

## Review Stance

Lead with findings. Prioritize defects, regressions, security or privacy exposure, missing verification, and maintainability risks. Summaries are secondary.

## Required Order

1. Findings ordered by severity.
2. Open questions or assumptions.
3. Change summary only after findings.
4. Verification status and remaining test gaps.

If there are no findings, say so directly and still note residual risk or unrun verification.

## Finding Format

Each finding should include:

- severity
- file and line reference when available
- the behavior or risk
- why it matters
- the smallest practical fix

Avoid style-only comments unless they hide a real maintainability or correctness risk.

## Workspace-Specific Checks

For root repository changes, review:

- public/private information boundaries
- whether the fact source belongs in `docs/`, `skills/`, `specs/`, or `projects/`
- whether new rules conflict with `AGENTS.md`
- whether changed docs cross-link to the source of truth
- whether environment and release information remains reproducible without exposing private values

For project changes, review:

- test coverage for changed behavior
- build and packaging impact
- deploy and smoke-test impact
- API compatibility
- configuration defaults
- whether useful lessons should be promoted back to root assets

## Verification Expectations

Reviewers should call out missing verification when a claim depends on:

- tests
- build output
- lint or type checks
- YAML, TOML, JSON, or Markdown parsing
- local or cloud smoke checks
- public/private sanitization scans
