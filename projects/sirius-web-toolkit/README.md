# sirius-web-toolkit

> Web microservice toolkit

![Java](https://img.shields.io/badge/Java-21-007396?style=flat-square&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-6DB33F?style=flat-square&logo=spring-boot&logoColor=white)
![Toolkit](https://img.shields.io/badge/Web-Toolkit-111827?style=flat-square)

Web 微服务公共组件样板，用来沉淀统一返回、异常处理和可复用基础能力。

## 快速说明

| 项目 | 内容 |
| --- | --- |
| 目标 | 统一返回值结构与通用异常处理 |
| 场景 | Web 服务公共能力沉淀 |
| 现状 | `ApiResponse` + `GlobalExceptionHandler` + RequestId 过滤器 |

## 目标

- 统一返回值结构
- 全局异常处理
- 为后续公共 starter 和基础能力沉淀做准备

## 当前内容

- `ApiResponse`
- `GlobalExceptionHandler`
- `RequestIdFilter`
- `ToolkitController` 示例接口
- Spring Boot 入口类

## 路线图

- 增加统一日志规范
- 增加请求上下文传递
- 增加鉴权辅助与通用工具类
- 抽象成可复用 starter 结构

## 启动

```bash
mvn spring-boot:run
```

## 目录约定

- `src/main/java`：公共类型和处理器
- `src/main/resources`：默认配置
- `README.md`：组件定位与扩展方向
