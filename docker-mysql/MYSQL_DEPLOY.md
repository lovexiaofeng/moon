# 远程服务器 MySQL 8.0 Docker 部署指南

## 📋 部署环境信息

- **服务器地址**: 106.53.47.70
- **操作系统**: Linux
- **部署方式**: Docker
- **MySQL 版本**: 8.0
- **SSH 用户**: root

---

## 🚀 部署步骤

### 第一步：准备文件

本项目已创建以下文件供你使用：

```
docker-mysql/
├── docker-compose-mysql.yml    # Docker Compose 配置
└── init.sql                    # MySQL 初始化脚本
```

### 第二步：上传文件到服务器

使用 SCP 或 FTP 将文件上传到服务器：

```bash
# 方式 1：使用 SCP 上传（本地执行）
scp -r docker-mysql root@106.53.47.70:/root/

# 方式 2：使用 WinSCP 等图形化工具上传
```

### 第三步：连接到服务器

```bash
ssh -l root 106.53.47.70
# 或
ssh root@106.53.47.70
```

根据提示输入密码。

### 第四步：安装 Docker（如果还未安装）

在服务器上执行：

```bash
# 更新包管理器
apt update && apt upgrade -y

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装 Docker Compose
apt install -y docker-compose

# 验证安装
docker --version
docker-compose --version
```

### 第五步：启动 MySQL 容器

```bash
# 进入上传的目录
cd /root/docker-mysql

# 启动 MySQL
docker-compose -f docker-compose-mysql.yml up -d

# 验证容器是否运行
docker-compose -f docker-compose-mysql.yml ps
```

**预期输出**:
```
NAME                COMMAND                  SERVICE             STATUS              PORTS
mysql-server        "docker-entrypoint.s…"   mysql               Up 2 seconds        0.0.0.0:3306->3306/tcp
```

---

## ✅ 验证部署

### 1. 检查容器日志

```bash
docker-compose -f docker-compose-mysql.yml logs -f mysql
```

### 2. 连接到 MySQL 验证

```bash
# 方式 1：在服务器上直接连接
docker exec -it mysql-server mysql -uroot -proot123456

# 方式 2：从本地连接
mysql -h 106.53.47.70 -u root -proot123456
```

进入 MySQL 后，执行以下命令验证：

```sql
-- 查看数据库
SHOW DATABASES;

-- 使用 moon 数据库
USE moon;

-- 查看表
SHOW TABLES;

-- 查看用户表数据
SELECT * FROM users;

-- 退出
EXIT;
```

### 3. 查看容器占用的端口

```bash
netstat -tulpn | grep 3306
# 或
docker port mysql-server
```

---

## 🔧 常见配置修改

### 修改 MySQL Root 密码

编辑 `docker-compose-mysql.yml` 文件：

```yaml
environment:
  MYSQL_ROOT_PASSWORD: your_new_password  # 修改这里
```

然后重启容器：

```bash
docker-compose -f docker-compose-mysql.yml down
docker-compose -f docker-compose-mysql.yml up -d
```

### 修改默认端口（如果 3306 被占用）

编辑 `docker-compose-mysql.yml`：

```yaml
ports:
  - "3307:3306"  # 将 3306 改为 3307
```

重启容器后用新端口连接。

### 增加 MySQL 连接数限制

编辑 `docker-compose-mysql.yml` 的 command 部分：

```yaml
command:
  - --max_connections=2000  # 改为你需要的值
```

---

## 📊 容器日常管理

### 查看运行中的容器

```bash
docker ps
```

### 停止 MySQL 容器

```bash
docker-compose -f docker-compose-mysql.yml stop
```

### 启动 MySQL 容器

```bash
docker-compose -f docker-compose-mysql.yml start
```

### 重启 MySQL 容器

```bash
docker-compose -f docker-compose-mysql.yml restart
```

### 删除容器和数据（谨慎！）

```bash
# 只删除容器，保留数据卷
docker-compose -f docker-compose-mysql.yml down

# 删除容器和所有数据（无法恢复）
docker-compose -f docker-compose-mysql.yml down -v
```

### 查看容器日志

```bash
# 实时查看日志
docker-compose -f docker-compose-mysql.yml logs -f mysql

# 查看最后 100 行
docker-compose -f docker-compose-mysql.yml logs --tail=100 mysql
```

---

## 💾 数据备份和恢复

### 备份数据库

```bash
# 备份整个 MySQL
docker exec mysql-server mysqldump -uroot -proot123456 --all-databases > backup.sql

# 备份特定数据库
docker exec mysql-server mysqldump -uroot -proot123456 moon > moon_backup.sql
```

### 恢复数据库

```bash
# 恢复整个 MySQL
docker exec -i mysql-server mysql -uroot -proot123456 < backup.sql

# 恢复特定数据库
docker exec -i mysql-server mysql -uroot -proot123456 moon < moon_backup.sql
```

### 定期备份脚本

创建 `backup.sh` 文件：

```bash
#!/bin/bash

BACKUP_DIR="/root/mysql-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/moon_backup_$TIMESTAMP.sql"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份
docker exec mysql-server mysqldump -uroot -proot123456 moon > $BACKUP_FILE

# 压缩备份
gzip $BACKUP_FILE

# 删除 30 天前的备份（可选）
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

设置定时备份：

```bash
# 添加到 crontab（每天凌晨 2 点执行）
crontab -e

# 添加以下行：
0 2 * * * /root/backup.sh
```

---

## 🔗 从应用连接 MySQL

### Spring Boot 连接配置

在 `application.properties` 中添加：

```properties
# MySQL 数据库配置
spring.datasource.url=jdbc:mysql://106.53.47.70:3306/moon?useSSL=false&serverTimezone=Asia/Shanghai
spring.datasource.username=moon_user
spring.datasource.password=moon_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate 配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
spring.jpa.properties.hibernate.format_sql=true
```

### 添加 MySQL 依赖到 pom.xml

```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>

<!-- 如果使用 Spring Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```

---

## 🚨 故障排除

### 问题：容器无法启动

```bash
# 查看详细错误信息
docker-compose -f docker-compose-mysql.yml logs mysql

# 常见原因：
# 1. 端口被占用：修改 ports 配置
# 2. 磁盘空间不足：清理磁盘
# 3. Docker 权限问题：使用 sudo
```

### 问题：连接超时

```bash
# 检查防火墙
ufw allow 3306

# 检查 MySQL 绑定的 IP
docker exec mysql-server mysql -uroot -proot123456 -e "SHOW VARIABLES LIKE 'bind_address';"
```

### 问题：密码错误

```bash
# 重置 root 密码
docker-compose -f docker-compose-mysql.yml down
# 编辑 docker-compose-mysql.yml，修改 MYSQL_ROOT_PASSWORD
docker-compose -f docker-compose-mysql.yml up -d
```

### 问题：磁盘空间满

```bash
# 查看 Docker 数据卷使用情况
docker system df

# 清理没有使用的镜像和卷
docker system prune -a --volumes
```

---

## 📞 获取帮助

如有问题，可以执行以下命令获取完整日志用于诊断：

```bash
# 导出完整日志
docker-compose -f docker-compose-mysql.yml logs > mysql_debug.log

# 查看系统资源使用
docker stats mysql-server
```

---

## 🎯 下一步

1. ✅ 部署 MySQL 后，将连接配置添加到应用
2. ✅ 在应用中创建数据库表和初始数据
3. ✅ 配置定期备份脚本
4. ✅ 考虑添加 MySQL 监控（Prometheus + Grafana）

