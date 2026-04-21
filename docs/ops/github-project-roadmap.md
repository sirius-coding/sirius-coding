# GitHub Project Roadmap / GitHub 项目看板路线

> Purpose: keep root-workstation evolution visible outside one chat session while keeping business implementation work inside `projects/` or independent project repositories.
>
> 目的：把根工作站的演进节奏纳入 GitHub Projects，而不是停留在一次会话或单个提交里；业务实现仍归属 `projects/` 或独立项目仓库。

## Project Definition / 看板定义

| Field | Value |
| --- | --- |
| Title | `Sirius Evolution Station Roadmap` |
| Owner | Current GitHub user (`@me`) unless the repository is moved under an organization |
| Repository | `sirius-coding/sirius-coding` |
| Scope | Root governance, reusable skills, template releases, public/private guardrails, cross-project alignment |
| Out of scope | Day-to-day business implementation inside child projects |

## Field Model / 字段模型

| Field | Type | Options / Meaning |
| --- | --- | --- |
| `Track` | Single select | `Template`, `Versioning`, `Diagram Capability`, `Project Alignment`, `Security`, `Automation` |
| `Release` | Text | Target SemVer line, such as `v3.0.0` or `v3.x` |
| `Risk` | Single select | `Low`, `Medium`, `High` |

Use the default GitHub Project `Status` field for `Backlog`, `In Progress`, `Review`, and `Done`.

## Seed Issues / 初始议题

| Issue | Track | Purpose |
| --- | --- | --- |
| `Root template release v3.0.0` | Template | Keep reusable root assets synced to the template repository after major releases. |
| `Backfill version history and release tags` | Versioning | Ensure `VERSION`, `CHANGELOG.md`, release history, and Git tags stay aligned. |
| `Harden public repository sanitization` | Security | Extend audits when new public/private boundary risks appear. |
| `Promote diagram pipeline into reusable plugin` | Diagram Capability | Evaluate whether the drawing pipeline should become a standalone reusable plugin. |
| `Review independent repositories against workstation goals` | Project Alignment | Keep independent project repositories aligned without copying business implementation into the template. |

## Setup Command / 初始化命令

```bash
./scripts/github/setup-root-project.sh \
  --owner @me \
  --repo sirius-coding/sirius-coding \
  --title "Sirius Evolution Station Roadmap"
```

The script is idempotent: it reuses an existing project and existing issues when their titles match.

## Operating Rule / 运行规则

Root Project items should describe reusable station evolution. If an item becomes business-specific implementation, move it to the corresponding child repository or independent repository issue tracker and keep only a root-level alignment task here.
