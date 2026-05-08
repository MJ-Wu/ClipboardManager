# ClipboardManager — macOS 剪贴板历史管理工具

一个运行在菜单栏的 macOS 应用，自动保存最近 10 条复制/剪切记录，随时点击即可重新粘贴。

## 功能特性

- ✅ 自动监听系统剪贴板，实时记录最近 10 条复制内容
- ✅ 菜单栏图标，点击弹出历史面板
- ✅ 点击「复制」按钮将内容重新写入剪贴板，直接 ⌘V 粘贴
- ✅ 双击任意条目快速复制
- ✅ 可单独删除某条记录，或一键清除全部
- ✅ 记录持久化存储（重启后依然保留）
- ✅ 纯文本内容支持（文字、代码、链接等）

## 项目结构

```
ClipboardManager/
├── ClipboardManagerApp.swift   # App 入口 (@main)
├── AppDelegate.swift           # 菜单栏图标 + Popover 管理
├── ClipboardMonitor.swift      # 定时轮询 NSPasteboard
├── ClipboardStore.swift        # 数据模型 + 持久化
├── ContentView.swift           # SwiftUI 界面
├── Info.plist                  # App 配置（LSUIElement = true 隐藏 Dock 图标）
└── Package.swift               # Swift Package（可选）
```

## 如何构建运行（推荐：Xcode）

### 方法一：使用 Xcode（推荐）

1. 打开 Xcode → File → New → Project
2. 选择 **macOS → App**，语言选 **Swift**，界面选 **SwiftUI**
3. 删除 Xcode 自动生成的所有 `.swift` 文件
4. 将本项目的 5 个 `.swift` 文件拖入 Xcode 项目
5. 替换 `Info.plist`（或在 Target → Info 中添加 `LSUIElement = YES`）
6. 选择目标为 **My Mac** → 点击 ▶ 运行

### 方法二：命令行（Swift Package）

```bash
# 进入项目目录
cd ClipboardManager

# 运行
swift run

# 构建 Release
swift build -c release
```

> ⚠️ 注意：命令行方式运行时菜单栏 UI 需要在主线程环境，建议使用 Xcode 方式。

## 注意事项

- **隐私权限**：macOS 13+ 不需要额外权限即可读取通用剪贴板（NSPasteboard.general）
- 若要读取密码管理器等受保护内容，需在 Entitlements 中添加相应授权
- 应用以 **LSUIElement = true** 模式运行，不显示 Dock 图标，只在菜单栏显示

## 自定义

| 配置项 | 文件 | 修改方法 |
|--------|------|----------|
| 最多保存条数 | `ClipboardStore.swift` | 修改 `maxItems` |
| 轮询间隔 | `ClipboardMonitor.swift` | 修改 `withTimeInterval` |
| 窗口大小 | `AppDelegate.swift` | 修改 `contentSize` |

## 系统要求

- macOS 13 Ventura 及以上
- Xcode 15+（构建用）
