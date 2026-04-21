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
| `VERSION` | 当前根工作站控制层版本号。 | Current root-workstation control-plane version. |
| `CHANGELOG.md` | 根工作站的 SemVer 版本历史。 | SemVer release history for the root workstation. |
| `LICENSE` | Apache-2.0 许可证文本，定义当前公开代码和文档的开源授权。 | Apache-2.0 license text for current public code and documentation. |
| `NOTICE` | 项目版权和 Sirius 品牌边界说明。 | Copyright and Sirius brand-boundary notice. |
| `COMMERCIALIZATION.md` | 未来部分商用的边界和可选路径说明。 | Boundary and options for future partial commercialization. |
| `pom.xml` | 当前工作站的根 Maven 聚合入口，连接 Java 子项目构建；不进入模板库。 | Root Maven aggregation entry for this workspace's Java child projects; excluded from the template repository. |

## 规则与规范 / Rules and Specs

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `specs/workspace/evolution-handbook.md` | 进化手册全文持久化版本，是工作站核心目标和协作协议。 | Persisted full evolution handbook, defining the workstation's core goal and collaboration protocol. |
| `specs/workspace/workstation-operating-rules.md` | 工作站运行规则摘要，适合作为快速执行规范。 | Concise workstation operating rules for quick execution. |
| `specs/workspace/public-private-boundary.md` | 公开/私有知识边界，规定哪些信息可以进入公开仓库。 | Public/private knowledge boundary defining what can be committed to the public repository. |
| `specs/workspace/core-assets-map.md` | 当前文件，双语说明核心目录和文件职责。 | This file; bilingual map of core files and directories. |
| `specs/workspace/independent-repo-alignment.md` | 独立仓库与根工作站目标对齐标准。 | Alignment standard between independent repositories and the root evolution station. |
| `specs/workspace/module-roadmap.md` | 根模块和子项目模块的持续完善路线。 | Continuous-improvement roadmap for root modules and project modules. |
| `specs/review/code_review.md` | 默认代码审查标准，约束 review 输出和验证要求。 | Default code review standard covering findings, review order, and verification expectations. |

## 文档与运维 / Docs and Operations

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `docs/ops/workspace-opening-model.md` | workspace 打开模型，定义项目暴露模式、目录契约和发布最小资产。 | Workspace opening model defining exposure modes, directory contract, and minimum release assets. |
| `docs/ops/github-project-roadmap.md` | GitHub Projects 看板模型、初始议题和初始化命令。 | GitHub Projects board model, seed issues, and setup command. |
| `docs/ops/environment-registry.yaml` | 公开环境登记模型，只保留可公开占位与抽象拓扑。 | Public environment registry model containing placeholders and abstract topology only. |
| `docs/ops/environment-registry.private.example.yaml` | 私有环境登记示例，复制成本地私有文件后填真实值。 | Example private registry; copy locally and fill with real values outside git. |
| `docs/diagrams/` | 图形能力目录，以结构源生成 intent、layout、SVG 和 image prompt。 | Diagram capability directory generating intent, layout, SVG, and image prompts from structured sources. |
| `docs/releases/release-history.md` | 版本治理、模板同步节奏和发布边界说明。 | Version governance, template sync cadence, and release boundary notes. |
| `docs/template/template-manifest.yaml` | 模板库同步清单，定义可进入模板的根资产和必须排除的业务/私有资产。 | Template sync manifest defining reusable root assets and excluded business/private assets. |
| `docs/sirius-xz-agent-cloud-deploy-checklist.md` | `sirius-xz-agent` 云端发布、联调、烟测和排障清单。 | Cloud deploy, integration, smoke-test, and triage checklist for `sirius-xz-agent`. |
| `docs/superpowers/specs/` | 历史设计规格，用于记录已完成或计划中的设计决策。 | Historical design specs recording completed or planned design decisions. |
| `docs/superpowers/plans/` | 历史实施计划，用于记录可复现的任务拆分和执行路径。 | Historical implementation plans recording reproducible task breakdowns and execution paths. |

## 复用能力 / Reusable Capabilities

| 路径 / Path | 中文说明 | English Description |
| --- | --- | --- |
| `skills/workspace-multi-env-delivery/SKILL.md` | 多环境交付 skill，覆盖项目暴露模式、环境登记、发布清单和证据采集。 | Multi-environment delivery skill covering exposure modes, environment registration, release checklist, and evidence capture. |
| `skills/diagram-pipeline/SKILL.md` | 高质量流程图生成 skill，规定 intent、layout、style、render 四阶段。 | High-quality diagram generation skill defining intent, layout, style, and render stages. |
| `specs/diagram-style.md` | ProcessOn 风格流程图视觉规范。 | ProcessOn-like visual style spec for flow diagrams. |
| `scripts/root-repo-structure-audit.sh` | 根仓库结构与脱敏审计脚本。 | Root repository structure and sanitization audit script. |
| `scripts/root-repo-structure-audit.test.sh` | 审计脚本的 shell 测试，覆盖通过路径和敏感值失败路径。 | Shell test for the audit script, covering clean and sensitive-data failure paths. |
| `scripts/template/` | 模板仓库生成、README 转换和模板快照审计脚本。 | Template repository generation, README conversion, and template snapshot audit scripts. |
| `scripts/template-repo.test.sh` | 模板同步链路测试，验证业务项目不会进入模板库。 | Template sync test verifying business projects do not enter the template repository. |
| `scripts/github/setup-root-project.sh` | GitHub Projects 初始化脚本，创建或复用根工作站路线看板和初始议题。 | GitHub Projects setup script that creates or reuses the root-workstation roadmap board and seed issues. |
| `scripts/diagram/` | 图形生成 pipeline 脚本目录，包含 intent、layout、SVG 和 prompt 阶段。 | Diagram pipeline scripts for intent, layout, SVG, and prompt stages. |
| `scripts/generate-diagrams.mjs` | 图形生成兼容入口，转发到 `scripts/diagram/build-all.mjs`。 | Compatibility diagram generator entrypoint delegating to `scripts/diagram/build-all.mjs`. |
| `scripts/diagram-pipeline.test.sh` | 图形 pipeline 测试，验证语义建模、版式规划、SVG 和 image prompt。 | Diagram pipeline test verifying intent modeling, layout planning, SVG, and image prompt output. |
| `scripts/generate-diagrams.test.sh` | 兼容入口测试，验证旧入口会调用新 pipeline。 | Compatibility entrypoint test verifying the old command calls the new pipeline. |
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
