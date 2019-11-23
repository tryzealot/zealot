# Zealot

移动应用上传没有如此简单、解放开发打包的烦恼，轻松放权给测试、产品、运营等使用 App 的人员，深度与 Jenkins 和 Gitlab 集成。

## 特性

- [x] 支持 iOS 和 Android 应用的上传和下载
- [x] 支持应用创建各种类型（Debug、AdHoc、Release）和渠道（小米、华为、Oppp、Vivo、应用宝等）
- [x] 支持 iOS dSYMs 和 Android Progruard 文件的备份管理和解析
- [x] 支持解析 iOS 和 Android 包信息
- [x] 支持自定义网络（WebHooks）数据来实时发送给通知服务（钉钉、企业微信、Slack 等）
- [x] 可接入 Jenkins 服务实现远程构建
- [x] 可接入 Gitlab 服务直接挂钩源码管理
- [x] 支持丰富的 REST APIs
- [ ] 提供 fastlane 插件提供上传服务
- [ ] 提供 cli 命令行工具

## 安装依赖

- Ruby 2.3+
- Postgres 8.0+
- Redis 2.7+
- ImageMagick/GraphicsMagick
- Nodejs 6.0+
- Yarn

## 安装

### 源码

安装完成上面的依赖后，配置 config/database.yml 数据库信息可从 ENV 环境变量获取，之后顺序执行：

```
$ bundle install
$ bundle exec guard start
```

打开浏览器 `http://localhost:3000`

### Docker

> TODO

## 最佳实践

本系统配合 zealot-cli 及 fastlane 插件 zealot 服用为佳。
