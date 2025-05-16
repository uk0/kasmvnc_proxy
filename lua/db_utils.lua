local _M = {}

-- 加载postgres模块
local postgres = require("conf.lua.postgres")


-- 添加到 db_utils.lua 顶部
-- 查询主机名的 IP 地址
local function get_host_ip(hostname)
    -- 首先尝试直接使用主机名
    local original_hostname = hostname

    -- 使用系统命令获取 IP
    local handle = io.popen("getent hosts " .. hostname .. " | awk '{print $1}'")
    local ip = handle:read("*a")
    handle:close()

    -- 去除可能的换行符
    ip = ip:gsub("%s+", "")

    -- 如果获取到 IP，则返回
    if ip and ip ~= "" then
        ngx.log(ngx.ERR, "将主机名 " .. hostname .. " 解析为 IP: " .. ip)
        return ip
    end

    -- 尝试 ping 命令
    handle = io.popen("ping -c 1 " .. hostname .. " 2>/dev/null | head -n1 | grep -o -E '\\([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\)' | tr -d '()'")
    ip = handle:read("*a")
    handle:close()

    -- 去除可能的换行符
    ip = ip:gsub("%s+", "")

    if ip and ip ~= "" then
        ngx.log(ngx.ERR, "通过 ping 将主机名 " .. hostname .. " 解析为 IP: " .. ip)
        return ip
    end

    -- 如果无法解析，返回原始主机名
    ngx.log(ngx.ERR, "无法将主机名 " .. hostname .. " 解析为 IP，使用原始主机名")
    return original_hostname
end

-- 获取数据库连接
function _M.get_db_connection()
    -- 从环境变量获取数据库连接信息
    local db_host = os.getenv("DB_HOST") or "postgresql"
    local db_port = os.getenv("DB_PORT") or "5432"
    local db_name = os.getenv("DB_NAME") or "admin"
    local db_user = os.getenv("DB_USER") or "admin"
    local db_pass = os.getenv("DB_PASSWORD") or "AAAAAAAA@20210"

    -- 构建连接字符串
    local conn_str = string.format(
        "host=%s port=%s dbname=%s user=%s password=%s",
        db_host, db_port, db_name, db_user, db_pass
    )

    ngx.log(ngx.ERR, "尝试连接数据库: " .. conn_str)

    -- 连接数据库
    local db, err = postgres:connect(conn_str)
    if err then
        ngx.log(ngx.ERR, "数据库连接失败: " .. err)
        return nil, err
    end

    ngx.log(ngx.ERR, "数据库连接成功")
    return db, nil
end

-- 查询 vmodel 信息：直接从 kasm_vnc 表用 connect_id
function _M.query_connection_info(connect_id)
    -- 默认配置
    local target_host = os.getenv("TARGET_HOST") or "8.8.8.8"
    local target_port = os.getenv("TARGET_PORT") or "3000"
    local username    = "admin"
    local password    = "admin"

    -- 如果未提供 connect_id，返回默认
    if not connect_id or connect_id == "" then
        ngx.log(ngx.WARN, "未提供 connect_id，使用默认配置")
        return target_host, target_port, username, password
    end

    ngx.log(ngx.ERR, "开始查询 kasm_vnc 表，connect_id=", connect_id)

    -- 建立数据库连接
    local db, err = _M.get_db_connection()
    if not db then
        ngx.log(ngx.ERR, "无法连接数据库，使用默认配置")
        return target_host, target_port, username, password
    end

    -- 从 kasm_vnc 表中取 connect_id、vnc_user、vnc_pass、port
    local sql = string.format([[
        SELECT connect_id, vnc_user, vnc_pass, port
          FROM kasm_vnc
         WHERE connect_id = '%s'
    ]], connect_id)
    ngx.log(ngx.ERR, "执行 SQL: ", sql)

    local rows, err = db:query(sql)
    db:close()

    if err then
        ngx.log(ngx.ERR, "kasm_vnc 查询失败: ", err)
        return target_host, target_port, username, password
    end

    if rows and #rows > 0 then
        ngx.log(ngx.ERR, "kasm_vnc 表返回记录，更新代理配置")
        local original = rows[1].connect_id or target_host
        -- 尝试将 hostname 解析成 IP
        target_host = get_host_ip(original)
        target_port = tonumber(rows[1].port) or target_port
        username    = rows[1].vnc_user or username
        password    = rows[1].vnc_pass or password

        ngx.log(ngx.ERR,
            "代理信息: connect_id=", original,
            " → IP=", target_host,
            ", port=", target_port,
            ", user=", username
        )
    else
        ngx.log(ngx.ERR, "未在 kasm_vnc 表找到 connect_id=", connect_id)
    end

    return target_host, target_port, username, password
end

-- 测试函数：获取agents表所有数据
function _M.get_all_kasm_vncs()
    -- 获取数据库连接
    local db, err = _M.get_db_connection()
    if not db then
        return nil, "数据库连接失败: " .. (err or "未知错误")
    end

    -- 查询所有agents
    local sql = "SELECT * FROM kasm_vnc LIMIT 100"

    ngx.log(ngx.ERR, "执行查询所有vnc instance: " .. sql)

    local rows, err = db:query(sql)
    if err then
        ngx.log(ngx.ERR, "查询执行失败: " .. err)
        db:close()
        return nil, "查询失败: " .. err
    end

    -- 关闭数据库连接
    db:close()

    return rows, nil
end

return _M