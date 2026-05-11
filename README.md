# 📋 CtrlC_CtrlV

> 一个轻量的 macOS 菜单栏剪贴板历史管理工具，自动记录最近 10 条复制内容，随时取用。

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue?style=flat-square&logo=apple)
![Language](https://img.shields.io/badge/language-Swift%205.9-orange?style=flat-square&logo=swift)
![UI](https://img.shields.io/badge/UI-SwiftUI-purple?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## ✨ 功能特性

- 🔍 **自动监听** — 实时检测系统剪贴板变化，复制即记录，无需手动操作
- 📝 **历史记录** — 保留最近 10 条复制/剪切内容，重启后依然保留
- ⚡ **快速粘贴** — 点击「复制」按钮将内容写回剪贴板，直接 ⌘V 粘贴；支持双击快速复制
- 🗂 **记录管理** — 可单独删除某条记录，或一键清除全部历史
- 🖥 **菜单栏常驻** — 不占用 Dock 空间，点击菜单栏图标随时呼出
- 💾 **持久化存储** — 基于 `UserDefaults`，数据跨会话保留

---

## 📸 界面预览

```
┌─────────────────────────────────────┐
│ 📋 剪贴板历史                  3/10 │
├─────────────────────────────────────┤
│ 1  https://github.com/...      复制 │
│ 2  这是一段复制的文字内容...   复制 │
│ 3  print("Hello, World!")      复制 │
│                                     │
│           暂无更多记录              │
├─────────────────────────────────────┤
│ 🗑 清除全部                    退出 │
└─────────────────────────────────────┘
```

---

## 🛠 技术栈

| 技术 | 用途 |
|------|------|
| SwiftUI | 界面构建 |
| AppKit (`NSStatusBar`) | 菜单栏图标与 Popover |
| `NSPasteboard` | 剪贴板读写 |
| Combine (`@Published`) | 数据响应式更新 |
| `UserDefaults` | 历史记录持久化 |

---

## 🚀 构建与运行

### 环境要求

- macOS 13 Ventura 及以上
- Xcode 15+

### 步骤

```bash
# 1. 克隆仓库
git clone https://github.com/yourname/CtrlC_CtrlV.git
cd CtrlC_CtrlV

# 2. 用 Xcode 打开
open CtrlC_CtrlV.xcodeproj

# 3. 选择 My Mac 为目标，点击 ▶ 运行
```

运行后，菜单栏右上角会出现 **📋** 图标，点击即可使用。

---

## 📁 项目结构

```
CtrlC_CtrlV/
├── ClipboardManagerApp.swift   # App 入口
├── AppDelegate.swift           # 菜单栏图标 + Popover 管理
├── ClipboardMonitor.swift      # 定时轮询 NSPasteboard（0.8s）
├── ClipboardStore.swift        # 数据模型、去重、持久化
└── ContentView.swift           # SwiftUI 主界面
```

---

## ⚙️ 自定义配置

| 配置项 | 文件 | 默认值 |
|--------|------|--------|
| 最多保存条数 | `ClipboardStore.swift` → `maxItems` | `10` |
| 轮询间隔 | `ClipboardMonitor.swift` → `withTimeInterval` | `0.8` 秒 |
| 弹出窗口大小 | `AppDelegate.swift` → `contentSize` | `380 × 520` |

---

## 🔒 隐私说明

- 本应用**完全本地运行**，不联网，不上传任何数据
- 剪贴板内容仅存储在本机 `UserDefaults` 中
- 不读取密码管理器等受沙盒保护的内容

---

## 📄 License

[MIT License](LICENSE) © 2025 yourname
