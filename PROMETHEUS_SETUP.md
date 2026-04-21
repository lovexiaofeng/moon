# Prometheus 监控配置指南

## 项目已配置的内容

### 1. 依赖项
已添加到 `pom.xml`：
- `spring-boot-starter-actuator` - Spring Boot 执行器
- `micrometer-registry-prometheus` - Prometheus 指标注册表

### 2. 应用配置
在 `application.properties` 中已配置：
```properties
management.endpoints.web.exposure.include=health,metrics,prometheus
management.endpoint.health.show-details=always
management.metrics.enable.jvm=true
management.metrics.enable.process=true
management.metrics.enable.system=true
```

### 3. Prometheus 配置
已创建 `prometheus.yml`，配置内容：
- 抓取间隔：15 秒
- 目标应用：localhost:8080
- 指标端点：/actuator/prometheus

### 4. Docker Compose 配置
已创建 `docker-compose.yml`，包含：
- Prometheus（端口 9090）
- Grafana（端口 3000）

---

## 快速启动步骤

### 选项 A：使用 Docker Compose（推荐）

**前提条件**：安装 Docker 和 Docker Compose

```bash
# 1. 构建并启动容器
docker-compose up -d

# 2. 验证服务是否运行
docker ps

# 3. 访问服务
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

**查看日志**：
```bash
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

**停止服务**：
```bash
docker-compose down
```

### 选项 B：手动运行应用 + Prometheus

**第一步：启动 Spring Boot 应用**
```bash
mvn spring-boot:run
```
应用将在 http://localhost:8080 启动

**第二步：下载并运行 Prometheus**

1. 从 https://prometheus.io/download/ 下载 Prometheus
2. 解压到某个目录
3. 将 `prometheus.yml` 文件复制到 Prometheus 目录
4. 运行 Prometheus：
   ```bash
   prometheus --config.file=prometheus.yml
   ```
5. 访问 http://localhost:9090

### 选项 C：本地已有 Prometheus

编辑你的 Prometheus 配置文件，添加以下任务：
```yaml
scrape_configs:
  - job_name: 'moon'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

---

## 验证配置

启动应用后，测试以下端点：

1. **健康检查**
   ```
   http://localhost:8080/actuator/health
   ```
   应返回 200，JSON 格式的健康状态

2. **所有可用指标**
   ```
   http://localhost:8080/actuator/metrics
   ```
   返回可用的指标列表

3. **Prometheus 格式指标**
   ```
   http://localhost:8080/actuator/prometheus
   ```
   返回 Prometheus 格式的指标数据

---

## Prometheus UI 使用

访问 http://localhost:9090 后：

1. **Graph 标签页**：查询和绘制指标
   - 示例查询：`jvm_memory_used_bytes`
   - 示例查询：`system_cpu_usage`
   - 示例查询：`http_requests_total`

2. **Targets 标签页**：查看所有抓取目标状态
   - 应该看到 `moon` 任务为 UP

3. **Alerts 标签页**：查看告警（如果配置了的话）

---

## Grafana 使用（可选）

访问 http://localhost:3000：

1. **首次登陆**：admin / admin
2. **添加数据源**：
   - 选择 Data Sources → Add new data source
   - 选择 Prometheus
   - 设置 URL：http://prometheus:9090（Docker 中使用服务名）
3. **创建仪表板**：导入预制的 Grafana 仪表板或自定义创建

---

## 常见指标说明

| 指标名称 | 说明 |
|---------|------|
| `jvm_memory_used_bytes` | JVM 已用内存 |
| `jvm_memory_max_bytes` | JVM 最大内存 |
| `process_cpu_usage` | 进程 CPU 使用率 |
| `system_cpu_usage` | 系统 CPU 使用率 |
| `http_server_requests_seconds_count` | HTTP 请求总数 |
| `http_server_requests_seconds_max` | HTTP 请求最大耗时 |

---

## 故障排除

### Prometheus 连接不到应用

1. 检查应用是否运行：`curl http://localhost:8080/actuator/health`
2. 检查 prometheus.yml 中的目标地址是否正确
3. 如果在 Docker 中，确保网络配置正确

### Grafana 看不到数据

1. 等待 Prometheus 采集数据（需要至少一个抓取周期）
2. 检查数据源配置是否正确
3. 在 Prometheus UI 中验证数据是否存在

### 内存占用过高

- 调整 `prometheus.yml` 中的 `scrape_interval`（增大抓取间隔）
- 调整 `storage.tsdb.retention.time` 来减少数据保留时间

---

## 停止和清理

```bash
# 停止 Docker 服务
docker-compose down

# 删除数据卷（谨慎操作）
docker-compose down -v

# 停止应用
Ctrl+C（在终端中）
```

