# Zealot

[![GitHub release](https://img.shields.io/github/v/release/tryzealot/zealot?include_prereleases)](https://github.com/tryzealot/zealot/blob/develop/CHANGELOG.md)
[![Docker Pulls](https://img.shields.io/docker/pulls/tryzealot/zealot.svg)](https://hub.docker.com/r/tryzealot/zealot/)
[![Maintainability](https://codeclimate.com/github/tryzealot/zealot/badges/gpa.svg)](https://codeclimate.com/github/tryzealot/zealot)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/5e5c7bbeb1214fa39b11a7414f0d7171)](https://www.codacy.com/gh/tryzealot/zealot)
[![License](https://img.shields.io/github/license/tryzealot/zealot)](LICENSE)

[English Document](https://zealot.ews.im/#/en/) | [简体中文文档](https://zealot.ews.im)

开源自部署 iOS、Android 及 macOS 应用分发平台，提供 iOS、Android SDK、fastlane 等丰富组件库，打包分发流程、上传应用竟然如此简单、独立部署解决企业使用的烦恼。 En Taro Adun! 🖖

![Zealot Showcase](https://zealot.ews.im/_media/showcase.png)
## 特性

- [x] 支持 iOS、Android (apk/aab) 和 macOS 应用的上传、在线安装和本地下载
- [x] 自定义网络钩子通知各种服务（譬如钉钉、企业微信、Slack 等）
- [x] 多类型（Debug、AdHoc、Release）及渠道（应用商店等）管理
- [x] iOS dSYM 和 Android Progruard 文件的解析和存储
- [x] 应用解包（甚至 mobileprovision 文件）存储和分享
- [x] 检查新版本和安装服务的 iOS 和 Android SDK 组件
- [x] 获取 iOS 设备 UDID 显示支持安装的应用列表
- [x] 飞书、Gitlab、Google 和 LDAP 一键登录
- [x] 托管苹果开发者智能注册 iOS 测试设备
- [x] 持续构建的 fastlane 插件 [zealot](https://github.com/tryzealot/fastlane-plugin-zealot)
- [x] Gitlab 服务直接挂钩源码管理
- [ ] Jenkins 服务实现远程构建
- [x] 丰富的 REST APIs
- [ ] GraphQL 接口
- [x] 黑暗模式

## 在线演示

- 演示地址：https://tryzealot.herokuapp.com/
- 电子邮箱: `admin@zealot.com`
- 登录密码：`ze@l0t`

> **注意**: 数据每日都会重新初始化，不对用户上传的应用承担任何法律风险，后果自负！

## 快速部署

```
$ git clone https://github.com/tryzealot/zealot-docker.git
$ cd zealot-docker
$ ./deploy
```

按照部署脚本可以快速部署系统服务，如需自定义其他配置请看[项目配置](https://zealot.ews.im/#/configuration)

## 最佳实践

如果想知道使用 Zealot 如何全流程无缝 CI/CD 接入 iOS 和 Android 请看[实践教程](https://zealot.ews.im/#/best_practices)

## 帮助和文档

你可以查看更多的功能截图:

https://zealot.ews.im/#/screenshot

你可以了解下支持什么插件:

https://zealot.ews.im/#/modules

你可以了解提供的 HTTP API 接口:

https://zealot.ews.im/#/api

你可以了解变更日志:

https://zealot.ews.im/#/changelog

对于项目细节感兴趣就来看看翻翻文档:

https://zealot.ews.im

对 Zealot 有疑问或者建议，欢迎[提交问题](https://github.com/tryzealot/zealot/issues/new)，我会非常欢迎的。
