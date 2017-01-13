# 穷游移动内部分发系统

基于 Rails 平台开发类似于 Testeflightapp、FIR、蒲公英等功能，除此之外还是三火的实验田。

## 安装依赖

- Linux
- Ruby 2.2+
- Rails 5.0+
- Mysql 5.3+/Mariadb 10.0+
- Redis 2.7+
- Sidekiq
- ImageMagick/GraphicsMagick

## 部署

部署脚本位于 `config/deploy.rb`

```
cap production deploy
```

## 定时任务

脚本位于 `config/schedule.rb`

## 最佳实践

本系统配合 qyer-mobile-app 及 fastlane-plugin-upload_to_qmobile 服用为佳。
