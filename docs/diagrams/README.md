# 图形能力 / Diagram Capability

> 目的：把工作站中的流程、架构、UML、ER 和协作规则先写成稳定结构，再生成可编辑草图。
>
> Purpose: describe diagrams as durable structured assets first, then generate editable drafts.

## 生成链路 / Generation Flow

1. 在 `*.diagram.json` 中维护图的结构事实源：层级、节点、连线和说明。
2. 运行 `node scripts/generate-diagrams.mjs docs/diagrams/<name>.diagram.json`。
3. 脚本生成四类产物：
   - `*.mmd`：Mermaid，适合 README 和轻量审阅。
   - `*.drawio`：draw.io 主草图，适合正式编辑和二次排版。
   - `*.excalidraw`：Excalidraw 草图，适合快速手绘式讨论。
   - `*.ai-drawio.md`：AI Drawio 提示词，适合让图形助手重新生成或美化。
4. 如果结构源声明了 `readmeSync`，脚本会同步 README 中对应的 Mermaid 标记块。

## 维护规则 / Maintenance Rules

- 优先修改 `*.diagram.json`，不要直接手改生成文件。
- README 中需要公开展示的流程图，应由 `readmeSync` 从 `*.diagram.json` 自动同步。
- draw.io 文件是主草图，Excalidraw 文件是快速草图，AI Drawio 文件是自动生成提示。
- 公开仓库中的图只能使用抽象环境、匿名拓扑和可公开流程，不写真实主机、账号、凭证和敏感路径。

## README 同步标记 / README Sync Markers

需要嵌入 README 的图，先在结构源中声明：

```json
{
  "readmeSync": {
    "path": "README.md",
    "marker": "evolution-workflow"
  }
}
```

再在 README 中放置同名标记：

````markdown
<!-- diagram:evolution-workflow:start -->
```mermaid
flowchart LR
```
<!-- diagram:evolution-workflow:end -->
````

之后运行生成器即可同步标记之间的 Mermaid 内容。

## 图类型约定 / Diagram Type Contract

| 类型 / Type | 推荐结构源 / Recommended Source | 当前处理方式 / Current Handling |
| --- | --- | --- |
| 流程图 / Flowchart | `*.diagram.json` | 由 `scripts/generate-diagrams.mjs` 生成 Mermaid、draw.io、Excalidraw 和 AI Drawio prompt。 |
| UML 类图 / UML class | Mermaid `classDiagram` 或后续 `*.diagram.json` class schema | 先进入 `docs/diagrams/` 作为结构源，必要时用 AI Drawio prompt 或 draw.io Mermaid import 生成草图。 |
| UML 时序图 / UML sequence | Mermaid `sequenceDiagram` | 先维护 Mermaid 结构源，再按需要补专用 draw.io / Excalidraw renderer。 |
| ER 图 / ER diagram | Mermaid `erDiagram` 或后续 `*.diagram.json` entity schema | 先维护实体和关系结构源，再按需要补专用 renderer。 |
| 架构图 / Architecture | `*.diagram.json` | 用节点、分层和连线表达系统边界、模块和依赖。 |

当前脚本先把最常用的流程图和架构图自动化。UML / ER 的事实源也应先进入本目录，避免只存在于一次聊天或某个外部画布中。

## 当前图 / Current Diagrams

| 图 / Diagram | 结构源 / Source | Mermaid | draw.io | Excalidraw | AI Drawio |
| --- | --- | --- | --- | --- | --- |
| 进化式工作站演进流程 / Evolution station workflow | [JSON](./evolution-workflow.diagram.json) | [Mermaid](./evolution-workflow.mmd) | [draw.io](./evolution-workflow.drawio) | [Excalidraw](./evolution-workflow.excalidraw) | [Prompt](./evolution-workflow.ai-drawio.md) |
