# 变更日志

## [未发布]

> 如下罗列的变更是还未发布的列表

### 新功能

- [Docker] 支持 Heroku 部署
- [Web] 游客模式允许查看 App 详情、列表和上传 App 详情
- [API] 上传 App 支持自定义字段 [#178](https://github.com/getzealot/zealot/issues/178)

### 修复

- [Web] 修正用户密码描述文案
- [Web] 修复网络钩子包含 url 字段的地址错误
- [Web/API] 修复上传 iOS dSYM 文件上传报错
- [API] 修复获取 App 接口 has_password 参数异常
- [API] 修复上传 App 记录的 source 来源都是 Web
- [API] 修复并支持上传 App 传递字符串类型的 json 格式的 changelog
- [Web] 修复系统信息没有正常获取 CPU 和内存信息

### 变更

- [Web] 开发环境移除 GraphQL 控制台功能，推荐使用 [graphql-playground](https://github.com/prisma-labs/graphql-playground)
- [Web] 页面底部移除 footbar，版本信息可以在系统信息查看

## [4.0.0.beta3] (2020-01-16)

### 新功能

- [Web] 管理员添加的用户在邮箱未激活会提示并显示确认邮箱的链接
- [Web] 默认开启 Sentry 匿名上报机制（可关闭）

### 修复

- [API] 修复上传应用总会创建新渠道
- [Web/API] 修复上传 Android 应用无法显示图标

### 变更

- [Docker] 初始化数据从镜像移出到 [zealot-docker](https://github.com/getzealot/zealot-docker) 操作 [#120](https://github.com/getzealot/zealot/pull/120)
- [Docker] 精简镜像的体积大小从 1.18G 降到 308M [#114](https://github.com/getzealot/zealot/issues/114)
- [Worker] 使用异步任务代替传统 cron job 来实现定时清理老版本历史包文件（可关闭）
- [Worker] 对异步任务进行分组和设置优先级
- [API] 所有报错信息改成中文显示，因数据库写操作会返回具体错误信息
- [Web] 使用 Rubocop Lint 规范化代码

## [4.0.0.beta2] (2020-01-10)

### 新功能

- [Web] 新增上传到具体应用渠道的全部版本列表同时支持删除操作

### 修复

- [Web] 对于上传应用不是有效 ipa 或 apk 的会给予错误提示而不是报错
- [API] 修复获取应用最新版本列表因查询版本号不存在数据库无法返回最新版本列表
- [API] 只针对写操作的接口才会要求 token 验证（之前是绝大部分都需要）

## 4.0.0.beta1

🌈 第一个公测版本发布啦

[未发布]: https://github.com/getzealot/zealot/compare/4.0.0.beta3...HEAD
[4.0.0.beta3]: https://github.com/getzealot/zealot/compare/4.0.0.beta2...4.0.0.beta3
[4.0.0.beta2]: https://github.com/getzealot/zealot/compare/4.0.0.beta1...4.0.0.beta2

