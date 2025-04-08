## KasmVNC Proxy


```bash

docker run -d --name kasmvnc-proxy -p 38881:38881 -e TARGET_HOST=10.8.0.19 -e TARGET_PORT=33335 -e USERNAME=admin -e PASSWORD=adminaisoc  -e PROXY_PORT=38881 -e ACCESS_TOKEN=adminaisoc swr.cn-north-4.myhuaweicloud.com/firshme/kasmvnc-proxy:neo


```