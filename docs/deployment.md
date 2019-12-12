# 部署 Zealot

Zealot 提供 iOS 和 Android 的上传、下载和手机安装服务，鉴于 iOS 系统的限制 `产品环境` 部署需要开启 https。

## Docker

!> 即使使用 Docker 部署也需要提前克隆 [Zealot](https://github.com/getzealot/zealot) 后配置，本教程提供了配置和使用 [Caddy](https://caddyserver.com/) Web 服务器的配置文件，请跟着教程来完成配置，最后如果您没有安装 [Docker](https://docs.docker.com/install/) 和 [docker-compose](https://docs.docker.com/compose/install/)。

### 自签名 SSL 证书

**第一步**：生成自签名的证书，可使用如下工具自行生成：

- [mkcert](https://github.com/FiloSottile/mkcert) - 推荐
- openssl 生成 pem

```bash
$ mkcert zealot.test
```

使用 mkcert 会生成 `zealot.test.pem` 和 `zealot.test-key.pem`，复制两个文件到 `docker/certs` 目录下

**第二步**：修改 `docker/Caddyfile` 第一行 `zealot.test` 为你需要的设置的域名，若你的 ssl 证书名不一样还需要修改第六行（`tls` 开头）配置。

```
zealot.test {
    gzip
    log stdout

    # mkcert - https://github.com/FiloSottile/mkcert
    tls /app/docker/certs/zealot.test.pem /app/docker/certs/zealot.test-key.pem

    # serve assets
    root /app/public

    proxy / http://zealot:3000 {
        except /assets /packs /uploads /config /favicon.ico /robots.txt

        transparent
        header_upstream X-Marotagem true
        header_upstream Host {host}
        header_upstream X-Real-IP {remote}
        header_upstream X-Forwarded-For {remote}
    }
}
```

**第三步**：改名 `example.env` 为 `.env` 并修改配置：

- 设置 `ZEALOT_DOMAIN` 为你的访问域名，并移除最开始 `#`
- 自定义其他你所需的配置

**第四步**：运行 docker-compose 完成初始化即可完成

```bash
$ docker-compose -f docker-compose-https.yml up -d

# 查看初始化情况
$ docker-compose zealot logs
...
Zealot server is ready to run ...   # <- 看到这个基本上已经可用了
```

**第五步**：如果域名是非注册域名则需要绑 host 才可以访问，通常是修改系统的 `/etc/hosts` 文件

```bash
$ sudo vim /etc/hosts

127.0.0.1 zealot.test
```

运行 docker-compose 完成初始化即可完成：

### Let's Encrypt SSL 证书

参照自签名证书的步骤，跳过第一步，把 `Caddyfile` 的 `tls` 后面参数改为你的常用邮箱即可激活 Let's Encrypt
的证书自动签发，其他步骤基本上没有什么变化。

### 外部接管 SSL 证书

参照自签名证书的步骤第三步，如果你外部接管证书的 Web 服务器还是 Docker 则需要使用指定 `docker-compose.yml` 的 `network`，如果是宿主机的 Web 服务器需要反代到 IP:13000 端口即可。

> 这里说的比较抽象，后续有时间在展开吧。

```bash
$ docker-compose up -d
```

## 源码

> TODO