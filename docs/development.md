# 开发指南

**技术栈:**

- Ruby on Rails 驱动 Web 和 API 服务
- Sidekiq 提供异步后台任务管理

**环境依赖:**

- Ruby 2.4+
- Postgres 9.5+
- Redis
- Nodejs 8+
- ImageMagick/GraphicsMagick

### 本地安装

#### 源码

安装完成上面的依赖后，克隆本项目配置 config/database.yml 数据库信息可从 ENV 环境变量获取，之后顺序执行：

```
$ git clone git@github.com:getzealot/zealot.git
$ cd zealot
$ bundle install
$ bundle exec guard start
```

打开浏览器 `http://localhost:3000`