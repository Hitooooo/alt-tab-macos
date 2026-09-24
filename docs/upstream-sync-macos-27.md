# 上游同步与 macOS 27 适配清单

更新日期：2026-09-23

## 当前基线

- CmdTab 当前提交：`135a22b5`，分叉点：上游 `45cd4c11`（AltTab 11.3.1）。
- 上游最新稳定版：`v11.7.1` / `56891e08`。
- 分叉后 CmdTab 有 7 个自定义提交，上游有 141 个新提交。
- 两边改动重叠 118 个路径；上游整体差异为 354 个文件、约 37,308 行新增和 6,499 行删除。
- CmdTab 的核心定制是改名/包标识、移除 Pro、移除窗口预览和自有发布流程。这些定制与上游窗口跟踪、设置界面、偏好迁移和发布脚本有大量重叠，不适合直接无审查合并。

## 已完成的 macOS 27 / Xcode 27 编译适配

- 最低部署版本从 macOS 10.13 提升到 12.0；这是 Xcode 27 支持的最低目标，也与上游 11.7.0 一致。
- 将已弃用的 AppKit API 换成 macOS 12 可用 API：
  - `NSAppearance.current` → `currentDrawing()` / `performAsCurrentDrawingAppearance`；
  - `allowedFileTypes`、旧 UTI 常量 → `UniformTypeIdentifiers`；
  - 旧 `NSWorkspace` 启动/打开 API → completion-handler API；
  - `NSStatusItem.popUpMenu` → 临时绑定菜单并触发按钮；
  - 旧归档、重绘、表格 source-list API → 当前 API。
- 修复 Swift 6.4 编译器对嵌套闭包隐式强捕获与显式弱捕获不一致的报错。
- 移植上游 macOS 27 Liquid Glass 圆角修复：同时设置 `NSGlassEffectView.cornerRadius` 与承载 layer 的连续圆角。
- 适配 macOS 27 上 `UserDefaults.persistentDomain` 删除后可能返回空字典而非 `nil` 的测试行为。
- 验证结果：无签名 Debug 构建成功；391 项测试全部通过。

## 上游 11.4–11.7.1 的重点变化

### 必须同步

- 窗口跟踪在 11.6 前后改为以 WindowServer 事件和单一状态所有者为核心，修复窗口遗漏、幽灵窗口、标签页重复/错误分组、唤醒后状态错误和无响应应用拖慢切换器等问题。
- macOS 27 上 Dock 不再发送原有的 Mission Control Accessibility 通知。上游 11.7.0 改为观察 `WindowManager` overlay，修复 Mission Control 期间窗口列表和聚焦错误（`69dbf4b3`）。这项修复依赖新的 WindowServer 事件架构，不能安全地只 cherry-pick 到当前旧架构。
- 11.7.1 修复窗口事件风暴造成的 CPU/内存持续增长（`4c49801f`），并进一步降低窗口快速变化时的开销。
- 多项崩溃修复：应用首个窗口打开、退出/注销、显示器重配置、快速切换/关闭窗口、触控板手势。

### 应同步但需保留 CmdTab 定制

- 设置窗口内存释放、搜索/快捷键编辑、RTL 布局、导入导出和 UI 细节修复。
- 窗口排序、跨 Space 聚焦、全屏退出、睡眠唤醒、快速 Alt-Tab 选择稳定性修复。
- 构建、测试、QA 状态输出和 CI 可靠性改进。
- 最低系统版本 macOS 12，以及随之而来的旧兼容分支清理。

### 不应直接带回

- Pro、试用、许可证、升级提示和相关 Keychain 逻辑。
- 窗口预览、截图后台捕获及其权限 UI（除非重新决定恢复该功能）。
- AltTab 的产品名、bundle ID、Developer ID / TeamID、Sparkle feed 和官方发布凭据。
- 与 CmdTab 自有 GitHub Actions 发布流程冲突的上游发布脚本。

## 推荐同步方式

1. 以 `v11.7.1` 建立独立集成分支，不直接在当前 `master` 做大 merge。
2. 先保留上游窗口跟踪和 macOS 27 修复的完整架构，跑上游测试作为干净基线。
3. 按独立提交重新应用 CmdTab 定制：
   1. 产品名、工程名、bundle ID 与签名配置；
   2. 移除 Pro / 许可证；
   3. 移除窗口预览与截图权限；
   4. 设置窗口去除对应选项；
   5. 自有 CI、README 和发布流程。
4. 每个定制提交后运行 `scripts/run_tests.sh`，最后按 `ai/build.sh` 的命令完成 Debug 和 Release 构建。
5. 保持 Developer ID、TeamID、bundle ID 和 Keychain 访问组不变；若必须调整，先实现许可证/Keychain 迁移方案。

## macOS 27 手工回归矩阵

- 基本切换：快速按键、长按循环、搜索、鼠标/触控板、拖放文件到应用。
- 窗口生命周期：首个窗口、最后一个窗口关闭、标签合并/拆分、最小化、全屏进入/退出、应用隐藏/退出。
- Spaces：跨 Space 聚焦、可见 Space 过滤、多显示器、Mission Control、App Exposé、Show Desktop、Stage Manager。
- 睡眠与显示器：睡眠唤醒、锁屏解锁、显示器拔插、分辨率/缩放变化。
- 权限：首次启动、辅助功能权限撤销/恢复；CmdTab 当前无预览时不应要求屏幕录制权限。
- 性能：长时间空闲后首次唤起、窗口快速创建/销毁、Activity Monitor 中 CPU 和内存是否持续增长。
- UI：Liquid Glass 圆角、深浅色切换、菜单栏左右键、设置窗口反复打开关闭。

## 尚待确认的上游问题

- 上游仍有 macOS 27 下“有窗口的应用被视为 windowless、绕过 Visible Spaces 过滤”的待发布问题（GitHub #6054）。同步 `v11.7.1` 后仍需单独复测并跟踪下一版本。
- ShortcutRecorder 依赖在 Xcode 27 下仍产生较多 Objective-C 弃用警告；当前不会阻断 CmdTab，但应在上游同步后评估升级依赖，避免未来 SDK 将警告提升为错误。

## 参考

- [AltTab releases](https://github.com/lwouis/alt-tab-macos/releases)
- [AltTab macOS 27 issues](https://github.com/lwouis/alt-tab-macos/issues?q=is%3Aissue%20macOS%2027)
- [Apple macOS 27 release notes](https://developer.apple.com/documentation/macos-release-notes/macos-27-release-notes)
