# API 接口

Zealot 提供提供 REST APIs 接口服务可用于自定义的查看 App 信息或者上传、下载 App。

## 接口认证

接口请求目前仅支持 User Token 的 query 认证，在登录用户的详情页面最下面 `API - 密钥` 找到。

## 接口版本

当前是 `v1` 版本，接口无需显性传递版本参数，另外 GraphGL 接口也在逐步开发中后续会考虑两个版本同时存在。

## 接口列表

### 应用列表

获取创建的应用列表，支持分页

```
GET /api/apps
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| page | `Integer` | false | 页数|
| per_page | `Integer` | false | 每页返回最大数目 |

#### 返回样例

> TODO

### 应用详情

查看应用的明细：应用类型、渠道等信息

```
GET /api/apps/{:id}
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| id | `String` | true | 应用 ID |

#### 返回样例

> TODO

### 应用版本列表

获取应用已上传的版本列表，按照上传时间倒序排列

```
GET /api/apps/versions
```

#### 参数

!> 需要用户认证。

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| channel_key | `String` | true | 应用具体渠道的 Key |
| page | `Integer` | false | 页数|
| per_page | `Integer` | false | 每页返回最大数目 |

#### 返回样例

> TODO

### 应用最新版本

获取指定应用的最新版本信息

```
GET /api/apps/latest
```

#### 参数

!> 需要用户认证。

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| channel_key | `String` | true | 应用具体渠道的 Key |
| release_version | `String` | true | 应用的发布版本 |
| build_version | `String` | true | 应用的构建版本 |

#### 返回样例

> TODO

### 上传应用

上传应用，仅支持 iOS 和 Android 类型。

```
GET /api/apps/uploads
```

#### 参数

!> 需要用户认证。

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| channel_key | `String` | true | 应用具体渠道的 Key |
| file | `File` | true | 应用本地路径的内容 |
| name | `String` | false | 应用名称，为空时取 App 的信息 |
| release_type | `String` | false | 应用类型，比如 debug, beta, adhoc, release, enterprise 等 |
| source | `String` | false | 上传渠道名称，默认是 api |
| changelog | `String` | false | 变更日志 |
| git_commit | `String` | false | 上传应用时的 git commit hash |
| ci_url | `String` | false | CI 项目构建地址 |

#### 返回样例

> TODO