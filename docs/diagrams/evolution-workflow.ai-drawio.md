# AI Drawio Prompt: Sirius Coding Evolution Workflow

Use this prompt in draw.io AI or another diagram assistant to regenerate an editable workflow diagram.

## Goal

The workflow that turns human and AI development conversations into durable workspace memory, rules, skills, scripts, diagrams, and project outputs.

## Layout

- Direction: LR
- Use grouped horizontal phases matching the layers below.
- Keep root governance assets, project execution assets, and generated automation visibly distinct.
- Use a clean technical style with light backgrounds, clear arrows, and short labels.

## Layers

- conversation: 1. 对话输入 / Conversation
- execution: 2. 构建验证 / Build
- evolution: 3. 进化复盘 / Evolution
- assets: 4. 长期资产 / Assets
- publication: 5. 公开工作站 / Station

## Nodes

- human-ai-dialogue: 人与 AI 对话 / 目标, 约束, 决策 [input; conversation]
- repo-context-scan: 读取仓库事实 / README, AGENTS, docs, projects [process; conversation]
- implementation-loop: 执行改造 / 代码, 文档, 脚本, 图表 [process; execution]
- verification-evidence: 收集证据 / 测试, 审计, 构建, 烟测 [process; execution]
- evolution-question: 进化问题 / 什么需要长期保存? [decision; evolution]
- knowledge-routing: 知识分流 / 规则, skill, 脚本, 文档, 项目 [process; evolution]
- workspace-rules: specs/ + AGENTS.md / 目标, 边界, 运行规则 [asset; assets]
- reusable-skills: skills/ / 可复用协作流程 [asset; assets]
- automation-scripts: scripts/ / 审计, 生成器, 检查 [asset; assets]
- docs-diagrams: docs/ + diagrams / 运行手册, 环境模型, 流程图 [asset; assets]
- project-outputs: projects/ / 实现, 测试, 部署资产 [asset; assets]
- public-guardrail: 公开/私有护栏 / 发布前脱敏 [process; publication]
- homepage-readme: 主页 README / 公开入口与导航 [output; publication]
- next-session: 下一次会话更强 / Vibe coding 进化为资产 [output; publication]

## Edges

- human-ai-dialogue -> repo-context-scan: 锚定需求
- repo-context-scan -> implementation-loop: 选择边界
- implementation-loop -> verification-evidence: 证明行为
- verification-evidence -> evolution-question: 复盘结果
- evolution-question -> knowledge-routing: 沉淀长期经验
- knowledge-routing -> workspace-rules: 规则
- knowledge-routing -> reusable-skills: 重复流程
- knowledge-routing -> automation-scripts: 检查或生成
- knowledge-routing -> docs-diagrams: 模型或图
- knowledge-routing -> project-outputs: 实现
- workspace-rules -> public-guardrail: 审计
- reusable-skills -> public-guardrail: 审计
- automation-scripts -> public-guardrail: 审计
- docs-diagrams -> public-guardrail: 审计
- project-outputs -> public-guardrail: 审计
- public-guardrail -> homepage-readme: 公开展示
- homepage-readme -> next-session: 强记忆
- next-session -> human-ai-dialogue: 反馈循环
