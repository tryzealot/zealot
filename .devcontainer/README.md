# Zealot Codespace

## 文档 | Document

- [English](https://zealot.ews.im/docs/contributing-guide/local-development/devcontainer)
- [简体中文](https://zealot.ews.im/zh-Hans/docs/contributing-guide/local-development/devcontainer)

## 文件清单 | Files

文件名 File | 说明 Description
---|---
`devcontainer.json` | vscode devcontainer 配置文件 main file
`Dockerfile.base` | 基础镜像 Base Image
`Dockerfile` | 运行时镜像，主要是节省编译时间 Dev Image
`docker-compose.yml` | 项目服务依赖 
`create-db-user.sql` | 用于初始化 Postgres 默认用户及权限 Initial Database and user

## 镜像 | Image

- [docker.io/tryzealot/codespace](https://hub.docker.com/r/tryzealot/codespace)
- [ghcr.io/tryzealot/codespace](https://github.com/tryzealot/zealot/pkgs/container/codespace)
