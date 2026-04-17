# sirius-xz-agent

> Spring AI / Spring AI Alibaba / RAG / Agent scaffold

![Java](https://img.shields.io/badge/Java-21-007396?style=flat-square&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-6DB33F?style=flat-square&logo=spring-boot&logoColor=white)
![AI](https://img.shields.io/badge/AI-RAG%20%7C%20Agent-111827?style=flat-square)

Spring AI / Spring AI Alibaba / RAG / Agent 方向的样板项目，用来沉淀 AI 应用的工程边界与接入方式。

## 快速说明

| 项目 | 内容 |
| --- | --- |
| 目标 | 建立 AI 应用的工程边界 |
| 场景 | 对话、检索增强、工具调用、Agent 编排 |
| 现状 | 可运行的离线 RAG 样板 + 示例接口 |

## 目标

- 建立 AI 应用的工程边界
- 预留 Spring AI 与 Spring AI Alibaba 的接入位置
- 让后续的 RAG、工具调用、工作流编排可以逐步落地

## 当前内容

- Spring Boot Web 骨架
- `/api/agent/summary` 示例接口
- `/api/agent/ask` 检索增强问答接口
- 标准化的目录与包名

## 路线图

- 接入 Spring AI 对话能力
- 加入向量检索与知识库
- 增加工具调用和 Agent 编排
- 补齐真实模型接入与持久化知识库

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
