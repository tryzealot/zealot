# Zealot

[![GitHub release](https://img.shields.io/github/v/release/tryzealot/zealot?include_prereleases)](https://github.com/tryzealot/zealot/blob/develop/CHANGELOG.md)
[![Docker Pulls](https://img.shields.io/docker/pulls/tryzealot/zealot.svg)](https://hub.docker.com/r/tryzealot/zealot/)
[![Maintainability](https://codeclimate.com/github/tryzealot/zealot/badges/gpa.svg)](https://codeclimate.com/github/tryzealot/zealot)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/bcff7d9de5ba48528bc80aa01bd525c6)](https://www.codacy.com/manual/icyleaf/zealot)
[![License](https://img.shields.io/github/license/tryzealot/zealot)](LICENSE)

开源自部署移动应用分发平台，提供 iOS、Android SDK、fastlane 等丰富组件库，打包分发流程、上传应用竟然如此简单、解决开发人员频繁打包的烦恼 En Taro Adun! 🖖

![Zealot Showcase](https://zealot.ews.im/_media/showcase.png)
## 特性

- [x] 支持 iOS 和 Android 应用的上传、在线安装和本地下载
- [x] 支持应用创建各种类型（Debug、AdHoc、Enterprise、Release）和渠道（小米、华为、Oppp、Vivo、应用宝等）
- [x] 支持 iOS dSYM 和 Android Progruard 文件的备份管理和解析
- [x] 支持单次上传解析 iOS、Android 包甚至是 mobileprovision 文件的信息并存储编译分享他人
- [x] 支持自定义网络钩子（WebHooks）发送给通知各种服务（钉钉、企业微信、Slack 等）
- [x] 支持获取 iOS 设备 UDID 及显示该设备可以安装的应用
- [x] 支持第三方服务的一键登录（目前以接入飞书、Gitlab、Google 和 LDAP）
- [x] 提供检查新版本和安装服务的 iOS 和 Android 组件
- [x] 提供 fastlane 插件 [zealot](https://github.com/tryzealot/fastlane-plugin-zealot) 提供上传应用和调试文件服务、同步 iOS 设备 UDID 名单
- [x] 可接入 Gitlab 服务直接挂钩源码管理
- [ ] 可接入 Jenkins 服务实现远程构建
- [x] 支持丰富的 REST APIs
- [ ] 支持 GraphQL 接口（进行中）

## 在线演示

- 演示地址：https://tryzealot.herokuapp.com/
- 电子邮箱: `admin@zealot.com`
- 登录密码：`ze@l0t`

> **注意**: 数据每日都会重新初始化，不对用户上传的应用承担任何法律风险，后果自负！

## 快速上手

```
$ git clone https://github.com/tryzealot/zealot-docker.git
$ cd zealot-docker
$ ./deploy
```

## 安装部署

- [Docker](https://zealot.ews.im/#/deployment)
- [源码](https://zealot.ews.im/#/development)

## 帮助和文档

对 Zealot 感兴趣，看看文档了解下

https://zealot.ews.im

对 Zealot 有疑问或者建议，欢迎[提交问题](https://github.com/tryzealot/zealot/issues/new)，我会非常欢迎的。