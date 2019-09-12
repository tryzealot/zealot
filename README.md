# Zealot

基于 Rails 平台开发类似于 Testeflightapp、FIR、蒲公英等功能，支持 iOS 和 Android 深度与 Jenkins 和 Gitlab 集成。

## 安装依赖

- Linux
- Ruby 2.2+
- Rails 5.0+
- Postgres 8.0+
- Redis 2.7+
- Sidekiq
- ImageMagick/GraphicsMagick
- Nodejs 6.0+
- Yarn

## 部署

### Docker 部署

> TODO

### 源码部署

本机部署脚本位于 `config/deploy.rb`

```
cap production deploy
```

#### 服务化

复制项目的 `lib/support/init.d/zealot` 到系统的 `/etc/init.d` 可操作如下命令：

```bash
Usage: service zealot {start|stop|restart|reload|status}
```

#### 定时任务

脚本位于 `config/schedule.rb`

## 最佳实践

本系统配合 zealot-cli 及 fastlane 插件 zealot 服用为佳。
