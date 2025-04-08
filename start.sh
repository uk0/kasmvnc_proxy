#!/bin/bash

# 打印环境信息
echo "Starting KasmVNC Proxy with the following configuration:"
echo "Target Host: $TARGET_HOST:$TARGET_PORT"
echo "Proxy Port: $PROXY_PORT"
echo "Auth: $USERNAME:******"
echo "Access Token: $ACCESS_TOKEN"

# 设置TARGET_URL环境变量
export TARGET_URL="http://$TARGET_HOST:$TARGET_PORT"

# 使用sed替换配置文件中的环境变量
sed -i "s|\${TARGET_HOST}|$TARGET_HOST|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${TARGET_PORT}|$TARGET_PORT|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${TARGET_URL}|$TARGET_URL|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf
sed -i "s|\${PROXY_PORT}|$PROXY_PORT|g" /usr/local/openresty/nginx/conf/conf.d/kasmvnc-proxy.conf

# 启动Nginx
exec /usr/local/openresty/bin/openresty -g "daemon off;"