#!/bin/bash
set -e

# 设置默认值（如果环境变量未定义）
PROXY_PORT=${PROXY_PORT:-8080}
TARGET_HOST=${TARGET_HOST:-8.8.8.8}
TARGET_PORT=${TARGET_PORT:-3000}
DB_HOST=${DB_HOST:-postgresql}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-kasmvnc}
DB_USER=${DB_USER:-admin}
DB_PASSWORD=${DB_PASSWORD:-"kasmvnc@20210"}
CONNECT_ID=${CONNECT_ID:-""}

# 设置TARGET_URL环境变量
export TARGET_URL="http://${TARGET_HOST}:${TARGET_PORT}"

# 打印环境信息
echo "Starting KasmVNC Proxy with the following configuration:"
echo "配置信息:"
echo "PROXY_PORT: ${PROXY_PORT}"
echo "TARGET_HOST: ${TARGET_HOST}"
echo "TARGET_PORT: ${TARGET_PORT}"
echo "TARGET_URL: ${TARGET_URL}"
echo "DB_HOST: ${DB_HOST}"
echo "DB_PORT: ${DB_PORT}"
echo "CONNECT_ID: ${CONNECT_ID}"

# 创建日志目录（如果不存在）
mkdir -p /usr/local/openresty/nginx/logs

# 使用sed替换配置文件中的环境变量
sed -i "s|\${TARGET_HOST}|$TARGET_HOST|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${TARGET_PORT}|$TARGET_PORT|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${TARGET_URL}|$TARGET_URL|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${PROXY_PORT}|$PROXY_PORT|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf

# 检查配置是否有效
echo "检查Nginx配置..."
/usr/local/openresty/bin/openresty -t

# 启动Nginx
echo "启动OpenResty..."
exec /usr/local/openresty/bin/openresty -g "daemon off;"