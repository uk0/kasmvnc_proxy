local db_utils = require("conf.lua.db_utils")

-- 获取vmodel_id参数
local connect_id = ngx.var.arg_connect_id or ""

ngx.log(ngx.ERR, "========== ACCESS阶段 - URL参数处理 ==========")
ngx.log(ngx.ERR, "请求URL: " .. ngx.var.request_uri)
ngx.log(ngx.ERR, "connect_id参数: " .. connect_id)

if connect_id ~= "" then
    -- 查询数据库获取配置
    local host, port, user, pass = db_utils.query_connection_info(connect_id)

    -- 更新目标配置
    target_host = host
    target_port = port
    username = user
    password = pass

    -- 更新target_url和auth_header
    target_url = "http://" .. target_host .. ":" .. target_port
    auth_header = "Basic " .. ngx.encode_base64(username .. ":" .. password)

    ngx.log(ngx.ERR, "更新后的配置:")
    ngx.log(ngx.ERR, "  target_url: " .. target_url)
    ngx.log(ngx.ERR, "  target_host: " .. target_host)
    ngx.log(ngx.ERR, "  auth_header: " .. auth_header)
else
    ngx.log(ngx.ERR, "未提供connect_id，使用默认配置")
    ngx.log(ngx.ERR, "  target_url: " .. target_url)
end