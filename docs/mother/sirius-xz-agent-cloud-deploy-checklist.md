# sirius-xz-agent 云端发布与联调检查清单

> 适用范围：`sirius-xz-agent`（后端）+ `sirius-xz-agent-ui`（前端）
> 环境事实源：公开模型见 `docs/ops/environment-registry.yaml`，真实值放在本地忽略文件 `docs/ops/environment-registry.private.yaml`。
> 目标：稳定发布、快速验收、减少回归与误判。

以下命令默认从仓库根目录执行。发布前先在本地 shell 设置私有环境变量，不要把真实值提交到公开文档：

```bash
export WORKSPACE_ROOT="$(pwd)"
export SSH_ALIAS="<private-ssh-alias>"
export REMOTE_BACKEND_DIR="<remote-backend-dir>"
export REMOTE_FRONTEND_DIR="<remote-frontend-dir>"
export PUBLIC_HOST="<private-host-or-ip>"
export BACKEND_PORT="<backend-public-port>"
export FRONTEND_PORT="<frontend-public-port>"
```

## 1. 发布前检查（必须全部通过）

### 1.1 本地代码与构建

```bash
cd "${WORKSPACE_ROOT}/projects/sirius-xz-agent"
mvn -q -DskipTests package

cd "${WORKSPACE_ROOT}/projects/sirius-xz-agent-ui"
npm run build
```

### 1.2 关键配置检查

- 前端 `VITE_API_BASE_URL` 在云端构建中应为 `""`，不要写成 `"/api"`。
- 前端路由拼接必须保证：
  - 业务接口：`/api/...`
  - 健康接口：`/actuator/health`（不能被拼成 `/api/actuator/health`）
- 后端必须包含 `spring-boot-starter-actuator` 依赖。
- 后端 `management.endpoints.web.exposure.include` 必须包含 `health`。
- 后端数据源地址必须指向实际可达 DB（当前使用 `sirius-xz-agent-pgvector:5432`）。

### 1.3 云端连通性检查

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes "${SSH_ALIAS}" 'echo ok'
```

如果这里失败，先不要发布，先恢复 SSH/网络。

## 2. 发布步骤（标准顺序）

### 2.1 同步代码到云端

```bash
rsync -a --delete "${WORKSPACE_ROOT}/projects/sirius-xz-agent/" "${SSH_ALIAS}:${REMOTE_BACKEND_DIR}/"
rsync -a --delete "${WORKSPACE_ROOT}/projects/sirius-xz-agent-ui/" "${SSH_ALIAS}:${REMOTE_FRONTEND_DIR}/"
```

### 2.2 先启动数据库，再发布后端，再发布前端

```bash
ssh "${SSH_ALIAS}" 'docker start sirius-xz-agent-pgvector || true'
ssh "${SSH_ALIAS}" "cd \"${REMOTE_BACKEND_DIR}\" && docker compose -f docker/docker-compose.cloud.yml up -d --build backend"
ssh "${SSH_ALIAS}" "cd \"${REMOTE_FRONTEND_DIR}\" && docker compose -f docker/docker-compose.cloud.yml up -d --build frontend"
```

## 3. 发布后验收（必须全部通过）

### 3.1 容器状态

```bash
ssh "${SSH_ALIAS}" 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "sirius-xz-agent-pgvector|sirius-xz-agent-backend|sirius-xz-agent-ui"'
ssh "${SSH_ALIAS}" 'docker inspect -f "{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{else}}nohealth{{end}}" sirius-xz-agent-pgvector'
```

期望：
- `pgvector`：`running healthy`
- `backend`：`Up` 且端口映射符合私有环境登记
- `ui`：`Up` 且端口映射符合私有环境登记

### 3.2 外网接口验收

```bash
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${BACKEND_PORT}/api/agent/summary?name=Sirius" | sed -n '1,20p'
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${BACKEND_PORT}/actuator/health" | sed -n '1,20p'
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${FRONTEND_PORT}/" | sed -n '1,20p'
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${FRONTEND_PORT}/api/agent/summary?name=Sirius" | sed -n '1,20p'
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${FRONTEND_PORT}/api/knowledge/documents" | sed -n '1,20p'
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${FRONTEND_PORT}/actuator/health" | sed -n '1,20p'
```

期望：
- 全部 `200`
- 健康接口返回 `{"status":"UP"}` 或 actuator 标准 JSON。

### 3.3 负向校验（防回归）

```bash
curl -sS -i --max-time 10 "http://${PUBLIC_HOST}:${FRONTEND_PORT}/api/actuator/health" | sed -n '1,20p'
```

期望：
- `404`（说明健康接口未被错误地放在 `/api` 前缀下）。

## 4. 快速故障定位（按顺序）

### 4.1 页面能开但 API 不通

1. 先测后端直连：`<backend-public-port>/api/...`
2. 再测前端代理：`<frontend-public-port>/api/...`
3. 看前端 Nginx 上游是否可达（容器名是否正确）

### 4.2 报 CORS 但同时有 502/timeout

- 先按网络故障处理，不要先改 CORS。
- 原则：先链路（端口/容器/上游），后跨域头。

### 4.3 后端反复重启

```bash
ssh "${SSH_ALIAS}" 'docker logs --tail 200 sirius-xz-agent-backend'
```

重点看：
- `UnknownHostException`：DB 主机名解析错误
- `Connect timed out`：DB 容器未运行或网络不通
- Flyway 初始化失败：数据源配置不正确

### 4.4 数据库容器异常

```bash
ssh "${SSH_ALIAS}" 'docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}" | grep sirius-xz-agent-pgvector'
ssh "${SSH_ALIAS}" 'docker logs --tail 120 sirius-xz-agent-pgvector'
```

`pgvector` 非 `running healthy` 时，后端发布没有意义。

## 5. 防错规则（长期执行）

1. URL 拼接统一收口到一个函数，禁止页面里手写拼接。
2. `baseURL` 与路径只允许一方带前缀；健康检查单独豁免。
3. 发布验收必须包含“负向校验”（如 `/api/actuator/health` 应该 404）。
4. 所有“跨域报错”先检查状态码与链路，不直接归因为 CORS。
5. 每次发布都保留 6 条证据：后端 2 条、前端 2 条、健康 1 条、容器状态 1 条。
