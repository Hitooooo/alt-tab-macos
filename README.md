# CmdTab

CmdTab 是一个轻量的 macOS 窗口切换工具，基于 [AltTab](https://github.com/lwouis/alt-tab-macos) 精简而来。它保留键盘驱动的窗口切换体验，去掉了 Pro 功能、授权系统、窗口预览、遥测和自动更新服务，目标是更简单、更快、更少常驻负担。

## 适合谁

- 想用 `Command + Tab` 风格快速切换窗口，而不是只切换 App
- 想要一个尽量轻的小工具
- 不需要内置购买、授权、遥测、自动更新等完整商业分发能力
- 愿意接受未公证构建带来的首次打开提示

## 下载构建

本仓库通过 GitHub Actions 自动生成可下载的 app 包。每次 push 到 `master`，或手动运行 `Build App` workflow，都会产出一个 artifact：

```text
CmdTab-unsigned.zip
```

下载路径：

1. 打开 GitHub 仓库的 `Actions` 页面
2. 选择最新的 `Build App` run
3. 在 `Artifacts` 里下载 `CmdTab-unsigned`
4. 解压后把 `CmdTab.app` 放到 `/Applications`

## 没有 Apple Developer 账号时的说明

这个项目目前不依赖付费 Apple Developer 账号。GitHub Actions 里的构建使用 ad-hoc signing：

```text
CODE_SIGN_IDENTITY=-
```

这意味着 app 可以被构建和下载，但不会经过 Apple notarization。首次打开时，macOS 可能提示无法验证开发者。

如果你信任自己仓库构建出来的包，可以这样打开：

1. 右键点击 `CmdTab.app`
2. 选择 `Open`
3. 如果仍被拦截，进入 `System Settings > Privacy & Security`
4. 点击 `Open Anyway`

这是没有开发者账号时的正常限制。要做到双击即开、无 Gatekeeper 提示，需要 Apple Developer 账号和 notarization。

## 本地开发构建

项目使用 Swift 5.8 和 AppKit，不使用 Interface Builder 或 SwiftUI。

首次本地构建前，先生成并导入本地自签名证书：

```sh
scripts/codesign/setup_local.sh
```

然后按仓库的 AI 工作流脚本构建 Debug 版本：

```sh
./ai/build.sh
```

构建产物在：

```text
DerivedData/Build/Products/Debug/CmdTab.app
```

Release 构建可以直接使用 GitHub Actions，也可以本地运行：

```sh
xcodebuild \
  -project cmdtab-macos.xcodeproj \
  -scheme Release \
  -configuration Release \
  -derivedDataPath DerivedData \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM= \
  OTHER_CODE_SIGN_FLAGS=--timestamp=none
```

## 自动构建

自动构建配置位于：

```text
.github/workflows/build-app.yml
```

它会：

- 拉取仓库代码
- 构建 Release 版本
- 使用 ad-hoc signing
- 打包 `CmdTab.app`
- 上传 `CmdTab-unsigned.zip` artifact

## 许可证与致谢

CmdTab 继续使用 GPL-3.0 许可证，详见 [LICENCE.md](LICENCE.md)。

本项目基于 AltTab 修改而来。上游项目和贡献者的版权、历史和致谢仍保留在仓库记录与相关文档中。
