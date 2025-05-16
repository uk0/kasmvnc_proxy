ngx.log(ngx.ERR, "========== INIT.LUA 开始执行 ==========")

-- 加载共享模块
local db_utils = require("conf.lua.db_utils")

-- 设置默认值
target_host = os.getenv("TARGET_HOST") or "8.8.8.8"
target_port = os.getenv("TARGET_PORT") or "3000"
username = "admin"
password = "admin"

-- 记录默认配置
ngx.log(ngx.ERR, "初始化默认配置:")
ngx.log(ngx.ERR, "  target_host: " .. target_host)
ngx.log(ngx.ERR, "  target_port: " .. target_port)
ngx.log(ngx.ERR, "  username: " .. username)

-- 设置目标URL
target_url = "http://" .. target_host .. ":" .. target_port

-- 设置Basic Auth认证信息
auth_header = "Basic " .. ngx.encode_base64(username .. ":" .. password)

ngx.log(ngx.ERR, "========== INIT.LUA 执行完毕 ==========")