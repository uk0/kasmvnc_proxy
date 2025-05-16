-- /usr/local/openresty/nginx/conf/lua/homepage.lua
local function log_error(msg)
    ngx.log(ngx.ERR, msg)
end

log_error("加载homepage.lua...")

-- 设置响应头
ngx.header["Content-Type"] = "text/html; charset=utf-8"

-- 获取URL参数
local connect_id = ngx.var.arg_connect_id or ""
log_error("homepage.lua - connect_id: " .. connect_id)

if connect_id ~= "" then
    -- 查询设置
    local db_utils = require("conf.lua.db_utils")
    local host, port, user, pass = db_utils.query_connection_info(connect_id)

    -- 构建代理信息并显示
    ngx.say([[
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VNC Remote Desktop</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            text-align: center;
            background-color: #f0f2f5;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        .info {
            margin: 20px 0;
            padding: 15px;
            background-color: #e9f5ff;
            border-radius: 5px;
            text-align: left;
        }
        .credentials {
            margin: 20px 0;
            padding: 15px;
            background-color: #fff8e1;
            border-radius: 5px;
            text-align: left;
            border: 1px solid #ffe082;
        }
        .btn {
            display: inline-block;
            margin: 10px;
            padding: 12px 24px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            font-size: 16px;
        }
        .btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>VNC远程连接</h1>
        <div class="info">
            <p><strong>Content ID:</strong> ]] .. connect_id .. [[</p>
            <p><strong>目标主机:</strong> ]] .. host .. [[:]] .. port .. [[</p>
        </div>

        <div class="credentials">
            <p><strong>连接信息</strong></p>
            <p><strong>URL:</strong> http://]] .. host .. [[:]] .. port .. [[</p>
            <p><strong>用户名:</strong> ]] .. user .. [[</p>
            <p><strong>密码:</strong> ]] .. pass .. [[</p>
        </div>

        <p>请直接在新窗口中访问以上URL并使用提供的凭据登录</p>
        <a href="http://]] .. host .. [[:]] .. port .. [[" class="btn" target="_blank">直接访问KasmVNC</a>
    </div>
</body>
</html>
    ]])
else
    -- 显示简单的表单
    ngx.say([[
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VNC Remote Desktop</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f0f2f5;
        }
        .form-container {
            background-color: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .input-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }
        button {
            background-color: #1890ff;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            transition: background-color 0.3s;
        }
        button:hover {
            background-color: #40a9ff;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <h1>VNC远程桌面</h1>
        <form action="/" method="get">
            <div class="input-group">
                <label for="connect_id">Content ID:</label>
                <input type="text" id="connect_id" name="connect_id" placeholder="请输入Content ID" required>
            </div>
            <button type="submit">连接</button>
        </form>
    </div>
</body>
</html>
    ]])
end