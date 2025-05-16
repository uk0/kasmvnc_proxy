FROM openresty/openresty:alpine

LABEL maintainer="Uk0 <zhangjianxinnet@gmail.com>"
LABEL description="KasmVNC Proxy using OpenResty with Lua"

# 设置工作目录
WORKDIR /usr/local/openresty/nginx


# 安装必要的构建工具和依赖
RUN apk add --no-cache \
    curl \
    wget \
    ca-certificates \
    bash \
    gettext \
    postgresql-dev \
    gcc \
    libc-dev \
    make \
    libffi-dev \
    libstdc++ \
    libgcc \
    zlib-dev \
    pcre-dev



# 设置LuaJIT路径
ENV LUA_PATH="/usr/local/openresty/lualib/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?.lua;;"
ENV LUA_CPATH="/usr/local/openresty/lualib/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;;"

# 创建Lua脚本目录和日志目录
RUN mkdir -p /usr/local/openresty/nginx/conf/lua \
    && mkdir -p /usr/local/openresty/nginx/logs




# 安装lua-cjson
RUN luarocks install lua-cjson || echo "lua-cjson already installed"




# 清理构建依赖
RUN apk del wget gcc libc-dev make \
    && rm -rf /var/cache/apk/* /tmp/*

# 设置默认环境变量
ENV PROXY_PORT=38881 \
    TARGET_HOST=8.8.8.8 \
    TARGET_PORT=3000 \
    DB_HOST=postgresql \
    DB_PORT=5432 \
    DB_NAME=aisoc \
    DB_USER=aisoc \
    DB_PASSWORD=Tensor@20210 \
    CONNECT_ID=""

# 复制配置文件
COPY nginx.conf /usr/local/openresty/nginx/conf/
COPY kasmvnc-proxy.conf /usr/local/openresty/nginx/conf/conf.d/
COPY start.sh /start.sh

# 创建lua目录
RUN mkdir -p /usr/local/openresty/nginx/conf/lua

# 复制Lua脚本
COPY lua/init.lua /usr/local/openresty/nginx/conf/lua/
COPY lua/auth.lua /usr/local/openresty/nginx/conf/lua/
COPY lua/homepage.lua /usr/local/openresty/nginx/conf/lua/
COPY lua/postgres.lua /usr/local/openresty/nginx/conf/lua/
COPY lua/db_utils.lua /usr/local/openresty/nginx/conf/lua/
COPY lua/access.lua /usr/local/openresty/nginx/conf/lua/

# 添加启动脚本执行权限
RUN chmod +x /start.sh

# 暴露端口
EXPOSE ${PROXY_PORT}

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PROXY_PORT}/ || exit 1

# 启动Nginx
CMD ["/start.sh"]