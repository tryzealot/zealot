# Zealot

[![GitHub release](https://img.shields.io/github/release/getzealot/zealot.svg)](https://github.com/getzealot/zealot/releases)
[![License](https://img.shields.io/github/license/getzealot/zealot)](LICENSE)

移动应用上传没有如此简单、解放开发打包的烦恼，轻松放权给测试、产品、运营等使用 App 的人员，深度与 Jenkins 和 Gitlab 集成。

## 特性

- [x] 支持 iOS 和 Android 应用的上传和下载
- [x] 支持应用创建各种类型（Debug、AdHoc、Release）和渠道（小米、华为、Oppp、Vivo、应用宝等）
- [x] 支持 iOS dSYM 和 Android Progruard 文件的备份管理和解析
- [x] 支持单次上传解析 iOS 和 Android 包信息
- [x] 支持自定义网络（WebHooks）数据来实时发送给通知服务（钉钉、企业微信、Slack 等）
- [x] 可接入 Jenkins 服务实现远程构建
- [x] 可接入 Gitlab 服务直接挂钩源码管理
- [x] 支持丰富的 REST APIs
- [x] 支持 OAuth 认证登录（目前以接入 Google，LDAP）
- [x] 提供 fastlane 插件 [zealot](https://github.com/getzealot/fastlane-plugin-zealot) 提供上传服务
- [ ] 提供检查新版本和安装服务的 iOS 和 Android 组件
- [ ] 支持 GraphGL 接口（进行中）
- [ ] 提供 cli 命令行工具（旧插件需要移植即可但貌似没有啥必要，有用没用先列在这）

## 部署

**技术栈:**

- Ruby on Rails 驱动 Web 和 API 服务
- Sidekiq 提供异步后台任务管理

**环境依赖:**

- Ruby 2.4+
- Postgres 9.5+
- Redis
- Nodejs 8+
- ImageMagick/GraphicsMagick

### Docker

```
$ git clone git@github.com:getzealot/zealot.git
$ cd zealot
$ docker-compose up
```

### 本地部署

#### 源码

安装完成上面的依赖后，克隆本项目配置 config/database.yml 数据库信息可从 ENV 环境变量获取，之后顺序执行：

```
$ git clone git@github.com:getzealot/zealot.git
$ cd zealot
$ bundle install
$ bundle exec guard start
```

打开浏览器 `http://localhost:3000`

## 关于项目名

Zealot 来自星际争霸 2 的神族的基础兵种，项目可能会使用到对于的图标版权归属[暴雪](https://www.blizzard.com)，
如果有热心设计师能够帮助设计更好的图标，本人代表本项目表示衷心的感谢。