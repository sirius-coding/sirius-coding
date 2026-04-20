# Sirius Coding Evolution Station

> 一个把工作方式、项目经验、发布证据、审查标准和自动化检查持续沉淀为可复用资产的进化式开发工作站。
>
> An evolving development station that turns workflow, project experience, release evidence, review standards, and automation checks into reusable assets.

<p align="center">
  <img src="assets/hero.svg" alt="Sirius Coding Evolution Station banner" />
</p>

<p align="left">
  <img src="https://img.shields.io/badge/Workspace-Evolution-111827?style=for-the-badge" alt="Workspace Evolution" />
  <img src="https://img.shields.io/badge/Codex-Agent%20Rules-2563EB?style=for-the-badge" alt="Codex Agent Rules" />
  <img src="https://img.shields.io/badge/Java-21-007396?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 21" />
  <img src="https://img.shields.io/badge/Spring%20AI-RAG%20%7C%20Agent-16A34A?style=for-the-badge" alt="Spring AI RAG Agent" />
</p>

<p align="center">
  <a href="#核心定位">核心定位</a> ·
  <a href="#进化闭环">进化闭环</a> ·
  <a href="#核心资产">核心资产</a> ·
  <a href="#项目执行层">项目执行层</a> ·
  <a href="#安全边界">安全边界</a> ·
  <a href="#许可证">许可证</a>
</p>

## 核心定位

这个仓库不只是 GitHub 主页，也不只是项目合集。它是 `sirius-coding` 的公开工作站根仓库，负责把长期有效的协作方式显式化、资产化、可检查化。

This repository is not only a GitHub profile README and not only a project collection. It is the public workspace root for `sirius-coding`, designed to make durable collaboration patterns explicit, reusable, and auditable.

| 层级 / Layer | 职责 / Responsibility |
| --- | --- |
| 根仓库 / Root workspace | 规则、强记忆、共享 skill、审查标准、发布模型、公开/私有边界 |
| 项目层 / Project layer | 业务实现、测试、构建、部署、项目级文档和发布质量 |
| 进化层 / Evolution layer | 每次任务结束后沉淀经验、抽取流程、补齐护栏、推进自动化 |

## 进化闭环

本工作站围绕五个动作持续演进：

1. **主动记忆**：把长期规则写入仓库，而不是留在一次会话中。
2. **主动复用**：把重复流程升级为 `skills/`、模板或脚本。
3. **主动护栏**：在发布、同步、改结构、公开文档前做边界检查。
4. **主动验证**：用测试、构建、静态扫描和烟测证据支撑结论。
5. **主动复盘**：每次任务输出 `Evolution`，判断哪些经验应继续沉淀。

## 核心资产

| 资产 / Asset | 说明 / Description |
| --- | --- |
| [AGENTS.md](./AGENTS.md) | 根仓库代理规则，定义事实源优先级、根/项目边界、护栏和输出结构 |
| [Evolution Handbook](./specs/workspace/evolution-handbook.md) | 进化手册全文持久化版本，是本工作站的核心目标说明 |
| [Workspace Opening Model](./docs/ops/workspace-opening-model.md) | 项目加入、发布形态和目录契约 |
| [Core Assets Map](./specs/workspace/core-assets-map.md) | 核心文件和目录的中文/英文双语索引 |
| [Public / Private Boundary](./specs/workspace/public-private-boundary.md) | 公开仓库脱敏规则和私有覆盖文件约定 |
| [Code Review Standard](./specs/review/code_review.md) | 默认代码审查标准 |
| [Environment Registry](./docs/ops/environment-registry.yaml) | 公开环境模型，真实环境值不进入仓库 |
| [Private Registry Example](./docs/ops/environment-registry.private.example.yaml) | 私有环境登记示例，复制后填入本地忽略文件 |
| [Cloud Deploy Checklist](./docs/sirius-xz-agent-cloud-deploy-checklist.md) | 云端发布与联调检查清单 |
| [Reusable Delivery Skill](./skills/workspace-multi-env-delivery/SKILL.md) | 多环境交付、独立仓库发布和部署排障复用流程 |
| [Root Repo Audit Script](./scripts/root-repo-structure-audit.sh) | 根仓库结构和公开脱敏检查脚本 |
| [Independent Repo Alignment](./specs/workspace/independent-repo-alignment.md) | 独立仓库与根工作站目标对齐标准 |
| [Module Roadmap](./specs/workspace/module-roadmap.md) | 根模块和子项目模块的持续完善路线 |

## 项目执行层

`projects/` 下的子项目保留实现职责，根仓库只沉淀跨项目可复用方法。

| 项目 / Project | 方向 / Direction |
| --- | --- |
| [sirius-xz-agent](./projects/sirius-xz-agent) | Spring AI Alibaba / DeepSeek / pgvector / RAG / Agent 样板 |
| [sirius-xz-agent-ui](./projects/sirius-xz-agent-ui) | 面向 Agent 的前端控制台 |
| [sirius-cloud-starter](./projects/sirius-cloud-starter) | Spring Cloud Alibaba 微服务起步骨架 |
| [sirius-web-toolkit](./projects/sirius-web-toolkit) | Web 微服务公共能力组件 |

## 安全边界

这个仓库按公开仓库维护。可公开沉淀结构、流程、模板、匿名化拓扑和检查项；不公开真实服务器账号、凭证、密钥、精确私有主机、敏感路径和登录细节。

真实环境值应放在本地忽略文件：

```bash
cp docs/ops/environment-registry.private.example.yaml docs/ops/environment-registry.private.yaml
```

## 本地检查

```bash
./scripts/root-repo-structure-audit.sh
```

该脚本检查必备控制层文件、README 本地链接、YAML/TOML 可解析性、私有环境文件未被追踪，以及公开资产中是否出现已知敏感值。

## 许可证

本仓库当前采用 [Apache License 2.0](./LICENSE)。未来商业化边界见 [COMMERCIALIZATION.md](./COMMERCIALIZATION.md)。

Sirius 名称、品牌方向和视觉标识按 [NOTICE](./NOTICE) 中的品牌边界说明使用。

## 当前主线

1. 让进化手册成为仓库强记忆。
2. 让 README 成为进化式工作站的公开入口。
3. 让根仓库结构、公开/私有边界和发布资产可审计。
4. 逐步把重复检查升级为脚本、workflow，再考虑插件化。
