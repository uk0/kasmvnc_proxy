FROM openresty/openresty:alpine

LABEL maintainer="Uk0 <zhangjianxinnet@gmail.com>"
LABEL description="KasmVNC Proxy using OpenResty with Lua"

# 设置工作目录
WORKDIR /usr/local/openresty/nginx

# 安装必要的工具
RUN apk add --no-cache curl ca-certificates bash gettext

# 设置环境变量
ENV TARGET_HOST="10.8.0.19" \
    TARGET_PORT="33335" \
    USERNAME="admin" \
    PASSWORD="adminaisoc" \
    ACCESS_TOKEN="adminaisoc" \
    PROXY_PORT="38881"

# 复制配置文件
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY kasmvnc-proxy.conf /usr/local/openresty/nginx/conf/conf.d/
COPY start.sh /start.sh

# 添加启动脚本执行权限
RUN chmod +x /start.sh

# 公开端口
EXPOSE ${PROXY_PORT}

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PROXY_PORT}/?token=${ACCESS_TOKEN} || exit 1

# 启动Nginx
CMD ["/start.sh"]