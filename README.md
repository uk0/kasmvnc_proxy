## KasmVNC Proxy



### 1. quick test

```bash

docker run -d --name kasmvnc-proxy -p 38881:38881 -e TARGET_HOST=10.8.0.19 -e TARGET_PORT=33335 -e USERNAME=admin -e PASSWORD=adminaisoc  -e PROXY_PORT=38881 -e ACCESS_TOKEN=adminaisoc firshme/kasmvnc-proxy:neo


```


### 2. build

```bash

docker build --platform=linux/amd64 -t firshme/kasmvnc-proxy:neo  .

```