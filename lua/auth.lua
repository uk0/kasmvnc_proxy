ngx.log(ngx.ERR, "执行认证检查...")

-- 检查是否来自可信IP
local remote_addr = ngx.var.remote_addr
local trusted_ips = {
    ["127.0.0.1"] = true,
    ["10.8.0.1"] = true,
    -- 添加其他可信IP
}

-- 检查是否是测试端点或者配置端点
local request_uri = ngx.var.request_uri
if string.match(request_uri, "^/test_") or string.match(request_uri, "^/show_config") then
    ngx.log(ngx.ERR, "访问测试或配置端点，跳过认证: " .. request_uri)
    return
end

-- 如果是可信IP，直接通过
if trusted_ips[remote_addr] then
    ngx.log(ngx.ERR, "来自可信IP: " .. remote_addr .. "，跳过认证")
    return
end