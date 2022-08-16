<div align='center'>
  <a href="https://www.producthunt.com/posts/zealot?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-zealot" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=322207&theme=light" style="width: 250px; height: 54px" width="250" height="54" /></a>

  <h1>Zealot</h1>

  <h4>
    开源自部署 iOS、Android 及 macOS 应用分发平台，提供 iOS、Android SDK、fastlane 等丰富组件库，打包分发流程、上传应用竟然如此简单、独立部署解决企业使用的烦恼。 En Taro Adun! 🖖
  </h4>

  <a href="https://github.com/tryzealot/zealot/blob/develop/CHANGELOG.md">
    <img alt="changelog" src="https://img.shields.io/github/v/release/tryzealot/zealot?include_prereleases">
  </a>
  <a href="https://hub.docker.com/r/tryzealot/zealot/">
    <img alt="docker image" src="https://img.shields.io/docker/pulls/tryzealot/zealot.svg">
  </a>
  <a href="https://t.me/tryzealot_lobby">
    <img alt="chat on telegram" src="https://img.shields.io/badge/chat-on%20telegram-important.svg">
  </a>
  <a href="https://codeclimate.com/github/tryzealot/zealot/maintainability">
    <img alt="codeclimate" src="https://api.codeclimate.com/v1/badges/f79b2fed0ce166b2ea2c/maintainability" />
  </a>
  <a href="https://www.codacy.com/gh/tryzealot/zealot/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=tryzealot/zealot&amp;utm_campaign=Badge_Grade">
    <img alt="codacy" src="https://app.codacy.com/project/badge/Grade/5e5c7bbeb1214fa39b11a7414f0d7171"/>
  </a>

  <br />

  <a href="https://zealot.ews.im/#/en/deployment">Install</a> •
  <a href="https://zealot.ews.im/#/en/configuration">Configuration</a> •
  <a href="https://zealot.ews.im/#/en/api">REST API</a> •
  <a href="https://zealot.ews.im/#/en/modules">SDK</a> •
  <a href="https://zealot.ews.im/#/en/screenshot">Screenshots</a>
</div>

![Zealot Showcase](https://zealot.ews.im/_media/showcase.png)
## 特性

- 🌏 **多平台应用支持**: macOS、iOS、甚至是 APK 和 AAB 格式的 Android 应用上传、安装（支持 ARM 的 macOS）和下载
- 🗄 **多渠道分类管理**: Debug、AdHoc、Enterprise 还是 Android 应用渠道管理统统没问题
- 📱 **测试设备一网打进**: 自动同步 iOS 测试设备信息，允许一键注册新设备到苹果开发者
- 🧑‍💻 **丰富开发者套件**: 提供 REST API、[iOS][zealot-ios-sdk]、[Android][android-android-sdk] SDK 以及 [fastlane][fastlane-plugin-zealot] 自动化构建插件
- 💥 **剖析应用内部的秘密**: 解读 iOS、Android 应用或 iOS 描述文件的元信息
- 🚨 **内置多种事件通知**: 数据可自定义 Income WebHook 到任意通知服务
- 🔑 **第三方登录**: 飞书、Gitlab、Google 和 LDAP 一键授权
- 🌑 **黑暗模式**: 黑夜白昼自由切换

## 快速部署

```
$ git clone https://github.com/tryzealot/zealot-docker.git
$ cd zealot-docker
$ ./deploy
```

按照部署脚本可以快速部署系统服务，如需自定义其他配置请看[项目配置](https://zealot.ews.im/#/configuration)

## 最佳实践

如果想知道使用 Zealot 如何全流程无缝 CI/CD 接入 iOS 和 Android 请看[实践教程](https://zealot.ews.im/#/best_practices)

## 在线演示

- 演示地址：https://tryzealot.herokuapp.com/
- 电子邮箱: `admin@zealot.com`
- 登录密码：`ze@l0t`

> **注意**: 数据每日都会重新初始化，不对用户上传的应用承担任何法律风险，后果自负！

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


## 发布协议

[MIT][mit-link]


[zealot-ios-sdk]: https://github.com/tryzealot/zealot-ios
[android-android-sdk]: https://github.com/tryzealot/zealot-android
[fastlane-plugin-zealot]: https://github.com/tryzealot/fastlane-plugin-zealot
[mit-link]: https://github.com/tryzealot/zealot/blob/develop/CHANGELOG.md