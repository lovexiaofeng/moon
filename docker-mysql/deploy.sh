#!/bin/bash

# MySQL Docker 部署脚本
# 使用方式: bash deploy.sh

set -e

echo "================================"
echo "MySQL 8.0 Docker 自动部署脚本"
echo "================================"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 未检测到 Docker，开始安装..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "✅ Docker 安装完成"
else
    echo "✅ Docker 已安装: $(docker --version)"
fi

echo ""

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ 未检测到 Docker Compose，开始安装..."
    apt update
    apt install -y docker-compose
    echo "✅ Docker Compose 安装完成"
else
    echo "✅ Docker Compose 已安装: $(docker-compose --version)"
fi

echo ""
echo "✅ 检查完成，开始启动 MySQL..."
echo ""

# 启动 MySQL
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "启动 MySQL 容器..."
docker-compose -f docker-compose-mysql.yml up -d

echo ""
echo "等待 MySQL 启动（最多 30 秒）..."
COUNTER=0
while [ $COUNTER -lt 30 ]; do
    if docker exec mysql-server mysql -uroot -proot123456 -e "SELECT 1" &> /dev/null; then
        echo "✅ MySQL 启动成功！"
        break
    fi
    COUNTER=$((COUNTER + 1))
    sleep 1
done

if [ $COUNTER -eq 30 ]; then
    echo "⚠️ MySQL 启动超时，请检查日志："
    docker-compose -f docker-compose-mysql.yml logs mysql
    exit 1
fi

echo ""
echo "================================"
echo "✅ 部署完成！"
echo "================================"
echo ""
echo "MySQL 连接信息："
echo "  地址: localhost:3306"
echo "  用户: root"
echo "  密码: root123456"
echo "  默认数据库: moon"
echo ""
echo "常用命令："
echo "  查看日志: docker-compose -f docker-compose-mysql.yml logs -f mysql"
echo "  停止服务: docker-compose -f docker-compose-mysql.yml stop"
echo "  启动服务: docker-compose -f docker-compose-mysql.yml start"
echo "  重启服务: docker-compose -f docker-compose-mysql.yml restart"
echo ""
echo "连接 MySQL:"
echo "  docker exec -it mysql-server mysql -uroot -proot123456"
echo ""
