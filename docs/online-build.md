# 在线编译（GitHub Actions）

本目录内置一套不依赖本机 DevEco Studio 的编译流程：

| 文件 | 作用 |
| --- | --- |
| `.github/workflows/build-hap.yml` | GitHub Actions 工作流：下载 Command Line Tools、配置 SDK、编译并上传 HAP |
| `scripts/ci/build-hap.sh` | 实际执行 `ohpm` / `hvigorw` 的构建脚本，也可在本地 CI 容器中复用 |
| `scripts/ci/strip-signing.py` | 清掉 `build-profile.json5` 里 DevEco 自动签名写入的本机绝对路径 |

## 快速开始

1. 把工程推送到 GitHub。
2. 打开仓库的 **Actions** → **Build HarmonyOS HAP** → **Run workflow**。
3. 选择 `debug` 或 `release`，点击运行。
4. 构建完成后，在该次运行的 **Artifacts** 中下载 `WeiboPura-<mode>-default-hap`。

首次运行需要下载约 2.3 GB 的 HarmonyOS Command Line Tools，通常 10–20 分钟；之后会命中 Actions 缓存。构建本身一般 2–5 分钟。

推送形如 `v1.0.0` 的 tag 也会自动触发一次 debug 构建。

## 产物是 unsigned HAP

工作流默认清除本机签名配置，因此产物是 `entry-default-unsigned.hap`，**不能直接安装到 HarmonyOS 设备**。需要签名时二选一：

### 方式一：DevEco Studio 自动签名（推荐）

1. 用 DevEco Studio 打开工程。
2. `File` → `Project Structure` → `Signing Configs`，登录华为账号后勾选自动签名。
3. 连接设备，执行 `Build` → `Build Hap(s)/APP(s)`，DevEco 会生成可安装的签名包。

> 自动签名会再次改写 `build-profile.json5`。提交前可执行
> `git checkout -- build-profile.json5`，或运行
> `python3 scripts/ci/strip-signing.py build-profile.json5` 清掉本机路径。

### 方式二：用 hap-sign-tool.jar 手动签名

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

### 可选：在 Actions 中自动签名

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

配置后工作流会用 `hap-sign-tool.jar` 对 unsigned HAP 签名，并优先上传
`entry-default-signed.hap`。签名材料属于敏感信息，请只放在 Secrets 中，不要提交到仓库。

## 工具链来源

工作流固定使用：

- HarmonyOS Command Line Tools `26.0.0.461`（Linux x64）
- JDK 17（Temurin）
- `hvigor` / `ohpm` 由 Command Line Tools 自带

Command Line Tools 来自第三方镜像
[`jerry-271828/harmonyos-commandline-tools`](https://github.com/jerry-271828/harmonyos-commandline-tools)
的 `v26.0.0.461` Release。由于 GitHub Release 单文件限制为 2 GiB，上游把 zip 拆成
`clt.zip.part00` 与 `clt.zip.part01`；工作流拼接后校验固定 SHA-256：

```text
b046da0a1a06fe13b3d82d198738abc54788d79c6c9d07c36617ec7fc31a3b3b
```

如果要从官方渠道或自己的镜像获取，修改 `.github/workflows/build-hap.yml` 中的
`CLT_VERSION`、两个下载 URL 和 `CLT_SHA256` 即可。

## 构建流程说明

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

## 本地复用

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

## 常见问题

**`hvigorw: command not found`**

解压后的目录层级可能不是 `command-line-tools/bin/hvigorw`。查看工作流
“Extract and configure SDK” 步骤输出的 `CLT_HOME` / `BIN_DIR`，确认 `bin` 已加入 `PATH`。

**提示找不到 HarmonyOS SDK**

确认 `DEVECO_SDK_HOME` 指向包含 `default/openharmony` 的 `sdk` 目录。工作流会自动设置；
本地运行时需要手动设置。

**Linux 大小写敏感导致编译失败**

工程已在 `build-profile.json5` 中开启 `caseSensitiveCheck: true`。如果仍报文件名大小写错误，
按错误信息修正 import / 资源文件名即可。

**缓存损坏或想强制重新下载**

删除 GitHub Actions 缓存，或把工作流里的缓存 key 从
`harmonyos-clt-26.0.0.461-linux-x64-v1` 改成 `...-v2`。

**构建超时**

默认 `timeout-minutes: 90`。首次下载较慢时可适当调大；后续命中缓存通常只需几分钟。
