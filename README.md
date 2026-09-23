# CmdTab

CmdTab 是一款键盘驱动的 macOS 窗口切换工具，基于 [AltTab](https://github.com/lwouis/alt-tab-macos) 开发。目前同步到上游 **11.7.1**，并保留 CmdTab 现有应用身份 `com.hitomeng.cmdtab`，以便更新覆盖同一应用并继续使用现有用户数据。

## macOS 支持

- 最低支持 macOS 12。
- GitHub Actions 使用 `xcode-27` 预览 runner，在 macOS 27 SDK 下构建和打包。
- 上游更新包含 macOS 27 下切换器圆角和 Mission Control 窗口检测修复，也带来窗口跟踪、长时间运行时 CPU 和内存增长等方面的修复。

## 下载测试版

打开 [GitHub Actions 的 Build App 页面](https://github.com/Hitooooo/alt-tab-macos/actions/workflows/build-app.yml)，选择成功的运行记录，在 **Artifacts** 区域下载 `CmdTab-unsigned`。推送到 `master` 会触发构建；也可以手动运行工作流并选择其他分支。

产物使用 ad-hoc 签名，未经 Apple 公证。首次打开时 macOS 可能会阻止启动；确认信任该构建后，可在“系统设置 > 隐私与安全性”中允许打开。

## 本地构建

项目使用 Swift 5.8 和 AppKit，不使用 Interface Builder 或 SwiftUI。首次构建先创建本地签名证书，再执行构建或测试脚本：

```sh
scripts/codesign/setup_local.sh
./ai/build.sh
./ai/test.sh
```

Debug 应用位于 `DerivedData/Build/Products/Debug/CmdTab.app`。

## 参与开发

源码按功能组织在 `src/`。适合单元测试的功能尽量维护实现、`*Specs.md` 和 `*Tests.swift` 三者同步。更多项目结构和开发说明见[贡献者指南](docs/contributing.md)。

## 许可证与致谢

CmdTab 以 GPL-3.0 许可证发布，详见 [LICENCE.md](LICENCE.md)。窗口切换核心基于 AltTab；上游项目及贡献者的归属和历史记录均予保留。
