# Zealot

基于 Rails 平台开发类似于 Testeflightapp、FIR、蒲公英等功能，支持 iOS 和 Android 深度与 Jenkins 和 Gitlab 集成。

## 安装依赖

- Ruby 2.3+
- Postgres 8.0+
- Redis 2.7+
- ImageMagick/GraphicsMagick
- Nodejs 6.0+
- Yarn

## 部署

### 源码部署

安装完成上面的依赖后，配置 config/database.yml 数据库信息可从 ENV 环境变量获取，之后顺序执行：

```
$ bundle install
$ bundle exec guard start
```

打开浏览器 `http://localhost:3000`

### Docker 部署

> TODO

## 最佳实践

本系统配合 zealot-cli 及 fastlane 插件 zealot 服用为佳。
