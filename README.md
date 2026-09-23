# CmdTab

CmdTab 是一款 macOS 窗口切换工具，基于 [AltTab](https://github.com/lwouis/alt-tab-macos) 开发。此分支将上游更新移植到 CmdTab，并保留 CmdTab 的应用身份：`com.hitomeng.cmdtab`。

## macOS 兼容性

- 最低支持 macOS 12。
- 使用 GitHub Actions 的 `xcode-27` runner 构建，以便在 macOS 27 上验证。
- 窗口跟踪使用上游新版 WindowServer 事件架构，包含 macOS 27 相关适配。

## 下载测试构建

GitHub Actions 会生成 `CmdTab-unsigned.zip`，并上传为 workflow artifact。构建为 ad-hoc 签名，未经过 Apple notarization；首次打开时 macOS 可能需要在“系统设置 > 隐私与安全性”中手动允许。

## 本地构建

项目使用 Swift 5.8 和 AppKit，不使用 Interface Builder 或 SwiftUI。先运行 `scripts/codesign/setup_local.sh` 创建本地自签名证书，再执行：

```sh
./ai/build.sh
```

运行测试：

```sh
./ai/test.sh
```

## 致谢与许可证

CmdTab 基于 GPL-3.0 许可发布，详见 [LICENCE.md](LICENCE.md)。窗口切换核心及其上游贡献者归属 AltTab 项目，历史记录保留相关来源。
