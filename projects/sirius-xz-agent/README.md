# sirius-xz-agent

Spring AI / Spring AI Alibaba / RAG / Agent 方向的样板项目。

## 目标

- 建立 AI 应用的工程边界
- 预留 Spring AI 与 Spring AI Alibaba 的接入位置
- 让后续的 RAG、工具调用、工作流编排可以逐步落地

## 当前内容

- Spring Boot Web 骨架
- `/api/agent/summary` 示例接口
- 标准化的目录与包名

## 下一阶段

- 接入 Spring AI 对话能力
- 加入向量检索与知识库
- 增加工具调用和 Agent 编排

## 启动

```bash
mvn spring-boot:run
```

## 访问

```bash
curl "http://localhost:8081/api/agent/summary?name=Sirius"
```

