# 图形能力 / Diagram Capability

> 目的：把工作站中的流程、架构、UML、ER 和协作规则先做语义建模和版式规划，再生成高质量 SVG 与 image prompt。
>
> Purpose: model diagram intent and layout before rendering high-quality SVG and image prompts.

## 生成链路 / Generation Flow

1. 在 `*.diagram.json` 中维护结构事实源：节点、主链、分支、汇聚和反馈回路。
2. 运行 `node scripts/diagram/build-all.mjs docs/diagrams/<name>.diagram.json`。
3. 脚本生成四类产物：
   - `*.intent.json`：语义模型，表达 `main_chain`、`parallel_groups`、`merge_nodes`、`feedback_loops`。
   - `*.layout.plan.json`：版式计划，表达主轴、居中节点、分支列、汇聚位置和箭头路由。
   - `*.svg`：ProcessOn 风格的可编辑/可展示 SVG。
   - `*.image-prompt.md`：高质量图像生成提示词。

## CLI

```bash
node scripts/diagram/build-all.mjs docs/diagrams/evolution-workflow.diagram.json
node scripts/diagram/build-all.mjs --check docs/diagrams/evolution-workflow.diagram.json
```

兼容入口：

```bash
node scripts/generate-diagrams.mjs docs/diagrams/evolution-workflow.diagram.json
```

## 维护规则 / Maintenance Rules

- 优先修改 `*.diagram.json`，不要直接手改 `*.intent.json`、`*.layout.plan.json`、`*.svg` 或 `*.image-prompt.md`。
- README 中需要公开展示的流程图，应优先嵌入 SVG。
- 后续所有流程图任务，优先生成 SVG + image prompt 双版本。
- 公开仓库中的图只能使用抽象环境、匿名拓扑和可公开流程，不写真实主机、账号、凭证和敏感路径。

## 图类型约定 / Diagram Type Contract

| 类型 / Type | 推荐结构源 / Recommended Source | 当前处理方式 / Current Handling |
| --- | --- | --- |
| 流程图 / Flowchart | `*.diagram.json` | 由 diagram-pipeline 生成 intent、layout、SVG 和 image prompt。 |
| UML 类图 / UML class | 后续 `*.diagram.json` class schema | 先进入 `docs/diagrams/` 作为结构源，再补专用 layout / SVG renderer。 |
| UML 时序图 / UML sequence | 后续 `*.diagram.json` sequence schema | 先维护语义结构，再补专用泳道和消息路由 renderer。 |
| ER 图 / ER diagram | 后续 `*.diagram.json` entity schema | 先维护实体和关系结构源，再补专用 entity layout renderer。 |
| 架构图 / Architecture | `*.diagram.json` | 用主链、分组、汇聚和反馈表达系统边界、模块和依赖。 |

当前脚本先把最常用的流程图和架构图自动化。UML / ER 的事实源也应先进入本目录，避免只存在于一次聊天或某个外部画布中。

## 当前图 / Current Diagrams

| 图 / Diagram | Source | Intent | Layout | SVG | Prompt |
| --- | --- | --- | --- | --- | --- |
| 进化式工作站演进流程 / Evolution station workflow | [Source](./evolution-workflow.diagram.json) | [Intent](./evolution-workflow.intent.json) | [Layout](./evolution-workflow.layout.plan.json) | [SVG](./evolution-workflow.svg) | [Prompt](./evolution-workflow.image-prompt.md) |
