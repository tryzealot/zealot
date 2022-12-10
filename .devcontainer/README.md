# Zealot Codespace

## 文档

- [English](https://zealot.ews.im/docs/contributing-guide/local-development/devcontainer)
- [简体中文](https://zealot.ews.im/zh-Hans/docs/contributing-guide/local-development/devcontainer)

## 文件清单

文件名 | 说明
---|---
`devcontainer.json` | VSCode devcontainer 配置文件
`Dockerfile.base` | 镜像核心，变更会自动推送到不同 registry 仓库
`Dockerfile` | 间接镜像，主要是节省编译时间
`docker-compose.yml` | 项目服务依赖
`create-db-user.sql` | 用于初始化 Postgres 默认用户及权限

## 镜像

- [docker.io/tryzealot/codespace](https://hub.docker.com/r/tryzealot/codespace)
- [ghcr.io/tryzealot/codespace](https://github.com/tryzealot/zealot/pkgs/container/codespace)
