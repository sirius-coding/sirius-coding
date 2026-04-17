# sirius-cloud-starter

Spring Cloud / Spring Cloud Alibaba 微服务脚手架。

## 目标

- 提供可复用的微服务起步骨架
- 预留 Nacos、OpenFeign、网关、配置中心等能力
- 保持本地默认可启动，不依赖外部基础设施

## 当前内容

- Spring Boot Web 服务
- `/api/health` 示例接口
- 关闭状态下的 Nacos discovery 配置

## 下一阶段

- 接入配置中心
- 接入服务注册与发现
- 增加 OpenFeign 调用示例
- 扩展网关与统一鉴权

## 启动

```bash
mvn spring-boot:run
```

## 访问

```bash
curl http://localhost:8082/api/health
```

