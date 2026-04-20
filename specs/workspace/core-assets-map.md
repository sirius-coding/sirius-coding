# 核心资产地图 / Core Assets Map

> 目的：用中文和英文说明根仓库中核心文件与目录的职责，方便未来会话、人工维护者和自动化脚本快速定位事实源。
>
> Purpose: describe the responsibilities of core files and directories in both Chinese and English so future sessions, human maintainers, and automation can locate sources of truth quickly.

## 根层 / Root Layer

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `README.md` | 公开首页，说明这个仓库是进化式开发工作站，并导航到核心资产。 | Public homepage describing this repository as an evolving development station and linking to core assets. |
| `AGENTS.md` | 根仓库代理规则，定义事实源优先级、工作边界、护栏、默认流程和 Evolution 输出。 | Root agent rules defining fact-source priority, work boundaries, guardrails, default workflow, and Evolution output. |
| `.codex/config.toml` | Codex 本地配置，占位并启用当前工作站需要的 agent 能力。 | Local Codex configuration for workspace-level agent capabilities. |
| `.gitignore` | 忽略构建产物、IDE 文件、工作树和私有环境登记文件。 | Ignores build outputs, IDE files, worktrees, and private environment registry files. |
| `pom.xml` | 根 Maven 聚合入口，连接 Java 子项目的构建。 | Root Maven aggregation entry that connects Java child project builds. |

## 规则与规范 / Rules and Specs

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `specs/workspace/evolution-handbook.md` | 进化手册全文持久化版本，是工作站核心目标和协作协议。 | Persisted full evolution handbook, defining the workstation's core goal and collaboration protocol. |
| `specs/workspace/workstation-operating-rules.md` | 工作站运行规则摘要，适合作为快速执行规范。 | Concise workstation operating rules for quick execution. |
| `specs/workspace/public-private-boundary.md` | 公开/私有知识边界，规定哪些信息可以进入公开仓库。 | Public/private knowledge boundary defining what can be committed to the public repository. |
| `specs/workspace/core-assets-map.md` | 当前文件，双语说明核心目录和文件职责。 | This file; bilingual map of core files and directories. |
| `specs/review/code_review.md` | 默认代码审查标准，约束 review 输出和验证要求。 | Default code review standard covering findings, review order, and verification expectations. |

## 文档与运维 / Docs and Operations

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `docs/ops/workspace-opening-model.md` | workspace 打开模型，定义项目暴露模式、目录契约和发布最小资产。 | Workspace opening model defining exposure modes, directory contract, and minimum release assets. |
| `docs/ops/environment-registry.yaml` | 公开环境登记模型，只保留可公开占位与抽象拓扑。 | Public environment registry model containing placeholders and abstract topology only. |
| `docs/ops/environment-registry.private.example.yaml` | 私有环境登记示例，复制成本地私有文件后填真实值。 | Example private registry; copy locally and fill with real values outside git. |
| `docs/sirius-xz-agent-cloud-deploy-checklist.md` | `sirius-xz-agent` 云端发布、联调、烟测和排障清单。 | Cloud deploy, integration, smoke-test, and triage checklist for `sirius-xz-agent`. |
| `docs/superpowers/specs/` | 历史设计规格，用于记录已完成或计划中的设计决策。 | Historical design specs recording completed or planned design decisions. |
| `docs/superpowers/plans/` | 历史实施计划，用于记录可复现的任务拆分和执行路径。 | Historical implementation plans recording reproducible task breakdowns and execution paths. |

## 复用能力 / Reusable Capabilities

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `skills/workspace-multi-env-delivery/SKILL.md` | 多环境交付 skill，覆盖项目暴露模式、环境登记、发布清单和证据采集。 | Multi-environment delivery skill covering exposure modes, environment registration, release checklist, and evidence capture. |
| `scripts/root-repo-structure-audit.sh` | 根仓库结构与脱敏审计脚本。 | Root repository structure and sanitization audit script. |
| `scripts/root-repo-structure-audit.test.sh` | 审计脚本的 shell 测试，覆盖通过路径和敏感值失败路径。 | Shell test for the audit script, covering clean and sensitive-data failure paths. |
| `scripts/dev-env-check.sh` | 本地开发环境检查脚本。 | Local development environment check script. |

## 项目执行层 / Project Execution Layer

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `projects/sirius-xz-agent/` | RAG / Agent 后端样板，负责业务实现、测试、Docker 和项目级文档。 | RAG / Agent backend sample responsible for implementation, tests, Docker assets, and project docs. |
| `projects/sirius-xz-agent-ui/` | Agent 前端控制台，负责 UI、API 调试页、知识库编辑和构建资产。 | Agent frontend console covering UI, API inspection, knowledge editing, and build assets. |
| `projects/sirius-cloud-starter/` | Spring Cloud Alibaba 起步骨架。 | Spring Cloud Alibaba starter skeleton. |
| `projects/sirius-web-toolkit/` | Web 微服务公共组件样板。 | Web microservice toolkit sample. |

## 资产归属原则 / Ownership Principles

| 判断 / Decision | 中文规则 | English Rule |
| --- | --- | --- |
| 根仓库 | 共享规则、复用流程、跨项目文档、公开/私有边界、发布模型放根仓库。 | Put shared rules, reusable workflows, cross-project docs, public/private boundaries, and release models in the root. |
| 子项目 | 实现代码、测试、构建、部署细节和项目级 specs 放子项目。 | Put implementation, tests, builds, deployment details, and project-level specs in child projects. |
| 强记忆 | 必须长期遵守的内容写入 `AGENTS.md`、`specs/`、`docs/` 或 `skills/`。 | Persist long-lived rules in `AGENTS.md`, `specs/`, `docs/`, or `skills/`. |
| 弱记忆 | 只作为协作辅助，不替代仓库事实源。 | Use weak memory only as collaboration context, never as a replacement for repository sources of truth. |
