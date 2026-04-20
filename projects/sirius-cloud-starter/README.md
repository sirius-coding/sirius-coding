# sirius-cloud-starter

> Spring Cloud / Spring Cloud Alibaba microservice scaffold

![Java](https://img.shields.io/badge/Java-21-007396?style=flat-square&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-6DB33F?style=flat-square&logo=spring-boot&logoColor=white)
![Cloud](https://img.shields.io/badge/Cloud-Spring%20Cloud%20Alibaba-00A1A7?style=flat-square)

Spring Cloud / Spring Cloud Alibaba 微服务脚手架，用来沉淀通用的服务起步结构和基础治理能力。

## 快速说明

| 项目 | 内容 |
| --- | --- |
| 目标 | 提供可复用的微服务起步骨架 |
| 场景 | 注册发现、配置治理、Feign 调用、网关接入 |
| 现状 | Spring Boot Web 服务 + 服务信息接口 |

## 目标

- 提供可复用的微服务起步骨架
- 预留 Nacos、OpenFeign、网关、配置中心等能力
- 保持本地默认可启动，不依赖外部基础设施

## 当前内容

- Spring Boot Web 服务
- `/api/service-info` 服务信息接口
- `/api/health` 示例接口
- 离线可运行的微服务骨架
- GitHub Actions CI

## 路线图

- 接入配置中心
- 接入服务注册与发现
- 增加 OpenFeign 调用示例
- 扩展网关与统一鉴权
- 重新接入 Spring Cloud Alibaba 依赖与真实基础设施

## 启动

```bash
mvn spring-boot:run
```

## 访问

```bash
curl http://localhost:8082/api/health
```

## 目录约定

- `src/main/java`：应用与示例接口
- `src/main/resources`：基础配置
- `README.md`：微服务脚手架说明与演进计划

## Workspace alignment

This project is the Spring Cloud starter execution layer of the Sirius Coding Evolution Station. It keeps service implementation, local tests, Spring Cloud integration choices, and project-level CI inside the project. Reusable starter rules, publication checks, and scaffold conventions should be promoted back to the root workspace docs and skills.

License: Apache-2.0 under this project `LICENSE` unless a file states otherwise.
