# Weibo

> 一款面向 HarmonyOS 的原生 ArkTS / ArkUI 微博浏览客户端原型。

Weibo 将微博内容浏览能力接入原生 ArkUI 界面：以卡片化信息流、沉浸式浮动底栏和深色主题呈现推荐、关注、热搜、搜索及帖子详情。工程面向手机和平板，目标平台为 HarmonyOS 7 / API 26。

> 本项目为个人技术验证，与微博及其关联方无关；微博商标、内容、接口和服务规则均归其权利人所有。

---

## 目录

- [界面预览](#界面预览)
- [功能一览](#功能一览)
- [使用说明](#使用说明)
- [数据、隐私与使用边界](#数据隐私与使用边界)
- [技术栈](#技术栈)
- [工程结构](#工程结构)
- [环境要求](#环境要求)
- [构建与运行](#构建与运行)
- [在线编译（GitHub Actions）](#在线编译github-actions)
- [权限说明](#权限说明)
- [常见问题](#常见问题)
- [许可证](#许可证)

---

## 界面预览

<p align="center">
  <img src="docs/images/01-home-feed.jpg" alt="首页推荐信息流：图片九宫格与浮动底部导航" width="19%" />
  <img src="docs/images/02-hot-search.jpg" alt="发现页微博热搜榜" width="19%" />
  <img src="docs/images/03-search-results.jpg" alt="微博搜索结果页" width="19%" />
  <img src="docs/images/04-post-detail.jpg" alt="微博详情与评论区" width="19%" />
  <img src="docs/images/05-system-share.jpg" alt="调用系统分享面板" width="19%" />
</p>

| 界面 | 展示内容 |
| --- | --- |
| 首页 | 推荐 / 关注双入口、图文与视频卡片、瀑布流布局、搜索快捷入口。 |
| 发现 | 无需登录即可读取的公开热搜榜。 |
| 搜索 | 关键词搜索、联想建议和结果流。 |
| 详情 | 原帖、视频播放、评论浏览，以及用户明确触发的点赞和评论。 |
| 分享 | 通过 HarmonyOS 系统分享能力交接内容，不在应用内代发。 |

---

## 功能一览

- **原生信息流**：首页提供“推荐”和“关注”两种时间线；支持继续加载，并以骨架屏反馈加载状态。
- **内容浏览**：支持用户主页、原帖详情、评论、图片预览及视频内容展示。
- **热搜与搜索**：可读取公开热榜，支持关键词联想与微博内容搜索。
- **账户入口**：在内嵌的官方登录页面完成登录后，应用读取该登录态用于需要账户权限的功能。
- **互动由用户掌控**：点赞、取消点赞、评论和分享均须由用户在对应界面明确操作；不会后台自动点赞、评论、转发或批量执行操作。
- **系统化体验**：支持深浅色主题、沉浸式安全区、圆角玻璃质感底栏、横竖屏与手机 / 平板布局。

---

## 使用说明

1. 首次启动时阅读数据使用说明并确认；确认前应用不会初始化微博凭据或发起微博请求。
2. 在“首页”浏览推荐动态；“关注”时间线通常需要先完成微博登录。
3. 在“发现”查看实时公开热搜，或在“搜索”输入关键词查找内容。
4. 点开卡片进入详情页，可阅读评论、浏览图片和播放视频。需要点赞或发表评论时，请在详情页自行点击操作。
5. 如需使用关注流或账户相关能力，前往“我的”并打开“登录微博”，在可见的内嵌登录页完成登录；登录态检测成功后返回应用即可使用。

---

## 数据、隐私与使用边界

WeiboPura 的目标是轻量浏览，而不是自动化运营工具。请在使用前了解以下边界：

- 公开内容在未登录状态下可尝试访问；微博侧可能因风控、验证码、网络或接口变更而限制访问。
- 登录由用户在可见的微博登录页面自行完成。应用仅在检测到有效登录态后，将所需会话信息保存到本机应用存储；除向微博服务发起授权请求外，不会向本项目控制的第三方上传或共享 `SUB`、`XSRF-TOKEN`、App Key 等账号凭据。
- 访客访问使用隔离的内存会话，并采用固定节流；应用不自动登录、不绕过验证码、不规避频率限制。
- 每一次写操作均由当前页面的用户动作触发。应用不提供自动化、定时或批量的点赞、评论、转发功能。
- 微博移动端接口并非本项目可控制的稳定第三方 API，返回字段、访问策略和可用性都可能变化。遇到加载失败时，请稍后重试，并以微博官方客户端的服务规则为准。

实现细节和请求边界见 [docs/weibo-readonly-adapter.md](docs/weibo-readonly-adapter.md)，隐私说明见 [docs/PRIVACY.md](docs/PRIVACY.md)。

---

## 技术栈

| 项目 | 说明 |
| --- | --- |
| 语言与 UI | ArkTS、ArkUI 声明式 UI |
| 平台 | HarmonyOS；工程 `targetSdkVersion` 为 `26.0.0`，`compatibleSdkVersion` 为 `6.1.0(23)` |
| 构建 | Hvigor / OHPM，通过 DevEco Studio 或 `devecocli` 调用 |
| 设备形态 | `phone`、`tablet`；随窗口宽度切换堆叠或分栏导航 |
| 网络与会话 | 独立微博 HTTP 层、用户本地登录态、内存访客会话与请求节流 |

---

## 工程结构

```text
.
├── .github/workflows/                 # GitHub Actions 自动化构建配置
│   └── build-hap.yml                  # 在线构建工作流
├── scripts/ci/                        # CI 构建辅助脚本
│   ├── build-hap.sh                   # CI 构建核心脚本
│   └── strip-signing.py               # 签名配置清理脚本
├── AppScope/                         # 应用元信息、图标与全局资源
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/          # 应用入口能力
│       │   ├── pages/                 # 首页、热搜、搜索、登录、详情和用户主页
│       │   ├── components/            # 公共卡片、骨架屏、访客会话引导等组件
│       │   ├── service/               # 微博服务、登录态、设置与本地状态
│       │   ├── network/               # 微博 HTTP 客户端与响应解析
│       │   ├── model/                 # 稳定的页面数据模型
│       │   ├── common/                # 主题、导航、分享和交互工具
│       │   └── cache/                 # 图片及本地缓存
│       └── resources/                 # 多语言、颜色、媒体和页面路由资源
├── docs/
│   ├── images/                        # README 使用的实机截图
│   └── weibo-readonly-adapter.md      # 微博数据层与边界说明
├── build-profile.json5                # 产品、SDK 和签名构建配置
└── hvigorfile.ts                      # Hvigor 构建入口
```

---

## 环境要求

- 已安装带 HarmonyOS SDK 的 DevEco Studio；SDK 需覆盖工程配置的兼容 SDK `6.1.0(23)` 和目标 API `26.0.0`。
- Node.js / OHPM / Hvigor 由 DevEco Studio 配套环境提供。
- 连接 HarmonyOS 真机，或准备可用的模拟器；设备需要联网以读取在线内容。

---

## 构建与运行

### 使用 DevEco Studio

1. 用 DevEco Studio 打开本仓库根目录 `D:\WeiboPura`。
2. 等待 OHPM 依赖同步完成，并确认选择了与工程版本匹配的 HarmonyOS SDK。
3. 在产品配置中选择 `default` 和 `debug`，然后执行 Build；连接设备后运行 `entry` 模块。

### 使用命令行

在仓库根目录执行：

```powershell
# 编译并生成 debug HAP
devecocli build

# 查看已连接的真机或正在运行的模拟器
devecocli device list

# 安装并启动（将 <device-serial> 换成上一步列出的设备标识）
devecocli run --module entry --device <device-serial>
```

如设备上安装过使用不同签名的同包名应用，可在最后一条命令中附加 `--uninstall` 后重新安装。构建产物位于 `entry/build/default/outputs/default/` 下。

---

## 在线编译（GitHub Actions）

本工程内置一套不依赖本机 DevEco Studio 的在线编译流程：

| 文件 | 作用 |
| --- | --- |
| `.github/workflows/build-hap.yml` | GitHub Actions 工作流：下载 Command Line Tools、配置 SDK、编译并上传 HAP |
| `scripts/ci/build-hap.sh` | 实际执行 `ohpm` / `hvigorw` 的构建脚本，也可在本地 CI 容器中复用 |
| `scripts/ci/strip-signing.py` | 清掉 `build-profile.json5` 里 DevEco 自动签名写入的本机绝对路径 |

### 快速开始

1. 把工程推送到 GitHub。
2. 打开仓库的 **Actions** → **Build HarmonyOS HAP** → **Run workflow**。
3. 选择 `debug` 或 `release`，点击运行。
4. 构建完成后，在该次运行的 **Artifacts** 中下载 `WeiboPura-<mode>-default-hap`。

首次运行需要下载约 2.3 GB 的 HarmonyOS Command Line Tools，通常 10–20 分钟；之后会命中 Actions 缓存。构建本身一般 2–5 分钟。推送形如 `v1.0.0` 的 tag 也会自动触发一次 debug 构建。

### 产物是 unsigned HAP

工作流默认清除本机签名配置，因此产物是 `entry-default-unsigned.hap`，**不能直接安装到 HarmonyOS 设备**。需要签名时二选一：

#### 方式一：DevEco Studio 自动签名（推荐）

1. 用 DevEco Studio 打开工程。
2. `File` → `Project Structure` → `Signing Configs`，登录华为账号后勾选自动签名。
3. 连接设备，执行 `Build` → `Build Hap(s)/APP(s)`，DevEco 会生成可安装的签名包。

> 自动签名会再次改写 `build-profile.json5`。提交前可执行
> `git checkout -- build-profile.json5`，或运行
> `python3 scripts/ci/strip-signing.py build-profile.json5` 清掉本机路径。

#### 方式二：用 hap-sign-tool.jar 手动签名

`hap-sign-tool.jar` 位于 Command Line Tools 的
`sdk/default/openharmony/toolchains/lib/` 下。准备好自己的 `.p12`、`.cer`、`.p7b` 后：

```bash
java -jar hap-sign-tool.jar sign-app \
  -keyAlias "debugKey" \
  -signAlg SHA256withECDSA \
  -mode localSign \
  -appCertFile app.cer \
  -profileFile app.p7b \
  -inFile entry-default-unsigned.hap \
  -keystoreFile keystore.p12 \
  -outFile entry-default-signed.hap \
  -keyPwd "<key password>" \
  -keystorePwd "<store password>"
```

#### 可选：在 Actions 中自动签名

如果不想每次下载后再签，可以把签名材料放进仓库 Secrets：

| Secret | 内容 |
| --- | --- |
| `HAP_SIGN_P12` | `.p12` 密钥库的 Base64 |
| `HAP_SIGN_CER` | `.cer` 证书链的 Base64 |
| `HAP_SIGN_P7B` | `.p7b` Profile 的 Base64 |
| `HAP_SIGN_STORE_PASSWORD` | 密钥库口令 |
| `HAP_SIGN_KEY_PASSWORD` | 密钥口令 |

可选 Repository variable：

| Variable | 默认值 | 说明 |
| --- | --- | --- |
| `HAP_SIGN_KEY_ALIAS` | `debugKey` | 密钥别名 |

生成 Base64（Linux/macOS）：

```bash
openssl base64 -A -in keystore.p12 -out keystore.p12.b64
openssl base64 -A -in app.cer -out app.cer.b64
openssl base64 -A -in app.p7b -out app.p7b.b64
```

Windows PowerShell：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("keystore.p12")) | Set-Content keystore.p12.b64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("app.cer")) | Set-Content app.cer.b64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("app.p7b")) | Set-Content app.p7b.b64
```

配置后工作流会用 `hap-sign-tool.jar` 对 unsigned HAP 签名，并优先上传 `entry-default-signed.hap`。签名材料属于敏感信息，请只放在 Secrets 中，不要提交到仓库。

### 工具链来源

工作流固定使用：

- HarmonyOS Command Line Tools `26.0.0.461`（Linux x64）
- JDK 17（Temurin）
- `hvigor` / `ohpm` 由 Command Line Tools 自带

Command Line Tools 来自第三方镜像
[`jerry-271828/harmonyos-commandline-tools`](https://github.com/jerry-271828/harmonyos-commandline-tools)
的 `v26.0.0.461` Release。由于 GitHub Release 单文件限制为 2 GiB，上游把 zip 拆成 `clt.zip.part00` 与 `clt.zip.part01`；工作流拼接后校验固定 SHA-256：

```text
b046da0a1a06fe13b3d82d198738abc54788d79c6c9d07c36617ec7fc31a3b3b
```

如果要从官方渠道或自己的镜像获取，修改 `.github/workflows/build-hap.yml` 中的
`CLT_VERSION`、两个下载 URL 和 `CLT_SHA256` 即可。

### 构建流程说明

`.github/workflows/build-hap.yml` 依次执行：

1. `actions/checkout` + `actions/setup-java`（JDK 17）。
2. 恢复/下载并校验 Command Line Tools。
3. 解压后把 `bin`、`node/bin`、`ohpm/bin` 加入 `PATH`，设置
   `DEVECO_SDK_HOME`、`OHOS_SDK_HOME` / `HOS_SDK_HOME`。
4. `scripts/ci/strip-signing.py` 清空 `signingConfigs` 和产品的 `signingConfig`。
5. `ohpm install --all`。
6. `hvigorw clean --no-daemon`。
7. `hvigorw assembleHap --mode module -p product=default -p buildMode=<mode> --no-daemon`。
8. 如配置签名 Secrets，则调用 `hap-sign-tool.jar`；随后只上传 signed 或 unsigned 中的一个 HAP。

### 本地复用 CI 脚本

如果本机已经有 Command Line Tools，可以直接运行：

```bash
export PATH="/path/to/command-line-tools/bin:/path/to/command-line-tools/node/bin:$PATH"
export DEVECO_SDK_HOME="/path/to/command-line-tools/sdk"
bash scripts/ci/build-hap.sh debug default
```

本地想保留自己的签名配置时：

```bash
STRIP_SIGNING=0 bash scripts/ci/build-hap.sh debug default
```

---

## 权限说明

工程声明的权限以 [`entry/src/main/module.json5`](entry/src/main/module.json5) 为准：

| 权限 | 用途 |
| --- | --- |
| `ohos.permission.INTERNET` | 读取微博内容、热搜和搜索结果。 |
| `ohos.permission.VIBRATE` | 为支持的交互提供触感反馈。 |
| `ohos.permission.DETECT_GESTURE` | 支持系统可用时的手势分享交互。 |
| `ohos.permission.KEEP_BACKGROUND_RUNNING` | 支持已声明的后台数据传输场景。 |

---

## 常见问题

**首页、热搜或搜索加载失败怎么办？**

请先检查网络，再稍后重试。微博侧可能返回限流、验证码或接口变化；本项目不会尝试绕过这些限制。

**为什么“关注”列表为空？**

该列表依赖当前登录账户。请在“我的”中完成微博登录，再返回首页刷新“关注”。

**Cookie 会被上传吗？**

登录态来自用户自行完成的内嵌登录，并保存在本机应用存储中；它只会随发往微博服务的授权请求使用，不会向本项目控制的第三方共享。

**能否自动点赞、评论或转发？**

不能。本项目只响应用户在当前页面明确发起的单次互动。

**`hvigorw: command not found` (CI 编译)**

解压后的目录层级可能不是 `command-line-tools/bin/hvigorw`。查看工作流“Extract and configure SDK”步骤输出的 `CLT_HOME` / `BIN_DIR`，确认 `bin` 已加入 `PATH`。

**提示找不到 HarmonyOS SDK (CI 编译)**

确认 `DEVECO_SDK_HOME` 指向包含 `default/openharmony` 的 `sdk` 目录。工作流会自动设置；本地运行时需要手动设置。

**Linux 大小写敏感导致编译失败**

工程已在 `build-profile.json5` 中开启 `caseSensitiveCheck: true`。如果仍报文件名大小写错误，按错误信息修正 import / 资源文件名即可。

**缓存损坏或想强制重新下载 (CI 编译)**

删除 GitHub Actions 缓存，或把工作流里的缓存 key 从 `harmonyos-clt-26.0.0.461-linux-x64-v1` 改成 `...-v2`。

**构建超时 (CI 编译)**

默认 `timeout-minutes: 90`。首次下载较慢时可适当调大；后续命中缓存通常只需几分钟。

---

## 许可证

本工程采用 [GPL-3.0](LICENSE) 许可证。
