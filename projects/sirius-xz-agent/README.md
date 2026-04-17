# sirius-xz-agent

> Spring AI Alibaba / DeepSeek / RAG / Agent scaffold

![Java](https://img.shields.io/badge/Java-21-007396?style=flat-square&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-6DB33F?style=flat-square&logo=spring-boot&logoColor=white)
![AI](https://img.shields.io/badge/AI-RAG%20%7C%20Agent-111827?style=flat-square)

Spring AI Alibaba / DeepSeek / RAG / Agent 方向的样板项目，用来沉淀 AI 应用的工程边界与接入方式。

## 快速说明

| 项目 | 内容 |
| --- | --- |
| 目标 | 建立 AI 应用的工程边界 |
| 场景 | 对话、检索增强、工具调用、Agent 编排 |
| 现状 | 可运行的离线 RAG 样板 + DeepSeek 在线生成 + 知识库管理 |

## 目标

- 建立 AI 应用的工程边界
- 预留 Spring AI Alibaba 与 DeepSeek 的接入位置
- 让后续的 RAG、工具调用、工作流编排可以逐步落地

## 当前内容

- Spring Boot Web 骨架
- `/api/agent/summary` 示例接口
- `/api/agent/ask` 检索增强问答接口
- `/api/knowledge/documents` 知识库管理接口
- DeepSeek 在线生成器（可选，默认关闭）
- 标准化的目录与包名
- GitHub Actions CI

## 路线图

- 接入 Spring AI Alibaba 的 Agent/RAG 生态
- 加入向量检索与知识库
- 增加工具调用和 Agent 编排
- 补齐真实模型接入与持久化知识库
- 把当前的规则检索替换为真实向量检索和模型生成

## 当前行为

- 检索结果会返回分数、命中 token 和来源文档
- 问答结果会返回结构化回答、置信度和参考来源
- 知识库支持查询、按 id 查看和 upsert
- 如果 `SIRIUS_AI_DEEPSEEK_ENABLED=true`，问答会优先走 DeepSeek 在线生成
- 如果没有配置 DeepSeek，系统会自动回退到本地规则生成器

## DeepSeek 配置

```bash
export SIRIUS_AI_DEEPSEEK_ENABLED=true
export DEEPSEEK_API_KEY=your-key
export DEEPSEEK_MODEL=deepseek-chat
```

默认保留离线 fallback，不配置时也能运行。

## 启动

```bash
mvn spring-boot:run
```

## 访问

```bash
curl "http://localhost:8081/api/agent/summary?name=Sirius"
```

## 目录约定

- `src/main/java`：应用代码
- `src/main/resources`：配置文件
- `README.md`：项目说明与后续演进方向
